//
//  SdefComment.m
//  Sdef Editor
//
//  Created by Grayfox on 19/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefComment.h"


@implementation SdefComment

+ (id)commentWithString:(NSString *)aString {
  return [[[self alloc] initWithString:aString] autorelease]; 
}

- (id)init {
  return [self initWithString:@" comment "];
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
  return @"comment";
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
    sd_value = [value copy];
  }
}

@end
