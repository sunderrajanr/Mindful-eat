//
//  EATHistoryLandscapeViewController.m
//  EAT
//
//  Created by Emlyn Murphy on 5/8/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATHistoryLandscapeViewController.h"
#import <CoreData/CoreData.h>
#import "CorePlot-CocoaTouch.h"
#import "EATConstants.h"
#import "EATMeal.h"
#import "EATRatingHistoryController.h"
#import "NSDate+Utils.h"
#import "EAT-Swift.h"

static const NSString *EATHistoryBeforePlot = @"EATHistoryBeforePlot";
static const NSString *EATHistoryAfterPlot  = @"EATHistoryAfterPlot";

@interface EATHistoryLandscapeViewController () <CPTPlotDataSource, CPTPlotSpaceDelegate, EATRatingHistoryControllerDelegate>

@property (nonatomic, weak) IBOutlet CPTGraphHostingView *hostView;

@property (nonatomic, strong) CPTGraph *graph;
@property (nonatomic, strong) EATRatingHistoryController *ratingHistoryController;
@property (nonatomic, assign) NSUInteger labelIncrement;

@end

@implementation EATHistoryLandscapeViewController

- (void)awakeFromNib {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (deviceOrientation == UIDeviceOrientationPortrait) {
        [self performSegueWithIdentifier:@"Portrait" sender:self];
    }
    else {
        self.ratingHistoryController = [[DataManager sharedInstance] ratingHistoryController];
        self.ratingHistoryController.delegate = self;
        [self initPlot];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;

    if (deviceOrientation == UIDeviceOrientationPortrait) {
        [self performSegueWithIdentifier:@"Portrait" sender:self];
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - Chart behavior

- (void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    [self configureLegend];
}

- (void)configureHost {
    self.hostView.allowPinchScaling = YES;
    self.labelIncrement = 1;
}

- (void)configureGraph {
    self.graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = self.graph;
    [self.graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 16.0f;

    self.graph.paddingLeft = 0.0f;
    self.graph.paddingTop = 0.0f;
    self.graph.paddingRight = 0.0f;
    self.graph.paddingBottom = 0.0f;
    self.graph.plotAreaFrame.paddingLeft = 0.0f;
    self.graph.plotAreaFrame.paddingBottom = 30.0f;
    self.graph.plotAreaFrame.borderLineStyle = nil;
}

- (void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.allowsMomentumX = YES;
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:[@(-1) decimalValue]
                                                          length:[@(self.ratingHistoryController.totalDays + 1) decimalValue]];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:[@0.8 decimalValue]
                                                          length:[@6.4 decimalValue]];
    plotSpace.delegate = self;

    // 2 - Create the two plots
    CPTScatterPlot *beforePlot = [[CPTScatterPlot alloc] init];
    beforePlot.dataSource = self;
    beforePlot.identifier = EATHistoryBeforePlot;
    beforePlot.title = NSLocalizedString(@"Hungry", @"Before plot title");
    
    CPTColor *beforeColor = [[CPTColor alloc] initWithCGColor:EATGreenColor.CGColor];
    [graph addPlot:beforePlot toPlotSpace:plotSpace];
    
    CPTScatterPlot *afterPlot = [[CPTScatterPlot alloc] init];
    afterPlot.dataSource = self;
    afterPlot.identifier = EATHistoryAfterPlot;
    afterPlot.title = NSLocalizedString(@"Full", @"After plot title");
    
    CPTColor *afterColor = [[CPTColor alloc] initWithCGColor:EATRedColor.CGColor];
    [graph addPlot:afterPlot toPlotSpace:plotSpace];
    
    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:beforePlot, afterPlot, nil]];
    
    double location = self.ratingHistoryController.totalDays - 6.5;
    
    if (location < 0) {
        location = -0.5;
    }
    
    double length = 7.5;
    
    if (length > self.ratingHistoryController.totalDays) {
        length = self.ratingHistoryController.totalDays + 0.5;
    }
    
    CPTMutablePlotRange *xRange = [CPTMutablePlotRange plotRangeWithLocation:[@(location) decimalValue]
                                                                      length:[@(length) decimalValue]];
    plotSpace.xRange = xRange;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[@0 decimalValue]
                                                    length:[@8 decimalValue]];
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *beforeLineStyle = [beforePlot.dataLineStyle mutableCopy];
    beforeLineStyle.lineWidth = 2.0;
    beforeLineStyle.lineColor = beforeColor;
    beforePlot.dataLineStyle = beforeLineStyle;
    
    CPTMutableLineStyle *beforeSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    beforeSymbolLineStyle.lineColor = beforeColor;
    
    CPTPlotSymbol *beforeSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    beforeSymbol.fill = [CPTFill fillWithColor:beforeColor];
    beforeSymbol.lineStyle = beforeSymbolLineStyle;
    beforeSymbol.size = CGSizeMake(6.0f, 6.0f);
    beforePlot.plotSymbol = beforeSymbol;
    
    CPTMutableLineStyle *afterLineStyle = [afterPlot.dataLineStyle mutableCopy];
    afterLineStyle.lineWidth = 2.0;
    afterLineStyle.lineColor = afterColor;
    afterPlot.dataLineStyle = afterLineStyle;
    
    CPTMutableLineStyle *afterSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    afterSymbolLineStyle.lineColor = afterColor;
    
    CPTPlotSymbol *afterSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    afterSymbol.fill = [CPTFill fillWithColor:afterColor];
    afterSymbol.lineStyle = afterSymbolLineStyle;
    afterSymbol.size = CGSizeMake(6.0f, 6.0f);
    afterPlot.plotSymbol = afterSymbol;
}

