/*
 *  SdefValidator.h
 *  Sdef Editor
 *
 *  Created by Grayfox on 22/04/07.
 *  Copyright 2007 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKWindowController.h>

@interface SdefValidator : SKWindowController {
  @private
  NSUInteger sd_version;
  NSMutableArray *sd_messages;
  IBOutlet NSTableView *uiTable;
  IBOutlet NSPopUpButton *uiVersion;
}

- (IBAction)refresh:(id)sender;
- (IBAction)changeVersion:(id)sender;

- (NSUInteger)version;
- (void)setVersion:(NSUInteger)version;

@end

