//
//  SdefLogWindowController.m
//  Sdef Editor
//
//  Created by Jean-Daniel Dupas on 18/07/13.
//
//

#import "SdefLogWindowController.h"

@interface SdefLogWindowController ()

@end

@implementation SdefLogWindowController

@synthesize logView = _logView;

- (id)init {
  return [super initWithWindowNibName:@"SdefLogWindow" owner:self];
}

- (id)initWithWindow:(NSWindow *)window {
  if (self = [super initWithWindow:window]) {
    // Initialization code here.
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  [_logView setFont:[NSFont userFixedPitchFontOfSize:0]];
}

- (void)setText:(NSString *)message {
  [self window]; // force load
  [_logView setString:message];
}

@end
