//
//  SdefTypeValidator.m
//  Sdef Editor
//
//  Created by Jean-Daniel Dupas on 23/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SdefValidatorBase.h"

#import "SdefTypedef.h"


@implementation SdefEnumeration (SdefValidator)

- (BOOL)validateCode { return YES; }

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (![self hasChildren]) {
    [messages addObject:[SdefValidatorItem errorItemWithNode:self 
                                                     message:@"enumeration must contains at least one enumerator."]];
  }
  [super validate:messages forVersion:vers];
}

@end

@implementation SdefEnumerator (SdefValidator)

- (BOOL)validateCode { return YES; }

@end

@implementation SdefValue (SdefValidator)

- (BOOL)validateCode { return YES; }

@end

@implementation SdefRecord (SdefValidator)

- (BOOL)validateCode { return YES; }

- (void)validate:(NSMutableArray *)messages forVersion:(SdefVersion)vers {
  if (![self hasChildren]) {
    [messages addObject:[SdefValidatorItem errorItemWithNode:self 
                                                     message:@"record must contains at least one property."]];
  }
  [super validate:messages forVersion:vers];
}

@end
