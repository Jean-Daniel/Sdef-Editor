//
//  SdefSuite.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefSuite.h"

#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefEnumeration.h"
#import "SdefDocumentation.h"

@implementation SdefSuite
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefSuite *copy = [super copyWithZone:aZone];
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
  return kSdefSuiteType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"Suite", @"SdefLibrary", @"Suite default name");
}

+ (NSString *)defaultIconName {
  return @"Suite";
}

- (void)createContent {
  [super createContent];
  sd_flags.hasDocumentation = 1;
  
  id child = [SdefCollection nodeWithName:NSLocalizedStringFromTable(@"Types", @"SdefLibrary", @"Types Collection default name")];
  [child setContentType:[SdefEnumeration class]];
  [child setElementName:@"types"];
  [self appendChild:child];
  
  child = [SdefCollection nodeWithName:NSLocalizedStringFromTable(@"Classes", @"SdefLibrary", @"Classes Collection default name")];
  [child setContentType:[SdefClass class]];
  [child setElementName:@"classes"];
  [self appendChild:child];
  
  child = [SdefCollection nodeWithName:NSLocalizedStringFromTable(@"Commands", @"SdefLibrary", @"Commands Collection default name")];
  [child setContentType:[SdefVerb class]];
  [child setElementName:@"commands"];
  [self appendChild:child];
  
  child = [SdefCollection nodeWithName:NSLocalizedStringFromTable(@"Events", @"SdefLibrary", @"Events Collection default name")];
  [child setContentType:[SdefVerb class]];
  [child setElementName:@"events"];
  [self appendChild:child];
}

- (SdefCollection *)types {
  return [self childAtIndex:0];
}

- (SdefCollection *)classes {
  return [self childAtIndex:1];
}

- (SdefCollection *)commands {
  return [self childAtIndex:2];
}

- (SdefCollection *)events {
  return [self childAtIndex:3];
}

@end
