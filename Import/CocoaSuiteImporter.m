//
//  CocoaSuiteImporter.m
//  Sdef Editor
//
//  Created by Grayfox on 25/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "CocoaSuiteImporter.h"

#import "ShadowMacros.h"

#import "SdefVerb.h"
#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefArguments.h"
#import "SdefEnumeration.h"
#import "SdefImplementation.h"

#import "SdefParser.h"
#import "SdefClassManager.h"

@implementation CocoaSuiteImporter

- (id)initWithFile:(NSString *)file {
  id term = [[file stringByDeletingPathExtension] stringByAppendingPathExtension:@"scriptTerminology"];
  if (![[NSFileManager defaultManager] fileExistsAtPath:file] || ![[NSFileManager defaultManager] fileExistsAtPath:term]) {
    [self release];
    self = nil;
  } else {
    self = [self initWithSuiteFile:file andTerminologyFile:term];
  }
  return self;
}

- (id)initWithSuiteFile:(NSString *)suite andTerminologyFile:(NSString *)aTerm {
  if (self = [super init]) {
    [self setSuite:[NSDictionary dictionaryWithContentsOfFile:suite]];
    [self setTerminology:[NSDictionary dictionaryWithContentsOfFile:aTerm]];
    if (![self suite] || ![self terminology]) {
      [self release];
      self = nil;
    }
  }
  return self;
}


- (void)dealloc {
  [sd_suite release];
  [sd_warnings release];
  [sd_sdefSuite release];
  [sd_terminology release];
  [super dealloc];
}

#pragma mark -
- (NSArray *)warnings {
  return sd_warnings;
}

- (SdefSuite *)sdefSuite {
  if (!sd_sdefSuite) [self import];
  return sd_sdefSuite;
}

- (NSDictionary *)suite {
  return sd_suite;
}

- (void)setSuite:(NSDictionary *)aSuite {
  if (sd_suite != aSuite) {
    [sd_suite release];
    sd_suite = [aSuite retain];
  }
}

- (NSDictionary *)terminology {
  return sd_terminology;
}

- (void)setTerminology:(NSDictionary *)aTerminology {
  if (sd_terminology != aTerminology) {
    [sd_terminology release];
    sd_terminology = [aTerminology retain];
  }
}

#pragma mark -
#pragma mark Importer

- (SdefEnumeration *)importEnumeration:(NSString *)name fromSuite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  SdefEnumeration *enume = [SdefEnumeration nodeWithName:SdefNameForCocoaName(name)];
  [[enume impl] setName:name];
  [enume setCodeStr:[suite objectForKey:@"AppleEventCode"]];
  id codes = [suite objectForKey:@"Enumerators"];
  id keys = [terminology keyEnumerator];
  id key;
  while (key = [keys nextObject]) {
    id enumDesc = [terminology objectForKey:key];
    id enumerator = [SdefEnumerator nodeWithName:[enumDesc objectForKey:@"Name"]];
    [enumerator setDesc:[enumDesc objectForKey:@"Description"]];
    [enumerator setCodeStr:[codes objectForKey:key]];
    [[enumerator impl] setName:key];
    [enume appendChild:enumerator];
  }
  return enume;
}

