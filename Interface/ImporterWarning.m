/*
 *  ImporterWarning.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "ImporterWarning.h"

@implementation ImporterWarning

+ (NSString *)nibName {
  return @"SdefImporterWarning";
}

+ (NSString *)frameAutoSaveName {
  return @"SdefWarningReport";
}

- (void)dealloc {
  [warningsTable setDelegate:nil];
  [warningsTable setDataSource:nil];
  [sd_warnings release];
  [super dealloc];
}

#pragma mark -
- (void)setWarnings:(NSArray *)warnings {
  if (sd_warnings != warnings) {
    [sd_warnings release];
    sd_warnings = [warnings retain];
    [warningsTable reloadData];
  }
}

#pragma mark -
- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
  return [sd_warnings count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
  return [[sd_warnings objectAtIndex:rowIndex] valueForKey:[aTableColumn identifier]];
}

@end
