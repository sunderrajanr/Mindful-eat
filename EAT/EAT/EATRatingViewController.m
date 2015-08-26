//
//  EATRatingBeforeViewController.m
//  EAT
//
//  Created by Emlyn Murphy on 1/27/14.
//  Copyright (c) 2014 Nitemotif. All rights reserved.
//

#import "EATRatingViewController.h"
#import "EATSliderCell.h"
#import "EATSwitchCell.h"
#import "EATSurveyViewController.h"
#import "EATSurveyRoutingCell.h"
#import "EATRatingSlider.h"
#import "EATMeal.h"
#import "EAT-Swift.h"

@interface EATRatingViewController () <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) EATImagePickerController *imagePickerController;

@end

@implementation EATRatingViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [AppRouteManager sharedInstance].ratingViewController = self;
    }
    
    return self;
}

- (void)setMeal:(EATMeal *)meal
{
    [_meal removeObserver:self forKeyPath:@"photo"];
    
    _meal = meal;
    
    [_meal addObserver:self forKeyPath:@"photo" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [_meal removeObserver:self forKeyPath:@"photo"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureDoneButton];
	
	
	
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Survey"])
	{
        EATSurveyViewController *surveyViewController = segue.destinationViewController;
        surveyViewController.meal = self.meal;
        surveyViewController.managedObjectContext = self.managedObjectContext;
        surveyViewController.doneButtonTitle = self.doneButtonTitle;
    }
}

- (void)ratingChanged:(EATRatingSlider *)ratingSlider
{
    self.meal.ratingBefore = @(ratingSlider.ratingBefore);
    self.meal.ratingAfter = @(ratingSlider.ratingAfter);
}

- (void)caloricBeverageChanged:(UISwitch *)sender {
    self.meal.caloricBeverage = @(sender.on);
}

- (void)configureDoneButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.doneButtonTitle
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(done:)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"photo"] && [self isViewLoaded]) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:4]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            
        case 1:
            return 1;
            
        case 2:
            return 1;
            
        case 3:
            return 1;
            
        case 4:
            return 1;
            
        default:
            break;
    }
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *RatingTypeCellIdentifier    = @"RatingTypeCell";
    static NSString *SliderCellIdentifier        = @"SliderCell";
    static NSString *SwitchCellIdentifier        = @"SwitchCell";
    static NSString *SurveyRoutingCellIdentifier = @"SurveyRoutingCell";
    static NSString *PhotoCellIdentifier         = @"PhotoCell";
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
	{
        cell = [tableView dequeueReusableCellWithIdentifier:RatingTypeCellIdentifier forIndexPath:indexPath];
        
        if (indexPath.row == 0)
		{
            cell.textLabel.text = NSLocalizedString(@"Meal", nil);
            
            if ([self.meal.snack boolValue]) {
                cell.accessoryView = nil;
            }
            else {
				cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"markIcon"]];
            }
        }
        else
		{
            cell.textLabel.text = NSLocalizedString(@"Snack", nil);
            
            if ([self.meal.snack boolValue])
			{
				cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"markIcon"]];
            }
            else {
                cell.accessoryView = nil;
            }
        }
    }
    else if (indexPath.section == 1)
	{
        EATSliderCell *ratingSliderCell = [tableView dequeueReusableCellWithIdentifier:SliderCellIdentifier forIndexPath:indexPath];
        
        ratingSliderCell.ratingSlider.ratingBefore = [self.meal.ratingBefore floatValue];
        ratingSliderCell.ratingSlider.ratingAfter = [self.meal.ratingAfter floatValue];
        
        [ratingSliderCell.ratingSlider addTarget:self
                                          action:@selector(ratingChanged:)
                                forControlEvents:UIControlEventValueChanged];
        
        cell = ratingSliderCell;
    }
    else if (indexPath.section == 2)
	{
        EATSwitchCell *caloricBeverageCell;
        
        switch (indexPath.row)
		{
            case 0:
                caloricBeverageCell = [tableView dequeueReusableCellWithIdentifier:SwitchCellIdentifier];
                caloricBeverageCell.label.text = NSLocalizedString(@"Caloric Beverage", nil);
                caloricBeverageCell.switchControl.on = [self.meal.caloricBeverage boolValue];
                
                [caloricBeverageCell.switchControl addTarget:self
                                                      action:@selector(caloricBeverageChanged:)
                                            forControlEvents:UIControlEventValueChanged];
                
                cell = caloricBeverageCell;
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section == 3)
	{
        EATSurveyRoutingCell *surveyRoutingCell = [tableView dequeueReusableCellWithIdentifier:SurveyRoutingCellIdentifier];
        
        surveyRoutingCell.surveyPositive = self.meal.surveyPositive;
        
        cell = surveyRoutingCell;
    }
    else if (indexPath.section == 4)
	{
        PhotoCell *photoCell = [tableView dequeueReusableCellWithIdentifier:PhotoCellIdentifier];
        
        photoCell.meal = self.meal;
        
        cell = photoCell;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            
        case 1:
            return NSLocalizedString(@"Rating", nil);
            
        case 2:
            return nil;
            
        case 3:
            return NSLocalizedString(@"How did it go?", nil);
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                self.meal.snack = @NO;
                break;
                
            case 1:
                self.meal.snack = @YES;
                break;
        }
        
        [self.tableView reloadData];
    }
    else if (indexPath.section == 4) {
        if (self.meal.photo == nil) {
            [self addPhoto];
        }
        else {
            [self removePhoto];
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 114;
    }
    else if (indexPath.section == 3) {
        return 79;
    }
    else if (indexPath.section == 4) {
        // Photo Cell
        if (self.meal.photo != nil) {
            return (CGFloat)self.meal.photo.height / self.meal.photo.width * self.view.frame.size.width;
        }
        else {
            return (CGFloat)3 / 4 * self.view.frame.size.width;
        }
    }
    else {
        return 44;
    }
}




- (void)addPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Choose From Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
	{
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)removePhoto
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Photo", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.managedObjectContext deleteObject:self.meal.photo];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    EATImagePickerController *imagePickerController = [[EATImagePickerController alloc] init];
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    [[PersistenceManager sharedInstance] saveContext:self.managedObjectContext];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if (buttonIndex == 1) {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma mark - Interface Builder Actions

- (IBAction)positiveSurvey:(id)sender
{
    self.meal.surveyPositive = @(YES);
    [self.tableView reloadData];
    [self performSegueWithIdentifier:@"Survey" sender:sender];
}

- (IBAction)negativeSurvey:(id)sender
{
    self.meal.surveyPositive = @(NO);
    
    [self.tableView reloadData];
    [self performSegueWithIdentifier:@"Survey" sender:sender];
}

- (IBAction)neturalSurvey:(id)sender
{
	self.meal.surveyPositive = @(2);
	[self.tableView reloadData];
	[self performSegueWithIdentifier:@"Survey" sender:sender];

}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [[PhotoManager sharedInstance] addImage:image toMeal:self.meal];
}

@end
