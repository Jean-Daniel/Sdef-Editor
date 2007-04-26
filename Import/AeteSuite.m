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

@implementation SdefSuite (AeteResource)

- (NSUInteger)parseData:(Byte *)data {
  NSUInteger length;
  BytePtr bytes = data;
  StringPtr pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  CFStringRef str = CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman);
  [self setName:(id)str];
  bytes += length + 1;
  CFRelease(str);
  
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman);
  [self setDesc:(id)str];
  bytes += length + 1;
  CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  OSType *identifier = (UInt32 *)bytes;
  [self setCode:SKStringForOSType(*identifier)];
  bytes += 4;
  
  /* skip level and version */
  bytes += 4;
  
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    for (NSUInteger idx = 0; idx < *val; idx++) {
      SdefVerb *verb = [[SdefVerb allocWithZone:[self zone]] init];
      bytes += [verb parseData:bytes];
      [[self commands] appendChild:verb];
      [verb release];
    }
  }
  
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    for (NSUInteger idx = 0; idx < *val; idx++) {
      SdefClass *class = [[SdefClass allocWithZone:[self zone]] init];
      bytes += [class parseData:bytes];
      [[self classes] appendChild:class];
      [class release];
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
      SdefEnumeration *enumeration = [[SdefEnumeration allocWithZone:[self zone]] init];
      bytes += [enumeration parseData:bytes];
      [[self types] appendChild:enumeration];
      [enumeration release];
    }
  }
  
  NSUInteger total = (NSUInteger)bytes;
  total -= (NSUInteger)data;
  return total;
}

@end
