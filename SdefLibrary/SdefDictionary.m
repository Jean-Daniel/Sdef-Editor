//
//  SdefDictionary.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDictionary.h"
#import "ShadowMacros.h"

#import "SdefSuite.h"
#import "SdefDocumentation.h"

@implementation SdefDictionary
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
//  id document = sd_document;
//  sd_document = nil; /* If document != nil => register some undo */
  SdefDictionary *copy = [super copyWithZone:aZone];
//  sd_document = document;
  copy->sd_document = nil;
//  [copy setDocument:sd_document];
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

+ (SdefObjectType)objectType {
  return kSdefDictionaryType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"Dictionary", @"SdefLibrary", @"Dictionary default name");
}

+ (NSString *)defaultIconName {
  return @"Dictionary";
}

- (void)createContent {
  sd_flags.hasDocumentation = 1;
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

- (NSArray *)suites {
  return [self children];
}

@end
