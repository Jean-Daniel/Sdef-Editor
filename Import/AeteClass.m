//
//  AeteClass.m
//  Sdef Editor
//
//  Created by Grayfox on 30/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "AeteObject.h"
#import "SdefClass.h"
#import "SKFunctions.h"

@implementation SdefClass (AeteResource)

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
  
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setDesc:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (long)bytes % 2;
  
  /* Properties */
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      SdefProperty *prop = [SdefProperty node];
      bytes += [prop parseData:bytes];
      [[self properties] appendChild:prop];
    }
  }
  
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      SdefElement *elt = [SdefElement node];
      bytes += [elt parseData:bytes];
      [[self elements] appendChild:elt];
    }
  }
  
  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end

#pragma mark -
@implementation SdefProperty (AeteResource)

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
  
  /* Type */
  ID = (UInt32 *)bytes;
  [self setType:SKFileTypeForHFSTypeCode(*ID)];
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
  
  /* Result flags */
  UInt16 *val = (UInt16 *)bytes;
  if ((1 << kAEUTlistOfItems) & *val) {
    [self setType:[@"list of " stringByAppendingString:[self type]]];
  }
  if ((1 << kAEUTPlural) & *val) {
    [self setName:@"<Plural>"];
  }
  unsigned access = kSdefAccessRead;
  if ((1 << kAEUTReadWrite) & *val) {
    access |= kSdefAccessWrite;
  }
  [self setAccess:access];
  bytes += 2;
  
  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end

#pragma mark -
@implementation SdefElement (AeteResource)

- (UInt32)parseData:(char *)data {
  BytePtr bytes = data;
  
  /* Type */
  OSType *ID = (OSType *)bytes;
  [self setType:SKFileTypeForHFSTypeCode(*ID)];
  bytes += 4;
  
  /* Accessors */
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      ID = (OSType *)bytes;
      switch (*ID) {
        case formAbsolutePosition:
          [self setAccIndex:YES];
          break;
        case formRelativePosition:
          [self setAccRelative:YES];
          break;
        case formTest:
          [self setAccTest:YES];
          break;
        case formRange:
          [self setAccRange:YES];
          break;
        case formUniqueID:
        case formPropertyID:
          [self setAccId:YES];
          break;
        case formName:
          [self setAccName:YES];
          break;
      }
      bytes += 4;
    }
  }
  
  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end

