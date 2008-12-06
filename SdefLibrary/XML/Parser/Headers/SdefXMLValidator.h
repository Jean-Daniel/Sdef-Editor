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
  kSdefValidatorVersionMask = 0x00ff,
  
  kSdefValidatorElementError   = 1 << 8,
  kSdefValidatorAttributeError = 2 << 8,
  kSdefValidatorErrorMask = 0xff00,
};
typedef NSUInteger SdefValidatorResult;
typedef NSUInteger SdefValidatorVersion;

@interface SdefXMLValidator : NSObject {
  @private
  CFMutableArrayRef sd_stack;
  SdefValidatorVersion sd_version;
}

- (SdefValidatorVersion)version;

- (CFStringRef)element;
- (void)startElement:(CFStringRef)element;
- (void)endElement:(CFStringRef)element;

- (SdefValidatorResult)validateElement:(CFStringRef)element attributes:(CFDictionaryRef)attributes error:(NSString **)error;

@end
