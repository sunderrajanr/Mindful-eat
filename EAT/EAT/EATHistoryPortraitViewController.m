//
//  EATHistoryViewController.m
//  EAT
//
//  Created by Emlyn Murphy on 2/9/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATHistoryPortraitViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "EATAverageRatingController.h"
#import "EATConstants.h"
#import "EAT-Swift.h"
#import "EATMeal.h"
#import "EATMyLessonsTableViewCell.h"

@interface EATHistoryPortraitViewController () <CPTPlotDataSource, EATAveragesDelegate,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *AlllessonsFetchController;
@property (nonatomic, weak) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTPieChart *pieChart;
@property (nonatomic, strong) EATAverageRatingController *averageRatingController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weekSegmentCtrl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *beforeAfterSegCtrl;
@property (weak, nonatomic) IBOutlet UITableView *m_AllLessonsTableView;
@property (nonatomic) NSMutableArray *allLessonsArr;
@end

@implementation EATHistoryPortraitViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	
	self.parentViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"HistoryIconSelected"];
	
	self.m_AllLessonsTableView.estimatedRowHeight = 100.0;
	self.m_AllLessonsTableView.rowHeight = UITableViewAutomaticDimension;
	self.m_AllLessonsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)awakeFromNib
{
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	
	if (deviceOrientation == UIDeviceOrientationLandscapeLeft ||
		deviceOrientation == UIDeviceOrientationLandscapeRight) {
		[self performSegueWithIdentifier:@"Landscape" sender:self];
	}
	else
	{
		
		
		self.averageRatingController = nil;
	
		self.averageRatingController = [[DataManager sharedInstance] averageRatingController:YES isBefore:NO];
		self.averageRatingController.delegate = self;

		
		[self initPlot];
		
		
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(orientationChanged:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	self.AlllessonsFetchController = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIDeviceOrientationDidChangeNotification
												  object:nil];
}

- (void)orientationChanged:(NSNotification *)notification {
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	
	if (deviceOrientation == UIDeviceOrientationLandscapeLeft ||
		deviceOrientation == UIDeviceOrientationLandscapeRight) {
		[self performSegueWithIdentifier:@"Landscape" sender:self];
	}
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)portrait:(UIStoryboardSegue *)segue
{
}


- (void)configureFetchedResultsController
{
	self.AlllessonsFetchController = [[DataManager sharedInstance] getAllLessons];
	self.AlllessonsFetchController.delegate = self;
	NSError *error2 = nil;
	
	
	
	if ([self.AlllessonsFetchController performFetch:&error2] == NO)
	{
		NSLog(@"Error performing fetch: %@,user info :%@", error2,[error2 userInfo]);
	}
	else
	{
		self.allLessonsArr = [[NSMutableArray alloc] init];
		for (EATMeal *meal in self.AlllessonsFetchController.fetchedObjects)
		{
			NSLog(@"sort order : %@",meal.sortOrder);
			NSString *textStr;
			if (meal.surveyPositiveComment.length>0)
			{
				textStr = meal.surveyPositiveComment;
			}
			else if(meal.surveyNegativeComment.length>0)
			{
				textStr = meal.surveyNegativeComment;
			}
			else if(meal.surveyNeturalComment.length>0)
			{
				textStr = meal.surveyNeturalComment;
			}
			else
			{
				textStr = @"";
			}
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"HH:mm:ss"];
			
			NSString *startTimeString = [formatter stringFromDate:meal.date];
			
			NSLog(@"Time:%@",startTimeString);
			
//			NSLog(@"text str:%@",textStr);
//			NSLog(@"Date:%@",meal.date);
//			NSTimeInterval seconds = [meal.date timeIntervalSinceReferenceDate];
//			double milliseconds = seconds*1000;
//			NSLog(@"Date as milli seconds:%f",milliseconds);
			[self.allLessonsArr addObject:textStr];
		}
		NSLog(@"all lessons:%@",self.allLessonsArr);
		self.allLessonsArr = [[[self.allLessonsArr reverseObjectEnumerator] allObjects] mutableCopy];
		[self.m_AllLessonsTableView reloadData];
	}
}

- (IBAction)weekSegCtrl:(id)sender
{
//		self.averageRatingController = nil;
//		
//		self.averageRatingController = [[DataManager sharedInstance] averageRatingController:!(_weekSegmentCtrl.selectedSegmentIndex) isBefore:NO];
//		self.averageRatingController.delegate = self;
//		[self initPlot];
}