- (SdefCommand *)importCommand:(NSString *)name fromSuite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  SdefCommand *cmd = [SdefCommand nodeWithName:[terminology objectForKey:@"Name"]];
  [cmd setDesc:[terminology objectForKey:@"Description"]];
  [cmd setCodeStr:[[suite objectForKey:@"AppleEventClassCode"] stringByAppendingString:[suite objectForKey:@"AppleEventCode"]]];
  
  if (![SdefNameForCocoaName(name) isEqualToString:[cmd name]])
    [[cmd impl] setName:name];
  
  [[cmd impl] setSdClass:[suite objectForKey:@"CommandClass"]];
  
  /* Result */
  [[cmd result] setType:[suite objectForKey:@"Type"]];
  
  /* Direct Parameter */
  id direct = [suite objectForKey:@"UnnamedArgument"];
  if (direct) {
    [[cmd directParameter] setOptional:[[direct objectForKey:@"Optional"] isEqualToString:@"YES"]];
    [[cmd directParameter] setDesc:[[terminology objectForKey:@"UnnamedArgument"] objectForKey:@"Description"]];
    [[cmd directParameter] setType:[direct objectForKey:@"Type"]];
  }
  
  id args = [suite objectForKey:@"Arguments"];
  id argsTerm = [terminology objectForKey:@"Arguments"];
  
  id keys = [argsTerm keyEnumerator];
  id key;
  while (key = [keys nextObject]) {
    id argSuite = [args objectForKey:key];
    id argTerm = [argsTerm objectForKey:key];
    SdefParameter *arg = [SdefParameter nodeWithName:[argTerm objectForKey:@"Name"]];
    [arg setDesc:[argTerm objectForKey:@"Description"]];
    [arg setType:[argSuite objectForKey:@"Type"]];
    [arg setCodeStr:[argSuite objectForKey:@"AppleEventCode"]];
    [arg setOptional:[[argSuite objectForKey:@"Optional"] isEqualToString:@"YES"]];
    [[arg impl] setKey:key];
    [cmd appendChild:arg];
  }
  return cmd;
}

- (SdefClass *)importClass:(NSString *)name fromSuite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  SdefClass *class = [SdefClass nodeWithName:[terminology objectForKey:@"Name"]];
  [class setDesc:[terminology objectForKey:@"Description"]];
  id plural = [terminology objectForKey:@"PluralName"];
  if (![[[class name] stringByAppendingString:@"s"] isEqualToString:plural]) {
    [class setPlural:plural];
  }
  [class setCodeStr:[suite objectForKey:@"AppleEventCode"]];
  [class setInherits:[suite objectForKey:@"Superclass"]];
  
  [[class impl] setSdClass:name];
  
  NSMutableDictionary *suiteItems = [[NSMutableDictionary alloc] initWithDictionary:[suite objectForKey:@"Attributes"]];
  [suiteItems addEntriesFromDictionary:[suite objectForKey:@"ToOneRelationships"]];
  NSMutableDictionary *termItems = [[NSMutableDictionary alloc] initWithDictionary:[terminology objectForKey:@"Attributes"]];
  [termItems addEntriesFromDictionary:[terminology objectForKey:@"ToOneRelationships"]];
  NSString *content = [suite objectForKey:@"DefaultSubcontainerAttribute"];
  id key, keys = [suiteItems keyEnumerator];
  while (key = [keys nextObject]) {
    id suiteAttr = [suiteItems objectForKey:key];
    id termAttr = [termItems objectForKey:key];
    SdefProperty *property = nil;
    if (content && [key isEqualToString:content]) {
      property = (id)[class contents];
      id value = [termAttr objectForKey:@"Name"];
      if (![value isEqualToString:@"contents"]) {
        [property setName:value];
      }
      value = [suiteAttr objectForKey:@"AppleEventCode"];
      if (![value isEqualToString:@"pcnt"]) {
        [property setCodeStr:value];
      }
    } else {
      property = [SdefProperty nodeWithName:[termAttr objectForKey:@"Name"]];
      [property setCodeStr:[suiteAttr objectForKey:@"AppleEventCode"]];
      [[class properties] appendChild:property];
    }
    [property setType:[suiteAttr objectForKey:@"Type"]];
    [property setDesc:[termAttr objectForKey:@"Description"]];
    /* Access */
    unsigned access = kSdefAccessRead | kSdefAccessWrite;
    if ([[suiteAttr objectForKey:@"ReadOnly"] isEqualToString:@"YES"]) {
      access = kSdefAccessRead;
    }
    [property setAccess:access];
    
    /* Cocoa Method */
    if (![key isEqualToString:[termAttr objectForKey:@"Name"]])
      [[property impl] setMethod:key];
  }
  
  [suiteItems release];
  [termItems release];
  
  suiteItems = [suite objectForKey:@"ToManyRelationships"];
  keys = [suiteItems keyEnumerator];
  while (key = [keys nextObject]) {
    id suiteElt = [suiteItems objectForKey:key];
    
    SdefElement *element = [SdefElement nodeWithName:[suiteElt objectForKey:@"Type"]];
    [element setCodeStr:[suiteElt objectForKey:@"AppleEventCode"]];
    
    /* Access */
    unsigned access = kSdefAccessRead | kSdefAccessWrite;
    if ([[suiteElt objectForKey:@"ReadOnly"] isEqualToString:@"YES"]) {
      access = kSdefAccessRead;
    }
    [element setAccess:access];
    
    /* Cocoa Method */
    if (![key isEqualToString:[suiteElt objectForKey:@"Name"]])
      [[element impl] setMethod:key];
    
    [[class elements] appendChild:element];
  }
  
  suiteItems = [suite objectForKey:@"SupportedCommands"];
  keys = [suiteItems keyEnumerator];
  while (key = [keys nextObject]) {
    id method = [suiteItems objectForKey:key];
    
    SdefRespondsTo *cmd = [SdefRespondsTo nodeWithName:key];
    
    /* Cocoa Method */
    if (![key isEqualToString:method])
      [[cmd impl] setMethod:method];
    
    [[class commands] appendChild:cmd];
  }
  
  return class;
}

