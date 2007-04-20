/*
 *  SdefLeaf.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class SdefObject;
@interface SdefLeaf : NSObject <NSCopying, NSCoding> {
@private
  NSString *sd_name;
  SdefObject *sd_owner;
@protected
  struct _sd_slFlags {
    unsigned int list:1;
    unsigned int hidden:1;
    unsigned int:6;
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

- (SdefObject *)owner;
- (void)setOwner:(SdefObject *)anObject;

@end
