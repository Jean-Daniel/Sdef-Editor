//
//  SdefLeave.h
//  Sdef Editor
//
//  Created by Grayfox on 22/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SdefObject;
@interface SdefLeave : NSObject <NSCopying, NSCoding> {
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

- (NSString *)objectTypeName;

- (NSImage *)icon;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (SdefObject *)owner;
- (void)setOwner:(SdefObject *)anObject;

@end
