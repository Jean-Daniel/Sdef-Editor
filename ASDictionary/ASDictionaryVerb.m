//
//  ASDictionaryVerb.m
//  Sdef Editor
//
//  Created by Grayfox on 27/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ASDictionaryObject.h"
#import "ASDictionaryStream.h"
#import "SdefVerb.h"
#import "SdefArguments.h"

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
  [dict setObject:[self name] forKey:@"name"];
  [dict setObject:[self asdictionaryString] forKey:@"content"];
  return dict;
}

- (NSDictionary *)asdictionaryString {
  ASDictionaryStream *stream = [[ASDictionaryStream alloc] init];
  [stream setFontFamily:@"Times" style:bold | underline size:14];
  [stream appendString:[self name]];
  [stream appendString:@": "];
  [stream closeStyle];
  
  [stream setStyle:underline];
  [stream appendString:[self desc] ? : @""];
  [stream appendString:@"\n\t"];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleApplicationKeyword];
  [stream appendString:[self name]];
  
  if ([[self directParameter] type]) {
    [stream closeStyle];
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"  "];

    [[self directParameter] appendStringToStream:stream];
  } else {
    [stream appendString:@"\n"];
  }
  
  id params = [self childEnumerator];
  id param;
  /* Required parameters */
  while (param = [params nextObject]) {
    if (![param isOptional]) {
      [stream closeStyle];
      [stream setASDictionaryStyle:kASStyleStandard];
      [stream appendString:@"\t\t"];
      
      [param appendStringToStream:stream];
    }
  }
  
  /* Optionals parameters */
  params = [self childEnumerator];
  while (param = [params nextObject]) {
    if ([param isOptional]) {
      [stream closeStyle];
      [stream setASDictionaryStyle:kASStyleStandard];
      [stream appendString:@"\t\t"];      
      
      [param appendStringToStream:stream];
    }
  }
  
  if ([[self result] type]) {
    [stream closeStyle];
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"\t"];

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
  id type = [self type];
  if ([type rangeOfString:@"list of" options:NSAnchoredSearch | NSLiteralSearch].location != NSNotFound) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"a list of "];
    type = [type substringFromIndex:8];
  }
  
  [stream closeStyle];
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:[self sdefTypeToASDictionaryType:type]];

  if ([[self desc] length]) {
    [stream closeStyle];
    [stream setASDictionaryStyle:kASStyleComment];
    [stream appendString:@"  -- "];
    [stream appendString:[self desc]];
  }
  [stream appendString:@"\n"];
}

@end

@implementation SdefParameter (ASDictionary)

- (void)appendStringToStream:(ASDictionaryStream *)stream {
  if ([self isOptional]) {
    [stream appendString:@"["];
  }
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleApplicationKeyword];
  [stream appendString:[self name]];
  [stream closeStyle];
  
  [stream appendString:@"  "];
  
  id type = [self type];
  if ([type rangeOfString:@"list of" options:NSAnchoredSearch | NSLiteralSearch].location != NSNotFound) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"a list of "];
    [stream closeStyle];
    type = [type substringFromIndex:8];
  }
  
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:[self sdefTypeToASDictionaryType:type]];
  
  if ([self isOptional]) {
    [stream closeStyle];
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"]"];
  }
  
  if ([[self desc] length]) {
    [stream closeStyle];
    [stream setASDictionaryStyle:kASStyleComment];
    [stream appendString:@"  -- "];
    [stream appendString:[self desc]];
  }
  [stream appendString:@"\n"];
}

@end

@implementation SdefResult (ASDictionary)

- (void)appendStringToStream:(ASDictionaryStream *)stream {
  [stream appendString:@"Result:   "];
  id type = [self type];
  if ([type rangeOfString:@"list of" options:NSAnchoredSearch | NSLiteralSearch].location != NSNotFound) {
    [stream appendString:@"a list of "];
    type = [type substringFromIndex:8];
  }
  [stream closeStyle];
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:[self sdefTypeToASDictionaryType:type]];
  
  if ([[self desc] length]) {
    [stream closeStyle];
    [stream setASDictionaryStyle:kASStyleComment];
    [stream appendString:@"  -- "];
    [stream appendString:[self desc]];
  }
  [stream appendString:@"\n"];
}

@end

