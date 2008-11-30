/*
 *  AeteVerb.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "AeteObject.h"
#import "SdefVerb.h"
#import "SdefArguments.h"

#import WBHEADER(WonderBoxFunctions.h)

@implementation SdefVerb (AeteResource)

- (NSUInteger)parseData:(Byte *)data {
  NSUInteger length;
  BytePtr bytes = data;
  StringPtr pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  CFStringRef str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setName:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setDesc:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  /* event class */
  OSType *identifier = (UInt32 *)bytes;
  NSString *type = WBStringForOSType(*identifier);
  bytes += 4;
  
  /* event id */
  identifier = (UInt32 *)bytes;
  [self setCode:[type stringByAppendingString:WBStringForOSType(*identifier)]];
  bytes += 4;
  
  /* Result */
  identifier = (UInt32 *)bytes;
  if (*identifier != typeNull) {
    [[self result] setType:SdefStringForOSType(*identifier)];
  }
  bytes += 4;
  
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [[self result] setDesc:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  /* Result flags */
  UInt16 *val = (UInt16 *)bytes;
  if ((1 << kAEUTlistOfItems) & *val) {
    [[self result] setType:[@"list of " stringByAppendingString:[[self result] type]]];
  }
  bytes += 2;
  
  /* Direct Parameter */
  identifier = (UInt32 *)bytes;
  if (*identifier != typeNull) {
    [[self directParameter] setType:SdefStringForOSType(*identifier)];
  }
  bytes += 4;
  
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [[self directParameter] setDesc:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (intptr_t)bytes % 2;
  
  /* Result flags */
  val = (UInt16 *)bytes;
  if ((1 << kAEUTlistOfItems) & *val) {
    [[self directParameter] setType:[@"list of " stringByAppendingString:[[self directParameter] type]]];
  }
  if ((1 << kAEUTOptional) & *val) {
    [[self directParameter] setOptional:YES];
  }
  bytes += 2;
  
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    for (NSUInteger idx = 0; idx < *val; idx++) {
      SdefParameter *param = [[SdefParameter allocWithZone:[self zone]] init];
      bytes += [param parseData:bytes];
      [self appendChild:param];
      [param release];
    }
  }

  NSUInteger total = (NSUInteger)bytes;
  total -= (NSUInteger)data;
  return total;
}

@end

@implementation SdefParameter (AeteResource)

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
  
  /* Keyword */
  OSType *identifier = (UInt32 *)bytes;
  [self setCode:WBStringForOSType(*identifier)];
  bytes += 4;
  
  /* event id */
  identifier = (UInt32 *)bytes;
  [self setType:SdefStringForOSType(*identifier)];
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
  
  /* Flags */
  UInt16 *val = (UInt16 *)bytes;
  if ((1 << kAEUTlistOfItems) & *val) {
    [self setType:[@"list of " stringByAppendingString:[self type]]];
  }
  if ((1 << kAEUTOptional) & *val) {
    [self setOptional:YES];
  }
  bytes += 2;
  
  NSUInteger total = (NSUInteger)bytes;
  total -= (NSUInteger)data;
  return total;
}

@end