- (IBAction)befAfterSegCtrlAction:(id)sender
{
	if (self.beforeAfterSegCtrl.selectedSegmentIndex == 2)
	{
		[self configureFetchedResultsController];
		[self.m_AllLessonsTableView reloadData];
		self.m_AllLessonsTableView.hidden = NO;
	}
	else
	{
		self.m_AllLessonsTableView.hidden = YES;
	}
	[self.pieChart reloadData];
	
}

#pragma mark - Chart behavior

- (void)initPlot
{
	[self configureHost];
	[self configureGraph];
	[self configureChart];
	[self configureLegend];
	[self configureFetchedResultsController];
}

- (void)configureHost {
	self.hostView.allowPinchScaling = NO;
}

- (void)configureGraph
{
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	self.hostView.hostedGraph = graph;
	graph.paddingLeft = 0.0f;
	graph.paddingTop = 0.0f;
	graph.paddingRight = 0.0f;
	graph.paddingBottom = 0.0f;
	graph.axisSet = nil;
	
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color = [CPTColor grayColor];
	textStyle.fontName = @"Helvetica-Bold";
	textStyle.fontSize = 16.0f;
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
}

- (void)configureChart
{
	CPTGraph *graph = self.hostView.hostedGraph;
	graph.plotAreaFrame.borderLineStyle = nil;
	
	self.pieChart = [[CPTPieChart alloc] init];
	self.pieChart.dataSource = self;
	self.pieChart.delegate = self;
	self.pieChart.pieRadius = (self.hostView.bounds.size.width * 0.95) / 2;
	self.pieChart.identifier = graph.title;
	self.pieChart.startAngle = M_PI_4;
	self.pieChart.sliceDirection = CPTPieDirectionClockwise;
	
	CPTGradient *overlayGradient = [[CPTGradient alloc] init];
	overlayGradient.gradientType = CPTGradientTypeRadial;
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0]  atPosition:0.0];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.05] atPosition:0.85];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.15] atPosition:0.95];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.2]  atPosition:1.0];
	self.pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
	
	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineColor = [CPTColor colorWithCGColor:UIColorFromRGB(0x777777).CGColor];
	self.pieChart.borderLineStyle = lineStyle;
	
	[graph addPlot:self.pieChart];
}

- (void)configureLegend
{
	// 1 - Get graph instance
	CPTGraph *graph = self.hostView.hostedGraph;
	// 2 - Create legend
	CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
	// 3 - Configure legend
	theLegend.numberOfColumns = 1;
	theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineColor = [CPTColor colorWithCGColor:UIColorFromRGB(0xcccccc).CGColor];
	theLegend.borderLineStyle = lineStyle;
	theLegend.cornerRadius = 5.0;
	// 4 - Add legend to graph
	graph.legend = theLegend;
	graph.legendAnchor = CPTRectAnchorRight;
	CGFloat legendPadding = -(self.view.bounds.size.width / 8);
	graph.legendDisplacement = CGPointMake(legendPadding + 35, -5);
	graph.legendAnchor = CPTRectAnchorTopRight;
}

