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
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefContents *copy = [super copyWithZone:aZone];
  copy->sd_access = sd_access;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  WBEncodeInteger(aCoder, sd_access, @"SCAccess");
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_access = WBDecodeInteger(aCoder, @"SCAccess");
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefContentsType;
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
  [self setLeaf:YES];
  [self setRemovable:NO];
}

- (NSUInteger)access {
  return sd_access;
}
- (void)setAccess:(NSUInteger)newAccess {
  [[[self undoManager] prepareWithInvocationTarget:self] setAccess:sd_access];
  sd_access = newAccess;
}

@end
