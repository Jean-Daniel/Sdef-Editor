/*
 *  SdefObjectInspector.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefObjectInspector.h"


#import "SdefObjects.h"
#import "SdefDocument.h"
#import "SdefWindowController.h"

@implementation SdefObjectInspector

+ (id)sharedInspector {
  static id inspector = nil;
  if (!inspector) {
    inspector = [[self alloc] init];
  }
  return inspector;
}

- (id)init {
  if (self = [super initWithWindowNibName:@"SdefInspector"]) {
    [self setWindowFrameAutosaveName:@"SdefObjectInspector"];
    needsUpdate = NO;
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

#pragma mark -
- (void)windowDidUpdate:(NSNotification *)notification {
  if (needsUpdate && [NSApp isActive]) {
    [self willChangeValueForKey:@"content"];
    [self didChangeValueForKey:@"content"];
    needsUpdate = NO;
  }
}

- (SdefObject *)content {
  return [sd_doc selection];
}

- (SdefDocument *)displayedDocument {
  return sd_doc;
}

- (void)setDisplayedDocument:(SdefDocument *)aDocument {
  if (sd_doc != aDocument) {
    sd_doc = aDocument;
    needsUpdate = YES;
  }
}

- (void)setMainWindow:(NSWindow *)mainWindow {
  if ([NSApp isActive]) {
    NSWindowController *controller = [mainWindow windowController];
    if (controller && [controller isKindOfClass:[SdefWindowController class]]) {
      [self setDisplayedDocument:[controller document]];
    } else {
      [self setDisplayedDocument:nil];
    }
  }
}

- (void)windowDidLoad {
  [super windowDidLoad];
  [self setMainWindow:[NSApp mainWindow]];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) name:NSWindowDidResignMainNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:SdefDictionarySelectionDidChangeNotification object:nil];
}

- (void)mainWindowChanged:(NSNotification *)aNotification {
  [self setMainWindow:[aNotification object]];
}

- (void)mainWindowResigned:(NSNotification *)aNotification {
  [self setMainWindow:nil];
}

- (void)selectionChanged:(NSNotification *)aNotification {
  if ([aNotification object] == sd_doc) {
    needsUpdate = YES;
  }
}

@end
