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
      tname = SdefNameFromCocoaName(name);
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
    
    [self impl].className = name;
    
    /* Properties & Contents */
    NSString *content = [suite objectForKey:@"DefaultSubcontainerAttribute"];
    
    NSMutableDictionary *suiteItems = [[NSMutableDictionary alloc] initWithDictionary:[suite objectForKey:@"Attributes"]];
    [suiteItems addEntriesFromDictionary:[suite objectForKey:@"ToOneRelationships"]];
    NSMutableDictionary *termItems = [[NSMutableDictionary alloc] initWithDictionary:[terminology objectForKey:@"Attributes"]];
    [termItems addEntriesFromDictionary:[terminology objectForKey:@"ToOneRelationships"]];
    
    for (NSString *key in suiteItems) {
      bool isContents = false;
      NSDictionary *pterm = [termItems objectForKey:key];
      NSDictionary *psuite = [suiteItems objectForKey:key];
      
      if (content && [key isEqualToString:content]) {
        isContents = true;
      } else if (!content && 
                 [[pterm objectForKey:@"Name"] isEqualToString:@"contents"] && 
                 [[psuite objectForKey:@"AppleEventCode"] isEqualToString:@"pcnt"]) {
        isContents = true;
      }
      
      if (isContents) {
        SdefContents *contents = [[SdefContents alloc] initWithName:key
                                                              suite:psuite
                                                     andTerminology:pterm];
        [self setContents:contents];
      } else {
        SdefProperty *property = [[SdefProperty alloc] initWithName:key
                                                              suite:psuite
                                                     andTerminology:pterm];
        [[self properties] appendChild:property];
      }
    }
    
    /* Elements */
    suiteItems = [suite objectForKey:@"ToManyRelationships"];
    for (NSString *key in suiteItems) {
      SdefElement *element = [[SdefElement alloc] initWithName:key
                                                         suite:[suiteItems objectForKey:key]
                                                andTerminology:nil];
      if (element)
        [[self elements] appendChild:element];
    }
    
    suiteItems = [suite objectForKey:@"SupportedCommands"];
    for (NSString *key in suiteItems) {
      SdefRespondsTo *cmd = [[SdefRespondsTo alloc] initWithName:key
                                                           suite:suiteItems
                                                  andTerminology:nil];
      if (cmd)
        [[self commands] appendChild:cmd];
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
      tname = SdefNameFromCocoaName(name);
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
    uint32_t rights = kSdefAccessRead | kSdefAccessWrite;
    if ([[suite objectForKey:@"ReadOnly"] isEqualToString:@"YES"]) {
      rights = kSdefAccessRead;
    }
    [self setAccess:rights];
    
    /* Cocoa Method */
    if (!tname || ![name isEqualToString:tname])
      [[self impl] setKey:name];
  }
  return self;
}

@end

@implementation SdefProperty (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super init]) {
    NSString *tname = [terminology objectForKey:@"Name"];
    if (!tname) {
      tname = SdefNameFromCocoaName(name);
      [self setHidden:YES];
    }
    [self setName:tname];
    [self setCode:[suite objectForKey:@"AppleEventCode"]];
    [self setType:[suite objectForKey:@"Type"]];
    [self setDesc:[terminology objectForKey:@"Description"]];
    
    /* Access */
    uint32_t rights = kSdefAccessRead | kSdefAccessWrite;
    if ([[suite objectForKey:@"ReadOnly"] isEqualToString:@"YES"]) {
      rights = kSdefAccessRead;
    }
    [self setAccess:rights];
    
    /* Cocoa Method */
    if (!tname || ![name isEqualToString:tname])
      [[self impl] setKey:name];
  }
  return self;
}

@end

@implementation SdefElement (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  if (self = [super initWithName:[suite objectForKey:@"Type"]]) {
    [self setCode:[suite objectForKey:@"AppleEventCode"]];
    
    /* Access */
    uint32_t rights = kSdefAccessRead | kSdefAccessWrite;
    if ([[suite objectForKey:@"ReadOnly"] isEqualToString:@"YES"]) {
      rights = kSdefAccessRead;
    }
    [self setAccess:rights];
    
    /* Cocoa Method */
    if (![name isEqualToString:[suite objectForKey:@"Name"]])
      [[self impl] setKey:name];
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
