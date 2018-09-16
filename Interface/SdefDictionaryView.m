/*
 *  SdefDictionaryView.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefDictionaryView.h"
#import "SdefDictionary.h"
#import "SdefSuite.h"

@implementation SdefDictionaryView

- (void)awakeFromNib {
  [suitesTable setTarget:self];
  [suitesTable setDoubleAction:@selector(revealInTree:)];
}

- (IBAction)addSuite:(id)sender {
  SdefSuite *suite = [[SdefSuite alloc] init];
  [[self object] appendChild:suite];
}

@end
