/*
 *  SdefXRef.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXRef.h"

@implementation SdefXRef

- (id)copyWithZone:(NSZone *)aZone {
  SdefXRef *copy = [super copyWithZone:aZone];
  copy->sd_target = [sd_target copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_target forKey:@"SXTarget"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_target = [[aCoder decodeObjectForKey:@"SXTarget"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefXrefType;
}

- (void)dealloc {
  [sd_target release];
  [super dealloc];
}

#pragma mark -
- (NSString *)target {
  return sd_target;
}
- (void)setTarget:(NSString *)target {
  if (target != sd_target) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_target];
    SPXSetterCopy(sd_target, target);
  }
}

@end
