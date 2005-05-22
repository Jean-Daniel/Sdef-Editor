//
//  SdefComment.m
//  Sdef Editor
//
//  Created by Grayfox on 19/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefComment.h"


@implementation SdefComment
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefComment *copy = NSCopyObject(self, 0, aZone);
  copy->sd_value = [sd_value copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:sd_value forKey:@"SCValue"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super init]) {
    sd_value = [[aCoder decodeObjectForKey:@"SCValue"] retain];
  }
  return self;
}

#pragma mark -
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

- (NSString *)name {
  return NSLocalizedStringFromTable(@"comment", @"SdefLibrary", @"Comment item name");
}
- (NSImage *)icon {
  return [NSImage imageNamed:@"Misc"];
}

- (NSString *)value {
  return sd_value;
}

- (void)setValue:(NSString *)value {
  if (sd_value != value) {
    [sd_value release];
    sd_value = [value retain];
  }
}

@end
