//
//  SdefEnumerationView.m
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefEnumerationView.h"
#import "SdefTypedef.h"

@implementation SdefEnumerationView

- (void)selectObject:(SdefObject*)anObject {
  int idx = -1;
  SdefEnumeration *content = [self object];
  if (anObject == content) idx = 0;
  else if ([anObject parent] == content) {
    idx = 1;
    [enumerators setSelectedObjects:[NSArray arrayWithObject:anObject]];
  }
  if (idx >= 0)
    [tab selectTabViewItemAtIndex:idx];
}

//- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
//  id table = [aNotification object];
//  int row = [table selectedRow];
//  if (row >= 0 && row < [[self object] childCount]) {
//    [self revealObjectInTree:[[self object] childAtIndex:row]];
//  }
//}

@end
