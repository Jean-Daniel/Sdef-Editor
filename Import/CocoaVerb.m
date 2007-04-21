/*
 *  CocoaVerb.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefVerb.h"
#import "CocoaObject.h"
#import "SdefArguments.h"
#import "SdefImplementation.h"

@implementation SdefVerb (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super initWithName:[terminology objectForKey:@"Name"]]) {
    [self setDesc:[terminology objectForKey:@"Description"]];
    [self setCode:[[suite objectForKey:@"AppleEventClassCode"] stringByAppendingString:[suite objectForKey:@"AppleEventCode"]]];    
    NSString *sdefName = SdefNameCreateWithCocoaName(name);
    if (![sdefName isEqualToString:[self name]])
      [[self impl] setName:name];
    [sdefName release];
    [[self impl] setSdClass:[suite objectForKey:@"CommandClass"]];
    
    /* Result */
    if ([(NSString *)[suite objectForKey:@"Type"] length])
      [[self result] setType:[suite objectForKey:@"Type"]];
    
    /* Direct Parameter */
    id direct = [suite objectForKey:@"UnnamedArgument"];
    if (direct) {
      [[self directParameter] setOptional:[[direct objectForKey:@"Optional"] isEqualToString:@"YES"]];
      [[self directParameter] setDesc:[[terminology objectForKey:@"UnnamedArgument"] objectForKey:@"Description"]];
      [[self directParameter] setType:[direct objectForKey:@"Type"]];
    }
    
    id args = [suite objectForKey:@"Arguments"];
    id argsTerm = [terminology objectForKey:@"Arguments"];
    
    id keys = [argsTerm keyEnumerator];
    id key;
    while (key = [keys nextObject]) {
      id param = [[SdefParameter allocWithZone:[self zone]] initWithName:key
                                               suite:[args objectForKey:key]
                                      andTerminology:[argsTerm objectForKey:key]];
      if (param) {
        [self appendChild:param];
        [param release];
      }
    }    
  }
  return self;
}

@end

@implementation SdefParameter (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super initWithName:[terminology objectForKey:@"Name"]]) {
    [self setDesc:[terminology objectForKey:@"Description"]];
    [self setType:[suite objectForKey:@"Type"]];
    [self setCode:[suite objectForKey:@"AppleEventCode"]];
    [self setOptional:[[suite objectForKey:@"Optional"] isEqualToString:@"YES"]];
    [[self impl] setKey:name];
  }
  return self;
}

@end
