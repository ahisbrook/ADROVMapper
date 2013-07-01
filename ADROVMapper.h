//
//  ADROVMapper.h
//  Copyright (c) 2013 Adrienne Hisbrook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADROVMapper : NSObject

@property (weak, nonatomic) id view;
@property (weak, nonatomic) id object;
@property (nonatomic) NSString *dateFormat;
@property (nonatomic) NSArray *currencyTags;
@property (nonatomic) BOOL autoSaveManagedObjects;

+ (ADROVMapper*)mapperWithView:(id)view object:(id)object;
+ (ADROVMapper*)mapperWithView:(id)view object:(id)object dateFormat:(NSString*)dateFormat;
+ (ADROVMapper*)mapperWithView:(id)view object:(id)object currencyTags:(NSArray*)currencyTags;
+ (ADROVMapper*)mapperWithView:(id)view object:(id)object dateFormat:(NSString*)dateFormat currencyTags:(NSArray*)currencyTags;

- (void)updateView;
- (void)updateObject;

@end
