//
//  SdefViewController.m
//  SDef Editor
//
//  Created by Grayfox on 04/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefViewController.h"
#import "SdefObject.h"

@implementation SdefViewController

- (id)initWithNibName:(NSString *)name {
  if (self = [super init]) {
    id nib = [[NSNib alloc] initWithNibNamed:name bundle:nil];
    [nib instantiateNibWithOwner:self topLevelObjects:&_nibTopLevelObjects];
    [_nibTopLevelObjects retain];
    [nib release];
  }
  return self;
}

- (void)dealloc {
  [_object release];
  [_nibTopLevelObjects release];
  [super dealloc];
}

- (NSView *)sdefView {
  return sdefView;
}

- (SdefObject *)object {
  return [[_object retain] autorelease];
}

- (void)setObject:(SdefObject *)newObject {
  if (_object != newObject) {
    [_object release];
    _object = [newObject retain];
  }
}

- (void)selectObject:(SdefObject*)object {
}

@end
