//
//  SdefSuiteView.m
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefSuiteView.h"
#import "SdefSuite.h"

@implementation SdefSuiteView

- (void)awakeFromNib {
  [typeTable setTarget:self];
  [typeTable setDoubleAction:@selector(revealType:)];
  [classTable setTarget:self];
  [classTable setDoubleAction:@selector(revealClass:)];
  [commandTable setTarget:self];
  [commandTable setDoubleAction:@selector(revealCommand:)];
  [eventTable setTarget:self];
  [eventTable setDoubleAction:@selector(revealEvent:)];
}

- (void)revealType:(id)sender {
  int row = [sender clickedRow];
  id objs = [(SdefSuite *)[self object] types];
  if (row >= 0 && row < [objs childCount]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)revealClass:(id)sender {
  int row = [sender clickedRow];
  id objs = [[self object] classes];
  if (row >= 0 && row < [objs childCount]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)revealCommand:(id)sender {
  int row = [sender clickedRow];
  id objs = [(SdefSuite *)[self object] commands];
  if (row >= 0 && row < [objs childCount]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)revealEvent:(id)sender {
  int row = [sender clickedRow];
  id objs = [[self object] events];
  if (row >= 0 && row < [objs childCount]) {
    [self revealObjectInTree:[objs childAtIndex:row]];
  }
}

- (void)selectObject:(SdefObject*)anObject {
  int idx = -1;
  SdefSuite *content = [self object];
  if (anObject == content) idx = 0;
  else if (anObject == [content types]) idx = 1;
  else if (anObject == [content classes]) idx = 2;
  else if (anObject == [content commands]) idx = 3;
  else if (anObject == [content events]) idx = 4;
  if (idx >= 0)
    [tab selectTabViewItemAtIndex:idx];
}

@end
