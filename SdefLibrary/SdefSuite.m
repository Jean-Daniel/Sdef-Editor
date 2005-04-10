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
#import "SdefValue.h"
#import "SdefEnumeration.h"
#import "SdefDocumentation.h"

@implementation SdefSuite
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefSuite *copy = [super copyWithZone:aZone];
#if !defined(TIGER_SDEF)
  copy->sd_values = [self->sd_values copyWithZone:aZone];
#endif
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
#if !defined(TIGER_SDEF)
  [aCoder encodeObject:sd_values forKey:@"SSValues"];
#endif
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
#if !defined(TIGER_SDEF)
    sd_values = [[aCoder decodeObjectForKey:@"SSValues"] retain];
#endif
  }
  return self;
}

#if !defined (TIGER_SDEF)
#pragma mark -
- (void)dealloc {
  [sd_values release];
  [super dealloc];
}
#endif

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

- (SdefSuite *)suite {
  return self;
}

- (void)createContent {
  [super createContent];
  sd_flags.hasDocumentation = 1;
  
  id child = [[SdefCollection allocWithZone:[self zone]] initWithName:NSLocalizedStringFromTable(@"Types", @"SdefLibrary", @"Types Collection default name")];
  [child setContentType:[SdefEnumeration class]];
  [child setElementName:@"types"];
  [self appendChild:child];
  [child release];
  
  child = [[SdefCollection allocWithZone:[self zone]] initWithName:NSLocalizedStringFromTable(@"Classes", @"SdefLibrary", @"Classes Collection default name")];
  [child setContentType:[SdefClass class]];
  [child setElementName:@"classes"];
  [self appendChild:child];
  [child release];
  
  child = [[SdefCollection allocWithZone:[self zone]] initWithName:NSLocalizedStringFromTable(@"Commands", @"SdefLibrary", @"Commands Collection default name")];
  [child setContentType:[SdefVerb class]];
  [child setElementName:@"commands"];
  [self appendChild:child];
  [child release];
  
  child = [[SdefCollection allocWithZone:[self zone]] initWithName:NSLocalizedStringFromTable(@"Events", @"SdefLibrary", @"Events Collection default name")];
  [child setContentType:[SdefVerb class]];
  [child setElementName:@"events"];
  [self appendChild:child];
  [child release];

  child = [[SdefCollection allocWithZone:[self zone]] initWithName:NSLocalizedStringFromTable(@"Values", @"SdefLibrary", @"Values Collection default name")];
  [child setContentType:[SdefValue class]];
  [child setElementName:nil];
#if defined(TIGER_SDEF)
  [self appendChild:child];
#else
  sd_values = [child retain];
#endif
  [child release];
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

- (SdefCollection *)values {
#if defined(TIGER_SDEF)
  return [self childAtIndex:4];
#else
  return sd_values;
#endif
}

@end
