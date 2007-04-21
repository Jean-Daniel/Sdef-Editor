/*
 *  ASDictionaryVerb.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "ASDictionaryObject.h"
#import "ASDictionaryStream.h"
#import "SdefVerb.h"
#import "SdefArguments.h"
#import <ShadowKit/SKExtensions.h>

#if !__LP64__

@interface SdefDirectParameter (ASDictionary)
- (void)appendStringToStream:(ASDictionaryStream *)stream;
@end

@interface SdefParameter (ASDictionary)
- (void)appendStringToStream:(ASDictionaryStream *)stream;
@end

@interface SdefResult (ASDictionary)
- (void)appendStringToStream:(ASDictionaryStream *)stream;
@end

#pragma mark -
@implementation SdefVerb (ASDictionary)

- (NSDictionary *)asdictionary {
  id dict = [NSMutableDictionary dictionary];
  NSString *name = [self name];
  [dict setObject:(name) ? name : @"<untitled>" forKey:@"name"];
  [dict setObject:[self asdictionaryString] forKey:@"content"];
  return dict;
}

- (NSDictionary *)asdictionaryString {
  ASDictionaryStream *stream = [[ASDictionaryStream alloc] init];
  [stream setFontFamily:@"Times" style:bold | underline size:14];
  [stream appendString:[self name] ? : @"<untitled>"];
  [stream appendString:@": "];
  [stream closeStyle];
  
  [stream setStyle:underline];
  [stream appendString:[self desc] ? : @""];
  [stream appendString:@"\n"];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleStandard];
  [stream appendString:@"\t"];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleApplicationKeyword];
  [stream appendString:[self name] ? : @"<untitled>"];
  [stream closeStyle];
  
  if ([[self directParameter] type]) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"  "];
    [stream closeStyle];
    [[self directParameter] appendStringToStream:stream];
  } else {
    [stream appendString:@"\n"];
    [stream closeStyle];
  }
  
  id params = [self childEnumerator];
  id param;
  /* Required parameters */
  while (param = [params nextObject]) {
    if (![param isOptional]) {
      [param appendStringToStream:stream];
    }
  }
  
  /* Optionals parameters */
  params = [self childEnumerator];
  while (param = [params nextObject]) {
    if ([param isOptional]) {
      [param appendStringToStream:stream];
    }
  }
  
  if ([[self result] type]) {
    [[self result] appendStringToStream:stream];
  }
  
  [stream appendString:@"\r"];
  [stream closeStyle];
  
  id dict = [stream asDictionaryString];
  [stream release];
  return dict;
}



@end

@implementation SdefDirectParameter (ASDictionary)

- (void)appendStringToStream:(ASDictionaryStream *)stream {
  BOOL list;
  id type = [self asDictionaryTypeForType:[self type] isList:&list];
  
  if (list) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"a list of "];
    [stream closeStyle];
  }
  
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:type];
  [stream closeStyle];
  
  if ([[self desc] length]) {
    [stream setASDictionaryStyle:kASStyleComment];
    [stream appendString:@"  -- "];
    [stream appendString:[self desc]];
    [stream closeStyle];
  }
  [stream appendString:@"\n"];
  [stream closeStyle];
}

@end

@implementation SdefParameter (ASDictionary)

- (void)appendStringToStream:(ASDictionaryStream *)stream {
  [stream setASDictionaryStyle:kASStyleStandard];
  [stream appendString:@"\t\t"];
  if ([self isOptional]) {
    [stream appendString:@"["];
  }
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleApplicationKeyword];
  [stream appendString:[self name] ? : @"<untitled>"];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleStandard];
  [stream appendString:@"  "];
  [stream closeStyle];
  
  BOOL list;
  id type = [self asDictionaryTypeForType:[self type] isList:&list];
  
  if (list) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"a list of "];
    [stream closeStyle];
  }
  
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:type];
  [stream closeStyle];
  
  if ([self isOptional]) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"]"];
    [stream closeStyle];
  }
  
  if ([[self desc] length]) {
    [stream setASDictionaryStyle:kASStyleComment];
    [stream appendString:@"  -- "];
    [stream appendString:[self desc]];
    [stream closeStyle];
  }
  [stream appendString:@"\n"];
  [stream closeStyle];
}

@end

@implementation SdefResult (ASDictionary)

- (void)appendStringToStream:(ASDictionaryStream *)stream {
  [stream setASDictionaryStyle:kASStyleStandard];
  [stream appendString:@"\tResult:   "];
 
  BOOL list;
  id type = [self asDictionaryTypeForType:[self type] isList:&list];
  
  if (list) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"a list of "];
  }
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:type];
  [stream closeStyle];
  
  if ([[self desc] length]) {
    [stream setASDictionaryStyle:kASStyleComment];
    [stream appendString:@"  -- "];
    [stream appendString:[self desc]];
    [stream closeStyle];
  }
  [stream appendString:@"\n"];
  [stream closeStyle];
}

@end

#endif /* LP64 */
