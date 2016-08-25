//
//  MasterViewController.m
//  BBCRadio4Schedule
//
//  Created by IG on 08/09/2015.
//  Copyright (c) 2015 Super Cool Start-up. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "BBCScheduleScrollerTableViewCell.h"

#import "DataManager.h"

@interface MasterViewController ()

/**
 *  Section tiutles and keys
 */
@property (nonatomic, strong) NSArray *sections;

/**
 *  Check if fetching is already in progress to avoid overlapping
 */
@property (atomic, assign) BOOL fetchingPrograms;

/**
 *  Timer to periodically refresh content
 */
@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation MasterViewController

NSString*       const ksectionKeyName           = @"sectionKey";
NSString*       const ksectionTitleName         = @"sectionTitle";
NSString*       const kdetailSegueIdentifier    = @"showDetail";

NSTimeInterval  const kProgramRefreshInterval   = 60.0; //Refresh programs in every n seconds
CGFloat         const kSectionHeaderHeight      = 20.0; //Header height

@synthesize sections = _sections;

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // ???: I wasn't sure what good is an edit button, so I just removed
    
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    [self fetchPrograms];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self startRefreshTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self stopRefreshTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:kdetailSegueIdentifier]) {
        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:sender];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BBCScheduleScrollerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bbcScheduleCellIdentifier forIndexPath:indexPath];

    NSDictionary *sectionData = self.sections[indexPath.section];
    
    cell.storyboard = self.storyboard;
    
    __weak typeof(self) weakSelf = self;
    [cell setupWithScheduleKey:sectionData[ksectionKeyName] programSelected:^(NSDictionary *program) {
        
        NSLog(@"selected program: %@", program);
        [weakSelf performSegueWithIdentifier:kdetailSegueIdentifier sender:program];
    }];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [(BBCScheduleScrollerTableViewCell*)cell willDisplayCellInController:self];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [(BBCScheduleScrollerTableViewCell*)cell didFinishDisplayingCell];
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDictionary *sectionData = self.sections[section];
    
    return sectionData[ksectionTitleName];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = tableView.bounds.size.height;
    height -= self.navigationController.navigationBar.frame.size.height;
    height -= [[UIApplication sharedApplication] statusBarFrame].size.height;
    height -= 3 * kSectionHeaderHeight;
    height -= 70;
    
    return height / 3;
}

#pragma mark - Data integration

- (NSArray*)sections {
    
    if (!_sections) {
        
        _sections = @[
             @{
                 ksectionKeyName:   todaysProgramsKeyName,
                 ksectionTitleName: NSLocalizedString(@"Today", @"Today's program section title")
                 },
             @{
                 ksectionKeyName:   tomorrowsProgramsKeyName,
                 ksectionTitleName: NSLocalizedString(@"Tomorrow", @"Tomorrow's program section title")
                 },
             @{
                 ksectionKeyName:   yesterdaysProgramsKeyName,
                 ksectionTitleName: NSLocalizedString(@"Yesterday", @"Yesterday's program section title")
                 },
             ];
    }
    
    return _sections;
}

- (void)setSections:(NSArray *)sections {
    _sections = sections;
}

#pragma mark - Refresh

- (void)toggleErrorDisplay:(BOOL)visible {
    
    if (self.tableView.tableHeaderView) {
        if (!visible) {
            self.tableView.tableHeaderView = nil;
        }
    }
    else if (visible) {
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20.0)];
        errorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        errorLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.9];
        errorLabel.textColor = [UIColor redColor];
        errorLabel.font = [UIFont systemFontOfSize:10.0];
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.text = NSLocalizedString(@"Error fetching schedule :(", @"Error title");
        self.tableView.tableHeaderView = errorLabel;
    }
}

- (void)fetchPrograms {

    if (!self.fetchingPrograms) {
        
        self.fetchingPrograms = YES;
        
        __weak typeof(self) weakSelf = self;
        
        [[DataManager sharedInstance] fetchProgramsWithCompletion:^(BOOL success, NSError *error) {
            
            if (self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }
            
            [weakSelf.tableView reloadData];
            [weakSelf toggleErrorDisplay:(error != nil)];
            
            self.fetchingPrograms = NO;
        }];
    }
}

- (IBAction)refreshInitiated:(id)sender {
    
    [self toggleErrorDisplay:NO];
    [self fetchPrograms];
}

- (void)refreshTimeFired:(NSTimer*)timer {
    
    [self fetchPrograms];
}

- (void)startRefreshTimer {

    [self stopRefreshTimer];

    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kProgramRefreshInterval target:self selector:@selector(refreshTimeFired:) userInfo:nil repeats:YES];
}

- (void)stopRefreshTimer {
    
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

@end
