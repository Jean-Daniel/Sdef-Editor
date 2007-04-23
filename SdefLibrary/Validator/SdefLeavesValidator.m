//
//  SdefLeavesValidator.m
//  Sdef Editor
//
//  Created by Jean-Daniel Dupas on 23/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SdefXRef.h"
#import "SdefType.h"
#import "SdefComment.h"

#import "SdefValidatorBase.h"

@implementation SdefXRef (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (!sd_target) {
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
  [super validate:messages forVersion:vers];
}

@end

@implementation SdefComment (SdefValidator)

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (sd_value && [sd_value rangeOfString:@"--"].location != NSNotFound) {
    [messages addObject:[SdefValidatorItem errorItemWithNode:self
                                                     message:@"Invalid character sequence '--' found in comment"]];
  }
  [super validate:messages forVersion:vers];
}

@end
