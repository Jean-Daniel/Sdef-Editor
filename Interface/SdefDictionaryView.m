//
//  SdefDictionaryView.m
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDictionaryView.h"
#import "SdefDictionary.h"
#import "SdefSuite.h"

@implementation SdefDictionaryView

- (void)awakeFromNib {
  [suitesTable setTarget:self];
  [suitesTable setDoubleAction:@selector(revealInTree:)];
}

- (IBAction)addSuite:(id)sender {
  [[self object] appendChild:[SdefSuite node]];
}

@end
