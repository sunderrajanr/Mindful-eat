//
//  EATMeal.h
//  
//
//  Created by vino on 19/08/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface EATMeal : NSManagedObject

@property (nonatomic, retain) NSNumber * caloricBeverage;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * ratingAfter;
@property (nonatomic, retain) NSNumber * ratingBefore;
@property (nonatomic, retain) NSNumber * snack;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSNumber * surveyNegative1;
@property (nonatomic, retain) NSNumber * surveyNegative2;
@property (nonatomic, retain) NSNumber * surveyNegative3;
@property (nonatomic, retain) NSNumber * surveyNegative4;
@property (nonatomic, retain) NSNumber * surveyNegative5;
@property (nonatomic, retain) NSNumber * surveyNegative6;
@property (nonatomic, retain) NSNumber * surveyNegative7;
@property (nonatomic, retain) NSNumber * surveyNegative8;
@property (nonatomic, retain) NSString * surveyNegativeComment;
@property (nonatomic, retain) NSNumber * surveyPositive;
@property (nonatomic, retain) NSNumber * surveyPositive1;
@property (nonatomic, retain) NSNumber * surveyPositive2;
@property (nonatomic, retain) NSNumber * surveyPositive3;
@property (nonatomic, retain) NSNumber * surveyPositive4;
@property (nonatomic, retain) NSNumber * surveyPositive5;
@property (nonatomic, retain) NSNumber * surveyPositive6;
@property (nonatomic, retain) NSNumber * surveyPositive7;
@property (nonatomic, retain) NSString * surveyPositiveComment;
@property (nonatomic, retain) NSNumber * surveyNegative9;
@property (nonatomic, retain) NSString * surveyNeturalComment;
@property (nonatomic, retain) Photo *photo;

@end
