//
//  SdefEnumerationView.m
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefEnumerationView.h"
#import "SdefEnumeration.h"

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

@end
