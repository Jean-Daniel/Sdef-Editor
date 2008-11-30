/*
 *  SdefClassValidator.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefValidatorBase.h"
#import "SdefClassManager.h"
#import "SdefClass.h"

@implementation SdefClass (SdefValidator)

- (BOOL)validateCode { return ![self isExtension]; }

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (![self name]) {
    [messages addObject:[self invalidValue:nil forAttribute:@"name"]];
  } else if (SdefValidatorIsKeyword([self name])) {
    [messages addObject:[SdefValidatorItem warningItemWithNode:self
                                                       message:@"'%@' is an applescript keyword and should not be used", [self name]]];
  } else {
    NSString *code = SdefValidatorCodeForName([self name]);
    if (code && [self code]) {
      if (!SdefTypeStringEqual(code, [self code]))
        [messages addObject:[SdefValidatorItem warningItemWithNode:self
                                                           message:@"the name '%@' should use the code '%@' to avoid conflict", [self name], code]];
    }
  }
  
  /* should be a simple type */
  if (sd_type) {
    if ([sd_type rangeOfString:@"list of "].location != NSNotFound ||
        [sd_type rangeOfString:@"|"].location != NSNotFound) {
      [messages addObject:[self invalidValue:sd_type forAttribute:@"type"]];
    }
  }
  
  /* class-extension */
  if ([self isExtension] && vers < kSdefLeopardVersion) {
    [messages addObject:[self versionRequired:kSdefLeopardVersion forElement:@"class-extension"]];
  }
  
  /* contents */
  if (sd_contents) {
    [sd_contents validate:messages forVersion:vers];
  }
  
  /* super class */
  if (sd_inherits) {
    SdefClassManager *manager = [self classManager];
    if (manager && ![manager classWithName:sd_inherits]) {
      [messages addObject:[SdefValidatorItem warningItemWithNode:self
                                                         message:@"super class '%@' not found", sd_inherits]];
    }
  }
  
  /* bugs: cocoa->class required */
  
  [super validate:messages forVersion:vers];
}

@end

@implementation SdefElement (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
//  if (sd_accessors && sd_accessors != 0x3f) {
//    [messages addObject:[SdefValidatorItem noteItemWithNode:self message:@"using accessors but cocoa scripting ignores them"]];
//  }
  
  /* should be a simple type */
  NSString *type = [self type];
  if (!type) {
    [messages addObject:[self invalidValue:type forAttribute:@"type"]];
  } else if ([type rangeOfString:@"list of "].location != NSNotFound ||
             [type rangeOfString:@"|"].location != NSNotFound) {
    [messages addObject:[self invalidValue:type forAttribute:@"type"]];
  } else if (![SdefClassManager isBaseType:type]) {
    SdefClassManager *manager = [self classManager];
    if (![manager typeWithName:type]) {
      [messages addObject:[SdefValidatorItem warningItemWithNode:self
                                                         message:@"unknown type '%@'", type]];
    }
  }
  
  [super validate:messages forVersion:vers];
}

@end

@implementation SdefProperty (SdefValidator)

- (BOOL)validateCode { return YES; }
- (BOOL)validateType { return YES; }

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (![self name]) {
    [messages addObject:[self invalidValue:nil forAttribute:@"name"]];
  } else if (SdefValidatorIsKeyword([self name])) {
    [messages addObject:[SdefValidatorItem warningItemWithNode:self
                                                       message:@"'%@' is an applescript keyword and should not be used", [self name]]];
  } else {
    NSString *code = SdefValidatorCodeForName([self name]);
    if (code && [self code]) {
      if (!SdefTypeStringEqual(code, [self code]))
        [messages addObject:[SdefValidatorItem warningItemWithNode:self
                                                           message:@"the name '%@' should use the code '%@' to avoid conflict", [self name], code]];
    }
  }
  [super validate:messages forVersion:vers];
}


@end

@implementation SdefRespondsTo (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (![self name]) {
    [messages addObject:[self invalidValue:nil forAttribute:@"command"]];
  } else if (![[self classManager] verbWithIdentifier:[self name]]) {
    [messages addObject:[SdefValidatorItem warningItemWithNode:self
                                                       message:@"command/event '%@' not found", [self name]]];
  }
  
  /* bugs: cocoa->method required */
  [super validate:messages forVersion:vers];
}

@end


