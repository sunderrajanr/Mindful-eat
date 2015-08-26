//
//  EATRatingSliderViewController.m
//  EAT
//
//  Created by Emlyn Murphy on 1/27/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATRatingSliderViewController.h"

@interface EATRatingSliderViewController ()

@property (nonatomic, weak) IBOutlet UISlider *slider;

@end

@implementation EATRatingSliderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.slider.value = self.rating;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
