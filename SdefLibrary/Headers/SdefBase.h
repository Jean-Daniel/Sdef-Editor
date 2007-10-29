/*
 *  SdefBase.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKUITreeNode.h>

enum {
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
  /* Misc */
  kSdefCocoaType           = 'Coco',
  kSdefDocumentationType   = 'Docu',
  /* XInclude */
  kSdefXIncludeType        = 'XInc',
};
typedef OSType SdefObjectType;

enum {
  kSdefVersionUndefined = 0,
  kSdefPantherVersion   = 1,
  kSdefTigerVersion     = 2,
  kSdefLeopardVersion   = 3,
};
typedef NSUInteger SdefVersion;

#pragma mark -
#pragma mark Publics Functions Declaration
SK_EXPORT
NSString *SdefNameFromCocoaName(NSString *cocoa);
SK_EXPORT
NSString *CocoaNameForSdefName(NSString *cocoa, BOOL isClass);

@class SdefObject, SdefDictionary;
@protocol SdefObject 

+ (SdefObjectType)objectType;
- (SdefObjectType)objectType;

- (SdefDictionary *)dictionary;
- (NSUndoManager *)undoManager;

- (NSString *)location;
- (NSString *)objectTypeName;

- (NSImage *)icon;
- (NSString *)name;

- (BOOL)isEditable;
- (void)setEditable:(BOOL)flag;

- (SdefObject *)container;
- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType;

@end

@class SdefDocument;
@class SdefClassManager;
@class SdefSuite, SdefCollection;
@class SdefImplementation, SdefDocumentation, SdefComment;
@interface SdefObject : SKUITreeNode <SdefObject, NSCopying, NSCoding> {
@protected
  struct _sd_soFlags {
    unsigned int xid:1;
    unsigned int xrefs:1;
    unsigned int event:1;
    unsigned int hidden:1;
    unsigned int optional:1;
    unsigned int editable:1;
    unsigned int removable:1;
    unsigned int hasSynonyms:1;
    unsigned int notinproperties:1;
    unsigned int hasDocumentation:1;
    unsigned int hasImplementation:1;
    unsigned int reserved:5;
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
- (BOOL)isHidden;
- (void)setHidden:(BOOL)isHidden;

#pragma mark Flags
- (BOOL)isEditable;
- (void)setEditable:(BOOL)flag;
- (void)setEditable:(BOOL)flag recursive:(BOOL)recu;

- (BOOL)isRemovable;
- (void)setRemovable:(BOOL)removable;

#pragma mark XRefs
- (BOOL)hasID;
- (NSString *)xmlid;
- (void)setXmlid:(NSString *)xmlid;

- (BOOL)hasXrefs;
- (NSMutableArray *)xrefs;
- (void)setXrefs:(NSArray *)xrefs;

#pragma mark Documentation
- (BOOL)hasDocumentation;
- (SdefDocumentation *)documentation;
- (void)setDocumentation:(SdefDocumentation *)doc;

#pragma mark Synonyms
- (BOOL)hasSynonyms;
- (NSMutableArray *)synonyms;
- (void)setSynonyms:(NSArray *)newSynonyms;

#pragma mark Implementation
- (BOOL)hasImplementation;
- (SdefImplementation *)impl;
- (void)setImpl:(SdefImplementation *)newImpl;

#pragma mark Comments
- (NSMutableArray *)comments;
- (void)setComments:(NSArray *)comments;

- (void)addComment:(SdefComment *)comment;

#pragma mark XInclude
- (BOOL)hasXInclude;
- (NSArray *)xincludes;
- (void)addXInclude:(id)xinclude;

@end

#pragma mark -
@interface SdefCollection : SdefObject <NSCopying, NSCoding> {
  @private
  Class sd_contentType;
  NSString *sd_elementName;
}

- (Class)contentType;
- (void)setContentType:(Class)newContentType;

- (NSString *)elementName;
- (void)setElementName:(NSString *)aName;

- (BOOL)acceptsObjectType:(SdefObjectType)aType;
@end

#pragma mark -
@interface SdefXInclude : SdefObject <NSCopying, NSCoding> {
  @private
//  NSString *sd_href;
//  NSString *sd_pointer;
  NSDictionary *sd_attrs;
}

//- (NSString *)href;
//- (void)setHref:(NSString *)aRef;
//
//- (NSString *)pointer;
//- (void)setPointer:(NSString *)aPointer;

- (NSDictionary *)attributes;
- (void)setAttributes:(NSDictionary *)attrs;

@end
