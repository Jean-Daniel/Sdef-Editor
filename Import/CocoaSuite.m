/*
 *  CocoaSuite.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefSuite.h"
#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefTypedef.h"
#import "CocoaObject.h"
#import "SdefImplementation.h"

@implementation SdefSuite (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super initWithName:[terminology objectForKey:@"Name"]]) {
    [self setDesc:[terminology objectForKey:@"Description"]];
    [self setCode:[suite objectForKey:@"AppleEventCode"]];
    [[self impl] setName:[suite objectForKey:@"Name"]];
    
    /* Enumerations */
    id termItems = [terminology objectForKey:@"Enumerations"];
    id suiteItems = [suite objectForKey:@"Enumerations"];
    
    id keys = [suiteItems keyEnumerator];
    id key;
    while (key = [keys nextObject]) {
      SdefEnumeration *child = [[SdefEnumeration alloc] initWithName:key
                                                               suite:[suiteItems objectForKey:key]
                                                      andTerminology:[termItems objectForKey:key]];
      if (child)
        [[self types] appendChild:child];
    }
    
    /* Commands */
    termItems = [terminology objectForKey:@"Commands"];
    suiteItems = [suite objectForKey:@"Commands"];
    
    keys = [suiteItems keyEnumerator];
    while (key = [keys nextObject]) {
      SdefVerb *child = [[SdefVerb alloc] initWithName:key
                                                 suite:[suiteItems objectForKey:key]
                                        andTerminology:[termItems objectForKey:key]];
      if (child)
        [[self commands] appendChild:child];
    }
    
    /* Classes */
    termItems = [terminology objectForKey:@"Classes"];
    suiteItems = [suite objectForKey:@"Classes"];
    
    keys = [suiteItems keyEnumerator];
    while (key = [keys nextObject]) {
      SdefClass *child = [[SdefClass alloc] initWithName:key
                                                   suite:[suiteItems objectForKey:key]
                                          andTerminology:[termItems objectForKey:key]];
      if (child)
        [[self classes] appendChild:child];
    }
  }
  return self;
}

@end
