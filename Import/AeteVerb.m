//
//  AeteVerb.m
//  Sdef Editor
//
//  Created by Grayfox on 30/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "AeteObject.h"
#import "SdefVerb.h"
#import "SdefArguments.h"
#import "SKFunctions.h"

@implementation SdefVerb (AeteResource)

- (UInt32)parseData:(char *)data {
  unsigned length;
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
  bytes += (long)bytes % 2;
  
  /* event class */
  OSType *ID = (UInt32 *)bytes;
  NSString *type = SKFileTypeForHFSTypeCode(*ID);
  bytes += 4;
  
  /* event id */
  ID = (UInt32 *)bytes;
  [self setCodeStr:[type stringByAppendingString:SKFileTypeForHFSTypeCode(*ID)]];
  bytes += 4;
  
  /* Result */
  ID = (UInt32 *)bytes;
  if (*ID != typeNull) {
    [[self result] setType:SKFileTypeForHFSTypeCode(*ID)];
  }
  bytes += 4;
  
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [[self result] setDesc:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (long)bytes % 2;
  
  /* Result flags */
  UInt16 *val = (UInt16 *)bytes;
  if ((1 << kAEUTlistOfItems) & *val) {
    [[self result] setType:[@"list of " stringByAppendingString:[[self result] type]]];
  }
  bytes += 2;
  
  /* Direct Parameter */
  ID = (UInt32 *)bytes;
  if (*ID != typeNull) {
    [[self directParameter] setType:SKFileTypeForHFSTypeCode(*ID)];
  }
  bytes += 4;
  
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [[self directParameter] setDesc:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (long)bytes % 2;
  
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
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      SdefParameter *param = [[SdefParameter allocWithZone:[self zone]] init];
      bytes += [param parseData:bytes];
      [self appendChild:param];
      [param release];
    }
  }

  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end

@implementation SdefParameter (AeteResource)

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
  
  /* Keyword */
  OSType *ID = (UInt32 *)bytes;
  [self setCodeStr:SKFileTypeForHFSTypeCode(*ID)];
  bytes += 4;
  
  /* event id */
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
  
  /* Flags */
  UInt16 *val = (UInt16 *)bytes;
  if ((1 << kAEUTlistOfItems) & *val) {
    [self setType:[@"list of " stringByAppendingString:[self type]]];
  }
  if ((1 << kAEUTOptional) & *val) {
    [self setOptional:YES];
  }
  bytes += 2;
  
  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end
