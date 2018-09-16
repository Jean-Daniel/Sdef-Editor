/*
 *  ImportApplicationAete.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "ImportApplicationAete.h"
#import <WonderBox/WBApplication.h>

#import "AeteImporter.h"
#import "SdefEditor.h"

@implementation ImportApplicationAete

+ (NSString *)frameAutoSaveName {
  return nil;
}

- (void)awakeFromNib {
  NSMenu *menu = [popup menu];

  for (NSRunningApplication *app in NSWorkspace.sharedWorkspace.runningApplications) {
    if ([app.bundleIdentifier isEqualToString:NSBundle.mainBundle.bundleIdentifier])
      continue;

    if (app.activationPolicy != NSApplicationActivationPolicyRegular)
      continue;

    WBApplication *appli = [[WBApplication alloc] initWithProcessIdentifier:app.processIdentifier];
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[appli name] action:nil keyEquivalent:@""];
    NSImage *icon = app.icon;
    [icon setScalesWhenResized:YES];
    [icon setSize:NSMakeSize(16, 16)];
    [menuItem setImage:icon];
    [menuItem setRepresentedObject:appli];
    [menu insertItem:menuItem atIndex:0];
  }
  [popup selectItemAtIndex:0];
}

- (void)windowDidLoad {
  [super windowDidLoad];
  [[self window] center];
}

- (WBApplication *)selection {
  return selection;
}

- (IBAction)import:(id)sender {
  selection = [[popup selectedItem] representedObject];
  [self close:sender];
}

- (IBAction)choose:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:NSLocalizedString(@"Choose", @"Choose App default button.")];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setTreatsFilePackagesAsDirectories:NO];
  [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"app", kUTTypeApplication, nil]];
  switch ([openPanel runModal]) {
    case NSCancelButton:
      return;
  }
  if ([[openPanel URLs] count] == 0)
    return;
  NSURL *file = [openPanel URL];
  WBApplication *appli = [WBApplication applicationWithURL:file];
  NSMenuItem *item = [popup itemWithTitle:[appli name]];
  if (!item) {
    item = [[NSMenuItem alloc] initWithTitle:[appli name] action:nil keyEquivalent:@""];
    NSImage *icon = [appli icon];
    [icon setScalesWhenResized:YES];
    [icon setSize:NSMakeSize(16, 16)];
    [item setImage:icon];
    [item setRepresentedObject:appli];
    [[popup menu] insertItem:item atIndex:0];
  }
  [popup selectItem:item];
}

@end
