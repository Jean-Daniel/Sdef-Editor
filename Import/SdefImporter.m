//
//  SdefImporter.m
//  Sdef Editor
//
//  Created by Grayfox on 30/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefImporter.h"

#import "SdefVerb.h"
#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefContents.h"
#import "SdefArguments.h"
#import "SdefEnumeration.h"
#import "SdefClassManager.h"

@implementation SdefImporter

- (id)initWithContentsOfFile:(NSString *)file {
  if (self = [super init]) {
  }
  return self;
}

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

- (unsigned)suiteCount {
  return [suites count];
}

- (NSArray *)sdefSuites {
  if (!suites) {
    [self prepareImport];
    if ([self import]) {
      id suite;
      id items = [suites objectEnumerator];
      manager = [[SdefClassManager alloc] init];
      while (suite = [items nextObject]) {
        [manager addSuite:suite];
      }
      [self postProcess];
    }
    [manager release];
    manager = nil;
    if ([sd_warnings count] == 0) {
      [sd_warnings release];
      sd_warnings = nil;
    }
  }
  return suites;
}

- (void)addWarning:(NSString *)warning forValue:(NSString *)value {
  [sd_warnings addObject:[NSDictionary dictionaryWithObjectsAndKeys:warning, @"warning", value, @"value", nil]];
}

#pragma mark -
#pragma mark Post Processor
- (void)postProcess {
  SdefSuite *suite;
  id items = [suites objectEnumerator];
  while (suite = [items nextObject]) {
    
    /* Enumerations */
    id items = [[suite types] childEnumerator];
    SdefEnumeration *enumeration;
    while (enumeration = [items nextObject]) {
      [self postProcessEnumeration:enumeration];
    }
    
    /* Classes */
    items = [[suite classes] childEnumerator];
    SdefClass *class;
    while (class = [items nextObject]) {
      [self postProcessClass:class];
    }
    
    /* Commands */
    items = [[suite commands] childEnumerator];
    SdefVerb *command;
    while (command = [items nextObject]) {
      [self postProcessCommand:command ];
    }
  }
}

- (BOOL)resolveObjectType:(SdefObject *)obj {
  return NO;
}

#pragma mark Class
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
            forValue:[aClass name]];
  }  
}

- (void)postProcessElement:(SdefElement *)anElement inClass:(SdefClass *)aClass {
  if (![self resolveObjectType:anElement]) {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve element type: %@", [anElement type]]
            forValue:[aClass name]];
  }
}

- (void)postProcessProperty:(SdefProperty *)aProperty inClass:(SdefClass *)aClass {
  if (![self resolveObjectType:aProperty]) {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve type: %@", [aProperty type]]
            forValue:[NSString stringWithFormat:@"%@->%@", [aClass name], [aProperty name]]];
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
            forValue:[NSString stringWithFormat:@"%@()", [aCmd name]]];
  }
}

- (void)postProcessParameter:(SdefParameter *)aParameter inCommand:(SdefVerb *)aCmd {
  if (![self resolveObjectType:aParameter]) {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve type: %@", [aParameter type]]
            forValue:[NSString stringWithFormat:@"%@(%@)", [aCmd name], [aParameter name]]];
  }
}

- (void)postProcessResult:(SdefResult *)aResult inCommand:(SdefVerb *)aCmd {
  if (![self resolveObjectType:aResult]) {
    [self addWarning:[NSString stringWithFormat:@"Unable to resolve Result type: %@", [aResult type]]
            forValue:[NSString stringWithFormat:@"%@()", [aCmd name]]];
  }
}

#pragma mark -
#pragma mark Enumeration
- (void)postProcessEnumeration:(SdefEnumeration *)anEnumeration {
  
}

@end
