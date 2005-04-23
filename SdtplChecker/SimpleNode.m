//
//  SimpleNode.m
//  SdtplChecker
//
//  Created by Grayfox on 12/04/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SimpleNode.h"

@implementation SimpleNode

+ (void)initialize {
  static BOOL tooLate = NO;
  if (!tooLate) {
    [self exposeBinding:@"icon"];
    [self exposeBinding:@"name"];
    tooLate = YES;
  }
}

+ (id)nodeWithName:(NSString *)aName {
  return [[[self alloc] initWithName:aName] autorelease];
}

- (id)initWithName:(NSString *)aName {
  if (self = [super init]) {
    [self setName:aName];
  }
  return self;
}

- (void)dealloc {
  [sd_icon release];
  [sd_name release];
  [super dealloc];
}

- (NSImage *)icon {
  return sd_icon;
}
- (void)setIcon:(NSImage *)anIcon {
  if (sd_icon != anIcon) {
    [sd_icon release];
    sd_icon = [anIcon retain];
  }
}

- (NSString *)name {
  return sd_name;
}
- (void)setName:(NSString *)aName {
  if (sd_name != aName) {
    [sd_name release];
    sd_name = [aName copy];
  }
}

@end
