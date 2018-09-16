/*
 *  SdefType.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefType.h"
#import "SdefObjects.h"

@implementation SdefType
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefType *copy = [super copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Type;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {name=%@ list=%@}", 
    NSStringFromClass([self class]), self,
 [self name], _slFlags.list ? @"YES" : @"NO"];
}

#pragma mark -
- (NSImage *)icon {
  return [NSImage imageNamed:@"Type"];
}

- (void)setName:(NSString *)aName {
  [[self owner] willChangeValueForKey:@"type"];
  [super setName:aName];
  [[self owner] didChangeValueForKey:@"type"];
}

- (BOOL)isList {
  return _slFlags.list;
}

- (void)setList:(BOOL)list {
  list = list ? 1 : 0;
  if (list != _slFlags.list) {
    [[self owner] willChangeValueForKey:@"type"];
    NSUndoManager *undo = [self undoManager];
    if (undo) {
      [[undo prepareWithInvocationTarget:self] setList:_slFlags.list];
      [undo setActionName:NSLocalizedStringFromTable(@"Check/Uncheck List", @"SdefLibrary", @"Undo Action: Check/Uncheck List.")];
    }
    _slFlags.list = list;
    [[self owner] didChangeValueForKey:@"type"];
  }
}

@end
