//
//  SdefClassManager.m
//  SDef Editor
//
//  Created by Grayfox on 17/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefClassManager.h"
#import "SdefClass.h"
#import "SdefSuite.h"
#import "ShadowMacros.h"

#import "SdefDictionary.h"
#import "SdefSuite.h"
#import "SdefVerb.h"

@interface SdefSuite (ClassQueries)

- (SdefClass *)classWithName:(NSString *)name;
- (NSArray *)subclassesOfClass:(SdefClass *)class;

@end

#pragma mark -
@implementation SdefClassManager

+ (NSArray *)baseTypes {
  static NSArray *types;
  if (nil == types) {
    types = [[NSArray alloc] initWithObjects:
      @"any",
      @"string",
      @"number",
      @"integer",
      @"real",
      @"boolean",
      @"object",
      @"location",
      @"record",
      @"file",
      @"point",
      @"rectangle",
      nil];
  }
  return types;
}

- (id)initWithDocument:(SdefDocument *)aDocument {
  if (self = [super init]) {
    sd_document = aDocument;
    sd_types = [[NSMutableArray alloc] init];
    sd_events = [[NSMutableArray alloc] init];
    sd_classes = [[NSMutableArray alloc] init];
    sd_commands = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAppendChild:)
                                                 name:@"SdefObjectDidAppendChild"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveChild:)
                                                 name:@"SdefObjectWillRemoveChild"
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [sd_types release];
  [sd_events release];
  [sd_classes release];
  [sd_commands release];
  [super dealloc];
}

- (void)addSuite:(SdefSuite *)aSuite {
  NSParameterAssert(nil != aSuite);
  id classes = [[aSuite classes] children];
  [sd_types addObjectsFromArray:classes];
  [sd_classes addObjectsFromArray:classes];
  [sd_types addObjectsFromArray:[[aSuite types] children]];
  [sd_events addObjectsFromArray:[[aSuite events] children]];
  [sd_commands addObjectsFromArray:[[aSuite commands] children]];
}

- (void)removeSuite:(SdefSuite *)aSuite {
  NSParameterAssert(nil != aSuite);
  id classes = [[aSuite classes] children];
  [sd_types removeObjectsInArray:classes];
  [sd_classes removeObjectsInArray:classes];
  [sd_types removeObjectsInArray:[[aSuite types] children]];
  [sd_events removeObjectsInArray:[[aSuite events] children]];
  [sd_commands removeObjectsInArray:[[aSuite commands] children]];
}

- (void)addDictionary:(SdefDictionary *)aDico {
  id suites = [aDico childrenEnumerator];
  SdefSuite *suite;
  while (suite = [suites nextObject]) {
    [self addSuite:suite];
  }
}

- (void)removeDictionary:(SdefDictionary *)aDico {
  id suites = [aDico childrenEnumerator];
  SdefSuite *suite;
  while (suite = [suites nextObject]) {
    [self removeSuite:suite];
  }
}

#pragma mark -
- (void)didAppendChild:(NSNotification *)aNotification {
  id node = [aNotification object];
  if (sd_document && [node document] == sd_document) {
    id child = [[aNotification userInfo] objectForKey:@"NewTreeNode"];
    switch ([child objectType]) {
      case kSDSuiteType:
        [self addSuite:child];
        break;
      case kSDEnumerationType:
        [sd_types addObject:child];
        break;
      case kSDClassType:
        [sd_types addObject:child];
        [sd_classes addObject:child];
        break;
      case kSDVerbType:
        if ([child isKindOfClass:[SdefCommand class]]) {
          [sd_commands addObject:child];
        } else if ([child isKindOfClass:[SdefEvent class]]) {
          [sd_events addObject:child];
        }
        break;
    }
  }
}

- (void)willRemoveChild:(NSNotification *)aNotification {
  id node = [aNotification object];
  if (sd_document && [node document] == sd_document) {
    id child = [[aNotification userInfo] objectForKey:@"RemovedTreeNode"];
    switch ([child objectType]) {
      case kSDSuiteType:
        [self removeSuite:child];
        break;
      case kSDEnumerationType:
        [sd_types removeObject:child];
        break;
      case kSDClassType:
        [sd_types removeObject:child];
        [sd_classes removeObject:child];
        break;
      case kSDVerbType:
        if ([child isKindOfClass:[SdefCommand class]]) {
          [sd_commands removeObject:child];
        } else if ([child isKindOfClass:[SdefEvent class]]) {
          [sd_events removeObject:child];
        }
        break;
    }
  }
}

#pragma mark -
- (SdefClass *)superClassOfClass:(SdefClass *)aClass {
  NSString *parent = [aClass inherits];
  if (parent) {
    id classes = [sd_classes objectEnumerator];
    id class;
    while (class = [classes nextObject]) {
      if (class != aClass && [[class name] isEqualToString:parent]) {
        return class;
      }
    }
  }
  return nil;
}

- (NSArray *)types {
  id types = [NSMutableArray arrayWithArray:[[self class] baseTypes]];
  id items = [sd_types objectEnumerator];
  id item;
  while (item = [items nextObject]) {
    if ([item name])
      [types addObject:[item name]];
  }
  return types;
}

- (NSArray *)classes {
  return sd_classes;
}

- (NSArray *)commands {
  return sd_commands;
}

- (NSArray *)events {
  return sd_events;
}

- (SdefClass *)classWithName:(NSString *)name {
  id classes = [sd_classes objectEnumerator];
  id class;
  while (class = [classes nextObject]) {
    if ([[class name] isEqualToString:name])
      return class;
  }
  return nil;
}

- (NSArray *)subclassesOfClass:(SdefClass *)class {
  
}

#pragma mark -
- (void)didAddDictionary:(NSNotification *)aNotification {
  [self addDictionary:[[aNotification userInfo] objectForKey:@"NewTreeNode"]];
}

- (void)willRemoveDictionary:(NSNotification *)aNotification {
  [self removeDictionary:[[aNotification userInfo] objectForKey:@"RemovedTreeNode"]];
}

@end

#pragma mark -
@implementation SdefSuite (ClassQueries)

- (SdefClass *)classWithName:(NSString *)name {
  id classes = [[self classes] childrenEnumerator];
  id class;
  while (class = [classes nextObject]) {
    if ([[class name] isEqualToString:name])
      return class;
  }
  return nil;
}

- (NSArray *)subclassesOfClass:(SdefClass *)class {
}

@end