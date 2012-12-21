/*
 *  AeteEnumeration.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "AeteObject.h"
#import "SdefTypedef.h"

#import <WonderBox/WBFunctions.h>

@implementation SdefEnumeration (AeteResource)

- (NSUInteger)parseData:(Byte *)data {
  BytePtr bytes = data;
  
  /* Identifier */
  OSType *identifier = (OSType *)bytes;
  [self setCode:WBStringForOSType(*identifier)];
  [self setName:[self code]];
  bytes += 4;
  
  /* Enumerators */
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
	for (NSUInteger idx = 0; idx < *val; idx++) {
      SdefEnumerator *enumerator = [[SdefEnumerator allocWithZone:[self zone]] init];
      bytes += [enumerator parseData:bytes];
      [self appendChild:enumerator];
      [enumerator release];
    }
  }
  
  NSUInteger total = (NSUInteger)bytes;
  total -= (NSUInteger)data;
  return total;
}

@end

@implementation SdefEnumerator (AeteResource)

- (NSUInteger)parseData:(Byte *)data {
  NSUInteger length;
  BytePtr bytes = data;
  
  StringPtr pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  CFStringRef str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setName:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  /* Identifier */
  OSType *identifier = (OSType *)bytes;
  [self setCode:WBStringForOSType(*identifier)];
  bytes += 4;
  
  /* Description */
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setDesc:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  NSUInteger total = (NSUInteger)bytes;
  total -= (NSUInteger)data;
  return total;
}

@end
