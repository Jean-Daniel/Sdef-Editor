//
//  SdefEditor.m
//  Sdef Editor
//
//  Created by Grayfox on 19/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefEditor.h"
#import "SKFunctions.h"
#import "ShadowMacros.h"
#import "SdefObjectInspector.h"

@implementation SdefEditor

- (void)awakeFromNib {
  [NSApp setDelegate:self];
}

- (IBAction)openInspector:(id)sender {
  [[SdefObjectInspector sharedInspector] showWindow:sender];
}

- (IBAction)openSuite:(id)sender {
  id suite = nil;
  switch ([sender tag]) {
    case 1:
      suite = @"NSCoreSuite";
      break;
    case 2:
      suite = @"NSTextSuite";
      break;
  }
  NSString *suitePath = [[NSBundle mainBundle] pathForResource:suite ofType:@"sdef"];
  if (suitePath) {
    id doc = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfFile:suitePath
                                                                                     display:NO];
    [doc setFileName:nil];
    [doc showWindows];
  }
}

@end
