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
  SdefLeaf *copy = [[SdefLeaf alloc] initWithName:self.name];
  copy->_slFlags = _slFlags;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_name forKey:@"STName"];
  [aCoder encodeConditionalObject:_owner forKey:@"STOwner"];
  [aCoder encodeBytes:(Byte *)&_slFlags length:sizeof(_slFlags) forKey:@"STFlags"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super init]) {
    NSUInteger length;
    const uint8_t *buffer = [aCoder decodeBytesForKey:@"STFlags" returnedLength:&length];
    memcpy(&_slFlags, buffer, length);
    
    _name = [aCoder decodeObjectForKey:@"STName"];
    _owner = [aCoder decodeObjectForKey:@"STOwner"];
  }
  return self;
}

+ (SdefObjectType)objectType {
  return kSdefType_Undefined;
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
    _name = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  }
}

- (BOOL)isEditable {
  return _slFlags.editable && !_slFlags.xinclude;
}
- (void)setEditable:(BOOL)flag {
  SPXFlagSet(_slFlags.editable, flag);
}

- (BOOL)isImported {
  return _slFlags.xinclude;
}
- (void)setImported:(BOOL)flag {
  SPXFlagSet(_slFlags.xinclude, flag);
}

- (BOOL)isHidden {
  return _slFlags.hidden;
}
- (void)setHidden:(BOOL)flag {
  flag = flag ? 1 : 0;
  if (flag != _slFlags.hidden) {
    [[[self undoManager] prepareWithInvocationTarget:self] setHidden:_slFlags.hidden];
    _slFlags.hidden = flag;
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
