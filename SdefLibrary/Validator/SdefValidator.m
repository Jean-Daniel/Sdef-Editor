/*
 *  SdefValidator.m
 *  Sdef Editor
 *
 *  Created by Grayfox on 22/04/07.
 *  Copyright 2007 Shadow Lab. All rights reserved.
 */

#import "SdefValidator.h"
#import "SdefValidatorBase.h"
#import "SdefWindowController.h"

#import "SdefBase.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"

@implementation SdefValidator

- (id)init {
  if (self = [super init]) {
    sd_version = kSdefLeopardVersion;
  }
  return self;
}

- (void)dealloc {
  ShadowTrace();
  [sd_messages release];
  [super dealloc];
}

#pragma mark -
- (void)awakeFromNib {
  [uiVersion selectItemWithTag:sd_version];
  [uiTable setTarget:self];
  [uiTable setDoubleAction:@selector(reveal:)];
  [self refresh:nil];
}

- (IBAction)reveal:(id)sender {
  NSInteger row;
  if (sender == uiTable) {
    row = [uiTable clickedRow];
  } else {
    row = [uiTable selectedRow];
  }
  if (row >= 0) {
    SdefValidatorItem *item = [sd_messages objectAtIndex:row];
    [[[self document] documentWindow] setSelection:[[item object] container]];
  }
}

- (IBAction)refresh:(id)sender {
  SdefDictionary *dict = [(SdefDocument *)[self document] dictionary];
  if (sd_messages) [sd_messages release];
  sd_messages = [[NSMutableArray alloc] init];
  [dict validate:sd_messages forVersion:sd_version];
  [uiTable reloadData];
}

- (IBAction)changeVersion:(id)sender {
  [self setVersion:[uiVersion selectedTag]];
}

- (NSUInteger)version {
  return sd_version;
}
- (void)setVersion:(NSUInteger)version {
  if (version != sd_version) {
    sd_version = version;
    [self refresh:nil];
  }
}

#pragma mark Data Source
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [sd_messages count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  return [[sd_messages objectAtIndex:row] valueForKey:[tableColumn identifier]];
}

@end

@implementation SdefValidatorItem

- (id)initWithLevel:(UInt8)level node:(NSObject<SdefObject> *)node message:(NSString *)message args:(va_list)args {
  if (self = [super init]) {
    sd_level = level;
    sd_object = [node retain];
    sd_message = [[NSString alloc] initWithFormat:message arguments:args];
  }
  return self;
}

+ (id)noteItemWithNode:(NSObject<SdefObject> *)aNode message:(NSString *)msg, ... {
  va_list args;
  va_start(args, msg);
  id item = [[[self alloc] initWithLevel:1 node:aNode message:msg args:args] autorelease];
  va_end(args);
  return item;
}
+ (id)errorItemWithNode:(NSObject<SdefObject> *)aNode message:(NSString *)msg, ... {
  va_list args;
  va_start(args, msg);
  id item = [[[self alloc] initWithLevel:3 node:aNode message:msg args:args] autorelease];
  va_end(args);
  return item;
}
+ (id)warningItemWithNode:(NSObject<SdefObject> *)aNode message:(NSString *)msg, ... {
  va_list args;
  va_start(args, msg);
  id item = [[[self alloc] initWithLevel:2 node:aNode message:msg args:args] autorelease];
  va_end(args);
  return item;
}

- (void)dealloc {
  [sd_object release];
  [sd_message release];
  [super dealloc];
}

#pragma mark -
- (NSObject<SdefObject> *)object {
  return sd_object;
}

- (NSImage *)icon {
  return [sd_object icon];
}

- (NSString *)name {
  return [sd_object name];
}

- (NSString *)type {
  return [sd_object objectTypeName];
}

- (NSString *)message {
  return sd_message;
}

- (NSString *)location {
  return [sd_object location];
}

- (NSUInteger)level {
  return sd_level;
}

- (NSImage *)levelIcon {
  switch (sd_level) {
    case 1:
      return [NSImage imageNamed:@"valid-note"];
    case 2:
      return [NSImage imageNamed:@"valid-warning"];
    case 3:
      return [NSImage imageNamed:@"valid-error"];
  }
  return nil;
}

@end
