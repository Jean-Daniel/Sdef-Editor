//
//  ImporterWarning.h
//  Sdef Editor
//
//  Created by Grayfox on 29/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ImporterWarning : NSWindowController {
  IBOutlet NSTableView *warningsTable;
  NSArray *sd_warnings;
}

- (void)setWarnings:(NSArray *)warnings;

@end
