/*
 *  AeteObject.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

#import <ShadowKit/SKFunctions.h>

@interface SdefObject (AeteResource)

- (UInt32)parseData:(Byte *)bytes;

@end

SK_INLINE
NSString *AeteStringForOSType(OSType type) {
  NSString *str = SKStringForOSType(type);
  if (!str) {
    str = [NSString stringWithFormat:@"0x%.8x", OSSwapHostToBigInt32(type)];
  }
  return str;
}

