//
//  AeteSuite.m
//  Sdef Editor
//
//  Created by Grayfox on 30/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefSuite.h"
#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefTypedef.h"

#import "SKFunctions.h"

@implementation SdefSuite (AeteResource)

- (UInt32)parseData:(Byte *)data {
  unsigned length;
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
  bytes += (long)bytes % 2;
  
  OSType *ID = (UInt32 *)bytes;
  [self setCode:SKFileTypeForHFSTypeCode(*ID)];
  bytes += 4;
  
  /* skip level and version */
  bytes += 4;
  
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      id verb = [[SdefVerb allocWithZone:[self zone]] init];
      bytes += [verb parseData:bytes];
      [[self commands] appendChild:verb];
      [verb release];
    }
  }
  
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      id class = [[SdefClass allocWithZone:[self zone]] init];
      bytes += [class parseData:bytes];
      [[self classes] appendChild:class];
      [class release];
    }
  }
  
  /* Comparaison operators: ignore */
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      /* Name */
      pStr = (StringPtr)bytes;
      length = StrLength(pStr);
      bytes += length + 1;
      
      /* Alignement */
      bytes += (long)bytes % 2;
      
      /* ID */
      bytes += 4;
      
      /* Description */
      pStr = (StringPtr)bytes;
      length = StrLength(pStr);
      bytes += length + 1;
      
      /* Alignement */
      bytes += (long)bytes % 2;
    }
  }
   
  /* Enumerations */
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      id enumeration = [[SdefEnumeration allocWithZone:[self zone]] init];
      bytes += [enumeration parseData:bytes];
      [[self types] appendChild:enumeration];
      [enumeration release];
    }
  }
  
  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end
