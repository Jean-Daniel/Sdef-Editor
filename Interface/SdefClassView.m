//
//  SdefClassView.m
//  SDef Editor
//
//  Created by Grayfox on 12/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefClassView.h"
#import "SdefContents.h"
#import "SdefClass.h"

@implementation SdefClassView

- (void)selectObject:(SdefObject*)anObject {
  int idx = -1;
  SdefObject *parent = [anObject parent];
  SdefClass *content = [self object];
  if (anObject == content) idx = 0;
  else if (anObject == [content contents]) idx = 1;
  else if (anObject == [content properties] || parent == [content properties]) idx = 2;
  else if (anObject == [content elements] || parent == [content elements]) idx = 3;
  else if (anObject == [content commands] || parent == [content commands]) idx = 4;
  else if (anObject == [content events] || parent == [content events]) idx = 5;
  if (idx >= 0)
    [tab selectTabViewItemAtIndex:idx];
}


@end
