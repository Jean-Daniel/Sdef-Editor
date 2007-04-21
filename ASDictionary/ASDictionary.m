/*
 *  ASDictionary.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "ASDictionary.h"

#import "SdefDictionary.h"
#import "ASDictionaryObject.h"
#import "ASDictionaryStream.h"

#if !__LP64__

#pragma mark -
NSDictionary *AppleScriptDictionaryFromSdefDictionary(SdefDictionary *sdef) {
  NSMutableArray *suites = [[NSMutableArray alloc] init];
  NSDictionary *asdict = [[NSDictionary alloc] initWithObjectsAndKeys:
    [sdef name], @"dictionary name",
    suites, @"script dictionary",
    nil];
  [suites release];
  /* Load AppleScript User Preferences */
  [ASDictionaryStream loadStandardsAppleScriptStyles];
  
  SdefObject *suite;
  NSEnumerator *enume = [sdef childEnumerator];
  while (suite = [enume nextObject]) {
    id asSuite = [suite asdictionary];
    if (asSuite)
      [suites addObject:asSuite];
  }
  return [asdict autorelease];
}

#endif /* LP64 */
