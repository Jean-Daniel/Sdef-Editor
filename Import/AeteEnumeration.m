//
//  AeteEnumeration.m
//  Sdef Editor
//
//  Created by Grayfox on 30/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "AeteObject.h"
#import "SKFunctions.h"
#import "SdefEnumeration.h"

@implementation SdefEnumeration (AeteResource)

- (UInt32)parseData:(char *)data {
  BytePtr bytes = data;
  
  /* Identifier */
  OSType *ID = (OSType *)bytes;
  [self setCodeStr:SKFileTypeForHFSTypeCode(*ID)];
  [self setName:[self codeStr]];
  bytes += 4;
  
  /* Enumerators */
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      SdefEnumerator *enumerator = [[SdefEnumerator allocWithZone:[self zone]] init];
      bytes += [enumerator parseData:bytes];
      [self appendChild:enumerator];
      [enumerator release];
    }
  }
  
  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end

@implementation SdefEnumerator (AeteResource)

- (UInt32)parseData:(char *)data {
  unsigned length;
  BytePtr bytes = data;
  
  StringPtr pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  CFStringRef str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setName:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (long)bytes % 2;
  
  /* Identifier */
  OSType *ID = (OSType *)bytes;
  [self setCodeStr:SKFileTypeForHFSTypeCode(*ID)];
  bytes += 4;
  
  /* Description */
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setDesc:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (long)bytes % 2;
  
  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end
