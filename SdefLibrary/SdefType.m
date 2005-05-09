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

#pragma mark -
- (NSString *)name {
  return sd_name;
}

- (void)setName:(NSString *)newName {
  if (sd_name != newName) {
    [sd_name release];
    sd_name = [newName copy];
  }
}

- (BOOL)isList {
  return sd_stFlags.list;
}

- (void)setList:(BOOL)list {
  list = list ? 1 : 0;
  if (list != sd_stFlags.list) {
    sd_stFlags.list = list;
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
