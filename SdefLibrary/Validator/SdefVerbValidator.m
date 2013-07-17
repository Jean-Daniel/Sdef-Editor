/*
 *  SdefVerbValidator.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefValidatorBase.h"

#import "SdefVerb.h"
#import "SdefArguments.h"

@implementation SdefVerb (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (![self name])
    [messages addObject:[self invalidValue:nil forAttribute:@"name"]];
  
  NSString *code = [self code];
  if (!code) {
    [messages addObject:[self invalidValue:nil forAttribute:@"code"]];
  } else {
    BOOL invalid = YES;
    if ([code length] == 10) {
      if ([code hasPrefix:@"'"] && [code hasSuffix:@"'"])
        invalid = NO;
    } else if ([code length] == 8) {
      invalid = NO;
    } else if ([code length] == 18) {
      const char *str = [code UTF8String];
      if (str)
        invalid = (0 == strtol(str, NULL, 16));
    }
    if (invalid)
      [messages addObject:[self invalidValue:code forAttribute:@"code"]];
  }
  
  [_direct validate:messages forVersion:vers];
  [_result validate:messages forVersion:vers];
  
  [super validate:messages forVersion:vers];
}

@end

@implementation SdefParameter (SdefValidator)

- (BOOL)validateType { return YES; }
- (BOOL)validateCode { return YES; }

/* bugs: cocoa->key required */

@end

#pragma mark -
@implementation SdefDirectParameter (SdefValidator)

/* type optional but must be valid if exists */
- (BOOL)validateType { return [self type] != nil; }

@end

#pragma mark -
@implementation SdefResult (SdefValidator)

/* type optional but must be valid if exists */
- (BOOL)validateType { return [self type] != nil; }

@end
