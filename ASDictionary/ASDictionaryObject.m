//
//  ASDictionaryObject.m
//  Sdef Editor
//
//  Created by Grayfox on 27/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ASDictionaryObject.h"
#import "SdefClassManager.h"
#import "SdefDocument.h"
#import "SKExtensions.h"
#import "ShadowBase.h"

@implementation SdefObject (ASDictionary)

- (NSDictionary *)asdictionary {
  [NSException raise:NSInternalInconsistencyException format:@"Method %@ must be implemented by sublass %@", 
    NSStringFromSelector(_cmd), NSStringFromClass([self class])];
  return nil;
}

- (NSDictionary *)asdictionaryString {
  [NSException raise:NSInternalInconsistencyException format:@"Method %@ must be implemented by sublass %@", 
    NSStringFromSelector(_cmd), NSStringFromClass([self class])];
  return nil;
}

- (NSString *)asDictionaryTypeForType:(NSString *)type isList:(BOOL *)list {
  if (!type) return @"";
  if (list)
    *list = NO;
  
  if ([type startsWithString:@"list of "]) {
    if (list)
      *list = YES;
    type = [type substringFromIndex:8];
  }
  
  SEL equalSel = @selector(isEqualToString:);
  EqualIMP equal = (EqualIMP)[type methodForSelector:equalSel];
  
  if (equal(type, equalSel, @"string"))
    return @"Unicode text";
  if (equal(type, equalSel, @"real"))
    return @"small real";
  if (equal(type, equalSel, @"type"))
    return @"type class";
  if (equal(type, equalSel, @"file"))
    return @"alias";
  if (equal(type, equalSel, @"object"))
    return @"reference";
  if (equal(type, equalSel, @"location"))
    return @"location reference";
  if (equal(type, equalSel, @"any"))
    return @"anything";
  if (equal(type, equalSel, @"rectangle"))
    return @"bounding rectangle";
  id manager = [self classManager];
  if (manager) {
    id enume = [manager enumerationWithName:type];
    if (enume) {
      id str = [NSMutableString string];
      id values = [enume childEnumerator];
      id value = [values nextObject];
      while (value) {
        [str appendString:[value name]];
        value = [values nextObject];
        if (value)
          [str appendString:@"/"];
      }
      return str;
    }
  }
  return type;
}

@end
