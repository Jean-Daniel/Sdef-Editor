//
//  SdefEnumeration.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefEnumeration.h"

@implementation SdefEnumeration
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefEnumeration *copy = [super copyWithZone:aZone];
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
  return kSdefEnumerationType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"enumeration", @"SdefLibrary", @"Enumeration default name");
}

+ (NSString *)defaultIconName {
  return @"Enum";
}

- (void)createContent {
  [super createContent];
  sd_flags.hasSynonyms = 1;
  sd_flags.hasDocumentation = 1;
}

@end

@implementation SdefEnumerator
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefEnumerator *copy = [super copyWithZone:aZone];
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
  return kSdefEnumeratorType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"enumerator", @"SdefLibrary", @"Enumerator default name");
}

+ (NSString *)defaultIconName {
  return @"Enum";
}

@end