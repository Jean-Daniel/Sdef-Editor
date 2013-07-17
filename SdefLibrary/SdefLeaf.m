/*
 *  SdefLeaf.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright ÔøΩ 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"
#import "SdefBase.h"

@implementation SdefLeaf

@synthesize name = _name;
@synthesize owner = _owner;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefLeaf *copy = (SdefLeaf *)NSCopyObject(self, 0, aZone);
  copy->_name = [_name copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_name forKey:@"STName"];
  [aCoder encodeConditionalObject:_owner forKey:@"STOwner"];
  [aCoder encodeBytes:(Byte *)&sd_slFlags length:sizeof(sd_slFlags) forKey:@"STFlags"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super init]) {
    NSUInteger length;
    const uint8_t *buffer = [aCoder decodeBytesForKey:@"STFlags" returnedLength:&length];
    memcpy(&sd_slFlags, buffer, length);
    
    _name = [[aCoder decodeObjectForKey:@"STName"] retain];
    _owner = [aCoder decodeObjectForKey:@"STOwner"];
  }
  return self;
}

+ (SdefObjectType)objectType {
  return kSdefUndefinedType;
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
  [_name release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {name=%@}", 
    NSStringFromClass([self class]), self, _name];
}

#pragma mark -
- (NSImage *)icon {
  return [NSImage imageNamed:@"Misc"];
}

- (void)setName:(NSString *)newName {
  if (_name != newName) {
    NSUndoManager *undo = [self undoManager];
    if (undo) {
      [undo registerUndoWithTarget:self selector:_cmd object:_name];
      [undo setActionName:NSLocalizedStringFromTable(@"Change Name", @"SdefLibrary", @"Undo Action: change name.")];
    }
    [_name release];
    _name = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [_name retain];
  }
}

- (BOOL)isEditable {
  return sd_slFlags.editable && !sd_slFlags.xinclude;
}
- (void)setEditable:(BOOL)flag {
  SPXFlagSet(sd_slFlags.editable, flag);
}

- (BOOL)isImported {
  return sd_slFlags.xinclude;
}
- (void)setImported:(BOOL)flag {
  SPXFlagSet(sd_slFlags.xinclude, flag);
}

- (BOOL)isHidden {
  return sd_slFlags.hidden;
}
- (void)setHidden:(BOOL)flag {
  flag = flag ? 1 : 0;
  if (flag != sd_slFlags.hidden) {
    [[[self undoManager] prepareWithInvocationTarget:self] setHidden:sd_slFlags.hidden];
    sd_slFlags.hidden = flag;
  }
}

- (SdefObjectType)objectType {
  return [[self class] objectType];
}

- (NSString *)objectTypeName {
  return SdefObjectTypeName(self.objectType);
}

#pragma mark Owner
/* Note: should copy change in SdefTypedOrphanObject */
//- (void)setOwner:(NSObject<SdefObject> *)anObject {
//  sd_owner = anObject;
  /* inherited flags */
//  if (sd_owner)
//    [self setEditable:[sd_owner isEditable]];
//}

- (NSString *)location {
  NSString *owner = [_owner name];
  NSString *loc = [_owner location];
  if (loc && owner) {
    return [loc stringByAppendingFormat:@":%@->%@", owner, [self objectTypeName]];
  } else if (loc) {
    return [loc stringByAppendingFormat:@"->%@", [self objectTypeName]];
  } else if (owner) {
    return [owner stringByAppendingFormat:@"->%@", [self objectTypeName]];
  } 
  return [self objectTypeName];
}

- (SdefObject *)container {
  return [_owner container];
}

- (SdefDictionary *)dictionary {
  return [_owner dictionary];
}

- (NSUndoManager *)undoManager {
  return [_owner undoManager];
}

/* Needed to be owner of an orphan object (like SdefImplementation) */
- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType {
  return [_owner firstParentOfType:aType];
}

@end
