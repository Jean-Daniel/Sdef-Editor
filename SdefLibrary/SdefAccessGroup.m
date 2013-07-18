/*
 *  SdefAccessGroup.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefAccessGroup.h"

@implementation SdefAccessGroup

@synthesize access = _access;

- (id)copyWithZone:(NSZone *)aZone {
  SdefAccessGroup *copy = [super copyWithZone:aZone];
  copy->_access = _access;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInt32:_access forKey:@"SAGAccess"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _access = [aCoder decodeInt32ForKey:@"SAGAccess"];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_AccessGroup;
}

#pragma mark -
- (NSString *)identifier { return self.name; }
- (void)setIdentifier:(NSString *)identifier { self.name = identifier; }

- (void)setAccess:(uint32_t)access {
  if (access != _access) {
    [[[self undoManager] prepareWithInvocationTarget:self] setAccess:_access];
    _access = access;
  }
}

@end
