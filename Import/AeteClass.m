/*
 *  AeteClass.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "AeteObject.h"
#import "SdefClass.h"

#import <WonderBox/WBFunctions.h>

@implementation SdefClass (AeteResource)

- (NSUInteger)parseData:(Byte *)data {
  NSInteger length;
  BytePtr bytes = data;
  
  StringPtr pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  CFStringRef str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setName:SPXCFToNSString(str)];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  /* Identifier */
  OSType *identifier = (OSType *)bytes;
  [self setCode:WBStringForOSType(*identifier)];
  bytes += 4;
  
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setDesc:SPXCFToNSString(str)];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  /* Properties */
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    for (NSUInteger idx = 0; idx < *val; idx++) {
      SdefProperty *prop = [[SdefProperty alloc] init];
      bytes += [prop parseData:bytes];
      [[self properties] appendChild:prop];
    }
  }
  
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
	for (NSInteger idx = 0; idx < *val; idx++) {
      SdefElement *elt = [[SdefElement alloc] init];
      bytes += [elt parseData:bytes];
      [[self elements] appendChild:elt];
    }
  }
  
  NSUInteger total = (NSUInteger)bytes;
  total -= (NSUInteger)data;
  return total;
}

@end

#pragma mark -
@implementation SdefProperty (AeteResource)

- (NSUInteger)parseData:(Byte *)data {
  NSUInteger length;
  BytePtr bytes = data;
  
  StringPtr pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  CFStringRef str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setName:SPXCFToNSString(str)];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  /* Identifier */
  OSType *identifier = (OSType *)bytes;
  [self setCode:WBStringForOSType(*identifier)];
  bytes += 4;
  
  /* Type */
  identifier = (UInt32 *)bytes;
  [self setType:SdefStringForOSType(*identifier)];
  bytes += 4;
  
  /* Description */
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setDesc:SPXCFToNSString(str)];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  /* Result flags */
  UInt16 *val = (UInt16 *)bytes;
  if ((1 << kAEUTlistOfItems) & *val) {
    [self setType:[@"list of " stringByAppendingString:[self type]]];
  }
  if ((1 << kAEUTPlural) & *val) {
    [self setName:@"<Plural>"];
  }
  uint32_t perm = kSdefAccessRead;
  if ((1 << kAEUTReadWrite) & *val) {
    perm |= kSdefAccessWrite;
  }
  [self setAccess:perm];
  bytes += 2;
  
  NSUInteger total = (NSUInteger)bytes;
  total -= (NSUInteger)data;
  return total;
}

@end

#pragma mark -
@implementation SdefElement (AeteResource)

- (NSUInteger)parseData:(Byte *)data {
  BytePtr bytes = data;
  
  /* Type */
  OSType *identifier = (OSType *)bytes;
  [self setType:SdefStringForOSType(*identifier)];
  bytes += 4;
  
  /* Accessors */
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    for (NSUInteger idx = 0; idx < *val; idx++) {
      identifier = (OSType *)bytes;
      switch (*identifier) {
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
  
  NSUInteger total = (NSUInteger)bytes;
  total -= (NSUInteger)data;
  return total;
}

@end

