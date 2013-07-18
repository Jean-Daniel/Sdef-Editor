/*
 *  SdefContents.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefContents.h"
#import "SdefClass.h"
#import "SdefDocument.h"

@implementation SdefContents

@synthesize access = _access;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefContents *copy = [super copyWithZone:aZone];
  copy->_access = _access;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInt32:_access forKey:@"SCAccess"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _access = [aCoder decodeInt32ForKey:@"SCAccess"];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Contents;
}

+ (NSString *)defaultIconName {
  return @"Content";
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark -
- (void)sdefInit {
  [super sdefInit];
  [self setIsLeaf:YES];
  [self setRemovable:NO];
}

- (void)setAccess:(uint32_t)newAccess {
  [[[self undoManager] prepareWithInvocationTarget:self] setAccess:_access];
  _access = newAccess;
}

@end
