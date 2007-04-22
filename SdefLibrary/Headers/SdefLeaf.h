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
  kSdefTypeAtomType = 'Type',
  kSdefSynonymType = 'Syno',
  kSdefCommentType = 'Cmnt',
  kSdefXrefType = 'Xref',
};

@interface SdefLeaf : NSObject <SdefObject, NSCopying, NSCoding> {
@private
  NSString *sd_name;
  SdefObject *sd_owner;
@protected
  struct _sd_slFlags {
    unsigned int list:1;
    unsigned int html:1;
    unsigned int hidden:1;
    unsigned int editable:1;
    unsigned int:4;
  } sd_slFlags;
}

- (id)init;
- (id)initWithName:(NSString *)name;

- (NSUndoManager *)undoManager;

- (NSString *)objectTypeName;

- (NSImage *)icon;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (BOOL)isEditable;
- (void)setEditable:(BOOL)flag;

- (BOOL)isHidden;
- (void)setHidden:(BOOL)flag;

- (SdefObject *)owner;
- (void)setOwner:(SdefObject *)anObject;

- (SdefDictionary *)dictionary;
- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType;

@end
