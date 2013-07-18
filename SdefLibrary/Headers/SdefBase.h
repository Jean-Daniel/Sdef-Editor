/*
 *  SdefBase.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <WonderBox/WBUITreeNode.h>

typedef NS_ENUM(OSType, SdefObjectType) {
  kSdefUndefinedType       = 0,
  kSdefDictionaryType      = 'Dico',
  kSdefSuiteType           = 'Suit',
  kSdefCollectionType      = 'Cole',
  /* Class */
  kSdefClassType           = 'Clas',
  kSdefContentsType        = 'Cont',
  kSdefPropertyType        = 'Prop',
  kSdefElementType         = 'Elmt',
  kSdefRespondsToType      = 'ReTo',
  /* Verbs */
  kSdefVerbType            = 'Verb',
  kSdefParameterType       = 'Para',
  kSdefDirectParameterType = 'DiPa',
  kSdefResultType          = 'Resu',
  /* Enumeration */
  kSdefEnumerationType     = 'Enum',
  kSdefEnumeratorType      = 'Enor',
  /* Value */
  kSdefValueType           = 'Valu',
  kSdefRecordType          = 'Reco',

  /* Leaves types */
  kSdefAccessGroupType   = 'Agpr',
  kSdefTypeAtomType      = 'Type',
  kSdefSynonymType       = 'Syno',
  kSdefCommentType       = 'Cmnt',
  kSdefXrefType          = 'Xref',
  /* XInclude */
  kSdefXIncludeType      = 'XInc',

  kSdefCocoaType         = 'Coco',
  kSdefDocumentationType = 'Docu',
};

typedef NS_ENUM(NSUInteger, SdefVersion) {
  kSdefVersionUndefined = 0,
  kSdefPantherVersion   = 1,
  kSdefTigerVersion     = 2,
  kSdefLeopardVersion   = 3,
  kSdefMountainLionVersion   = 4,
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
    unsigned int notinproperties:1;
    unsigned int hasDocumentation:1;
    unsigned int hasImplementation:1;
    unsigned int reserved:4;
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

#pragma mark Documentation
- (BOOL)hasDocumentation;
@property(nonatomic, retain) SdefDocumentation *documentation;

#pragma mark Synonyms
- (BOOL)hasSynonyms;
@property(nonatomic, copy) NSArray *synonyms;

#pragma mark Implementation
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
@interface SdefCollection : SdefObject <NSCopying, NSCoding> {
  @private
  Class _contentType;
  NSString *_elementName;
}

@property(nonatomic, assign) Class contentType;
@property(nonatomic, copy) NSString *elementName;

- (BOOL)acceptsObjectType:(SdefObjectType)aType;
@end

