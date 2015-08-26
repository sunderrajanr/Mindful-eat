//
//  EATDiaryViewController.m
//  EAT
//
//  Created by Emlyn Murphy on 1/29/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATDiaryCell.h"
#import "EATDiaryViewController.h"
#import "EATMeal.h"
#import "EATRatingSlider.h"
#import "EATRatingViewController.h"
#import "NSDate+Utils.h"
#import "UIColor+EAT.h"
#import "Notifications.h"
#import "EAT-Swift.h"

@interface EATDiaryViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIButton *dateButton;
@property (nonatomic, strong) UIBarButtonItem *previousDayButton;
@property (nonatomic, strong) UIBarButtonItem *nextDayButton;
@property (nonatomic, strong) UIBarButtonItem *flexibleSpace;
@property (nonatomic, strong) UIBarButtonItem *fixedSpace;
@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

// Edit Meal
@property (nonatomic, strong) EATMeal *mealToEdit;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContextToEdit;
@property (nonatomic, assign) BOOL mealCreated;

@end

@implementation EATDiaryViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [AppRouteManager sharedInstance].diaryViewController = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.flexibleSpace = [[UIBarButtonItem alloc]
                          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                          target:nil
                          action:nil];
    
    self.fixedSpace = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                       target:nil
                       action:nil];
    [self.fixedSpace setWidth:20];
    
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                    target:self
                                                                    action:@selector(edit:)];
    
    self.previousDayButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ChevronLeft"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(previousDay:)];
    
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(addMeal:)];
    
    self.nextDayButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ChevronRight"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(nextDay:)];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(doneEditing:)];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    
    
    self.dateButton = [[UIButton alloc] init];
    [self.dateButton setTitle:@"Today" forState:UIControlStateNormal];
    self.dateButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.dateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dateButton addTarget:self action:@selector(today:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:self.dateButton];
    
    [titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:titleView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    [titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:titleView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0]];
    
    self.navigationItem.titleView = titleView;
    self.parentViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"DiaryIconSelected"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(significantTimeChangeNotification:)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureFetchedResultsController
{
    self.fetchedResultsController = [[DataManager sharedInstance] mealsFetchedResultsControllerForDate:self.date];
    self.fetchedResultsController.delegate = self;
	
    NSError *error = nil;
    
    if ([self.fetchedResultsController performFetch:&error] == NO)
	{
        NSLog(@"Error performing fetch: %@", error);
    }
      NSLog(@"%lu",(unsigned long)self.fetchedResultsController.fetchedObjects.count);
	
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.fetchedResultsController = nil;
}

- (NSDate *)date
{
    if (_date != nil) {
        return _date;
    }
    
    _date = [NSDate new];
    
    return _date;
}

- (NSDate *)dateWithCurrentTime {
    static NSCalendar *calendar = nil;
    
    if (calendar == nil) {
        calendar = [NSCalendar currentCalendar];
    }
    
    NSDateComponents *nowDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |
                                           NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |
                                           NSCalendarUnitSecond
                                                      fromDate:[NSDate new]];
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |
                                        NSCalendarUnitDay
                                                   fromDate:self.date];
    
    dateComponents.hour = nowDateComponents.hour;
    dateComponents.minute = nowDateComponents.minute;
    dateComponents.second = nowDateComponents.second;
    
    return [calendar dateFromComponents:dateComponents];
}

// Count number of meals that are or are not snacks
- (void)totalMealsAreSnack:(BOOL)snack indexPath:(NSIndexPath *)indexPath outIndex:(NSUInteger *)outIndex outTotal:(NSUInteger *)outTotal {
    *outIndex = 0;
    *outTotal = 0;
    
    for (NSUInteger i = 0; i < self.fetchedResultsController.fetchedObjects.count; i++)
	{
        EATMeal *meal = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        
        if ([meal.snack boolValue] == snack)
		{
            *outTotal += 1;
            
            if (indexPath.row == i) {
                *outIndex = *outTotal;
            }
        }
    }
}

