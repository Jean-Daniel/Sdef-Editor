//
//  CocoaObject.m
//  Sdef Editor
//
//  Created by Grayfox on 03/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "CocoaObject.h"

@implementation SdefObject (CocoaTerminology)

- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology {
  [NSException raise:NSInternalInconsistencyException format:@"Method -%@ must be implemented by subclass %@",
    NSStringFromSelector(_cmd), NSStringFromClass([self class])];
  return nil;
}

@end
