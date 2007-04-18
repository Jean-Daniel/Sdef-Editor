/*
 *  ASDictionaryObject.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "ASDictionaryObject.h"
#import "SdefClassManager.h"
#import "SdefDocument.h"
#import <ShadowKit/SKExtensions.h>

@implementation SdefObject (ASDictionary)

#if !__LP64__

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

#endif /* LP64 */

- (NSString *)asDictionaryTypeForType:(NSString *)type isList:(BOOL *)list {
  if (!type) return @"";
  if (list)
    *list = NO;
  
  if ([type hasPrefix:@"list of "]) {
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
    if (enume && [enume hasChildren]) {
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

