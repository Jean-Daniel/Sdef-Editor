//
//  SdefEditor.m
//  Sdef Editor
//
//  Created by Grayfox on 19/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefEditor.h"
#import "ShadowMacros.h"
#import "SdefObjectInspector.h"

@implementation SdefEditor

- (void)awakeFromNib {
  [NSApp setDelegate:self];
}

- (IBAction)openInspector:(id)sender {
  [[SdefObjectInspector sharedInspector] showWindow:sender];
}


@end
