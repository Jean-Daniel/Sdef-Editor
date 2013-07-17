/*
 *  SdefComment.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefComment.h"


@implementation SdefComment

@synthesize value = _value;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefComment *copy = [super copyWithZone:aZone];
  copy->_value = [_value copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_value forKey:@"SCValue"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _value = [[aCoder decodeObjectForKey:@"SCValue"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefCommentType;
}

+ (id)commentWithString:(NSString *)aString {
  return [[[self alloc] initWithString:aString] autorelease]; 
}

- (id)init {
  return [self initWithString:NSLocalizedStringFromTable(@" comment ", @"SdefLibrary", @"Default comment")];
}

- (id)initWithString:(NSString *)aString {
  if (self = [super init]) {
    [self setValue:aString];
  }
  return self;
}

- (void)dealloc {
  [_value release];
  [super dealloc];
}

#pragma mark -
- (NSString *)name {
  return NSLocalizedStringFromTable(@"comment", @"SdefLibrary", @"Comment item name");
}

//- (void)setValue:(NSString *)value {
//  if (_value != value) {
//    //[[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_value];
//    [_value release];
//    _value = [value copy];
//  }
//}

@end
