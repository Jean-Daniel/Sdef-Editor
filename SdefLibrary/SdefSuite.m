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
#import "SdefTypedef.h"
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
- (void)dealloc {
  [super dealloc];
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefSuiteType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"Suite", @"SdefLibrary", @"Object Type Name.");
}

+ (NSString *)defaultIconName {
  return @"Suite";
}

- (SdefSuite *)suite {
  return self;
}

- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.hasSynonyms = 0;
  NSZone *zone = [self zone];
  id child;
  
  child = [[SdefTypeCollection allocWithZone:zone] initWithName:NSLocalizedStringFromTable(@"Types", @"SdefLibrary", @"Types Collection default name")];
  [child setContentType:[SdefEnumeration class]];
  [child setElementName:@"types"];
  [self appendChild:child];
  [child release];
  
  child = [[SdefCollection allocWithZone:zone] initWithName:NSLocalizedStringFromTable(@"Classes", @"SdefLibrary", @"Classes Collection default name")];
  [child setContentType:[SdefClass class]];
  [child setElementName:@"classes"];
  [self appendChild:child];
  [child release];
  
  child = [[SdefCollection allocWithZone:zone] initWithName:NSLocalizedStringFromTable(@"Commands", @"SdefLibrary", @"Commands Collection default name")];
  [child setContentType:[SdefVerb class]];
  [child setElementName:@"commands"];
  [self appendChild:child];
  [child release];
  
  child = [[SdefCollection allocWithZone:zone] initWithName:NSLocalizedStringFromTable(@"Events", @"SdefLibrary", @"Events Collection default name")];
  [child setContentType:[SdefVerb class]];
  [child setElementName:@"events"];
  [self appendChild:child];
  [child release];
}

- (SdefTypeCollection *)types {
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

@implementation SdefTypeCollection 
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefTypeCollection *copy = [super copyWithZone:aZone];
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
- (BOOL)acceptsObjectType:(SdefObjectType)aType {
  if (![self contentType])
    return NO;
  SdefObjectType type = [[self contentType] objectType];
  return (type == kSdefValueType) || (type == kSdefRecordType) || (type == kSdefEnumerationType);
}

@end