static NSString *DecomposeCocoaName(NSString *type, NSString **suite) {
  unsigned idx = [type rangeOfString:@"." options:NSLiteralSearch].location;
  if (suite)
    *suite = (idx != NSNotFound) ? [type substringToIndex:idx] : nil;
  return (idx != NSNotFound) ? [type substringFromIndex:idx+1] : type;
}

static NSString *DecomposeCocoaType(NSString *type, NSString **suite) {
  *suite = NULL;
  if ([type rangeOfString:@"."].location == NSNotFound) return type;
  
  if ([type rangeOfString:@"NSNumber" options:NSAnchoredSearch].location == NSNotFound) {
    return DecomposeCocoaName(type, suite);
  }
  
  unsigned dot = [type rangeOfString:@"." options:NSLiteralSearch].location;
  unsigned start = [type rangeOfString:@"<" options:NSLiteralSearch].location;
  unsigned end = [type rangeOfString:@">" options:NSLiteralSearch].location;
  if (NSNotFound == dot || NSNotFound == start || NSNotFound == end)
    return nil;
  if (suite)
    *suite = [type substringWithRange:NSMakeRange(start+1, dot - start - 1)];
  return [type substringWithRange:NSMakeRange(dot+1, end - dot - 1)];  
}

- (void)loadSuite:(NSString *)suite inManager:(SdefClassManager *)manager {
  if (!suite || [sd_suites containsObject:suite]) {
    return;
  }
  if ([suite isEqualToString:@"NSCoreSuite"] || [suite isEqualToString:@"NSTextSuite"]) {
    id parser = [[SdefParser alloc] init];
    NSString *suitePath = [[NSBundle mainBundle] pathForResource:suite ofType:@"sdef"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:suitePath];
    if (data && [parser parseData:data])
      [manager addDictionary:[parser document]];
    [data release];
    [parser release]; 
  } else {
    // Ask user
  }
  DLog(@"Load Suite: %@", suite);
  [sd_suites addObject:suite];
}

