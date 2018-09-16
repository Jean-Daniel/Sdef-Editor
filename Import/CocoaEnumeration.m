/*
 *  CocoaEnumeration.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefTypedef.h"
#import "CocoaObject.h"
#import "SdefImplementation.h"

@implementation SdefEnumeration (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  NSString *sdefName = SdefNameFromCocoaName(name);
  if (self = [super initWithName:sdefName]) {
    [[self impl] setName:name];
    [self setCode:[suite objectForKey:@"AppleEventCode"]];
    id codes = [suite objectForKey:@"Enumerators"];
    id keys = [terminology keyEnumerator];
    id key;
    while (key = [keys nextObject]) {
      SdefEnumerator *enumerator = [[SdefEnumerator alloc] initWithName:key
                                                                  suite:codes
                                                         andTerminology:[terminology objectForKey:key]];
      [self appendChild:enumerator];
    }
  }
  return self;
}

@end

@implementation SdefEnumerator (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super initWithName:[terminology objectForKey:@"Name"]]) {
    [self setDesc:[terminology objectForKey:@"Description"]];
    [self setCode:[suite objectForKey:name]];
    [[self impl] setName:name];
  }
  return self;
}

@end
