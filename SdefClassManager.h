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

- (id)initWithDocument:(SdefDocument *)aDocument;

- (void)addDictionary:(SdefDictionary *)aDico;
- (void)removeDictionary:(SdefDictionary *)aDico;

- (void)addSuite:(SdefSuite *)aSuite;
- (void)removeSuite:(SdefSuite *)aSuite;

- (NSArray *)types;
- (NSArray *)classes;

- (NSArray *)commands;
- (NSArray *)events;

- (SdefClass *)classWithName:(NSString *)name;
- (NSArray *)subclassesOfClass:(SdefClass *)aClass;
- (SdefClass *)superClassOfClass:(SdefClass *)aClass;

- (SdefEnumeration *)enumerationWithName:(NSString *)name;

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
