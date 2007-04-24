/*
 *  CocoaClass.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefClass.h"
#import "CocoaObject.h"
#import "SdefContents.h"
#import "SdefImplementation.h"

@implementation SdefClass (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super init]) {
    NSString *tname = [terminology objectForKey:@"Name"];
    if (!tname) {
      tname = name;
      [self setHidden:YES];
    }
    [self setName:tname];
    [self setDesc:[terminology objectForKey:@"Description"]];
    id plural = [terminology objectForKey:@"PluralName"];
    if (![[[self name] stringByAppendingString:@"s"] isEqualToString:plural]) {
      [self setPlural:plural];
    }
    [self setCode:[suite objectForKey:@"AppleEventCode"]];
    [self setInherits:[suite objectForKey:@"Superclass"]];
    
    [[self impl] setSdClass:name];
    
    /* Properties & Contents */
    NSMutableDictionary *suiteItems = [[NSMutableDictionary alloc] initWithDictionary:[suite objectForKey:@"Attributes"]];
    [suiteItems addEntriesFromDictionary:[suite objectForKey:@"ToOneRelationships"]];
    NSMutableDictionary *termItems = [[NSMutableDictionary alloc] initWithDictionary:[terminology objectForKey:@"Attributes"]];
    [termItems addEntriesFromDictionary:[terminology objectForKey:@"ToOneRelationships"]];
    NSString *content = [suite objectForKey:@"DefaultSubcontainerAttribute"];
    id key, keys = [suiteItems keyEnumerator];
    while (key = [keys nextObject]) {
      if (content && [key isEqualToString:content]) {
        id contents = [[SdefContents allocWithZone:[self zone]] initWithName:key
                                                                       suite:[suiteItems objectForKey:key]
                                                              andTerminology:[termItems objectForKey:key]];
        [self setContents:contents];
        [contents release];
      } else {
        id property = [[SdefProperty allocWithZone:[self zone]] initWithName:key
                                                                       suite:[suiteItems objectForKey:key]
                                                              andTerminology:[termItems objectForKey:key]];
        [[self properties] appendChild:property];
        [property release];
      }
    }
    [suiteItems release];
    [termItems release];
    
    /* Elements */
    suiteItems = [suite objectForKey:@"ToManyRelationships"];
    keys = [suiteItems keyEnumerator];
    while (key = [keys nextObject]) {
      SdefElement *element = [[SdefElement allocWithZone:[self zone]] initWithName:key
                                                                             suite:[suiteItems objectForKey:key]
                                                                    andTerminology:nil];
      if (element) {
        [[self elements] appendChild:element];
        [element release];
      }
    }
    
    suiteItems = [suite objectForKey:@"SupportedCommands"];
    keys = [suiteItems keyEnumerator];
    while (key = [keys nextObject]) {
      SdefRespondsTo *cmd = [[SdefRespondsTo allocWithZone:[self zone]] initWithName:key
                                                           suite:suiteItems
                                                  andTerminology:nil];
      if (cmd) {
        [[self commands] appendChild:cmd];
        [cmd release];
      }
    }
  }
  return self;
}

@end

@implementation SdefContents (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super init]) {
    NSString *tname = [terminology objectForKey:@"Name"];
    if (!tname)
      tname = name;
    if (![tname isEqualToString:@"contents"]) {
      [self setName:tname];
    }
    
    NSString *value = [suite objectForKey:@"AppleEventCode"];
    if (![value isEqualToString:@"pcnt"]) {
      [self setCode:value];
    }
    
    [self setCode:[suite objectForKey:@"AppleEventCode"]];
    [self setType:[suite objectForKey:@"Type"]];
    [self setDesc:[terminology objectForKey:@"Description"]];
    
    /* Access */
    NSUInteger rights = kSdefAccessRead | kSdefAccessWrite;
    if ([[suite objectForKey:@"ReadOnly"] isEqualToString:@"YES"]) {
      rights = kSdefAccessRead;
    }
    [self setAccess:rights];
    
    /* Cocoa Method */
    if (![name isEqualToString:[terminology objectForKey:@"Name"]])
      [[self impl] setMethod:name];
  }
  return self;
}

@end

@implementation SdefProperty (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super init]) {
    NSString *tname = [terminology objectForKey:@"Name"];
    if (!tname) {
      tname = name;
      [self setHidden:YES];
    }
    [self setName:tname];
    [self setCode:[suite objectForKey:@"AppleEventCode"]];
    [self setType:[suite objectForKey:@"Type"]];
    [self setDesc:[terminology objectForKey:@"Description"]];
    
    /* Access */
    NSUInteger rights = kSdefAccessRead | kSdefAccessWrite;
    if ([[suite objectForKey:@"ReadOnly"] isEqualToString:@"YES"]) {
      rights = kSdefAccessRead;
    }
    [self setAccess:rights];
    
    /* Cocoa Method */
    if (![name isEqualToString:[terminology objectForKey:@"Name"]])
      [[self impl] setMethod:name];
  }
  return self;
}

@end

@implementation SdefElement (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super initWithName:[suite objectForKey:@"Type"]]) {
    [self setCode:[suite objectForKey:@"AppleEventCode"]];
    
    /* Access */
    NSUInteger rights = kSdefAccessRead | kSdefAccessWrite;
    if ([[suite objectForKey:@"ReadOnly"] isEqualToString:@"YES"]) {
      rights = kSdefAccessRead;
    }
    [self setAccess:rights];
    
    /* Cocoa Method */
    if (![name isEqualToString:[suite objectForKey:@"Name"]])
      [[self impl] setMethod:name];
  }
  return self;
}

@end

@implementation SdefRespondsTo (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super initWithName:name]) {
    
    /* Cocoa Method */
    if (![name isEqualToString:[suite objectForKey:name]])
      [[self impl] setMethod:[suite objectForKey:name]];
  }
  return self;
}

@end
