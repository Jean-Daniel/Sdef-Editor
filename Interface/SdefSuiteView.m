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
