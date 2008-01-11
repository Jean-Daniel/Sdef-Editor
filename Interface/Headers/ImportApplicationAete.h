/*
 *  ImportApplicationAete.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import WBHEADER(WBWindowController.h)

@class WBApplication;
@interface ImportApplicationAete : WBWindowController {
  IBOutlet NSPopUpButton *popup;
  WBApplication *selection;
}

- (WBApplication *)selection;

- (IBAction)import:(id)sender;
- (IBAction)choose:(id)sender;

@end
