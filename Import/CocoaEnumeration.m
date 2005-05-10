//
//  CocoaEnumeration.m
//  Sdef Editor
//
//  Created by Grayfox on 03/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefTypedef.h"
#import "CocoaObject.h"
#import "SdefImplementation.h"

@implementation SdefEnumeration (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  NSString *sdefName = SdefNameCreateWithCocoaName(name);
  if (self = [super initWithName:sdefName]) {
    [[self impl] setName:name];
    [self setCodeStr:[suite objectForKey:@"AppleEventCode"]];
    id codes = [suite objectForKey:@"Enumerators"];
    id keys = [terminology keyEnumerator];
    id key;
    while (key = [keys nextObject]) {
      SdefEnumerator *enumerator = [[SdefEnumerator allocWithZone:[self zone]] initWithName:key
                                                                                      suite:codes
                                                                             andTerminology:[terminology objectForKey:key]];
      [self appendChild:enumerator];
      [enumerator release];
    }
  }
  [sdefName release];
  return self;
}

@end

@implementation SdefEnumerator (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super initWithName:[terminology objectForKey:@"Name"]]) {
    [self setDesc:[terminology objectForKey:@"Description"]];
    [self setCodeStr:[suite objectForKey:name]];
    [[self impl] setName:name];
  }
  return self;
}

@end
