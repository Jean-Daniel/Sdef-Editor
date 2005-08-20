//
//  SdefLeave.m
//  Sdef Editor
//
//  Created by Grayfox on 22/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefLeave.h"
#import "SdefBase.h"

@implementation SdefLeave
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefLeave *copy = NSCopyObject(self, 0, aZone);
  copy->sd_name = [sd_name copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:sd_name forKey:@"STName"];
  [aCoder encodeConditionalObject:sd_owner forKey:@"STOwner"];
  [aCoder encodeBytes:(Byte *)&sd_slFlags length:sizeof(sd_slFlags) forKey:@"STFlags"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super init]) {
    unsigned length;
    const uint8_t *buffer = [aCoder decodeBytesForKey:@"STFlags" returnedLength:&length];
    memcpy(&sd_slFlags, buffer, length);
    
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
  return [NSString stringWithFormat:@"<%@ %p> {name=%@}", 
    NSStringFromClass([self class]), self, sd_name];
}

#pragma mark -
- (NSImage *)icon {
  return [NSImage imageNamed:@"Misc"];
}

- (NSString *)name {
  return sd_name;
}

- (void)setName:(NSString *)newName {
  if (sd_name != newName) {
    NSUndoManager *undo = [sd_owner undoManager];
    if (undo) {
      [undo registerUndoWithTarget:self selector:_cmd object:sd_name];
      [undo setActionName:NSLocalizedStringFromTable(@"Change Name", @"SdefLibrary", @"Undo Action: change name.")];
    }
    [sd_name release];
    sd_name = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [sd_name retain];
  }
}

- (NSString *)objectTypeName {
  return nil;
}

#pragma mark Owner
- (SdefObject *)owner {
  return sd_owner;
}

- (void)setOwner:(SdefObject *)anObject {
  sd_owner = anObject;
}

/* Needed to be owner of an orphan object (like SdefImplementation) */
- (id)firstParentOfType:(SdefObjectType)aType {
  return [sd_owner firstParentOfType:aType];
}

@end
