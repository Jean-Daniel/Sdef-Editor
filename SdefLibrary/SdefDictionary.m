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

@synthesize version = _version;
@synthesize document = _document;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefDictionary *copy = [super copyWithZone:aZone];
  copy->_document = nil;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInteger:_version forKey:@"SDVersion"];
  //[aCoder encodeObject:sd_xincludes forKey:@"SDXIncludes"];
  [aCoder encodeConditionalObject:_document forKey:@"SDDocument"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _version = [aCoder decodeIntegerForKey:@"SDVersion"];
    _document = [aCoder decodeObjectForKey:@"SDDocument"];
  }
  return self;
}

#pragma mark -

- (void)sdefInit {
  [super sdefInit];
  _version = kSdefMountainLionVersion;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Dictionary;
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

- (SdefClassManager *)classManager {
  return [_document classManager];
}

- (NSNotificationCenter *)notificationCenter {
  return [_document notificationCenter];
}

- (NSArray *)suites {
  return [self children];
}

@end
