//
//  SdefClassView.m
//  SDef Editor
//
//  Created by Grayfox on 12/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefClassView.h"
#import "SdefClassManager.h"
#import "SdefContents.h"
#import "SdefClass.h"

@implementation SdefClassView

- (void)awakeFromNib {
  [commandTable setTarget:self];
  [commandTable setDoubleAction:@selector(revealCommand:)];
  [eventTable setTarget:self];
  [eventTable setDoubleAction:@selector(revealEvent:)];
}

- (void)revealCommand:(id)sender {
  int row = [sender clickedRow];
  id objs = [(SdefClass *)[self object] commands];
  if (row >= 0 && row < [objs childCount]) {
    id cmd = [[self classManager] commandWithName:[[objs childAtIndex:row] name]];
    if (cmd)
      [self revealObjectInTree:cmd];
  }
}

- (void)revealEvent:(id)sender {
  int row = [sender clickedRow];
  id objs = [(SdefClass *)[self object] events];
  if (row >= 0 && row < [objs childCount]) {
    id event = [[self classManager] eventWithName:[[objs childAtIndex:row] name]];
    if (event)
      [self revealObjectInTree:event];
  }
}

- (void)selectObject:(SdefObject*)anObject {
  int idx = -1;
  NSArrayController *controller = nil;
  SdefObject *parent = [anObject parent];
  SdefClass *content = [self object];
  if (anObject == content) idx = 0;
  else if (anObject == [content contents]) { idx = 1; }
  else if (anObject == [content properties] || parent == [content properties]) {
    idx = 2;
    controller = properties;
  } else if (anObject == [content elements] || parent == [content elements]) {
    idx = 3;
    controller = elements;
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
    [controller setSelectedObjects:[NSArray arrayWithObject:anObject]];
  }
}


@end
