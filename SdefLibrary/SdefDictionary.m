/*
 *  SdefDictionary.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefDictionary.h"

#import "SdefSuite.h"
#import "SdefClassManager.h"
#import "SdefDocumentation.h"

@implementation SdefDictionary
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefDictionary *copy = [super copyWithZone:aZone];
  copy->sd_document = nil;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeConditionalObject:sd_document forKey:@"SDDocument"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_document = [aCoder decodeObjectForKey:@"SDDocument"];
  }
  return self;
}

#pragma mark -
+ (void)initialize {
  [self setKeys:[NSArray arrayWithObject:@"name"] triggerChangeNotificationsForDependentKey:@"title"];
}

- (void)dealloc {
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
  return [[self document] classManager];
}

- (NSArray *)suites {
  return [self children];
}

@end