- (BOOL)resolveObjectType:(SdefObject *)obj withManager:(SdefClassManager *)manager {
  NSString *suite = nil, *typename = nil, *type;
  type = [obj valueForKey:@"type"];
  if (!type) return YES;
  type = DecomposeCocoaType(type, &suite);
  if (suite) {
    [self loadSuite:suite inManager:manager];
    typename = [[manager sdefTypeWithCocoaType:type inSuite:suite] name];
  } else {
    typename = [manager sdefTypeForCocoaType:type];
  }
  if (typename) {
    [obj setValue:typename forKey:@"type"];
    return YES;
  } else {
    DLog(@"Unable to resolve Type: %@", [obj valueForKey:@"type"]);
    return NO;
  }
}

- (void)postProcessClass:(SdefClass *)aClass withManager:(SdefClassManager *)manager {
  id suite = nil;
  id superclass = [aClass inherits];
  if (superclass) {
    superclass = DecomposeCocoaName(superclass, &suite);
    if (suite)
      [self loadSuite:suite inManager:manager];
    SdefClass *parent = [manager sdefClassWithCocoaClass:superclass inSuite:suite];
    if (parent) {
      [aClass setInherits:[parent name]];
    } else {
      [sd_warnings addObject:[NSString stringWithFormat:@"%@: Unable to resolve super class name: %@", [aClass name], [aClass inherits]]];
    }
  }
  
  SdefObject *item;
  id items = [[aClass elements] childrenEnumerator];
  while (item = [items nextObject]) {
    if ([[item valueForKey:@"type"] isEqualToString:@"NSArray"]) 
      [sd_warnings addObject:[NSString stringWithFormat:@"%@: Element NSArray type set to \"list of any\"", [aClass name]]];
    if (![self resolveObjectType:item withManager:manager]) {
      [sd_warnings addObject:[NSString stringWithFormat:@"%@: Unable to resolve element type: %@", [aClass name], [item valueForKey:@"type"]]];
    }
  }
  
  items = [[aClass properties] childrenEnumerator];
  while (item = [items nextObject]) {
    if ([[item valueForKey:@"type"] isEqualToString:@"NSArray"])
      [sd_warnings addObject:[NSString stringWithFormat:@"%@->%@: NSArray type set to \"list of any\"", [aClass name], [item name]]];
    if (![self resolveObjectType:item withManager:manager]) {
      [sd_warnings addObject:[NSString stringWithFormat:@"%@->%@: Unable to resolve type: %@", [aClass name], [item name], [item valueForKey:@"type"]]];
    }
  }
  
  items = [[aClass commands] childrenEnumerator];
  while (item = [items nextObject]) {
    id cmdName = DecomposeCocoaName([item name], &suite);
    if (suite)
      [self loadSuite:suite inManager:manager];
    SdefVerb *cmd = [manager verbWithCocoaName:cmdName inSuite:suite];
    if (cmd) {
      [item setName:[cmd name]];
    } else {
      [sd_warnings addObject:[NSString stringWithFormat:@"%@->%@(): Unable to resolve command: %@", [aClass name], [item name]]];
    }
  }
}

- (void)postProcessCommand:(SdefCommand *)aCmd withManager:(SdefClassManager *)manager {
  SdefObject *item = nil;
  id items = [aCmd childrenEnumerator];
  while (item = [items nextObject]) {
    if ([[item valueForKey:@"type"] isEqualToString:@"NSArray"])
      [sd_warnings addObject:[NSString stringWithFormat:@"%@(%@): NSArray type set to \"list of any\"", [aCmd name], [item name]]];
    if (![self resolveObjectType:item withManager:manager]) {
      [sd_warnings addObject:[NSString stringWithFormat:@"%@(%@): Unable to resolve type: %@", [aCmd name], [item name], [item valueForKey:@"type"]]];
    }
  }
  
  item = [aCmd directParameter];
  if ([[item valueForKey:@"type"] isEqualToString:@"NSArray"])
    [sd_warnings addObject:[NSString stringWithFormat:@"%@(): Direct-Param NSArray type set to \"list of any\"", [aCmd name]]];
  if (![self resolveObjectType:item withManager:manager]) {
    [sd_warnings addObject:[NSString stringWithFormat:@"%@(): Unable to resolve Direct-Param type: %@", [aCmd name], [item valueForKey:@"type"]]];
  }
  
  item = [aCmd result];
  if ([[item valueForKey:@"type"] isEqualToString:@"NSArray"])
    [sd_warnings addObject:[NSString stringWithFormat:@"%@(): Result NSArray type set to \"list of any\"", [aCmd name]]];
  if (![self resolveObjectType:item withManager:manager]) {
    [sd_warnings addObject:[NSString stringWithFormat:@"%@(): Unable to resolve Result type: %@", [aCmd name], [item valueForKey:@"type"]]];
  } 
}

