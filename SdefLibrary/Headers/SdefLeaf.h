/*
 *  SdefLeaf.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

/* Leaves types */
enum {
  kSdefTypeAtomType      = 'Type',
  kSdefSynonymType       = 'Syno',
  kSdefCommentType       = 'Cmnt',
  kSdefXrefType          = 'Xref',
  /* XInclude */
  kSdefXIncludeType      = 'XInc',
  
  kSdefCocoaType         = 'Coco',
  kSdefDocumentationType = 'Docu',
};

@interface SdefLeaf : NSObject <SdefObject, NSCopying, NSCoding> {
@private
  NSString *sd_name;
  NSObject<SdefObject> *sd_owner;
@protected
  struct _sd_slFlags {
    unsigned int list:1;
    unsigned int html:1;
    unsigned int hidden:1;
    unsigned int xinclude:1;
    unsigned int editable:1;
    unsigned int beginning:1; // for cocoa elements
    unsigned int reserved:2;
  } sd_slFlags;
}

- (id)init;
- (id)initWithName:(NSString *)name;

- (NSUndoManager *)undoManager;

- (NSString *)objectTypeName;

- (NSImage *)icon;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (BOOL)isHidden;
- (void)setHidden:(BOOL)flag;

- (BOOL)isEditable;
- (void)setEditable:(BOOL)flag;

- (BOOL)isXIncluded;
- (void)setXIncluded:(BOOL)flag;

- (NSObject<SdefObject> *)owner;
- (void)setOwner:(NSObject<SdefObject> *)anObject;

- (SdefDictionary *)dictionary;
- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType;

@end
