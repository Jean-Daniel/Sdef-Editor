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
#import "SKExtensions.h"

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
  id type = [self type];
  if ([type startsWithString:@"list of"]) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"a list of "];
    type = [type substringFromIndex:8];
    [stream closeStyle];
  }
  
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:[self sdefTypeToASDictionaryType:type]];
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
  
  id type = [self type];
  if ([type startsWithString:@"list of"]) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"a list of "];
    [stream closeStyle];
    type = [type substringFromIndex:8];
  }
  
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:[self sdefTypeToASDictionaryType:type]];
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
 
  id type = [self type];
  if ([type startsWithString:@"list of"]) {
    [stream appendString:@"a list of "];
    type = [type substringFromIndex:8];
  }
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:[self sdefTypeToASDictionaryType:type]];
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

