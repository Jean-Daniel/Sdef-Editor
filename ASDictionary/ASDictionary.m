//
//  ASDictionary.m
//  Sdef Editor
//
//  Created by Grayfox on 27/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ASDictionary.h"
#import "ShadowMacros.h"

#import "SdefDictionary.h"
#import "ASDictionaryObject.h"

#pragma mark -
@implementation ASDictionary

+ (NSDictionary *)asdictionaryFromSdefDictionary:(SdefDictionary *)sdef {
  NSMutableArray *suites = [[NSMutableArray alloc] init];
  NSDictionary *asdict = [[NSDictionary alloc] initWithObjectsAndKeys:
    [sdef name], @"dictionary name",
    suites, @"script dictionary",
    nil];
  [suites release];
  
  id children = [sdef childEnumerator];
  SdefObject *suite;
  while (suite = [children nextObject]) {
    [suites addObject:[suite asdictionary]];
  }
  return asdict;
}

@end
