/*
 *  SdefLeaf.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

@interface SdefLeaf : NSObject <SdefObject, NSCopying, NSCoding> {
@private
  NSString *_name;
@protected
  struct _sd_slFlags {
    unsigned int list:1;
    unsigned int html:1;
    unsigned int hidden:1;
    unsigned int xinclude:1;
    unsigned int editable:1;
    unsigned int beginning:1; // for cocoa elements
    unsigned int reserved:2;
  } _slFlags;
}

- (id)init;
- (id)initWithName:(NSString *)name;

- (NSUndoManager *)undoManager;

- (NSString *)objectTypeName;

- (NSImage *)icon;

@property(nonatomic, copy) NSString *name;

@property(nonatomic, getter=isHidden) BOOL hidden;

@property(nonatomic, assign) NSObject<SdefObject> *owner;

- (SdefDictionary *)dictionary;
- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType;

@end
