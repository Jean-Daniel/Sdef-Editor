//
//  ImporterWarning.m
//  Sdef Editor
//
//  Created by Grayfox on 29/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ImporterWarning.h"


@implementation ImporterWarning

- (id)init {
  if (self = [super initWithWindowNibName:@"SdefImporterWarning"]) {
    [self setWindowFrameAutosaveName:@"SdefWarningReport"];
  }
  return self;
}

- (void)dealloc {
  [warningsTable setDelegate:nil];
  [warningsTable setDataSource:nil];
  [sd_warnings release];
  [super dealloc];
}

- (void)awakeFromNib {

}

- (void)setWarnings:(NSArray *)warnings {
  if (sd_warnings != warnings) {
    [sd_warnings release];
    sd_warnings = [warnings retain];
    [warningsTable reloadData];
  }
}

#pragma mark -
- (void)close:(id)sender {
  if ([[self window] isSheet]) {
    [NSApp endSheet:[self window]];
  }
  [self close];
}

- (void)windowWillClose:(NSNotification *)aNotification {
  [self autorelease];
}

#pragma mark -
- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
  return [sd_warnings count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
  return [[sd_warnings objectAtIndex:rowIndex] valueForKey:[aTableColumn identifier]];
}

@end
