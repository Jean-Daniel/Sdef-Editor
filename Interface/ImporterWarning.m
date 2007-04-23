/*
 *  ImporterWarning.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "ImporterWarning.h"

#import "SdefBase.h"
#import "SdefDocument.h"
#import "SdefWindowController.h"

@implementation ImporterWarning

+ (NSString *)nibName {
  return @"SdefImporterWarning";
}

+ (NSString *)frameAutoSaveName {
  return @"SdefWarningReport";
}

- (void)awakeFromNib {
  [warningsTable setTarget:self];
  [warningsTable setDoubleAction:@selector(reveal:)];
}

- (void)dealloc {
  [warningsTable setDelegate:nil];
  [warningsTable setDataSource:nil];
  [sd_warnings release];
  [super dealloc];
}

#pragma mark -
- (IBAction)reveal:(id)sender {
  NSInteger row = [sender clickedRow];
  if (row >= 0) {
    NSDictionary *item = [sd_warnings objectAtIndex:row];
    SdefObject *node = [item objectForKey:@"node"];
    if (node) {
      [[sd_document documentWindow] setSelection:[node container]];
    }
  }
}

- (void)setWarnings:(NSArray *)warnings {
  if (sd_warnings != warnings) {
    [sd_warnings release];
    sd_warnings = [warnings retain];
    [warningsTable reloadData];
  }
}

- (void)setDocument:(SdefDocument *)aDocument {
  sd_document = aDocument;
}

#pragma mark -
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
  return [sd_warnings count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
  return [[sd_warnings objectAtIndex:rowIndex] valueForKey:[aTableColumn identifier]];
}

@end
