//
//  ASDictionarySuite.m
//  Sdef Editor
//
//  Created by Grayfox on 27/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ASDictionaryObject.h"
#import "ASDictionaryStream.h"
#import "SdefSuite.h"

@implementation SdefSuite (ASDictionary)

- (NSDictionary *)asdictionary {
  id dict = [NSMutableDictionary dictionary];
  [dict setObject:[self name] forKey:@"name"];
  [dict setObject:[self asdictionaryString] forKey:@"suite description"];
  
  id classes = [NSMutableArray array];
  id objects = [[self classes] childEnumerator];
  SdefObject *object;
  while (object = [objects nextObject]) {
    [classes addObject:[object asdictionary]];
  }
  if ([classes count])
    [dict setObject:classes forKey:@"classes"];
  
  id events = [NSMutableArray array];
  objects = [[self commands] childEnumerator];
  while (object = [objects nextObject]) {
    [events addObject:[object asdictionary]];
  }
  objects = [[self events] childEnumerator];
  while (object = [objects nextObject]) {
    [events addObject:[object asdictionary]];
  }
  if ([events count])
    [dict setObject:events forKey:@"events"];
  return dict;
}

- (NSDictionary *)asdictionaryString {
  ASDictionaryStream *stream = [[ASDictionaryStream alloc] init];
  [stream setFontFamily:@"Times" style:bold size:18];
  [stream appendString:[self name]];
  [stream appendString:@": "];
  [stream closeStyle];
  
  [stream setStyle:bold | italic];
  [stream appendString:[self desc] ? : @""];
  [stream appendString:@"\n\r"];
  [stream closeStyle];
  
  id dict = [stream asDictionaryString];
  [stream release];
  return dict;
}

@end
