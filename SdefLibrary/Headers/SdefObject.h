//
//  SdefObject.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SKTreeNode.h"

typedef enum {
  kSdefUndefinedType		= 0,
  kSdefDictionaryType 		= 'Dico',
  kSdefSuiteType			= 'Suit',
  kSdefCollectionType		= 'Cole',
  kSdefImportsType			= 'Impo',
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
  /* Misc */
  kSdefCocoaType			= 'Coco',
  kSdefSynonymType			= 'Syno',
  kSdefDocumentationType	= 'Docu'
} SdefObjectType;


extern NSString * const SdefNewTreeNode;
extern NSString * const SdefRemovedTreeNode;
extern NSString * const SdefObjectDidAppendChildNotification;
extern NSString * const SdefObjectWillRemoveChildNotification;
extern NSString * const SdefObjectDidRemoveChildNotification;
extern NSString * const SdefObjectWillRemoveAllChildrenNotification;
extern NSString * const SdefObjectDidRemoveAllChildrenNotification;

extern NSString * const SdefObjectWillChangeNameNotification;
extern NSString * const SdefObjectDidChangeNameNotification;

extern NSString *SdefNameForCocoaName(NSString *cocoa);
extern NSString *CocoaNameForSdefName(NSString *cocoa, BOOL isClass);

@class SdefXMLNode, SdefSuite, SdefDocumentation, SdefCollection, SdefDocument;
@interface SdefObject : SKTreeNode <NSCopying, NSCoding> {
@protected
  struct {
    unsigned int hidden:1;
    unsigned int optional:1;
    unsigned int editable:1;
    unsigned int removable:1;
    unsigned int hasSynonyms:1;
    unsigned int notInProperties:1;
    unsigned int hasDocumentation:1;
    unsigned int hasImplementation:1;
  } sd_flags;
@private
  NSImage *sd_icon;
  NSString *sd_name;
  SdefCollection *sd_synonyms;
  NSMutableArray *sd_comments;
  SdefDocumentation *sd_documentation;
}

+ (SdefObjectType)objectType;

+ (NSString *)defaultName;
+ (NSString *)defaultIconName;

+ (id)emptyNode;
+ (id)nodeWithName:(NSString *)newName;

- (id)initEmpty;
- (id)initWithName:(NSString *)newName;

- (SdefObjectType)objectType;
- (void)createContent;

#pragma mark -
- (SdefSuite *)suite;
- (id)firstParentOfType:(SdefObjectType)aType;

- (SdefDocument *)document;

- (NSImage *)icon;
- (void)setIcon:(NSImage *)newIcon;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (BOOL)isEditable;
- (void)setEditable:(BOOL)flag;
- (void)setEditable:(BOOL)flag recursive:(BOOL)recu;

- (BOOL)isRemovable;
- (void)setRemovable:(BOOL)removable;

- (BOOL)hasDocumentation;
- (SdefDocumentation *)documentation;
- (void)setDocumentation:(SdefDocumentation *)doc;

- (BOOL)hasSynonyms;
- (SdefCollection *)synonyms;
- (void)setSynonyms:(SdefCollection *)newSynonyms;

#pragma mark -
- (NSArray *)comments;
- (void)setComments:(NSArray *)comments;
- (void)addComment:(NSString *)comment;
- (void)removeCommentAtIndex:(unsigned)index;

@end

#pragma mark -
@interface SdefCollection : SdefObject <NSCopying, NSCoding> {
  Class sd_contentType;
  NSString *sd_elementName;
}

- (Class)contentType;
- (void)setContentType:(Class)newContentType;

- (NSString *)elementName;
- (void)setElementName:(NSString *)aName;
@end

#pragma mark -
@class SdefImplementation;
@interface SdefTerminologyElement : SdefObject <NSCopying, NSCoding> {
@private
  NSString *sd_code; 
  NSString *sd_desc;
  SdefImplementation *sd_impl;
}

- (SdefImplementation *)impl;
- (void)setImpl:(SdefImplementation *)newImpl;

- (BOOL)isHidden;
- (void)setHidden:(BOOL)isHidden;

- (NSString *)codeStr;
- (void)setCodeStr:(NSString *)str;

- (NSString *)desc;
- (void)setDesc:(NSString *)newDesc;

- (NSString *)cocoaKey;
- (NSString *)cocoaName;
- (NSString *)cocoaClass;
- (NSString *)cocoaMethod;

@end

#pragma mark -
@interface SdefOrphanObject : SdefObject <NSCopying, NSCoding> {
@private
  SdefObject *sd_owner;
}

- (id)owner;
- (void)setOwner:(SdefObject *)anObject;

@end

#pragma mark -
@interface SdefImports : SdefCollection <NSCopying, NSCoding> {  
}

@end
