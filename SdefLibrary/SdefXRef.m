/*
 *  SdefXRef.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXRef.h"

@implementation SdefXRef

@synthesize target = _target;

- (id)copyWithZone:(NSZone *)aZone {
  SdefXRef *copy = [super copyWithZone:aZone];
  copy->_target = [_target copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_target forKey:@"SXTarget"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _target = [[aCoder decodeObjectForKey:@"SXTarget"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_XRef;
}

- (void)dealloc {
  [_target release];
  [super dealloc];
}

#pragma mark -
- (void)setTarget:(NSString *)target {
  if (target != _target) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:_target];
    SPXSetterCopy(_target, target);
  }
}

@end
