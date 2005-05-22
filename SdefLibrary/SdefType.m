//
//  SdefType.m
//  Sdef Editor
//
//  Created by Grayfox on 09/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefType.h"
#import "SdefObjects.h"

@implementation SdefType
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefType *copy = NSCopyObject(self, 0, aZone);
  copy->sd_name = [sd_name copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:sd_name forKey:@"STName"];
  [aCoder encodeConditionalObject:sd_owner forKey:@"STOwner"];
  [aCoder encodeBytes:(Byte *)&sd_stFlags length:sizeof(sd_stFlags) forKey:@"STFlags"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super init]) {
    unsigned length;
    const uint8_t *buffer = [aCoder decodeBytesForKey:@"STFlags" returnedLength:&length];
    memcpy(&sd_stFlags, buffer, length);
    
    sd_name = [[aCoder decodeObjectForKey:@"STName"] retain];
    sd_owner = [aCoder decodeObjectForKey:@"STOwner"];
  }
  return self;
}

- (id)init {
  return [self initWithName:nil];
}

- (id)initWithName:(NSString *)name {
  if (self = [super init]) {
    [self setName:name];
  }
  return self;
}

- (void)dealloc {
  [sd_name release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {name=%@ list=%@}", 
    NSStringFromClass([self class]), self,
 sd_name, sd_stFlags.list ? @"YES" : @"NO"];
}

#pragma mark -
- (NSImage *)icon {
  return [NSImage imageNamed:@"Type"];
}

- (NSString *)name {
  return sd_name;
}

- (void)setName:(NSString *)newName {
  if (sd_name != newName) {
    NSUndoManager *undo = [sd_owner undoManager];
    if (undo) {
      [undo registerUndoWithTarget:self selector:_cmd object:sd_name];
      [undo setActionName:@"Change Type"];
    }
    [sd_owner willChangeValueForKey:@"type"];
    [sd_name release];
    sd_name = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [sd_name retain];
    [sd_owner didChangeValueForKey:@"type"];
  }
}

- (BOOL)isList {
  return sd_stFlags.list;
}

- (void)setList:(BOOL)list {
  list = list ? 1 : 0;
  if (list != sd_stFlags.list) {
    [sd_owner willChangeValueForKey:@"type"];
    NSUndoManager *undo = [sd_owner undoManager];
    if (undo) {
      [[undo prepareWithInvocationTarget:self] setList:sd_stFlags.list];
      [undo setActionName:@"Change Type"];
    }
    sd_stFlags.list = list;
    [sd_owner didChangeValueForKey:@"type"];
  }
}

#pragma mark Owner
- (SdefTypedObject *)owner {
  return sd_owner;
}

- (void)setOwner:(SdefTypedObject *)anObject {
  sd_owner = anObject;
}

@end
