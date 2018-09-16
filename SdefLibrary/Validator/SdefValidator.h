/*
 *  SdefValidator.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

#import <WonderBox/WBWindowController.h>

@interface SdefValidator : WBWindowController {
  @private
  NSUInteger sd_version;
  IBOutlet NSTableView *uiTable;
  IBOutlet NSPopUpButton *uiVersion;
  IBOutlet NSArrayController *ibMessages;
}

- (IBAction)refresh:(id)sender;
- (IBAction)changeVersion:(id)sender;

- (NSUInteger)version;
- (void)setVersion:(NSUInteger)version;

@end

