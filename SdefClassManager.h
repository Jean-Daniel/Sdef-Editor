//
//  SdefClassManager.h
//  SDef Editor
//
//  Created by Grayfox on 17/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTreeNode.h"

@class SdefSuite, SdefObject, SdefEnumeration, SdefClass, SdefVerb, SdefDocument, SdefDictionary;
@interface SdefClassManager : NSObject {
@private
  SdefDocument *sd_document;
  NSMutableArray *sd_classes, *sd_commands, *sd_events, *sd_types;
}

+ (BOOL)isBaseType:(NSString *)type;

- (id)initWithDocument:(SdefDocument *)aDocument;

- (void)addDictionary:(SdefDictionary *)aDico;
- (void)removeDictionary:(SdefDictionary *)aDico;

- (void)addSuite:(SdefSuite *)aSuite;
- (void)removeSuite:(SdefSuite *)aSuite;

/*!
    @method     types
    @result     Returns all types name including base types.
*/
- (NSArray *)types;
/*!
    @method     sdefTypes
    @abstract   Returns all types whitout base types (ie. classes and enumeration).
*/
- (NSArray *)sdefTypes;
- (NSArray *)classes;

- (NSArray *)commands;
- (NSArray *)events;

- (id)typeWithName:(NSString *)name;
- (SdefClass *)classWithName:(NSString *)name;
- (SdefVerb *)eventWithName:(NSString *)name;
- (SdefVerb *)commandWithName:(NSString *)name;
- (SdefEnumeration *)enumerationWithName:(NSString *)name;

- (NSArray *)subclassesOfClass:(SdefClass *)aClass;
- (SdefClass *)superClassOfClass:(SdefClass *)aClass;

#pragma mark -
#pragma mark Cocoa Additions
- (NSString *)sdefTypeForCocoaType:(NSString *)cocoaType;
- (SdefVerb *)verbWithCocoaName:(NSString *)cocoaName inSuite:(NSString *)suite;
- (SdefClass *)sdefClassWithCocoaClass:(NSString *)cocoaClass inSuite:(NSString *)suite;
- (SdefObject *)sdefTypeWithCocoaType:(NSString *)cocoaType inSuite:(NSString *)suite;

#pragma mark -
#pragma mark 'aete' Additions
- (NSString *)sdefTypeForAeteType:(NSString *)aType;
- (SdefVerb *)verbWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode;
- (SdefClass *)sdefClassWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode;
- (SdefObject *)sdefTypeWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode;

@end
