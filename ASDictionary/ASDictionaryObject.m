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

- (NSString *)sdefTypeToASDictionaryType:(NSString *)type {
  if (!type) return @"";
  
  if ([type isEqualToString:@"string"])
    return @"Unicode text";
  if ([type isEqualToString:@"real"])
    return @"small real";
  if ([type isEqualToString:@"type"])
    return @"type class";
  if ([type isEqualToString:@"file"])
    return @"alias";
  if ([type isEqualToString:@"object"])
    return @"reference";
  if ([type isEqualToString:@"location"])
    return @"location reference";
  if ([type isEqualToString:@"any"])
    return @"anything";
  if ([type isEqualToString:@"rectangle"])
    return @"bounding rectangle";
  id manager = [[self document] manager];
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
