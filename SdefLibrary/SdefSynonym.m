//
//  SdefSynonym.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefSynonym.h"

@implementation SdefSynonym
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefSynonym *copy = [super copyWithZone:aZone];
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
  return kSdefSynonymType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"synonym", @"SdefLibrary", @"Synonym default name");
}

+ (NSString *)defaultIconName {
  return @"Misc";
}

- (void)dealloc {
  [sd_code release];
  [super dealloc];
}

- (NSString *)code {
  return sd_code;
}

- (void)setCode:(NSString *)code {
  if (code != sd_code) {
    [sd_code release];
    sd_code = [code copy];
  }
}

@end
