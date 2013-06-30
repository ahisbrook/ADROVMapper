//
//  ADROVMapper.m
//  Copyright (c) 2013 Adrienne Hisbrook. All rights reserved.
//

#define DEFAULT_DATE_FORMAT @"MM/dd/yyyy"
#define DEFAULT_DATE_TAGS @[@"date"]
#define DEFAULT_CURRENCY_TAGS @[@"amount", @"balance", @"price", @"msrp"]

#import "ADROVMapper.h"
#import <objc/runtime.h>

@interface ADROVMapper()
@property (nonatomic) NSArray * mappedKeys;
@end

@implementation ADROVMapper

typedef enum {	
    ADROVObjectUpdate,
    ADROVViewUpdate
} ADROVUpdateType;

// Constructors
- (id)initWithView:(id)view object:(id)object dateFormat:(NSString*)dateFormat currencyTags:(NSArray*)currencyTags {
    self = [super init];
    if (self) {
        self.view = view;
        self.object = object;
        self.dateFormat = dateFormat;
        self.currencyTags = currencyTags;
    }
    return self;
}
+ (ADROVMapper*)mapperWithView:(id)view object:(id)object {
    return [[ADROVMapper alloc] initWithView:view
                                      object:object
                                  dateFormat:DEFAULT_DATE_FORMAT
                                currencyTags:DEFAULT_CURRENCY_TAGS];
}
+ (ADROVMapper*)mapperWithView:(id)view object:(id)object dateFormat:(NSString*)dateFormat {
    return [[ADROVMapper alloc] initWithView:view
                                      object:object
                                  dateFormat:dateFormat
                                currencyTags:DEFAULT_CURRENCY_TAGS];
}
+ (ADROVMapper*)mapperWithView:(id)view object:(id)object currencyTags:(NSArray*)currencyTags {
    return [[ADROVMapper alloc] initWithView:view
                                      object:object
                                  dateFormat:DEFAULT_DATE_FORMAT
                                currencyTags:currencyTags];
}
+ (ADROVMapper*)mapperWithView:(id)view object:(id)object dateFormat:(NSString*)dateFormat currencyTags:(NSArray*)currencyTags {
    return [[ADROVMapper alloc] initWithView:view
                                      object:object
                                  dateFormat:dateFormat
                                currencyTags:currencyTags];
}

// Public
- (void)updateView {
    [self performUpdate:ADROVViewUpdate];
}
- (void)updateObject {
    [self performUpdate:ADROVObjectUpdate];
}
- (void)syncViewAndObject {
    NSArray *myProperties = [self getProperties:self.view];
    NSArray *objectProperties = [self getProperties:self.object];
    
    NSMutableArray *tempMappedKeys = [NSMutableArray new];
    for (NSString *propertyKey in myProperties) {
        if ([objectProperties indexOfObject:propertyKey] == NSNotFound) {
            continue;
        }
        [tempMappedKeys addObject:propertyKey];
    }
    self.mappedKeys = [NSArray arrayWithArray:tempMappedKeys];
    tempMappedKeys = nil;
    myProperties = nil;
    objectProperties = nil;
}

// Private
- (BOOL)string:(NSString*)string containsSubstring:(NSString*)subString {
    NSRange range = [string rangeOfString:subString];
    BOOL found = (range.location != NSNotFound );
    return found;
}
- (NSArray*)getProperties:(id)object {
    unsigned int outCount, i;
    NSMutableArray *theProperties = [NSMutableArray new];
    objc_property_t * properties = class_copyPropertyList([object class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithFormat:@"%s", propName];
            [theProperties addObject:propertyName];
        }
    }
    free(properties);
    
    return theProperties;
}

- (void)updateObjectValue:(id)objectValue withTextControl:(id)control isDate:(BOOL)isDate isCurrency:(BOOL)isCurrency {
    if (isCurrency) {
        NSNumberFormatter *nf = [NSNumberFormatter new];
        if ([self string:[control text] containsSubstring:@"$"]) {
            [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        }
        else {
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setMaximumFractionDigits:2];
            [nf setMinimumFractionDigits:2];
        }
        objectValue = [nf numberFromString:[control text]];
        nf = nil;
    }
    else if (isDate) {
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:self.dateFormat];
        objectValue = [df dateFromString:[control text]];
        df = nil;
    }
    else {
        objectValue = [control text];
    }
}
- (void)updateObjectValue:(id)objectValue withImageView:(id)control {
    if ([objectValue isKindOfClass:[UIImage class]]) {
        objectValue = [(UIImageView*)control image];
    }
}
- (void)updateObjectValue:(id)objectValue withSlider:(id)control {
    objectValue = [NSNumber numberWithFloat:[(UISlider*)control value]];
}
- (void)updateObjectValue:(id)objectValue withSwitch:(id)control {
    objectValue = [NSNumber numberWithBool:[control isOn]];
}
- (void)updateObjectValue:(id)objectValue withSegmentedControl:(id)control {
    BOOL found = NO;
    if ([objectValue isKindOfClass:[NSString class]]) {
        objectValue = [control titleForSegmentAtIndex:[control selectedSegmentIndex]];
        found = YES;
    }
    if (!found) {
        if ([objectValue isKindOfClass:[NSNumber class]]) {
            objectValue = [NSNumber numberWithInt:[control selectedSegmentIndex]];
        }
    }
}
- (void)updateObjectValue:(id)objectValue withDatePicker:(id)control {
    objectValue = [control date];
}

