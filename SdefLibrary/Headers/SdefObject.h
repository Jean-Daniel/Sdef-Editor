//
//  SdefObject.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTreeNode.h"

typedef enum {
  kSDUndefinedType		 	= 0,
  kSDDictionaryType 		= 'Dico',
  kSDSuiteType				= 'Suit',
  kSDCollectionType			= 'Cole',
  kSDImportsType			= 'Impo',
  /* Class */
  kSDClassType				= 'Clas',
  kSDContentsType			= 'Cont',
  kSDPropertyType			= 'Prop',
  kSDElementType			= 'Elmt',
  kSDRespondsToType			= 'ReTo',
  /* Verbs */
  kSDVerbType				= 'Verb',
  kSDParameterType			= 'Para',
  kSDDirectParameterType	= 'DiPa',
  kSDResultType				= 'Resu',
  /* Enumeration */
  kSDEnumerationType		= 'Enum',
  kSDEnumeratorType			= 'Enor',
  /* Misc */
  kSDCocoaType				= 'Coco',
  kSDSynonymType			= 'Syno',
  kSDDocumentationType		= 'Docu'
} SDObjectType;

@class SdefXMLNode, SdefDocumentation, SdefCollection, SdefDocument;
@interface SdefObject : SKTreeNode {
@protected
  NSMutableArray *sd_childComments;
@private
  NSImage *sd_icon;
  NSString *sd_name;
  SdefCollection *sd_synonyms;
  struct {
    unsigned int editable:1;
    unsigned int removable:1;
    unsigned int reserved:6;
  } sd_flags;
  NSMutableArray *sd_comments;
  SdefDocumentation *sd_documentation;
}

+ (SDObjectType)objectType;

+ (NSString *)defaultName;
+ (NSString *)defaultIconName;

+ (id)emptyNode;
+ (id)nodeWithName:(NSString *)newName;

- (id)initEmpty;
- (id)initWithName:(NSString *)newName;
- (id)initWithAttributes:(NSDictionary *)attributes;

- (SDObjectType)objectType;
- (void)createContent;
- (void)createSynonyms;
- (SdefDocument *)document;

#pragma mark -
- (NSImage *)icon;
- (void)setIcon:(NSImage *)newIcon;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (BOOL)isEditable;
- (void)setEditable:(BOOL)flag;
- (void)setEditable:(BOOL)flag recursive:(BOOL)recu;

- (BOOL)isRemovable;
- (void)setRemovable:(BOOL)removable;

- (BOOL)hasSynonyms;
- (BOOL)hasDocumentation;

- (SdefDocumentation *)documentation;
- (void)setDocumentation:(SdefDocumentation *)doc;

- (SdefCollection *)synonyms;
- (void)setSynonyms:(SdefCollection *)newSynonyms;

#pragma mark -
- (NSArray *)comments;
- (void)setComments:(NSArray *)comments;
- (void)addComment:(NSString *)comment;
- (void)removeCommentAtIndex:(unsigned)index;

#pragma mark -
- (void)setAttributes:(NSDictionary *)attrs;

- (SdefXMLNode *)xmlNode;
- (NSString *)xmlElementName;

@end

#pragma mark -
@interface SdefCollection : SdefObject {
  Class _contentType;
  NSString *sd_elementName;
}

- (Class)contentType;
- (void)setContentType:(Class)newContentType;

- (NSString *)elementName;
- (void)setElementName:(NSString *)aName;
@end

#pragma mark -
@class SdefImplementation;
@interface SdefTerminologyElement : SdefObject {
@private
  BOOL sd_hidden;
  NSString *sd_code; 
  NSString *sd_desc;
  SdefImplementation *sd_impl;
}

- (SdefImplementation *)impl;
- (void)setImpl:(SdefImplementation *)newImpl;

- (BOOL)isHidden;
- (void)setHidden:(BOOL)newHidden;

- (NSString *)codeStr;
- (void)setCodeStr:(NSString *)str;

- (NSString *)desc;
- (void)setDesc:(NSString *)newDesc;

@end

#pragma mark -
@interface SdefImports : SdefCollection {  
}

@end
