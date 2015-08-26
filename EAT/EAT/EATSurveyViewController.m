//
//  EATSurveyViewController.m
//  EAT
//
//  Created by Emlyn Murphy on 2/1/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATSurveyViewController.h"
#import "EATTextViewCell.h"
#import "EATMeal.h"
#import "EAT-Swift.h"

@interface EATSurveyViewController () <UITextViewDelegate>

@property (nonatomic, strong) EATTextViewCell *otherTextViewCell;
@property (nonatomic, readonly, strong) NSArray *questions;

@end

@implementation EATSurveyViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	NSLog(@"survey no:%@",self.meal.surveyPositive);
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self configureDoneButton];
	//	Edited ny mavinapps on 18Aug15
	
	
	//    if ([self.meal.surveyPositive boolValue]) {
	//        self.title = NSLocalizedString(@"How?", nil);
	//    }
	//    else {
	//        self.title = NSLocalizedString(@"Lessons", nil);
	//    }
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

- (void)configureDoneButton {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.doneButtonTitle
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(done:)];
}

- (NSArray *)questions {
	static NSArray *goodQuestions = nil;
	static NSArray *badQuestions = nil;
	static NSArray *neturalQuestions = nil;
	if (self.meal == nil) {
		return nil;
	}
	
	if ([self.meal.surveyPositive isEqualToNumber:@(1)])
	{
		if (goodQuestions == nil)
		{
			//Edited by mavin apps on 18Aug15
			goodQuestions = @[
							  //							  NSLocalizedString(@"I remembered to rate\nbefore/after eating", nil),
							  NSLocalizedString(@"I didn’t wait and get too hungry", nil),
							  NSLocalizedString(@"Was able to stop before got too full", nil),
							  NSLocalizedString(@"Enjoyed my food", nil),
							  NSLocalizedString(@"Ate slowly", nil),
							  NSLocalizedString(@"I predicted accurately what would feel good afterwards", nil),
							  NSLocalizedString(@"I didn’t let others’ choices affect my choices", nil),
							  NSLocalizedString(@"Personal Lessons", nil)];
		}
		
		return goodQuestions;
	}
	else if ([self.meal.surveyPositive isEqualToNumber:@(0)])
	{
		if (badQuestions == nil)
		{
			badQuestions = @[NSLocalizedString(@"Don’t skip meals/planned snacks", nil),
							 NSLocalizedString(@"Plan ahead", nil),
							 NSLocalizedString(@"Notice what triggers mindless eating", nil),
							 NSLocalizedString(@"Don’t get too hungry before eating", nil),
							 NSLocalizedString(@"Resist urge to eat when not hungry", nil),
							 NSLocalizedString(@"Stop at moderate fullness", nil),
							 NSLocalizedString(@"Stay tuned in – notice point of diminishing returns", nil),
							 NSLocalizedString(@"Remember foods or amounts that didn’t feel good", nil),
							 //                             NSLocalizedString(@"Remember worth it/not worth it predictions", nil),
							 NSLocalizedString(@"Personal Lessons", nil)];
		}
		
		return badQuestions;
	}
	else
	{
		return neturalQuestions;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if ([keyPath isEqualToString:@"text"])
	{
		if ([self.meal.surveyPositive boolValue])
		{
			self.meal.surveyPositiveComment = change[NSKeyValueChangeNewKey];
		}
		else
		{
			self.meal.surveyNegativeComment = change[NSKeyValueChangeNewKey];
		}
	}
}

- (IBAction)done:(id)sender {
	[[PersistenceManager sharedInstance] saveContext:self.managedObjectContext];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	self.navigationItem.rightBarButtonItem = nil;
	
	NSValue *keyboardFrameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardFrame;
	[keyboardFrameValue getValue:&keyboardFrame];
	
	NSValue *animationDurationValue = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
	double animationDuration;
	[animationDurationValue getValue:&animationDuration];
	
	//    [UIView animateWithDuration:animationDuration animations:^{
	//        self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, keyboardFrame.size.height, 0);
	//        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, keyboardFrame.size.height, 0);
	//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.questions.count - 1 inSection:0]
	//                              atScrollPosition:UITableViewScrollPositionTop
	//                                      animated:NO];
	//    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	[self configureDoneButton];
	NSValue *animationDurationValue = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
	double animationDuration;
	[animationDurationValue getValue:&animationDuration];
	
	//    [UIView animateWithDuration:animationDuration animations:^{
	//        self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 0, 0);
	//        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 0, 0);
	//    }];
}

- (NSString *)answerKeyForIndexPath:(NSIndexPath *)indexPath
{
	if ([self.meal.surveyPositive isEqualToNumber:@(1)])
	{
		return [NSString stringWithFormat:@"surveyPositive%li", (long)indexPath.row + 1];
	}
	else if ([self.meal.surveyPositive isEqualToNumber:@(0)])
	{
		return [NSString stringWithFormat:@"surveyNegative%li", (long)indexPath.row + 1];
	}
	else
	{
		return nil;
	}
}

- (UITableViewCellAccessoryType)cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath
{
	   NSNumber *answer = nil;
	    NSString *keyPath = [self answerKeyForIndexPath:indexPath];
	
	    answer = [self.meal valueForKey:keyPath];
	
	   if ([answer boolValue])
	   {
	        return UITableViewCellAccessoryCheckmark;
	    }
	    else {
	        return UITableViewCellAccessoryNone;
	    }
	
	return UITableViewCellAccessoryNone;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SurveyQuestionCellIdentifier = @"SurveyQuestionCell";
	static NSString *OtherTextCellIdentifier      = @"OtherTextCell";
	
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 0)
	{
		SurveyCell *surveyCell = [tableView dequeueReusableCellWithIdentifier:SurveyQuestionCellIdentifier forIndexPath:indexPath];
		surveyCell.surveyTextLabel.text = self.questions[indexPath.row];
		surveyCell.accessoryType = [self cellAccessoryTypeForIndexPath:indexPath];
		cell = surveyCell;
	}
	else if (indexPath.section == 1)
	{
		EATTextViewCell *otherTextViewCell2 = [tableView dequeueReusableCellWithIdentifier:OtherTextCellIdentifier forIndexPath:indexPath];
		
		if ([self.meal.surveyPositive isEqualToNumber:@(1)])
		{
			otherTextViewCell2.textView.text = self.meal.surveyPositiveComment;
		}
		else if ([self.meal.surveyPositive isEqualToNumber:@(0)])
		{
			otherTextViewCell2.textView.text = self.meal.surveyNegativeComment;
		}
		else
		{
			otherTextViewCell2.textView.text = self.meal.surveyNeturalComment;
		}
		
		otherTextViewCell2.textView.delegate = self;
		
		self.otherTextViewCell = otherTextViewCell2;
		cell = otherTextViewCell2;
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return self.questions.count;
	}
	else if (section == 1)
	{
		return 1;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		if ([self.meal.surveyPositive boolValue])
		{
			
			return NSLocalizedString(@"What went well?", nil);
		}
		else
		{
			return NSLocalizedString(@"Lessons to Remember", nil);
		}
	}
	
	return nil;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *answerKeyPath = [self answerKeyForIndexPath:indexPath];
	NSNumber *currentAnswer = [self.meal valueForKey:answerKeyPath];
	
	[self.meal setValue:@(![currentAnswer boolValue]) forKey:answerKeyPath];
	// toggle the answer
	[self.tableView reloadData];
	
	if (indexPath.row == self.questions.count - 1 && [[self.meal valueForKey:answerKeyPath] boolValue])
	{
		[self.otherTextViewCell.textView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
	}
	
	return nil;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 1) {
//        return 44 * 5;
//    }
////	else
////	{
////		if (indexPath.row == 4 || indexPath.row == 5)
////		{
////			return 70;
////		}
////	}
//
//    return 60;
//}


-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewAutomaticDimension;
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text rangeOfString:@"\n"].location != NSNotFound)
	{
		[textView resignFirstResponder];
		
		return NO;
	}
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
	if ([self.meal.surveyPositive isEqualToNumber:@(1)])
	{
		self.meal.surveyPositiveComment = textView.text;
	}
	else if ([self.meal.surveyPositive isEqualToNumber:@(0)])
	{
		self.meal.surveyNegativeComment = textView.text;
	}
	else
	{
		self.meal.surveyNeturalComment = textView.text;
	}
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
	
}

@end
