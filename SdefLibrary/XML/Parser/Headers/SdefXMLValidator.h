/*
 *  SdefXMLValidator.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

enum {
  kSdefParserVersionUnknown = 0,
  kSdefParserVersionPanther = 1 << 0,
  kSdefParserVersionTiger   = 1 << 1,
  kSdefParserVersionLeopard = 1 << 2,
  kSdefParserVersionMountainLion = 1 << 3,

  kSdefParserVersionAll     = kSdefParserVersionPanther | kSdefParserVersionTiger | kSdefParserVersionLeopard | kSdefParserVersionMountainLion,
  kSdefParserVersionTigerAndLater = kSdefParserVersionTiger | kSdefParserVersionLeopard | kSdefParserVersionMountainLion,
  kSdefParserVersionLeopardAndLater = kSdefParserVersionLeopard | kSdefParserVersionMountainLion,
  kSdefParserVersionMountainLionAndLater = kSdefParserVersionMountainLion,

  kSdefValidatorVersionMask = 0x00ff,
  
  kSdefValidatorElementError   = 1 << 8,
  kSdefValidatorAttributeError = 2 << 8,
  kSdefValidatorErrorMask = 0xff00,
};
typedef NSUInteger SdefValidatorResult;
typedef NSUInteger SdefValidatorVersion;

@interface SdefXMLValidator : NSObject {
@private
  NSMutableArray *sd_stack;
  SdefValidatorVersion sd_version;
}

- (SdefValidatorVersion)version;

- (NSString *)element;
- (void)startElement:(NSString *)element;
- (void)endElement:(NSString *)element;

- (SdefValidatorResult)validateElement:(NSString *)element attributes:(NSDictionary *)attributes error:(NSString **)error;

@end
