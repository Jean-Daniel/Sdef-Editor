/*
 *  CocoaObject.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "CocoaObject.h"

@implementation SdefObject (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  [NSException raise:NSInternalInconsistencyException format:@"Method -%@ must be implemented by subclass %@",
    NSStringFromSelector(_cmd), NSStringFromClass([self class])];
  return nil;
}

@end
