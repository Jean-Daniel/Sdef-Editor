//
//  SdefDocumentationView.m
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDocumentationWindow.h"
#import "SdefDocumentation.h"

@implementation SdefDocumentationWindow

+ (void)initialize {
  [self setKeys:[NSArray arrayWithObject:@"object"] triggerChangeNotificationsForDependentKey:@"title"];
}

- (id)init {
  if (self = [super initWithWindowNibName:@"SdefDocumentation"]) {
    [self window];
  }
  return self;
}

- (void)dealloc {
  [_object release];
  [super dealloc];
}

- (IBAction)close:(id)sender {
  [[[self object] documentation] setContent:[[text textStorage] string]];
  [NSApp endSheet:[self window]];
  [self close];
}

- (SdefObject *)object {
  return _object;
}

- (void)setObject:(SdefObject *)newObject {
  if (_object != newObject) {
    [_object release];
    _object = [newObject retain];
    NSTextStorage *storage = [text textStorage];
    id doc = [[_object documentation] content];
    [storage replaceCharactersInRange:NSMakeRange(0, [storage length]) withString:(doc) ? doc : nil];
    [text setEditable:[_object isEditable]];
  }
}

- (NSString *)title {
  return [NSString stringWithFormat:@"%@ documentation", [[self object] name]];
}

@end
