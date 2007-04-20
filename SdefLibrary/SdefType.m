/*
 *  SdefType.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
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
- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {name=%@ list=%@}", 
    NSStringFromClass([self class]), self,
 [self name], sd_slFlags.list ? @"YES" : @"NO"];
}

#pragma mark -
- (NSImage *)icon {
  return [NSImage imageNamed:@"Type"];
}
- (NSString *)objectTypeName {
  return @"type";
}

- (void)setName:(NSString *)aName {
  [[self owner] willChangeValueForKey:@"type"];
  [super setName:aName];
  [[self owner] didChangeValueForKey:@"type"];
}

- (BOOL)isList {
  return sd_slFlags.list;
}

- (void)setList:(BOOL)list {
  list = list ? 1 : 0;
  if (list != sd_slFlags.list) {
    [[self owner] willChangeValueForKey:@"type"];
    NSUndoManager *undo = [self undoManager];
    if (undo) {
      [[undo prepareWithInvocationTarget:self] setList:sd_slFlags.list];
      [undo setActionName:NSLocalizedStringFromTable(@"Check/Uncheck List", @"SdefLibrary", @"Undo Action: Check/Uncheck List.")];
    }
    sd_slFlags.list = list;
    [[self owner] didChangeValueForKey:@"type"];
  }
}

@end
