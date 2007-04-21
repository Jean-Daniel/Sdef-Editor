/*
 *  AeteObject.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "AeteObject.h"

@implementation SdefObject (AeteResource)

- (NSUInteger)parseData:(Byte *)bytes {
  ShadowTrace();
  [NSException raise:NSInternalInconsistencyException format:@"Method must be implemented by subclasses"];
  return 0;
}

@end
