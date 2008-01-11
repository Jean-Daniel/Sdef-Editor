/*
 *  ImporterWarning.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import WBHEADER(WBWindowController.h)

@class SdefDocument;
@interface ImporterWarning : WBWindowController {
  IBOutlet NSTableView *warningsTable;
  NSArray *sd_warnings;
  SdefDocument *sd_document;
}

- (void)setDocument:(SdefDocument *)aDocument;
- (void)setWarnings:(NSArray *)warnings;

@end
