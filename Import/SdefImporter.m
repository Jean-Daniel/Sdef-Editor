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
#import "SdefArguments.h"
#import "SdefEnumeration.h"
#import "SdefClassManager.h"

@implementation SdefImporter

- (id)init {
  if (self = [super init]) {
  }
  return self;
}

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

#pragma mark Post Processor
- (BOOL)resolveObjectType:(SdefObject *)obj {
  return NO;
}

- (void)postProcessClass:(SdefClass *)aClass {
  
}

- (void)postProcessCommand:(SdefVerb *)aCmd {

}

- (void)postProcessEnumeration:(SdefEnumeration *)anEnumeration {
  
}

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

@end
