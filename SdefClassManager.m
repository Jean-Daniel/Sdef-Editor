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

@interface SdefSuite (ClassQueries)

- (SdefClass *)classWithName:(NSString *)name;
- (NSArray *)subclassesOfClass:(SdefClass *)class;

@end

#pragma mark -
@implementation SdefClassManager

- (id)initWithDocument:(SdefDocument *)aDocument {
  if (self = [super init]) {
    sd_document = aDocument;
    sd_classes = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [sd_classes release];
  [super dealloc];
}

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

- (void)addDictionary:(SdefDictionary *)aDico {
  id suites = [aDico childrenEnumerator];
  SdefSuite *suite;
  while (suite = [suites nextObject]) {
    [sd_classes addObjectsFromArray:[[suite classes] children]];
  }
  DLog(@"Classes: %@", sd_classes);
}

- (void)removeDictionary:(SdefDictionary *)aDico {
  id suites = [aDico childrenEnumerator];
  SdefSuite *suite;
  while (suite = [suites nextObject]) {
    [sd_classes removeObjectsInArray:[[suite classes] children]];
  }
  DLog(@"Classes: %@", sd_classes);
}

- (SdefClass *)superClassOfClass:(SdefClass *)aClass {
  NSString *parent = [aClass name];
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
}

- (NSArray *)classes {
}

- (NSArray *)commands {
}

- (NSArray *)events {
}

- (SdefClass *)classWithName:(NSString *)name {

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