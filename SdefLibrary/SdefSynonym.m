//
//  SdefSynonym.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefSynonym.h"

@implementation SdefSynonym

- (void)dealloc {
  [super dealloc];
}

- (BOOL)hidden {
  return hidden;
}

- (void)setHidden:(BOOL)newHidden {
  if (hidden != newHidden) {
    hidden = newHidden;
  }
}

- (OSType)code {
  return code;
}

- (void)setCode:(OSType)newCode {
  if (code != newCode) {
    code = newCode;
  }
}

@end
