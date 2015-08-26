//
//  EATLearnViewController.m
//  EAT
//
//  Created by Emlyn Murphy on 2/10/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATLearnViewController.h"

@interface EATLearnViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, assign) NSUInteger historyLevel;

@end

@implementation EATLearnViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.parentViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"LearnIconSelected"];
    
    self.webView.delegate = self;
    
    NSString *indexHtmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *indexHtmlURL = [NSURL fileURLWithPath:indexHtmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:indexHtmlURL];
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender {
    [self.webView goBack];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        self.historyLevel++;
    }
    else if (self.historyLevel > 0) {
        self.historyLevel--;
    }
    
    if (self.historyLevel == 0) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(back:)];
    }
    
    return YES;
}

@end
