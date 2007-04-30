/*
 *  SdefXMLValidator.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

enum {
  kSdefParserVersionUnknown = 0,
  kSdefParserVersionPanther = 1 << 0,
  kSdefParserVersionTiger   = 1 << 1,
  kSdefParserVersionLeopard = 1 << 2,
  kSdefParserVersionAll     = kSdefParserVersionPanther | kSdefParserVersionTiger | kSdefParserVersionLeopard,
};
typedef NSUInteger SdefParserVersion;

@interface SdefXMLValidator : NSObject {
  @private
  CFMutableArrayRef sd_stack;
  SdefParserVersion sd_version;
}

- (SdefParserVersion)version;

- (CFStringRef)element;
- (void)startElement:(CFStringRef)element;
- (void)endElement:(CFStringRef)element;

- (SdefParserVersion)validateElement:(CFStringRef)element attributes:(CFDictionaryRef)attributes error:(NSString **)error;

@end
