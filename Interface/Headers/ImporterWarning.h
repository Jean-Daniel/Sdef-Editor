/*
 *  ImporterWarning.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKWindowController.h>

@class SdefDocument;
@interface ImporterWarning : SKWindowController {
  IBOutlet NSTableView *warningsTable;
  NSArray *sd_warnings;
  SdefDocument *sd_document;
}

- (void)setDocument:(SdefDocument *)aDocument;
- (void)setWarnings:(NSArray *)warnings;

@end
