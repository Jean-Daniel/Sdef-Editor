/*
 *  SdefImporter.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefImporter.h"

#import "SdefVerb.h"
#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefTypedef.h"
#import "SdefContents.h"
#import "SdefArguments.h"
#import "SdefClassManager.h"

@implementation SdefImporter

- (void)dealloc {
  [suites release];
  [manager release];
  [sd_warnings release];
  [super dealloc];
}

- (void)prepareImport {
  if (sd_warnings) {
    [sd_warnings release];
    sd_warnings = nil;
  }
  sd_warnings = [[NSMutableArray alloc] init];
  
  if (manager) {
    [manager release];
    manager = nil;
  }

  if (suites) {
    [suites release];
    suites = nil;
  }
  suites = [[NSMutableArray alloc] init];
}

- (BOOL)import {
  return NO;
}

- (NSArray *)warnings {
  return sd_warnings;
}

- (NSUInteger)suiteCount {
  return [suites count];
}

- (NSArray *)sdefSuites {
  if (!suites) {
    [self prepareImport];
    if ([self import]) {
      NSUInteger idx = [suites count];
      manager = [[SdefClassManager alloc] init];
      while (idx-- > 0) {
        [manager addSuite:[suites objectAtIndex:idx]];
      }
      [self postProcess];
      [manager release];
      manager = nil;
    }
    if ([sd_warnings count] == 0) {
      [sd_warnings release];
      sd_warnings = nil;
    }
  }
  return suites;
}

- (SdefDictionary *)sdefDictionary {
  if (!suites) {
    [self sdefSuites];
  }
  return nil;
}

- (void)addWarning:(NSString *)warning forValue:(NSString *)value node:(SdefObject *)node {
  [sd_warnings addObject:[NSDictionary dictionaryWithObjectsAndKeys:warning, 
    @"warning", value, @"value", node, @"node", nil]];
}

#pragma mark -
#pragma mark Post Processor
- (void)postProcess {
  NSUInteger idx = [suites count];
  /* Because aete format use fake classes to store meta-data
  we have to first cleanup class and then whe can do a full resolution */
  while (idx-- > 0) {
    SdefSuite *suite = [suites objectAtIndex:idx];
    
    /* Classes */
    SdefClass *class;
    NSEnumerator *children = [[suite classes] childEnumerator];
    while (class = [children nextObject]) {
      [self postProcessCleanupClass:class];
    }
  }
  
  idx = [suites count];
  while (idx-- > 0) {
    SdefSuite *suite = [suites objectAtIndex:idx];
    
    /* Enumerations */
    SdefEnumeration *enumeration;
    NSEnumerator *children = [[suite types] childEnumerator];
    while (enumeration = [children nextObject]) {
      [self postProcessEnumeration:enumeration];
    }
    
    /* Class */
    SdefClass *class;
    children = [[suite classes] childEnumerator];
    while (class = [children nextObject]) {
      [self postProcessClass:class];
    }
    
    /* Commands */
    SdefVerb *command;
    children = [[suite commands] childEnumerator];
    while (command = [children nextObject]) {
      [self postProcessCommand:command ];
    }
  }
}

- (BOOL)resolveObjectType:(SdefObject *)obj {
  return NO;
}

#pragma mark Class
- (void)postProcessCleanupClass:(SdefClass *)aClass {
    // see aete
}
- (void)postProcessClass:(SdefClass *)aClass {
  SdefObject *item;
  
  item = [aClass contents];
  if ([[(SdefContents *)item type] length] > 0) {
    [self postProcessContents:(SdefContents *)item forClass:aClass];
  }
  
  id items = [[aClass elements] childEnumerator];
  while (item = [items nextObject]) {
    [self postProcessElement:(SdefElement *)item inClass:aClass];
  }
  
  items = [[aClass properties] childEnumerator];
  while (item = [items nextObject]) {
    [self postProcessProperty:(SdefProperty *)item inClass:aClass];
  }
  
  items = [[aClass commands] childEnumerator];
  while (item = [items nextObject]) {
    [self postProcessRespondsTo:(SdefRespondsTo *)item inClass:aClass];
  }
}

- (void)postProcessContents:(SdefContents *)aContents forClass:aClass {
  if (![self resolveObjectType:aContents]) {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve contents type: %@", [aContents type]]
            forValue:[aClass name] node:aClass];
  }  
}

- (void)postProcessElement:(SdefElement *)anElement inClass:(SdefClass *)aClass {
  if (![self resolveObjectType:anElement]) {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve element type: %@", [anElement type]]
            forValue:[aClass name] node:anElement];
  }
}

- (void)postProcessProperty:(SdefProperty *)aProperty inClass:(SdefClass *)aClass {
  if (![self resolveObjectType:aProperty]) {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve type: %@", [aProperty type]]
            forValue:[NSString stringWithFormat:@"%@->%@", [aClass name], [aProperty name]] node:aProperty];
  }
}

- (void)postProcessRespondsTo:(SdefRespondsTo *)aCmd inClass:(SdefClass *)aClass {
}

#pragma mark Verb
- (void)postProcessCommand:(SdefVerb *)aCmd {
  SdefObject *item = nil;
  id items = [aCmd childEnumerator];
  while (item = [items nextObject]) {
    [self postProcessParameter:(SdefParameter *)item inCommand:aCmd];
  }
  
  item = [aCmd directParameter];
  if ([[(SdefDirectParameter *)item type] length] != 0) {
    [self postProcessDirectParameter:(SdefDirectParameter *)item inCommand:aCmd];
  }
  
  item = [aCmd result];
  if ([[(SdefResult *)item type] length] != 0) {
    [self postProcessResult:(SdefResult *)item inCommand:aCmd];
  }
}

- (void)postProcessDirectParameter:(SdefDirectParameter *)aParameter inCommand:(SdefVerb *)aCmd {
  if (![self resolveObjectType:aParameter]) {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve Direct-Parameter type: %@", [aParameter type]]
            forValue:[NSString stringWithFormat:@"%@()", [aCmd name]] node:aCmd];
  }
}

- (void)postProcessParameter:(SdefParameter *)aParameter inCommand:(SdefVerb *)aCmd {
  if (![self resolveObjectType:aParameter]) {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve type: %@", [aParameter type]]
            forValue:[NSString stringWithFormat:@"%@(%@)", [aCmd name], [aParameter name]] node:aParameter];
  }
}

- (void)postProcessResult:(SdefResult *)aResult inCommand:(SdefVerb *)aCmd {
  if (![self resolveObjectType:aResult]) {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve Result type: %@", [aResult type]]
            forValue:[NSString stringWithFormat:@"%@()", [aCmd name]] node:aCmd];
  }
}

#pragma mark -
#pragma mark Enumeration
- (void)postProcessEnumeration:(SdefEnumeration *)anEnumeration {
  
}

@end