- (void)configureCell:(EATDiaryCell *)diaryCell atIndexPath:(NSIndexPath *)indexPath
{
    EATMeal *meal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    diaryCell.ratingSlider.ratingBefore = [meal.ratingBefore floatValue];
    diaryCell.ratingSlider.ratingAfter = [meal.ratingAfter floatValue];
    
    NSUInteger mealNumber, totalOfType;
    NSString *typeString = nil;
    
    [self totalMealsAreSnack:[meal.snack boolValue] indexPath:indexPath outIndex:&mealNumber outTotal:&totalOfType];
    
    if ([meal.snack boolValue])
	{
        typeString = NSLocalizedString(@"Snack", nil);
    }
    else {
        typeString = NSLocalizedString(@"Meal", nil);
    }

    if (totalOfType > 1)
	{
        typeString = [NSString stringWithFormat:@"%@ %lu", typeString, (unsigned long)mealNumber];
    }
    
    diaryCell.mealTypeLabel.text = typeString;
    diaryCell.drinkCollapsibleImageView.collapsed = ![meal.caloricBeverage boolValue];
    
    if (meal.surveyPositive == nil)
	{
        diaryCell.sunCollapsibleImageView.collapsed = YES;
        diaryCell.cloudCollapsibleImageView.collapsed = YES;
		diaryCell.rainCloudCollapsibleImageView.collapsed = YES;
    }
    else if ([meal.surveyPositive isEqualToNumber:@(1)])
	{
        diaryCell.sunCollapsibleImageView.collapsed = NO;
        diaryCell.cloudCollapsibleImageView.collapsed = YES;
		diaryCell.rainCloudCollapsibleImageView.collapsed = YES;
    }
    else if ([meal.surveyPositive isEqualToNumber:@(0)])
	{
        diaryCell.sunCollapsibleImageView.collapsed = YES;
        diaryCell.cloudCollapsibleImageView.collapsed = NO;
		diaryCell.rainCloudCollapsibleImageView.collapsed = YES;
    }
	else
	{
		diaryCell.sunCollapsibleImageView.collapsed = YES;
		diaryCell.cloudCollapsibleImageView.collapsed = YES;
		diaryCell.rainCloudCollapsibleImageView.collapsed = NO;
	}
}

- (void)updateView
{
    if (self.tableView.editing)
	{
        self.navigationItem.leftBarButtonItems  = @[];
        self.navigationItem.rightBarButtonItems = @[self.doneButton];
    }
    else
	{
        if ([self.date isToday])
		{
            self.navigationItem.leftBarButtonItems  = @[self.editButton, self.flexibleSpace, self.previousDayButton, self.fixedSpace];
            self.navigationItem.rightBarButtonItems = @[self.addButton, self.flexibleSpace];
        }
        else
		{
            self.navigationItem.leftBarButtonItems  = @[self.editButton, self.flexibleSpace, self.previousDayButton, self.fixedSpace];
            self.navigationItem.rightBarButtonItems = @[self.addButton, self.flexibleSpace, self.nextDayButton, self.fixedSpace];
        }
    }
    
    [self.dateButton setTitle:[self.date humanString] forState:UIControlStateNormal];
    [self configureFetchedResultsController];
}

- (void)previousDay:(id)sender
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = -1;
    
    self.date = [calendar dateByAddingComponents:dateComponents
                                          toDate:self.date
                                         options:0];
    
    [self updateView];
}

- (void)nextDay:(id)sender {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = 1;
    
    self.date = [calendar dateByAddingComponents:dateComponents
                                          toDate:self.date
                                         options:0];
    [self updateView];
}

