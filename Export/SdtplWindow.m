//
//  SdtplWindow.m
//  Sdef Editor
//
//  Created by Grayfox on 25/03/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdtplWindow.h"
#import "SdtplPreview.h"

#import "SdefTemplate.h"
#import "SdefDocument.h"
#import "SdtplGenerator.h"
#import "SKDisclosurePanel.h"
#import "SdefWindowController.h"

@implementation SdtplWindow

+ (void)initialize {
  [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
    SKInt(0x03), @"SdtplDislosurePanel", /* 1 << 0 & 1 << 1 => the two first view are opened */
    nil]];
}

+ (NSString *)nibName {
  return @"SdtplExport";
}

+ (NSString *)frameAutoSaveName {
  return nil;
}

- (id)initWithDocument:(SdefDocument *)aDoc {
  if (self = [super init]) {
    sd_document = [aDoc retain];
  }
  return self;
}

- (void)dealloc {
  ShadowTrace();
  [sd_document release];
  if (sd_preview) {
    [sd_preview close];
    [sd_preview release];
  }
  [super dealloc];
}

#pragma mark -
- (void)awakeFromNib {
  /* Init Disclosure Panel */
  SKDisclosurePanel *panel = (SKDisclosurePanel *)[self window];
  [panel setTopPadding:37];
  [panel setBottomPadding:37];
  [panel addView:generalView withLabel:@"General"];
  [panel addView:tocView withLabel:@"Table Of Content"];
  [panel addView:htmlView withLabel:@"HTML Options"];
  
  unsigned idx;
  NSArray *views = [panel disclosureViews];
  UInt32 prefs = [[NSUserDefaults standardUserDefaults] integerForKey:@"SdtplDislosurePanel"];
  for (idx = 0; idx < [views count]; idx++) {
    [[views objectAtIndex:idx] setVisible:(prefs & (1 << idx))];
  }
  
  /* Init Templates Menu */
  id tpls = [[SdefTemplate findAllTemplates] allValues];
  id sort1 = [[NSSortDescriptor alloc] initWithKey:@"html" ascending:NO];
  id sort2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
  NSArray *sorts = [[NSArray alloc] initWithObjects:sort1, sort2, nil];
  [sort2 release];
  [sort1 release];
  
  tpls = [[tpls sortedArrayUsingDescriptors:sorts] reverseObjectEnumerator];
  [sorts release];
  
  id tpl;
  while (tpl = [tpls nextObject]) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[tpl menuName] action:nil keyEquivalent:@""];
    [item setRepresentedObject:tpl];
    [[templates menu] insertItem:item atIndex:0];
    [item release];
  }
  
  [templates selectItemAtIndex:0];
  [self changeTemplate:templates];
}

#pragma mark -
- (IBAction)close:(id)sender {
  NSArray *views = [(SKDisclosurePanel *)[self window] disclosureViews];
  unsigned idx;
  SInt32 prefs = 0;
  for (idx = 0; idx < [views count]; idx++) {
    BOOL state = [[views objectAtIndex:idx] isVisible] ? 1 : 0;
    prefs |= (state << idx);
  }
  [[NSUserDefaults standardUserDefaults] setInteger:prefs forKey:@"SdtplDislosurePanel"];
  [super close:sender];
}

- (IBAction)export:(id)sender {
  [self retain];
  [NSApp endSheet:[self window]];
  [[self window] close];
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setCanSelectHiddenExtension:YES];
  [panel setTitle:@"Create Dictionary"];
  [panel setRequiredFileType:[sd_template extension]];
  [panel beginSheetForDirectory:nil
                           file:[[sd_document displayName] stringByDeletingPathExtension]
                 modalForWindow:[[sd_document documentWindow] window]
                  modalDelegate:self
                 didEndSelector:@selector(exportPanelDidEnd:result:context:)
                    contextInfo:nil];
}

- (void)exportPanelDidEnd:(NSSavePanel *)aPanel result:(unsigned)code context:(void *)ctxt {
  if (NSOKButton == code) {
    NSString *file = [aPanel filename];
    @try {
      [generator writeDictionary:[sd_document dictionary] toFile:file];
    } @catch (id exception) {
      SKLogException(exception);
    }
  }
  [self close:nil];
  [self autorelease];
}

- (IBAction)showPreview:(id)sender {
  if (!sd_preview) {
    sd_preview = [[SdtplPreview alloc] init];
    [sd_preview setTemplate:[self selectedTemplate]];
  }
  if (![[sd_preview window] isVisible]) {
    [sd_preview refresh];
  }
  [sd_preview showWindow:sender];
}

- (void)templateDidChange:(NSNotification *)aNotification {
  if (sd_preview && [[sd_preview window] isVisible]) {
    [sd_preview refresh];
  }  
}

- (SdefTemplate *)selectedTemplate {
  return sd_template;
}

- (void)setSelectedTemplate:(SdefTemplate *)aTemplate {
  if (sd_template) {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SdefTemplateDidChangeNotification object:sd_template];
  }
  sd_template = aTemplate;
  [sd_preview setTemplate:sd_template];
  [generator setTemplate:sd_template];
  if (sd_template) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(templateDidChange:)
                                                 name:SdefTemplateDidChangeNotification
                                               object:sd_template];
  }
  [self templateDidChange:nil];
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
                                types:[NSArray arrayWithObject:@"sdtpl"]] == NSOKButton) {
    id file = [[openPanel filenames] objectAtIndex:0];
    id tpl = [[SdefTemplate alloc] initWithPath:file];
    if (tpl) {
      if ([[templates itemAtIndex:0] tag] == 0) {
        [[templates menu] insertItem:[NSMenuItem separatorItem] atIndex:0];
      }
      id item = [[NSMenuItem alloc] initWithTitle:[tpl menuName]
                                           action:nil
                                    keyEquivalent:@""];
      [item setRepresentedObject:tpl];
      [item setTag:1];
      [[templates menu] insertItem:item atIndex:0];
      [item release];
      [tpl release];
      return YES;
    }
  }
  return NO;
}

@end
