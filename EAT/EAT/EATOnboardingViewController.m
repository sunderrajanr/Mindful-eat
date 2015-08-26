//
//  EATOnboardingViewController.m
//  EAT
//
//  Created by Emlyn Murphy on 1/23/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATOnboardingViewController.h"
#import "EATPageViewController.h"

@class EATPageViewController;

@interface EATOnboardingViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate> 

@end

@implementation EATOnboardingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewControllers:@[[self viewControllerForIndex:0]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    self.dataSource = self;
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (EATPageViewController *)viewControllerForIndex:(NSUInteger)index {
    EATPageViewController *pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardingPage"];
    
    pageViewController.pageIndex = index;
    
    switch (index) {
        case 0:
            [pageViewController setWebURL:[[NSBundle mainBundle] URLForResource:@"onboarding1" withExtension:@"html"]];
            break;
            
        case 1:
            [pageViewController setWebURL:[[NSBundle mainBundle] URLForResource:@"onboarding2" withExtension:@"html"]];
            break;
            
        case 2:
            [pageViewController setWebURL:[[NSBundle mainBundle] URLForResource:@"onboarding3" withExtension:@"html"]];
            break;
            
        case 3:
            [pageViewController setWebURL:[[NSBundle mainBundle] URLForResource:@"onboarding4" withExtension:@"html"]];
            [pageViewController setButtonText:NSLocalizedString(@"Get Started", nil)
                                       target:self
                                       action:@selector(getStarted)];
            break;
            
        default:
            break;
    }
    
    return pageViewController;
}

- (void)getStarted {
    [self performSegueWithIdentifier:@"GetStarted" sender:self];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(EATPageViewController *)viewController {
    if (viewController.pageIndex > 0) {
        return [self viewControllerForIndex:viewController.pageIndex - 1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(EATPageViewController *)viewController {
    if (viewController.pageIndex < 3) {
        return [self viewControllerForIndex:viewController.pageIndex + 1];
    }
    
    return nil;
}

#pragma mark - UIPageViewControllerDelegate


@end
