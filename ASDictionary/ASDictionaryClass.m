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
  NSString *name = [self name];
  [dict setObject:(name) ? name : @"<untitled>" forKey:@"name"];
  [dict setObject:[self asdictionaryString] forKey:@"content"];
  return dict;
}

- (NSDictionary *)asdictionaryString {
  ASDictionaryStream *stream = [[ASDictionaryStream alloc] init];
  [stream setFontFamily:@"Times" style:bold | underline size:14];
  NSString *name = [self name];
  [stream appendFormat:@"Class %@: ", (name) ? name : @"<untitled>"];
  [stream closeStyle];
  
  [stream setStyle:underline];
  [stream appendString:[self desc] ? : @""];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleStandard];
  [stream appendString:@"\n"];
  [stream closeStyle];
  
  if ([self plural]) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"Plural form:\n\t"];
    [stream closeStyle];
    
    [stream setASDictionaryStyle:kASStyleApplicationKeyword];
    [stream appendString:[self plural]];
    [stream appendString:@"\n"];
    [stream closeStyle];
  }
  
  if ([[self elements] hasChildren]) {    
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"Elements:\n"];
    [stream closeStyle];
    
    id elements = [[self elements] childEnumerator];
    SdefElement *elt;
    while (elt = [elements nextObject]) {
      @try {
        [elt appendStringToStream:stream];
      } @catch (id exception) {
        SKLogException(exception);
      }
    }
  }
  
  if ([[self properties] hasChildren] || [self inherits]) {    
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"Properties:\n"];
    [stream closeStyle];
    
    if ([self inherits]) {
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
      @try {
        [prop appendStringToStream:stream];
      } @catch (id exception) {
        SKLogException(exception);
      }
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

- (void)writeAccessorsStringToStream:(id)stream {
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
}

- (void)appendStringToStream:(ASDictionaryStream *)stream {
  [stream setASDictionaryStyle:kASStyleStandard];
  [stream appendString:@"\t"];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleApplicationKeyword];
  [stream appendString:[self name] ? : @"<untitled>"];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleStandard];
  [self writeAccessorsStringToStream:stream];

  [stream appendString:@"\r"];
  [stream closeStyle];
}

@end

@implementation SdefProperty (ASDictionary) 

- (void)appendStringToStream:(ASDictionaryStream *)stream {
  [stream appendString:@"\t"];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleApplicationKeyword];
  [stream appendString:[self name] ? : @"<untitled>"];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleStandard];
  [stream appendString:@"  "];
  [stream closeStyle];
  
  [stream setASDictionaryStyle:kASStyleLanguageKeyword];
  [stream appendString:[self asDictionaryTypeForType:[self type] isList:nil]];
  [stream closeStyle];
  
  if (([self access] & kSdefAccessWrite) == 0) {
    [stream setASDictionaryStyle:kASStyleStandard];
    [stream appendString:@"  [r/o]"];
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
