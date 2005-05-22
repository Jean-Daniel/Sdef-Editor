//
//  SdefType.h
//  Sdef Editor
//
//  Created by Grayfox on 09/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 <!-- TYPES -->
 <!ELEMENT type EMPTY>
 <!ATTLIST type
 type       %Typename;      #REQUIRED 
 list       %yorn;          #IMPLIED
 >
 */

@class SdefTypedObject;
@interface SdefType : NSObject <NSCopying, NSCoding> {
@private
  NSString *sd_name;
  struct _sd_stFlags {
    unsigned int list:1;
    unsigned int:7;
  } sd_stFlags;
  SdefTypedObject *sd_owner;
}

- (id)init;
- (id)initWithName:(NSString *)name;

- (NSImage *)icon;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (BOOL)isList;
- (void)setList:(BOOL)list;

- (SdefTypedObject *)owner;
- (void)setOwner:(SdefTypedObject *)anObject;

@end
