//
//  SdefBase.h
//  Sdef Editor
//
//  Created by Grayfox on 09/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SKTreeNode.h"

typedef enum {
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
} SdefObjectType;

typedef enum {
  kSdefPantherVersion,
  kSdefTigerVersion,
} SdefVersion;

extern NSString * const SdefNewTreeNode;
extern NSString * const SdefRemovedTreeNode;
extern NSString * const SdefObjectDidAppendChildNotification;
extern NSString * const SdefObjectWillRemoveChildNotification;
extern NSString * const SdefObjectDidRemoveChildNotification;
extern NSString * const SdefObjectWillRemoveAllChildrenNotification;
extern NSString * const SdefObjectDidRemoveAllChildrenNotification;
extern NSString * const SdefObjectDidSortChildrenNotification;

extern NSString * const SdefObjectWillChangeNameNotification;
extern NSString * const SdefObjectDidChangeNameNotification;

#pragma mark -
#pragma mark Publics Functions Declaration
extern NSString *SdefNameCreateWithCocoaName(NSString *cocoa);
extern NSString *CocoaNameForSdefName(NSString *cocoa, BOOL isClass);

@class SdefDocument;
@class SdefClassManager;
@class SdefImplementation, SdefDocumentation;
@class SdefDictionary, SdefSuite, SdefCollection;
@interface SdefObject : SKTreeNode {
@protected
  struct _sd_soFlags {
    unsigned int hidden:1;
    unsigned int optional:1;
    unsigned int editable:1;
    unsigned int reserved:1;
    unsigned int removable:1;
    unsigned int hasSynonyms:1;
    unsigned int hasDocumentation:1;
    unsigned int hasImplementation:1;
  } sd_soFlags;
@private
  NSImage *sd_icon;
  NSString *sd_name;
  NSMutableArray *sd_ignore;
  NSMutableArray *sd_comments;
}

+ (id)nodeWithName:(NSString *)newName;
- (id)initWithName:(NSString *)newName;

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

- (void)sortByName;

#pragma mark Accessors
- (NSImage *)icon;
- (void)setIcon:(NSImage *)newIcon;

- (NSString *)name;
- (void)setName:(NSString *)newName;

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
- (void)removeCommentAtIndex:(unsigned)index;

#pragma mark Ignore
- (BOOL)hasIgnore;
- (NSMutableArray *)ignores;
- (void)addIgnore:(id)anObject;
- (void)setIgnores:(NSArray *)anArray;
- (void)removeIgnoreAtIndex:(unsigned)index;

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
