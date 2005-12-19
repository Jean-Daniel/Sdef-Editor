//
//  ImportApplicationAete.m
//  Sdef Editor
//
//  Created by Grayfox on 31/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ImportApplicationAete.h"
#import <ShadowKit/SKApplication.h>
#import <ShadowKit/SKImageUtils.h>
#import "AeteImporter.h"
#import "SdefEditor.h"

@implementation ImportApplicationAete

+ (NSString *)frameAutoSaveName {
  return nil;
}

- (void)awakeFromNib {
  id menu = [popup menu];
  
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
          id appli = [[SKApplication alloc] initWithProcessSerialNumber:&psn];
          id menuItem = [[NSMenuItem alloc] initWithTitle:[appli name] action:nil keyEquivalent:@""];
          [menuItem setImage:SKResizedIcon([appli icon], NSMakeSize(16, 16))];
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

- (SKApplication *)selection {
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
  switch ([openPanel runModalForTypes:[NSArray arrayWithObjects:@"app", NSFileTypeForHFSTypeCode('APPL'), nil]]) {
    case NSCancelButton:
      return;
  }
  if ([[openPanel filenames] count] == 0) return;
  id file = [[openPanel filenames] objectAtIndex:0];
  id appli = [SKApplication applicationWithPath:file];
  id item = [popup itemWithTitle:[appli name]];
  if (!item) {
    item = [[NSMenuItem alloc] initWithTitle:[appli name] action:nil keyEquivalent:@""];
    [item setImage:SKResizedIcon([appli icon], NSMakeSize(16, 16))];
    [item setRepresentedObject:appli];
    [[popup menu] insertItem:item atIndex:0];
    [item release];
  }
  [popup selectItem:item];
}

@end
