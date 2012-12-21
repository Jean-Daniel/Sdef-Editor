/*
 *  SdefClassView.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefWindowController.h"

#import <WonderBox/NSTabView+WonderBox.h>
#import <WonderBox/NSArrayController+WonderBox.h>

#import "SdefClassView.h"
#import "SdefClassManager.h"
#import "SdefContents.h"
#import "SdefClass.h"
#import "SdefVerb.h"

@implementation SdefClassView

- (void)awakeFromNib {
  [commandTable setTarget:self];
  [commandTable setDoubleAction:@selector(revealCommand:)];
  [eventTable setTarget:self];
  [eventTable setDoubleAction:@selector(revealEvent:)];
}

- (void)revealCommand:(id)sender {
  NSInteger row = [sender clickedRow];
  SdefCollection *objs = [(SdefClass *)[self object] commands];
  if (row >= 0 && row < (int)[objs count]) {
    SdefVerb *cmd = [[self classManager] commandWithIdentifier:[[objs childAtIndex:row] name]];
    if (cmd)
      [self revealObjectInTree:cmd];
  }
}

- (void)revealEvent:(id)sender {
  NSInteger row = [sender clickedRow];
  SdefCollection *objs = [(SdefClass *)[self object] events];
  if (row >= 0 && row < (int)[objs count]) {
    SdefVerb *event = [[self classManager] eventWithIdentifier:[[objs childAtIndex:row] name]];
    if (event)
      [self revealObjectInTree:event];
  }
}

- (void)setObject:(SdefObject *)anObject {
  [super setObject:anObject];
  sd_idx = -1;
}

- (void)selectObject:(SdefObject*)anObject {
  int idx = -1;
  NSArrayController *controller = nil;
  SdefObject *parent = [anObject parent];
  SdefClass *content = [self object];
  if (anObject == content) idx = sd_idx;
  else if (anObject == [content contents]) { idx = 1; }
  else if (anObject == [content elements] || parent == [content elements]) {
    idx = 2;
    controller = elements;
  } else if (anObject == [content properties] || parent == [content properties]) {
    idx = 3;
    controller = properties;
  } else if (anObject == [content commands] || parent == [content commands]) {
    idx = 4;
    controller = commands;
  } else if (anObject == [content events] || parent == [content events]) {
    idx = 5;
    controller = events;
  }
  if (idx >= 0)
    [tab selectTabViewItemAtIndex:idx];
  if (controller) {
    [controller setSelectedObject:anObject];
  }
  sd_idx = 0;
}

- (id)editedObject:(id)sender {
  SdefClass *class = [self object];
  switch ([tab indexOfSelectedTabViewItem]) {
    case 1:
      return [class contents];
    case 2:
      return [elements selectedObject];
    case 3:
      return [properties selectedObject];
    case 4:
      return [commands selectedObject];
    case 6:
      return [events selectedObject];
  }
  return nil;
}

@end