- (void)postProcessor {
  if (!sd_sdefSuite) return;
  id manager = [[SdefClassManager alloc] init];
  sd_suites = [[NSMutableArray alloc] init];

  [manager addSuite:sd_sdefSuite];
  [sd_suites addObject:[sd_sdefSuite cocoaName]];
  
  /* Classes */
  id items = [[sd_sdefSuite classes] childrenEnumerator];
  SdefClass *class;
  while (class = [items nextObject]) {
    [self postProcessClass:class withManager:manager];
  }
  
  /* Commands */
  items = [[sd_sdefSuite commands] childrenEnumerator];
  SdefCommand *command;
  while (command = [items nextObject]) {
    [self postProcessCommand:command withManager:manager];
  }
  
  [manager release];
  [sd_suites release];
  sd_suites = nil;
}

- (BOOL)import {
  if (sd_sdefSuite) {
    [sd_sdefSuite release];
    sd_sdefSuite = nil;
  }
  if (sd_warnings) {
    [sd_warnings release];
    sd_warnings = nil;
  }
  if (![self suite] || ![self terminology])
    return NO;
  
  sd_warnings = [[NSMutableArray alloc] init];
  
  sd_sdefSuite = [[SdefSuite alloc] initWithName:[sd_terminology objectForKey:@"Name"]];
  [sd_sdefSuite setDesc:[sd_terminology objectForKey:@"Description"]];
  [sd_sdefSuite setCodeStr:[sd_suite objectForKey:@"AppleEventCode"]];
  [[sd_sdefSuite impl] setName:[sd_suite objectForKey:@"Name"]];
  
  /* Enumerations */
  id termItems = [sd_terminology objectForKey:@"Enumerations"];
  id suiteItems = [sd_suite objectForKey:@"Enumerations"];
  
  id keys = [suiteItems keyEnumerator];
  id key;
  while (key = [keys nextObject]) {
    SdefEnumeration *child = [self importEnumeration:key
                                           fromSuite:[suiteItems objectForKey:key]
                                      andTerminology:[termItems objectForKey:key]];
    if (child) [[sd_sdefSuite types] appendChild:child];
  }
  
  /* Commands */
  termItems = [sd_terminology objectForKey:@"Commands"];
  suiteItems = [sd_suite objectForKey:@"Commands"];
  
  keys = [suiteItems keyEnumerator];
  while (key = [keys nextObject]) {
    SdefCommand *child = [self importCommand:key
                                   fromSuite:[suiteItems objectForKey:key]
                              andTerminology:[termItems objectForKey:key]];
    if (child) [[sd_sdefSuite commands] appendChild:child];
  }
  
  /* Classes */
  termItems = [sd_terminology objectForKey:@"Classes"];
  suiteItems = [sd_suite objectForKey:@"Classes"];
  
  keys = [suiteItems keyEnumerator];
  while (key = [keys nextObject]) {
    SdefClass *child = [self importClass:key
                               fromSuite:[suiteItems objectForKey:key]
                          andTerminology:[termItems objectForKey:key]];
    if (child) [[sd_sdefSuite classes] appendChild:child];
  }
  
  [self postProcessor];
  DLog(@"WARNINGS: %@", sd_warnings);
  return YES;
}

@end
