//
//  ASDictionarySuite.m
//  Sdef Editor
//
//  Created by Grayfox on 27/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#include <Carbon/Carbon.h>

#import "ASDictionaryObject.h"
#import "ASDictionaryStream.h"
#import "SKFunctions.h"
#import "SdefSuite.h"

@implementation SdefSuite (ASDictionary)

- (NSDictionary *)asdictionary {
  if (SKHFSTypeCodeFromFileType([self codeStr]) == kASTypeNamesSuite) /* Hidden terms */
    return nil;
  
  id dict = [NSMutableDictionary dictionary];
  NSString *name = [self name];
  [dict setObject:(name) ? name : @"<untitled>" forKey:@"name"];
  [dict setObject:[self asdictionaryString] forKey:@"suite description"];
  
  id classes = [NSMutableArray array];
  id objects = [[self classes] childEnumerator];
  SdefObject *object;
  while (object = [objects nextObject]) {
    @try {
      [classes addObject:[object asdictionary]];
    } @catch (id exception) {
      SKLogException(exception);
    }
  }
  if ([classes count])
    [dict setObject:classes forKey:@"classes"];
  
  /* Commands */
  id events = [NSMutableArray array];
  objects = [[self commands] childEnumerator];
  while (object = [objects nextObject]) {
    @try {
      [events addObject:[object asdictionary]];
    } @catch (id exception) {
      SKLogException(exception);
    }
  }
  /* Events */
  objects = [[self events] childEnumerator];
  while (object = [objects nextObject]) {
    @try {
      [events addObject:[object asdictionary]];
    } @catch (id exception) {
      SKLogException(exception);
    }
  }
  if ([events count])
    [dict setObject:events forKey:@"events"];
  
  return dict;
}

- (NSDictionary *)asdictionaryString {
  ASDictionaryStream *stream = [[ASDictionaryStream alloc] init];
  [stream setFontFamily:@"Times" style:bold size:18];
  NSString *name = [self name];
  [stream appendString:(name) ? : @"<untitled>"];
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