- (void)updateObjectValue:(id)objectValue withControl:(id)control propertyKey:(NSString*)propertyKey {
    if ([control isKindOfClass:[UITextField class]] ||
        [control isKindOfClass:[UITextView class]] ||
        [control isKindOfClass:[UILabel class]])
    {
        BOOL isDate = [objectValue isKindOfClass:[NSDate class]];
        BOOL isCurrency = NO;
        if (!isDate) {
            for (NSString *tag in self.currencyTags) {
                if ([self string:propertyKey.lowercaseString containsSubstring:tag.lowercaseString]) {
                    isCurrency = YES;
                    break;
                }
            }
        }
        [self updateObjectValue:objectValue withTextControl:control isDate:isDate isCurrency:isCurrency];
        return;
    }
    
    if ([control isKindOfClass:[UIImageView class]])
    {
        [self updateObjectValue:objectValue withImageView:control ];
        return;
    }
    
    if ([control isKindOfClass:[UISlider class]] &&
        [objectValue isKindOfClass:[NSNumber class]])
    {
        [self updateObjectValue:objectValue withSlider:control];
        return;
    }
    
    if ([control isKindOfClass:[UISwitch class]] &&
        [objectValue isKindOfClass:[NSNumber class]])
    {
        [self updateObjectValue:objectValue withSwitch:control];
        return;
    }
    
    if ([control isKindOfClass:[UISegmentedControl class]])
    {
        [self updateObjectValue:objectValue withSegmentedControl:control];
        return;
    }
    
    if ([control isKindOfClass:[UIDatePicker class]])
    {
        [self updateObjectValue:objectValue withDatePicker:control];
        return;
    }
}

- (void)updateTextControl:(id)control withObjectValue:(id)objectValue isDate:(BOOL)isDate isCurrency:(BOOL)isCurrency {
    if (isCurrency) {
        NSNumberFormatter *cnf = [NSNumberFormatter new];
        [cnf setNumberStyle:NSNumberFormatterCurrencyStyle];
        [control setText:[cnf stringFromNumber:objectValue]];
        cnf = nil;
    }
    else if (isDate) {
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:self.dateFormat];
        [control setText:[df stringFromDate:objectValue]];
        df = nil;
    }
    else {
        [control setText:[objectValue description]];
    }
}
- (void)updateImageView:(id)control withObjectValue:(id)objectValue {
    if ([objectValue isKindOfClass:[UIImage class]]) {
        [control setImage:objectValue];
    }
    if ([objectValue isKindOfClass:[NSString class]]) {
        [control setImage:[UIImage imageNamed:objectValue]];
    }
}
- (void)updateSlider:(id)control withObjectValue:(id)objectValue {
    [(UISlider*)control setValue:[objectValue floatValue]];
}
- (void)updateSwitch:(id)control withObjectValue:(id)objectValue {
    [control setOn:[objectValue boolValue]];
}
- (void)updateSegmentedControl:(id)control withObjectValue:(id)objectValue {
    BOOL found = NO;
    for (int i=0; i < [control numberOfSegments]; i++) {
        if ([[objectValue description] isEqualToString:[control titleForSegmentAtIndex:i]]) {
            [control setSelectedSegmentIndex:i];
            found = YES;
            break;
        }
    }
    if (!found) {
        if ([objectValue isKindOfClass:[NSNumber class]] && ([objectValue integerValue] < [control numberOfSegments])) {
            [control setSelectedSegmentIndex:[objectValue integerValue]];
        }
    }
}
- (void)updateDatePicker:(id)control withObjectValue:(id)objectValue {
    [control setDate:objectValue];
}

- (void)updateControl:(id)control withObjectValue:(id)objectValue propertyKey:(NSString*)propertyKey {
    if ([control isKindOfClass:[UITextField class]] ||
        [control isKindOfClass:[UITextView class]] ||
        [control isKindOfClass:[UILabel class]])
    {
        BOOL isDate = [objectValue isKindOfClass:[NSDate class]];
        BOOL isCurrency = NO;
        if (!isDate) {
            for (NSString *tag in self.currencyTags) {
                if ([self string:propertyKey.lowercaseString containsSubstring:tag.lowercaseString]) {
                    isCurrency = YES;
                    break;
                }
            }
        }
        [self updateTextControl:control withObjectValue:objectValue isDate:isDate isCurrency:isCurrency];
        return;
    }
    
    if ([control isKindOfClass:[UIImageView class]])
    {
        [self updateImageView:control withObjectValue:objectValue];
        return;
    }
    
    if ([control isKindOfClass:[UISlider class]] &&
        [objectValue isKindOfClass:[NSNumber class]])
    {
        [self updateSlider:control withObjectValue:objectValue];
        return;
    }
    
    if ([control isKindOfClass:[UISwitch class]] &&
        [objectValue isKindOfClass:[NSNumber class]])
    {
        [self updateSwitch:control withObjectValue:objectValue];
        return;
    }
    
    if ([control isKindOfClass:[UISegmentedControl class]])
    {
        [self updateSegmentedControl:control withObjectValue:objectValue];
        return;
    }
    
    if ([control isKindOfClass:[UIDatePicker class]])
    {
        [self updateDatePicker:control withObjectValue:objectValue];
        return;
    }
}

- (void)performUpdate:(ADROVUpdateType)updateType {
    if (self.mappedKeys == nil) {
        [self syncViewAndObject];
    }
    for (NSString *propertyKey in self.mappedKeys) {
        id control = [self.view valueForKey:propertyKey];
        id objectValue = [self.object valueForKey:propertyKey];
        
        switch (updateType) {
            case ADROVObjectUpdate:
                [self updateObjectValue:objectValue withControl:control propertyKey:propertyKey];
                break;
            case ADROVViewUpdate:
                [self updateControl:control withObjectValue:objectValue propertyKey:propertyKey];
                break;
        }
    }
}



@end
