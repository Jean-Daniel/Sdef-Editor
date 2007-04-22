/*
 *  SdefComment.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefComment.h"


@implementation SdefComment
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefComment *copy = [super copyWithZone:aZone];
  copy->sd_value = [sd_value copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_value forKey:@"SCValue"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_value = [[aCoder decodeObjectForKey:@"SCValue"] retain];
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
  [sd_value release];
  [super dealloc];
}

#pragma mark -
- (NSString *)name {
  return NSLocalizedStringFromTable(@"comment", @"SdefLibrary", @"Comment item name");
}

- (NSString *)value {
  return sd_value;
}
- (void)setValue:(NSString *)value {
  if (sd_value != value) {
    //[[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_value];
    [sd_value release];
    sd_value = [value retain];
  }
}

@end
