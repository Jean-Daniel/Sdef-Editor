//
//  ASDictionaryClass.m
//  Sdef Editor
//
//  Created by Grayfox on 27/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ASDictionaryObject.h"
#import "ASDictionaryStream.h"
#import "SdefClass.h"

@interface SdefElement (ASDictionary) 
- (void)appendStringToStream:(ASDictionaryStream *)stream;
@end

@interface SdefProperty (ASDictionary) 
- (void)appendStringToStream:(ASDictionaryStream *)stream;
@end

#pragma mark -
@implementation SdefClass (ASDictionary)

- (NSDictionary *)asdictionary {
  id dict = [NSMutableDictionary dictionary];
  [dict setObject:[self name] forKey:@"name"];
  [dict setObject:[self asdictionaryString] forKey:@"content"];
  return dict;
}

- (NSDictionary *)asdictionaryString {
  ASDictionaryStream *stream = [[ASDictionaryStream alloc] init];
  [stream setFontFamily:@"Times" style:bold | underline size:14];
  [stream appendFormat:@"Class %@: ", [self name]];
  [stream closeStyle];
  
  [stream setStyle:underline];
  [stream appendString:[self desc] ? : @""];
  [stream appendString:@"\n"];
  
  if ([self plural]) {
    [stream closeStyle];
    
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"Plural form:\n\t"];
    [stream closeStyle];
    
    [stream setASDictionaryStyle:kASStyleApplicationKeyword];
    [stream appendString:[self plural]];
    [stream appendString:@"\n"];
  }
  
  if ([[self elements] hasChildren]) {
    [stream closeStyle];
    
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"Elements:\n"];
    
    id elements = [[self elements] childEnumerator];
    SdefElement *elt;
    while (elt = [elements nextObject]) {
      [stream closeStyle];
      [elt appendStringToStream:stream];
    }
  }
  
  if ([[self properties] hasChildren] || [self inherits]) {
    [stream closeStyle];
    
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"Properties:\n"];
    
    if ([self inherits]) {
      [stream closeStyle];
      SdefProperty *parent = [[SdefProperty alloc] initWithName:@"<Inheritance>"];
      [parent setType:[self inherits]];
      [parent setAccess:kSdefAccessRead];
      [parent setDesc:[NSString stringWithFormat:@"inherits some of its properties from the %@ class", [self inherits]]];
      [parent appendStringToStream:stream];
      [parent release];
    }
    id properties = [[self properties] childEnumerator];
    id prop;
    while (prop = [properties nextObject]) {
      [stream closeStyle];
      [prop appendStringToStream:stream];
    }
  }
  
  [stream appendString:@"\r"];
  [stream closeStyle];
  
  id dict = [stream asDictionaryString];
  [stream release];
  return dict;
}

@end

@implementation SdefElement (ASDictionary) 

- (void)appendStringToStream:(ASDictionaryStream *)stream {
  [stream setASDictionaryStyle:kASStyleApplicationKeyword];
  [stream appendString:@"\t"];
  [stream appendString:[self name]];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleStandard];
  
  BOOL isEmpty = YES;
  if ([self accName])  {
    isEmpty = NO;
    [stream appendString:@" by name"];
  }
  if ([self accIndex]) {
    if (!isEmpty)
      [stream appendString:@","];
    isEmpty = NO;
    [stream appendString:@" by numeric index"];
  }
  if ([self accRelative]) {
    if (!isEmpty)
      [stream appendString:@","];
    isEmpty = NO;
    [stream appendString:@" before/after another element"];
  }
  if ([self accRange]) {
    if (!isEmpty)
      [stream appendString:@","];
    isEmpty = NO;
    [stream appendString:@" as a range of elements"];
  }
  if ([self accTest]) {
    if (!isEmpty)
      [stream appendString:@","];
    isEmpty = NO;
    [stream appendString:@" satisfying a test"];
  }
  if ([self accId]) {
    if (!isEmpty)
      [stream appendString:@","];
    [stream appendString:@" by ID"];
  }
  [stream appendString:@"\n"];
}

@end

@implementation SdefProperty (ASDictionary) 

- (void)appendStringToStream:(ASDictionaryStream *)stream {
  [stream setASDictionaryStyle:kASStyleApplicationKeyword];
  [stream appendString:@"\t"];
  [stream appendString:[self name]];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleStandard];
  [stream appendString:@"  "];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:[self sdefTypeToASDictionaryType:[self type]]];
  
  if (([self access] & kSdefAccessWrite) == 0) {
    [stream closeStyle];
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"  [r/o]"];
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