- (void)configureAxes {
	// 1 - Create styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor blackColor];
	axisTitleStyle.fontName = @"HelveticaNeue";
	axisTitleStyle.fontSize = 17.0f;
    
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [CPTColor blackColor];
    
	CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
	axisTextStyle.color = [CPTColor blackColor];
	axisTextStyle.fontName = @"HelveticaNeue";
	axisTextStyle.fontSize = 17.0f;
    
	CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor blackColor];
	tickLineStyle.lineWidth = 2.0f;
    
	CPTMutableLineStyle *gridLineStyle = nil;
	tickLineStyle.lineColor = [CPTColor blackColor];
	tickLineStyle.lineWidth = 1.0f;
    
	// 2 - Get axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.hostView.hostedGraph.axisSet;
    
	// 3 - Configure x-axis
	CPTXYAxis *x = axisSet.xAxis;
    x.orthogonalCoordinateDecimal = [@0.8 decimalValue];
	x.titleTextStyle = axisTitleStyle;
	x.titleOffset = 15.0f;
	x.axisLineStyle = axisLineStyle;
	x.labelingPolicy = CPTAxisLabelingPolicyNone;
	x.labelTextStyle = axisTextStyle;
	x.majorTickLineStyle = axisLineStyle;
	x.majorTickLength = 6.0f;
	x.tickDirection = CPTSignNegative;

    [self relabel];
    
	// 4 - Configure y-axis
	CPTAxis *y = axisSet.yAxis;
	y.titleTextStyle = axisTitleStyle;
	y.titleOffset = -40.0f;
	y.axisLineStyle = nil;
	y.majorGridLineStyle = gridLineStyle;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
	y.labelTextStyle = axisTextStyle;
	y.labelOffset = 16.0f;
	y.majorTickLineStyle = axisLineStyle;
	y.majorTickLength = 4.0f;
	y.minorTickLength = 2.0f;
	y.tickDirection = CPTSignPositive;

	NSMutableSet *yLabels = [NSMutableSet set];
	NSMutableSet *yMajorLocations = [NSMutableSet set];
	NSMutableSet *yMinorLocations = [NSMutableSet set];

	y.axisLabels = yLabels;
	y.majorTickLocations = yMajorLocations;
	y.minorTickLocations = yMinorLocations;
}

- (void)configureLegend {
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


- (void)relabel
{
	// 2 - Get axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.hostView.hostedGraph.axisSet;
    
	// 3 - Configure x-axis
	CPTXYAxis *x = axisSet.xAxis;
	NSMutableSet *xLabels = [NSMutableSet setWithCapacity:self.ratingHistoryController.mealCount];
	NSMutableSet *xLocations = [NSMutableSet setWithCapacity:self.ratingHistoryController.mealCount];
    NSDate *firstDate = nil;
    
    if (self.ratingHistoryController.totalDays > 0) {
        firstDate = [[self.ratingHistoryController mealAtIndex:0].date withoutTime];
    }
    
    NSUInteger firstDay = (self.ratingHistoryController.totalDays - 1) % self.labelIncrement;
    
    for (NSUInteger day = firstDay; day < self.ratingHistoryController.totalDays; day += self.labelIncrement) {
        NSDate *date = [firstDate dateByAddingTimeInterval:86400 * day];
        
        [xLocations addObject:@(day)];
        
		CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[date humanString]
                                                       textStyle:x.labelTextStyle];
		label.tickLocation = [@(day) decimalValue];
		label.offset = x.majorTickLength;
        
        [xLabels addObject:label];
    }
    
	x.axisLabels = xLabels;
	x.majorTickLocations = xLocations;
}

#pragma mark - CPTPlotDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.ratingHistoryController.mealCount;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (fieldEnum == 0) {
        return [self.ratingHistoryController dayAtIndex:index];
    }
    
    EATMeal *meal = [self.ratingHistoryController mealAtIndex:index];
    
    if (plot.identifier == EATHistoryBeforePlot) {
        return meal.ratingBefore;
    }

    if (plot.identifier == EATHistoryAfterPlot) {
        return meal.ratingAfter;
    }
    
    return nil;
}

#pragma mark - CPTPlotSpaceDelegate

- (CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange
              forCoordinate:(CPTCoordinate)coordinate
{
    if (coordinate == CPTCoordinateY)
	{
        return [CPTPlotRange plotRangeWithLocation:[@0.8 decimalValue]
                                            length:[@6.4 decimalValue]];
    }
    else
	{
        double rangeLength = [[NSDecimalNumber decimalNumberWithDecimal:newRange.length] doubleValue];
        NSUInteger increment = rangeLength / 8 + 1;
        
        if (self.labelIncrement != increment)
		{
            self.labelIncrement = increment;
            [self relabel];
        }
        
        return newRange;
    }
}

#pragma mark - EATRatingHistoryControllerDelegate

- (void)ratingHistoryDidChange
{
    [self.graph reloadData];
}

@end
