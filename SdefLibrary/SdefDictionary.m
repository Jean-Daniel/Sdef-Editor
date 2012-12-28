/*
 *  SdefDictionary.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefDictionary.h"

#import "SdefSuite.h"
#import "SdefDocument.h"
#import "SdefClassManager.h"
#import "SdefDocumentation.h"

@implementation SdefDictionary
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefDictionary *copy = [super copyWithZone:aZone];
  copy->sd_document = nil;
  copy->sd_xincludes = [sd_xincludes copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInteger:sd_version forKey:@"SDVersion"];
  //[aCoder encodeObject:sd_xincludes forKey:@"SDXIncludes"];
  [aCoder encodeConditionalObject:sd_document forKey:@"SDDocument"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_version = [aCoder decodeIntegerForKey:@"SDVersion"];
    sd_document = [aCoder decodeObjectForKey:@"SDDocument"];
    //sd_xincludes = [[aCoder decodeObjectForKey:@"SDXIncludes"] retain];
  }
  return self;
}

#pragma mark -

- (void)sdefInit {
  [super sdefInit];
  sd_version = kSdefLeopardVersion;
}

- (void)dealloc {
  [sd_xincludes release];
  [super dealloc];
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefDictionaryType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"Dictionary", @"SdefLibrary", @"Object Type Name.");
}

+ (NSString *)defaultIconName {
  return @"Dictionary";
}

#pragma mark -
+ (NSSet *)keyPathsForValuesAffectingTitle {
  return [NSSet setWithObject:@"name"];
}

- (NSString *)title {
  return [self name];
}
- (void)setTitle:(NSString *)newTitle {
  [self setName:newTitle];
}

- (SdefDocument *)document {
  return sd_document;
}
- (void)setDocument:(SdefDocument *)document {
  sd_document = document;
}

- (SdefClassManager *)classManager {
  return [sd_document classManager];
}

- (NSNotificationCenter *)notificationCenter {
  return [sd_document notificationCenter];
}

- (NSArray *)suites {
  return [self children];
}

- (SdefVersion)version {
  return sd_version;
}
- (void)setVersion:(SdefVersion)vers {
  sd_version = vers;
}

@end