- (void)today:(id)sender;
{
    self.date = [NSDate date];
    [self updateView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditMeal"]) {
    EATRatingViewController *ratingViewController = (EATRatingViewController *)[segue.destinationViewController topViewController];
        ratingViewController.meal = self.mealToEdit;
        ratingViewController.managedObjectContext = self.managedObjectContextToEdit;
        
        if (self.mealCreated) {
            ratingViewController.doneButtonTitle = NSLocalizedString(@"Add", @"Create meal button title");
        }
        else {
            ratingViewController.doneButtonTitle = NSLocalizedString(@"Save", @"Save meal button title");
        }
        
        self.mealToEdit = nil;
        self.managedObjectContextToEdit = nil;
        self.mealCreated = NO;
    }
}

- (void)doneEditing:(id)sender {
    self.tableView.editing = NO;
    [self updateView];
}

- (void)updateCellsAfterRow:(NSUInteger)row
{
    NSMutableArray *indexPaths = [NSMutableArray new];
    
    for (NSUInteger i = row; i < self.fetchedResultsController.fetchedObjects.count; i++)
	{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i + 1 inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    if ([indexPaths count] > 0) {
        [self.tableView reloadRowsAtIndexPaths:[indexPaths copy] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (IBAction)cancelNewEntry:(UIStoryboardSegue *)segue {
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self updateCellsAfterRow:indexPath.row];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.managedObjectContextToEdit = [[PersistenceManager sharedInstance] temporaryContext];
    self.mealToEdit = (EATMeal *)[[PersistenceManager sharedInstance] existingObject:[self.fetchedResultsController objectAtIndexPath:indexPath]
                                                                           inContext:self.managedObjectContextToEdit];
    self.mealCreated = NO;
    [self performSegueWithIdentifier:@"EditMeal" sender:self];
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.fetchedResultsController == nil) {
        return 1;
    }
    else
	{
		NSLog(@"%lu",(unsigned long)self.fetchedResultsController.fetchedObjects.count);
        return self.fetchedResultsController.fetchedObjects.count;
		
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController == nil)
	{
        return [tableView dequeueReusableCellWithIdentifier:@"Loading"];
    }
    else
	{
        EATDiaryCell *diaryCell = [tableView dequeueReusableCellWithIdentifier:@"DiaryCell" forIndexPath:indexPath];
        [self configureCell:diaryCell atIndexPath:indexPath];
        return diaryCell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.fetchedResultsController != nil;
}

- (void)     tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EATMeal *meal = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[DataManager sharedInstance] deleteObject:meal];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fetchedResultsController == nil) {
        return self.tableView.frame.size.height - [self.topLayoutGuide length] - [self.bottomLayoutGuide length];
    }
    else {
        return 98;
    }
}

#pragma mark - Interface Builder Actions

- (IBAction)addMeal:(id)sender
{
	NSCalendar *gregorianCal = [[NSCalendar alloc] init];
	NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate: [NSDate date]];
	// Then use it
	[dateComps minute];
	[dateComps hour];
	
	
	
	NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	// Extract date components into components1
	NSDateComponents *components1 = [gregorianCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
	
	// Extract time components into components2
	NSDateComponents *components2 = [gregorianCalendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
	
	// Combine date and time into components3
	NSDateComponents *components3 = [[NSDateComponents alloc] init];
	
	[components3 setYear:components1.year];
	[components3 setMonth:components1.month];
	[components3 setDay:components1.day];
	
	[components3 setHour:components2.hour];
	[components3 setMinute:components2.minute];
	[components3 setSecond:components2.second];
	
	// Generate a new NSDate from components3.
	NSDate *combinedDate = [gregorianCalendar dateFromComponents:components3];

	

    self.managedObjectContextToEdit = [[PersistenceManager sharedInstance] temporaryContext];
    self.mealToEdit = [[DataManager sharedInstance] createMealForDate:combinedDate inManagedObjectContext:self.managedObjectContextToEdit];
    self.mealCreated = YES;
    [self performSegueWithIdentifier:@"EditMeal" sender:sender];
}

- (IBAction)edit:(id)sender {
    self.tableView.editing = YES;
    [self updateView];
}

#pragma mark - Notifications

- (void)significantTimeChangeNotification:(NSNotification *)notification {
    self.date = nil;
    [self updateView];
}

@end
