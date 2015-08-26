//
//  EATPageViewController.m
//  EAT
//
//  Created by Emlyn Murphy on 1/23/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATPageViewController.h"

@interface EATPageViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSURL *webURL;

@property (nonatomic, strong) NSString *buttonText;
@property (nonatomic, strong) id buttonTarget;
@property (nonatomic, assign) SEL buttonAction;
@property (nonatomic, weak) IBOutlet UIButton *button;

@end

@implementation EATPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    self.button.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    NSError *error;
    NSString *html = [NSString stringWithContentsOfURL:self.webURL
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    
    if (html == nil) {
        NSLog(@"Error loading HTML: %@", error.localizedDescription);
    }
    
    [self.webView loadHTMLString:html baseURL:self.webURL];
    [self updateButton];
    self.pageControl.currentPage = self.pageIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setButtonText:(NSString *)text target:(id)target action:(SEL)action {
    self.buttonText = text;
    self.buttonTarget = target;
    self.buttonAction = action;
}

- (void)updateButton {
    if (self.buttonText != nil) {
        [self.button setTitle:self.buttonText forState:UIControlStateNormal];
        [self.button addTarget:self.buttonTarget action:self.buttonAction forControlEvents:UIControlEventTouchUpInside];
        self.button.hidden = NO;
    }
    else {
        self.button.hidden = YES;
    }
}

@end
