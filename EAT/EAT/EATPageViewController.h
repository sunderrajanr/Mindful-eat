//
//  EATPageViewController.h
//  EAT
//
//  Created by Emlyn Murphy on 1/23/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EATPageViewController : UIViewController

@property (nonatomic, assign) NSUInteger pageIndex;

- (void)setWebURL:(NSURL *)url;
- (void)setButtonText:(NSString *)text target:(id)target action:(SEL)action;

@end
