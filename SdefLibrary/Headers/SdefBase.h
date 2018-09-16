/*
 *  SdefBase.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import <WonderBox/WBUITreeNode.h>

typedef NS_ENUM(uint32_t, SdefObjectType) {
  kSdefType_Undefined = 0,

  kSdefType_Dictionary = 'Dico',
  kSdefType_Suite = 'Suit',
  // Top level Objects
  kSdefType_Class = 'Clas', // + class extension
  kSdefType_Command = 'Verb', // + event
  kSdefType_ValueType = 'Valu',
  kSdefType_RecordType = 'Reco',
  kSdefType_Enumeration = 'Enum',

  // Enumeration
  kSdefType_Enumerator = 'Enor',

  // Class Objects
  kSdefType_Element = 'Elmt',
  kSdefType_Property = 'Prop',
  kSdefType_Contents = 'Cont',
  kSdefType_RespondsTo = 'ReTo',

  // Command Objects
  kSdefType_DirectParameter = 'DiPa',
  kSdefType_Parameter = 'Para',
  kSdefType_Result = 'Resu',

  // Common Objects
  kSdefType_XInclude = 'XInc', // xinclude reference (href + pointer)

  kSdefType_Type = 'Type', // type element used wherever a type attribute is allowed
  kSdefType_XRef = 'Xref',
  kSdefType_Synonym = 'Syno',
  kSdefType_AccessGroup = 'Agpr',
  kSdefType_Documentation = 'Docu',
  kSdefType_Implementation = 'Coco', // Cocoa element

  // internal type. to be removed.
  kSdefType_Comment = 'Cmnt',
  kSdefType_Collection = 'Cole',
};

typedef NS_ENUM(NSUInteger, SdefVersion) {
  kSdefVersionUndefined    = 0,
  kSdefPantherVersion      = 1,
  kSdefTigerVersion        = 2,
  kSdefLeopardVersion      = 3,
  kSdefMountainLionVersion = 4,
};

#pragma mark -
#pragma mark Publics Functions Declaration
WB_EXPORT
NSString *SdefNameFromCocoaName(NSString *cocoa);
WB_EXPORT
NSString *CocoaNameForSdefName(NSString *cocoa, BOOL isClass);

WB_EXPORT
NSString *SdefObjectTypeName(SdefObjectType type);

@class SdefObject, SdefDictionary;
@protocol SdefObject <NSObject>

+ (SdefObjectType)objectType;
- (SdefObjectType)objectType;

- (SdefDictionary *)dictionary;
- (NSUndoManager *)undoManager;

- (NSString *)location;
- (NSString *)objectTypeName;

- (NSImage *)icon;
- (NSString *)name;

@property(nonatomic, getter = isEditable) BOOL editable;
@property(nonatomic, getter = isImported) BOOL imported; // xinclude reference

- (SdefObject *)container;
- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType;

@end

@class SdefDocument;
@class SdefAccessGroup;
@class SdefClassManager;
@class SdefSuite, SdefCollection;
@class SdefImplementation, SdefDocumentation, SdefComment;
@interface SdefObject : WBUITreeNode <SdefObject, NSCopying, NSCoding> {
@protected
  struct _sd_soFlags {
    unsigned int xid:1;
    unsigned int xrefs:1;
    unsigned int event:1;
    unsigned int hidden:1;
    unsigned int xinclude:1;
    unsigned int optional:1;
    unsigned int editable:1;
    unsigned int removable:1;
    unsigned int hasSynonyms:1;
    unsigned int hasAccessGroup:1;
    unsigned int notinproperties:1;
    unsigned int hasDocumentation:1;
    unsigned int hasImplementation:1;
    unsigned int reserved:3;
  } sd_soFlags;
@private
  NSMutableArray *sd_comments;
  NSMutableArray *sd_includes;
}

#pragma mark API
- (void)sdefInit;

+ (SdefObjectType)objectType;
- (SdefObjectType)objectType;

+ (NSString *)defaultName;
+ (NSString *)defaultIconName;

#pragma mark Parents
- (SdefDocument *)document;
- (NSUndoManager *)undoManager;
- (SdefClassManager *)classManager;

- (SdefSuite *)suite;
- (SdefDictionary *)dictionary;

- (SdefObject *)container;
- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType;

#pragma mark Strings Representations
- (NSString *)location;
- (NSString *)objectTypeName;

#pragma mark Accessors
@property(nonatomic) BOOL hidden;

#pragma mark Flags
- (void)setEditable:(BOOL)flag recursive:(BOOL)recu;

@property(nonatomic, getter = isRemovable) BOOL removable;

#pragma mark XRefs
- (BOOL)hasID;
@property(nonatomic, copy) NSString *xmlid;

- (BOOL)hasXrefs;
@property(nonatomic, copy) NSArray *xrefs;

- (BOOL)hasDocumentation;
@property(nonatomic, retain) SdefDocumentation *documentation;

- (BOOL)hasSynonyms;
@property(nonatomic, copy) NSArray *synonyms;

- (BOOL)hasAccessGroup;
@property(nonatomic, retain) SdefAccessGroup *accessGroup;

- (BOOL)hasImplementation;
@property(nonatomic, retain) SdefImplementation *impl;


#pragma mark Comments
@property(nonatomic, copy) NSArray *comments;
- (void)addComment:(SdefComment *)comment;

#pragma mark XInclude
- (BOOL)hasXInclude;
- (NSArray *)xincludes;
- (void)addXInclude:(id)xinclude;
/* returns YES if contains at least one xinclude element */
- (BOOL)containsXInclude;

@end

#pragma mark -
@interface SdefCollection : SdefObject <NSCopying, NSCoding>

@property(nonatomic, assign) Class contentType;
@property(nonatomic, copy) NSString *elementName;

- (BOOL)acceptsObjectType:(SdefObjectType)aType;
@end

