/*
 *  ImportApplicationAete.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "ImportApplicationAete.h"
#import <WonderBox/WBAliasedApplication.h>

#import "AeteImporter.h"
#import "SdefEditor.h"

@implementation ImportApplicationAete

+ (NSString *)frameAutoSaveName {
  return nil;
}

- (void)awakeFromNib {
  NSMenu *menu = [popup menu];
  
  ProcessSerialNumber psn = {kNoProcess, kNoProcess};
  CFDictionaryRef info;
  while (procNotFound != GetNextProcess(&psn))  {
    BOOL hidden = NO;
    info = ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
    if (info) {
      if (![[(id)info objectForKey:@"FileCreator"] isEqualToString:@"SdEd"]) {
        CFBooleanRef value = CFDictionaryGetValue(info, CFSTR("LSUIElement"));
        hidden = hidden || (value && CFBooleanGetValue(value));
        
        value = CFDictionaryGetValue(info, CFSTR("LSBackgroundOnly"));
        hidden = hidden || (value && CFBooleanGetValue(value));
        
        if (!hidden) {
          WBApplication *appli = [[WBAliasedApplication alloc] initWithProcessSerialNumber:&psn];
          NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[appli name] action:nil keyEquivalent:@""];
          NSImage *icon = [appli icon];
          [icon setScalesWhenResized:YES];
          [icon setSize:NSMakeSize(16, 16)];
          [menuItem setImage:icon];
          [menuItem setRepresentedObject:appli];
          [menu insertItem:menuItem atIndex:0];
          [menuItem release];
          [appli release];
        }
      }
      CFRelease(info);
      info = NULL;
    }
  }
  [popup selectItemAtIndex:0];
}

- (void)dealloc {
  [super dealloc];
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
  WBApplication *appli = [WBAliasedApplication applicationWithPath:[file path]];
  NSMenuItem *item = [popup itemWithTitle:[appli name]];
  if (!item) {
    item = [[NSMenuItem alloc] initWithTitle:[appli name] action:nil keyEquivalent:@""];
    NSImage *icon = [appli icon];
    [icon setScalesWhenResized:YES];
    [icon setSize:NSMakeSize(16, 16)];
    [item setImage:icon];
    [item setRepresentedObject:appli];
    [[popup menu] insertItem:item atIndex:0];
    [item release];
  }
  [popup selectItem:item];
}

@end
