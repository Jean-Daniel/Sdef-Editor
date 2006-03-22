/*
 *  ImporterWarning.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKWindowController.h>

@interface ImporterWarning : SKWindowController {
  IBOutlet NSTableView *warningsTable;
  NSArray *sd_warnings;
}

- (void)setWarnings:(NSArray *)warnings;

@end
