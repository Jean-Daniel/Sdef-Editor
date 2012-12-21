/*
 *  SdefClassManager.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <WonderBox/WBTreeNode.h>

@class SdefValue, SdefRecord, SdefEnumeration;
@class SdefSuite, SdefObject, SdefClass, SdefVerb, SdefDocument, SdefDictionary;
@interface SdefClassManager : NSObject {
@private
  NSHashTable *sd_dicts;
  SdefDocument *sd_document;
  struct _sd_cmFlags {
    unsigned int sortType:1;
    unsigned int sortClass:1;
    unsigned int sortEvent:1;
    unsigned int sortCommand:1;
    unsigned int reserved:28;
  } sd_cmFlags;
  NSMutableArray *sd_classes, *sd_commands, *sd_events, *sd_types;
}

+ (BOOL)isBaseType:(NSString *)type;

- (id)initWithDocument:(SdefDocument *)aDocument;

- (void)setDocument:(SdefDocument *)aDoc;

- (void)addDictionary:(SdefDictionary *)aDico;
- (void)removeDictionary:(SdefDictionary *)aDico;

- (void)addSuite:(SdefSuite *)aSuite;
- (void)removeSuite:(SdefSuite *)aSuite;

- (void)addClass:(SdefClass *)aClass;
- (void)removeClass:(SdefClass *)aClass;

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
- (SdefVerb *)verbWithIdentifier:(NSString *)identifier;
- (SdefVerb *)eventWithIdentifier:(NSString *)identifier;
- (SdefVerb *)commandWithIdentifier:(NSString *)identifier;
- (SdefValue *)valueWithName:(NSString *)name;
- (SdefRecord *)recordWithName:(NSString *)name;
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

