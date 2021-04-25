/*
 *  SdtplWindow.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdtplWindow.h"

#import "SdefTemplate.h"
#import "SdefDocument.h"
#import "SdtplGenerator.h"
#import "SdefWindowController.h"

#import <WonderBox/WBCollapseView.h>
#import <WonderBox/WBCollapseViewItem.h>

@interface SdtplWindow () <WBCollapseViewDelegate>

@end

@implementation SdtplWindow

+ (void)initialize {
  if ([SdtplWindow class] == self) {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
      @(0x03), @"SdtplDislosurePanel", /* 1 << 0 & 1 << 1 => the two first view are opened */
      nil]];
  }
}

+ (NSString *)nibName {
  return @"SdtplExport";
}

+ (NSString *)frameAutoSaveName {
  return nil;
}

- (id)initWithDocument:(SdefDocument *)aDoc {
  if (self = [super init]) {
    sd_document = aDoc;
  }
  return self;
}

#pragma mark -
- (void)awakeFromNib {
  /* Init Disclosure Panel */
  WBCollapseViewItem *item = [[WBCollapseViewItem alloc] initWithView:generalView identifier:@"general"];
  item.title = @"General";
  [collapseView addItem:item];

  item = [[WBCollapseViewItem alloc] initWithView:tocView identifier:@"toc"];
  item.title = @"Table Of Content";
  [collapseView addItem:item];

  item = [[WBCollapseViewItem alloc] initWithView:htmlView identifier:@"options"];
  item.title = @"HTML Options";
  [collapseView addItem:item];

  item = [[WBCollapseViewItem alloc] initWithView:infoView identifier:@"description"];
  item.title = @"Description";
  [collapseView addItem:item];

  NSScrollView *scroll = [collapseView enclosingScrollView];
  // 10.6 compat
  if ([scroll respondsToSelector:@selector(setHorizontalScrollElasticity:)]) {
    [scroll setHorizontalScrollElasticity:NSScrollElasticityNone];
    [scroll setVerticalScrollElasticity:NSScrollElasticityNone];
  }

  // Patch responder chain before collasping view
  [self.window recalculateKeyViewLoop];
  
  NSUInteger prefs = [[NSUserDefaults standardUserDefaults] integerForKey:@"SdtplDislosurePanel"];
  NSUInteger itemIdx = 0;
  for (item in collapseView) {
    item.animates = NO;
    [item setExpanded:(prefs & (1 << itemIdx++)) != 0];
  }
  
  NSRect size = [collapseView bounds];
  NSRect scrollsize = [[collapseView enclosingScrollView] bounds];
  CGFloat delta = scrollsize.size.height - size.size.height;
  NSRect frame = [self.window frame];
  frame.origin.y += delta;
  frame.size.height -= delta;
  [self.window setFrame:frame display:NO animate:NO];

  /* Init Templates Menu */
  NSArray *tpls = [[SdefTemplate findAllTemplates] allValues];
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
  tpls = [tpls sortedArrayUsingDescriptors:@[sort]];

  NSUInteger idx = [tpls count];
  while (idx-- > 0) {
    SdefTemplate *tpl = [tpls objectAtIndex:idx];
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[tpl menuName] action:nil keyEquivalent:@""];
    [menuItem setRepresentedObject:tpl];
    [[templates menu] insertItem:menuItem atIndex:0];
  }
  
  [templates selectItemAtIndex:0];
  [self changeTemplate:templates];
}

- (void)collapseView:(WBCollapseView *)aView didSetExpanded:(BOOL)expanded forItem:(WBCollapseViewItem *)anItem {
  NSRect size = [collapseView bounds];
  NSRect scrollsize = [[collapseView enclosingScrollView] bounds];

  CGFloat delta = scrollsize.size.height - size.size.height;
  NSRect frame = [self.window frame];
  frame.origin.y += delta;
  frame.size.height -= delta;
  [self.window setFrame:frame display:YES animate:NO];
}

#pragma mark -
- (IBAction)close:(id)sender {
  NSInteger prefs = 0;
  NSUInteger itemIdx = 0;
  for (WBCollapseViewItem *item in collapseView) {
    BOOL state = [item isExpanded] ? 1 : 0;
    prefs |= (state << itemIdx++);
  }
  [[NSUserDefaults standardUserDefaults] setInteger:prefs forKey:@"SdtplDislosurePanel"];
  [super close:sender];
}

- (IBAction)export:(id)sender {
  [NSApp endSheet:self.window];
  [self.window close];
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setCanSelectHiddenExtension:YES];
  [panel setTitle:@"Create Dictionary"];
  [panel setAllowedFileTypes:[NSArray arrayWithObject:[sd_template extension]]];
  [panel setNameFieldStringValue:[[sd_document displayName] stringByDeletingPathExtension]];
  [panel beginSheetModalForWindow:[[sd_document documentWindow] window]
                completionHandler:^(NSInteger result) {
                  if (NSModalResponseOK == result) {
                    NSURL *file = [panel URL];
                    @try {
                      [generator writeDictionary:[self->sd_document dictionary] toFile:[file path]];
                    } @catch (id exception) {
                      spx_log_exception(exception);
                    }
                  }
                  [self close:nil];
                }];
}

- (SdefTemplate *)selectedTemplate {
  return sd_template;
}

- (void)setSelectedTemplate:(SdefTemplate *)aTemplate {
  sd_template = aTemplate;
  [generator setTemplate:sd_template];
}

- (IBAction)changeTemplate:(id)sender {
  id selection = [sender selectedItem];
  if ([selection tag] == -1) {
    if ([self importTemplate]) {
      [sender selectItemAtIndex:0];
      [self setSelectedTemplate:[[sender itemAtIndex:0] representedObject]];
    } else {
      [sender selectItemWithTitle:[sd_template menuName]];
    }
  } else {
    [self setSelectedTemplate:[[templates selectedItem] representedObject]];
  }
}

- (BOOL)importTemplate {
  id openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setTreatsFilePackagesAsDirectories:NO];
  if ([openPanel runModalForDirectory:nil
                                 file:nil
                                types:[NSArray arrayWithObject:@"sdtpl"]] == NSModalResponseOK) {
    NSString *file = [[openPanel filenames] objectAtIndex:0];
    SdefTemplate *tpl = [[SdefTemplate alloc] initWithPath:file];
    if (tpl) {
      if ([[templates itemAtIndex:0] tag] == 0) {
        [[templates menu] insertItem:[NSMenuItem separatorItem] atIndex:0];
      }
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[tpl menuName]
                                                    action:nil
                                             keyEquivalent:@""];
      [item setRepresentedObject:tpl];
      [item setTag:1];
      [[templates menu] insertItem:item atIndex:0];
      return YES;
    }
  }
  return NO;
}

@end
