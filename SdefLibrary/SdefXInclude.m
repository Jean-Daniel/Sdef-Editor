/*
 *  SdefXInclude.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXInclude.h"

#import "SdefParser.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"

@implementation SdefXInclude

@synthesize href = _href;
@synthesize pointer = _pointer;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefXInclude *copy = [super copyWithZone:aZone];
  copy->_href = [_href copyWithZone:aZone];
  copy->_pointer = [_pointer copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_href forKey:@"SXIncludeHRef"];
  [aCoder encodeObject:_pointer forKey:@"SXIncludePointer"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _href = [aCoder decodeObjectForKey:@"SXIncludeHRef"];
    _pointer = [aCoder decodeObjectForKey:@"SXIncludePointer"];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_XInclude;
}

+ (NSString *)defaultIconName {
  return @"XInclude";
}

#pragma mark -
- (BOOL)sdefParser:(SdefParser *)parser shouldIgnoreValidationError:(NSError *)error isFatal:(BOOL)fatal {
  [[[self dictionary] document] presentError:error];
  return NO;
}

@end