#pragma mark - CPTPlotDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	if (self.beforeAfterSegCtrl.selectedSegmentIndex == 0)
	{
		return 3;
	}
	else if (self.beforeAfterSegCtrl.selectedSegmentIndex == 1)
	{
		return 4;
	}
	return 0;
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
	if (self.beforeAfterSegCtrl.selectedSegmentIndex == 0)
	{
		switch (index)
	 {
		 case 0:
			 if (self.averageRatingController.hungryCountBefore > 0)
			 {
				 return @"Ate When Not Hungry";
			 }
			 else
			 {
				 return nil;
			 }
			 
		 case 1:
			 if (self.averageRatingController.goodCountBefore > 0)
			 {
				 return @"Mindful of Hunger";
			 }
			 else {
				 return nil;
			 }
			 
		 case 2:
			 if (self.averageRatingController.fullCountBefore)
			 {
				 return @"Ate When Too Hungry";
			 }
			 else
			 {
				 return nil;
			 }
			 
		 default:
			 break;
	 }
		
	}
	else if (self.beforeAfterSegCtrl.selectedSegmentIndex == 1)
	{
		switch (index)
		{
			case 0:
				if (self.averageRatingController.hungryCountAfter > 0)
				{
					return @"Restriction?";
				}
				else
				{
					return nil;
				}
				
			case 1:
				if (self.averageRatingController.goodCountAfter > 0)
				{
					return @"Mindfully Full";
				}
				else {
					return nil;
				}
				
			case 2:
				if (self.averageRatingController.fullCountAfter)
				{
					return @"Too Full";
				}
				else
				{
					return nil;
				}
				
			case 3:
				if (self.averageRatingController.stuffedCountAfter)
				{
					return @"Stuffed";
				}
				else {
					return nil;
				}
				
			default:
				break;
		}
		
	}
	
	return nil;
	
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	if (self.beforeAfterSegCtrl.selectedSegmentIndex == 0)
	{
//		NSLog(@"hungry count : %lu",(unsigned long)self.averageRatingController.hungryCountBefore);
//		NSLog(@"good count : %lu",(unsigned long)self.averageRatingController.goodCountBefore);
//		NSLog(@"full count : %lu",(unsigned long)self.averageRatingController.fullCountBefore);
		switch (index)
		{
			case 0:
				return @(self.averageRatingController.hungryCountBefore);
				
			case 1:
				return @(self.averageRatingController.goodCountBefore);
				
			case 2:
				return @(self.averageRatingController.fullCountBefore);
			default:
				return nil;
		}
	}
	else if (self.beforeAfterSegCtrl.selectedSegmentIndex == 1)
	{
		switch (index)
		{
			case 0:
			 return @(self.averageRatingController.hungryCountAfter);
			 
			case 1:
			 return @(self.averageRatingController.goodCountAfter);
			 
			case 2:
			 return @(self.averageRatingController.fullCountAfter);
			 
			case 3:
			 return @(self.averageRatingController.stuffedCountAfter);
				
			default:
				return nil;
		}
	}
	return nil;
}

- (CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
	if (self.beforeAfterSegCtrl.selectedSegmentIndex == 0)
	{
		switch (index)
		{
			case 0:
				return [CPTFill fillWithColor:[[CPTColor alloc] initWithCGColor:[UIColor orangeColor].CGColor]];
				
			case 1:
				return [CPTFill fillWithColor:[[CPTColor alloc] initWithCGColor:EATGreenColor.CGColor]];
				
			case 2:
				return [CPTFill fillWithColor:[[CPTColor alloc] initWithCGColor:EATRedColor.CGColor]];
				
			default:
				break;
		}
	}
	else if (self.beforeAfterSegCtrl.selectedSegmentIndex == 1)
	{
		switch (index)
		{
			case 0:
				return [CPTFill fillWithColor:[[CPTColor alloc] initWithCGColor:[UIColor yellowColor].CGColor]];
				
			case 1:
				return [CPTFill fillWithColor:[[CPTColor alloc] initWithCGColor:EATGreenColor.CGColor]];
				
			case 2:
				return [CPTFill fillWithColor:[[CPTColor alloc] initWithCGColor:[UIColor orangeColor].CGColor]];
				
			case 3:
				return [CPTFill fillWithColor:[[CPTColor alloc] initWithCGColor:EATRedColor.CGColor]];
				
			default:
				break;
		}
	}
	return nil;
}

#pragma mark - EATAveragesDelegate

- (void)averageValuesDidChange
{
	[self.pieChart reloadData];
}


#pragma mark - Table view Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	return self.allLessonsArr.count;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *MyIdentifier = @"MyLessonTableViewCell";
	
	EATMyLessonsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
//	if (cell == nil)
//	{
//		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
//	}
	
	
	
	cell.m_MyLessonStr.text = [self.allLessonsArr objectAtIndex:indexPath.row];
	return cell;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewAutomaticDimension;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.m_AllLessonsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
//	UITableView *tableView = self.tableView;
//	
//	switch (type) {
//		case NSFetchedResultsChangeInsert:
//			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//			break;
//			
//		case NSFetchedResultsChangeDelete:
//			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//			[self updateCellsAfterRow:indexPath.row];
//			break;
//			
//		case NSFetchedResultsChangeUpdate:
//			[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//			break;
//			
//		case NSFetchedResultsChangeMove:
//			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//			break;
//	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.m_AllLessonsTableView endUpdates];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	self.managedObjectContextToEdit = [[PersistenceManager sharedInstance] temporaryContext];
//	self.mealToEdit = (EATMeal *)[[PersistenceManager sharedInstance] existingObject:[self.fetchedResultsController objectAtIndexPath:indexPath]
//																		   inContext:self.managedObjectContextToEdit];
//	self.mealCreated = NO;
//	[self performSegueWithIdentifier:@"EditMeal" sender:self];
	return nil;
}


@end
