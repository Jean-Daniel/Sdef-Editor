//
//  SdefValue.m
//  Sdef Editor
//
//  Created by Grayfox on 02/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefValue.h"

@implementation SdefValue

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefValue *copy = [super copyWithZone:aZone];
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
  return kSdefValueType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"value", @"SdefLibrary", @"Value default name");
}

+ (NSString *)defaultIconName {
  return @"Misc";
}

@end
