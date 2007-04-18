/*
 *  SdefBase.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKUITreeNode.h>

enum {
  kSdefUndefinedType		= 0,
  kSdefDictionaryType 		= 'Dico',
  kSdefSuiteType			= 'Suit',
  kSdefCollectionType		= 'Cole',
  /* Class */
  kSdefClassType			= 'Clas',
  kSdefContentsType			= 'Cont',
  kSdefPropertyType			= 'Prop',
  kSdefElementType			= 'Elmt',
  kSdefRespondsToType		= 'ReTo',
  /* Verbs */
  kSdefVerbType				= 'Verb',
  kSdefParameterType		= 'Para',
  kSdefDirectParameterType	= 'DiPa',
  kSdefResultType			= 'Resu',
  /* Enumeration */
  kSdefEnumerationType		= 'Enum',
  kSdefEnumeratorType		= 'Enor',
  /* Value */
  kSdefValueType			= 'Valu',
  kSdefRecordType			= 'Reco',
  /* Misc */
  kSdefCocoaType			= 'Coco',
  kSdefDocumentationType	= 'Docu'
};
typedef OSType SdefObjectType;

enum {
  kSdefPantherVersion = 1,
  kSdefTigerVersion   = 2,
  kSdefLeopardVersion = 3,
};
typedef NSInteger SdefVersion;

#pragma mark -
#pragma mark Publics Functions Declaration
SK_EXPORT
NSString *SdefNameCreateWithCocoaName(NSString *cocoa);
SK_EXPORT
NSString *CocoaNameForSdefName(NSString *cocoa, BOOL isClass);

@class SdefDocument;
@class SdefClassManager;
@class SdefImplementation, SdefDocumentation;
@class SdefDictionary, SdefSuite, SdefCollection;
@interface SdefObject : SKUITreeNode <NSCopying, NSCoding> {
@protected
  struct _sd_soFlags {
    unsigned int html:1;
    unsigned int xrefs:1;
    unsigned int hidden:1;
    unsigned int optional:1;
    unsigned int editable:1;
    unsigned int removable:1;
    unsigned int hasSynonyms:1;
    unsigned int notinproperties:1;
    unsigned int hasDocumentation:1;
    unsigned int hasImplementation:1;
    unsigned int reserved:6;
  } sd_soFlags;
@private
  NSMutableArray *sd_ignore;
  NSMutableArray *sd_comments;
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
- (id)firstParentOfType:(SdefObjectType)aType;

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
- (void)addComment:(NSString *)comment;
- (void)removeCommentAtIndex:(NSUInteger)index;

#pragma mark Ignore
- (BOOL)hasIgnore;
- (NSMutableArray *)ignores;
- (void)addIgnore:(id)anObject;
- (void)setIgnores:(NSArray *)anArray;
- (void)removeIgnoreAtIndex:(NSUInteger)index;

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
@interface SdefOrphanObject : SdefObject <NSCopying, NSCoding> {
  @private
  SdefObject *sd_owner;
}

- (id)owner;
- (void)setOwner:(SdefObject *)anObject;

@end
