/*
 *  SdefSuite.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

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
+ (SdefObjectType)objectType {
  return kSdefType_Suite;
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
  sd_soFlags.hasAccessGroup = 1;
  
  SdefCollection *child = [[SdefTypeCollection alloc] initWithName:NSLocalizedStringFromTable(@"Types", @"SdefLibrary", @"Types Collection default name")];
  [child setContentType:[SdefEnumeration class]];
  [child setElementName:@"types"];
  [self appendChild:child];
  
  child = [[SdefCollection alloc] initWithName:NSLocalizedStringFromTable(@"Classes", @"SdefLibrary", @"Classes Collection default name")];
  [child setContentType:[SdefClass class]];
  [child setElementName:@"classes"];
  [self appendChild:child];
  
  child = [[SdefCollection alloc] initWithName:NSLocalizedStringFromTable(@"Commands", @"SdefLibrary", @"Commands Collection default name")];
  [child setContentType:[SdefVerb class]];
  [child setElementName:@"commands"];
  [self appendChild:child];
  
  child = [[SdefCollection alloc] initWithName:NSLocalizedStringFromTable(@"Events", @"SdefLibrary", @"Events Collection default name")];
  [child setContentType:[SdefVerb class]];
  [child setElementName:@"events"];
  [self appendChild:child];
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
  return (aType == kSdefType_ValueType) || (aType == kSdefType_RecordType) || (aType == kSdefType_Enumeration);
}

@end
