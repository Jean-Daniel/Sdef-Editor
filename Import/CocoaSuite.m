//
//  CocoaSuite.m
//  Sdef Editor
//
//  Created by Grayfox on 03/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefSuite.h"
#import "SdefVerb.h"
#import "SdefClass.h"
#import "CocoaObject.h"
#import "SdefEnumeration.h"
#import "SdefImplementation.h"

@implementation SdefSuite (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super initWithName:[terminology objectForKey:@"Name"]]) {
    [self setDesc:[terminology objectForKey:@"Description"]];
    [self setCodeStr:[suite objectForKey:@"AppleEventCode"]];
    [[self impl] setName:[suite objectForKey:@"Name"]];
    
    /* Enumerations */
    id termItems = [terminology objectForKey:@"Enumerations"];
    id suiteItems = [suite objectForKey:@"Enumerations"];
    
    id keys = [suiteItems keyEnumerator];
    id key;
    while (key = [keys nextObject]) {
      SdefEnumeration *child = [[SdefEnumeration allocWithZone:[self zone]] initWithName:key
                                                                                   suite:[suiteItems objectForKey:key]
                                                                          andTerminology:[termItems objectForKey:key]];
      if (child) {
        [[self types] appendChild:child];
        [child release];
      }
    }
    
    /* Commands */
    termItems = [terminology objectForKey:@"Commands"];
    suiteItems = [suite objectForKey:@"Commands"];
    
    keys = [suiteItems keyEnumerator];
    while (key = [keys nextObject]) {
      SdefVerb *child = [[SdefVerb allocWithZone:[self zone]] initWithName:key
                                                                     suite:[suiteItems objectForKey:key]
                                                            andTerminology:[termItems objectForKey:key]];
      if (child) {
        [[self commands] appendChild:child];
        [child release];
      }
    }
    
    /* Classes */
    termItems = [terminology objectForKey:@"Classes"];
    suiteItems = [suite objectForKey:@"Classes"];
    
    keys = [suiteItems keyEnumerator];
    while (key = [keys nextObject]) {
      SdefClass *child = [[SdefClass allocWithZone:[self zone]] initWithName:key
                                                                       suite:[suiteItems objectForKey:key]
                                                              andTerminology:[termItems objectForKey:key]];
      if (child) {
        [[self classes] appendChild:child];
        [child release];
      }
    }
  }
  return self;
}

@end
