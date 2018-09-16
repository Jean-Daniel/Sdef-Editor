/*
 *  AeteSuite.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefSuite.h"
#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefTypedef.h"

#import "AeteObject.h"

#import <WonderBox/WBFunctions.h>

@implementation SdefSuite (AeteResource)

- (NSUInteger)parseData:(Byte *)data {
  NSUInteger length;
  BytePtr bytes = data;
  StringPtr pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  CFStringRef str = CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman);
  [self setName:SPXCFToNSString(str)];
  bytes += length + 1;
  CFRelease(str);
  
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman);
  [self setDesc:SPXCFToNSString(str)];
  bytes += length + 1;
  CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  OSType *identifier = (UInt32 *)bytes;
  [self setCode:WBStringForOSType(*identifier)];
  bytes += 4;
  
  /* skip level and version */
  bytes += 4;
  
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    for (NSUInteger idx = 0; idx < *val; idx++) {
      SdefVerb *verb = [[SdefVerb alloc] init];
      bytes += [verb parseData:bytes];
      [[self commands] appendChild:verb];
    }
  }
  
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    for (NSUInteger idx = 0; idx < *val; idx++) {
      SdefClass *class = [[SdefClass alloc] init];
      bytes += [class parseData:bytes];
      [[self classes] appendChild:class];
    }
  }
  
  /* Comparaison operators: ignore */
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    for (NSUInteger idx = 0; idx < *val; idx++) {
      /* Name */
      pStr = (StringPtr)bytes;
      length = StrLength(pStr);
      bytes += length + 1;
      
      /* Alignement */
      bytes += (intptr_t)bytes % 2;
      
      /* ID */
      bytes += 4;
      
      /* Description */
      pStr = (StringPtr)bytes;
      length = StrLength(pStr);
      bytes += length + 1;
      
      /* Alignement */
      bytes += (intptr_t)bytes % 2;
    }
  }
   
  /* Enumerations */
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    for (NSUInteger idx = 0; idx < *val; idx++) {
      SdefEnumeration *enumeration = [[SdefEnumeration alloc] init];
      bytes += [enumeration parseData:bytes];
      [[self types] appendChild:enumeration];
    }
  }
  
  NSUInteger total = (NSUInteger)bytes;
  total -= (NSUInteger)data;
  return total;
}

@end
