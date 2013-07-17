/*
 *  SdefLeavesValidator.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXRef.h"
#import "SdefType.h"
#import "SdefComment.h"
#import "SdefSynonym.h"
#import "SdefImplementation.h"

#import "SdefValidatorBase.h"

@implementation SdefXRef (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (!_target) {
    [messages addObject:[self invalidValue:nil forAttribute:@"target"]];
  }
  [super validate:messages forVersion:vers];
}

@end


@implementation SdefType (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (![self name]) {
    [messages addObject:[self invalidValue:nil forAttribute:@"name"]];
  }
  if (self.hidden && vers < kSdefLeopardVersion)
    [messages addObject:[self versionRequired:kSdefLeopardVersion forAttribute:@"hidden"]];
  
  [super validate:messages forVersion:vers];
}

@end

@implementation SdefComment (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (_value && [_value rangeOfString:@"--"].location != NSNotFound) {
    [messages addObject:[SdefValidatorItem errorItemWithNode:self
                                                     message:@"Invalid character sequence '--' found in comment"]];
  }
  [super validate:messages forVersion:vers];
}

@end

@implementation SdefSynonym (SdefValidator)
  
- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (![self name] && ![self code]) {
    [messages addObject:[SdefValidatorItem errorItemWithNode:self
                                                     message:@"at least one of 'name' and 'code' is required"]];
  }
  if ([self code] && !SdefValidatorCheckCode([self code])) {
    [messages addObject:[self invalidValue:[self code] forAttribute:@"code"]];
  }
  [super validate:messages forVersion:vers];
}
  
@end

@implementation SdefImplementation (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (vers < kSdefLeopardVersion) {
    if ([self valueType] != kSdefValueTypeNone)
      [messages addObject:[self versionRequired:kSdefLeopardVersion forAttribute:@"*-value"]];
    if ([self insertAtBeginning])
      [messages addObject:[self versionRequired:kSdefLeopardVersion forAttribute:@"insert-at-beginning"]];
  } else {
    switch ([self valueType]) {
      case kSdefValueTypeString:
        if (![self textValue])
          [messages addObject:[self invalidValue:nil forAttribute:@"*-value"]];
        break;
    }
  }
  [super validate:messages forVersion:vers];
}

@end

