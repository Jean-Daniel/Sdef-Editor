//
//  SdefEditor.m
//  Sdef Editor
//
//  Created by Grayfox on 19/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefEditor.h"
#import "SKFunctions.h"
#import "ShadowMacros.h"

#import "SdefSuite.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"
#import "ImporterWarning.h"
#import "CocoaSuiteImporter.h"
#import "SdefObjectInspector.h"

#if defined (DEBUG)
#import <Foundation/NSDebug.h>
#endif

int main(int argc, char *argv[]) {
#if defined (DEBUG)  
  NSDebugEnabled = YES;
  NSHangOnUncaughtException = YES;
#endif
  return NSApplicationMain(argc, (const char **) argv);
}

NSString * const ScriptingDefinitionFileType = @"ScriptingDefinition";

#if defined (DEBUG)
#import "AeteImporter.h"
@interface SdefEditor (DebugFacility)
- (void)createDebugMenu;
@end
#endif

@implementation SdefEditor

- (void)awakeFromNib {
  [NSApp setDelegate:self];
#if defined (DEBUG)
  [self createDebugMenu];
#endif
}

- (IBAction)openInspector:(id)sender {
  [[SdefObjectInspector sharedInspector] showWindow:sender];
}

- (IBAction)openSuite:(id)sender {
  id suite = nil;
  switch ([sender tag]) {
    case 1:
      suite = @"NSCoreSuite";
      break;
    case 2:
      suite = @"NSTextSuite";
      break;
  }
  NSString *suitePath = [[NSBundle mainBundle] pathForResource:suite ofType:@"sdef"];
  if (suitePath) {
    id doc = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfFile:suitePath
                                                                                     display:NO];
    [doc setFileName:nil];
    [doc showWindows];
  }
}

#pragma mark -
#pragma mark Importation
- (void)importWithImporter:(SdefImporter *)importer {
  @try {
    id suites = [importer sdefSuites];
    if ([suites count]) {
      SdefDocument *doc = [[NSDocumentController sharedDocumentController] openUntitledDocumentOfType:ScriptingDefinitionFileType display:NO];
      [[doc dictionary] removeAllChildren];
      
      suites = [suites objectEnumerator];
      SdefSuite *suite;
      while (suite = [suites nextObject]) {
        [[doc dictionary] appendChild:suite];
      }

      [[doc undoManager] removeAllActions];
      [doc updateChangeCount:NSChangeCleared];
      [doc showWindows];
      
      if ([importer warnings]) {
        ImporterWarning *alert = [[ImporterWarning alloc] init];
        [alert setWarnings:[importer warnings]];
        [alert showWindow:nil];
      }
    } else {
      NSRunAlertPanel(@"Importation failed!", @"Sdef Editor cannot import this file. Is it in a valid format?", @"OK", nil, nil);
    }
  } @catch (id exception) {
    SKLogException(exception);
    NSBeep();
  }
}

- (IBAction)importCocoaTerminology:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:NSLocalizedString(@"Import", @"Import a Cocoa Terminology.")];
  [openPanel setMessage:NSLocalizedString(@"Choose a Cocoa .scriptSuite File", @"Choose Cocoa File Import Message.")];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setTreatsFilePackagesAsDirectories:YES];
  switch([openPanel runModalForTypes:[NSArray arrayWithObject:@"scriptSuite"]]) {
    case NSCancelButton:
      return;
  }
  if (![[openPanel filenames] count]) return;
  
  id file = [[openPanel filenames] objectAtIndex:0];
  CocoaSuiteImporter *importer = [[CocoaSuiteImporter alloc] initWithContentsOfFile:file];
  if (![importer terminology]) {
    [openPanel setPrompt:@"Open Terminology"];
    [openPanel setMessage:[NSString stringWithFormat:@"Where is %@.scriptTerminology?",
      [[file lastPathComponent] stringByDeletingPathExtension]]];
    switch([openPanel runModalForTypes:[NSArray arrayWithObject:@"scriptTerminology"]]) {
      case NSCancelButton:
        [importer release];
        return;
    }
    if (![[openPanel filenames] count]) {
      [importer release];
      return;
    }
    [importer setTerminology:[NSDictionary dictionaryWithContentsOfFile:[[openPanel filenames] objectAtIndex:0]]];
  }
  [self importWithImporter:importer];
  [importer release];
}

- (IBAction)importAete:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:NSLocalizedString(@"Import", @"Import default button.")];
  [openPanel setMessage:NSLocalizedString(@"Choose an aete Rsrc File", @"Choose aete File Import Message.")];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setTreatsFilePackagesAsDirectories:YES];
  switch([openPanel runModalForTypes:[NSArray arrayWithObjects:@"rsrc", NSFileTypeForHFSTypeCode('rsrc'), nil]]) {
    case NSCancelButton:
      return;
  }
  if (![[openPanel filenames] count]) return;
  
  id file = [[openPanel filenames] objectAtIndex:0];
  id aete = [[AeteImporter alloc] initWithContentsOfFile:file];
  [self importWithImporter:aete];
  [aete release];
}

#pragma mark -
#pragma mark Application Delegate
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
  return NO;
}

#pragma mark -
#pragma mark Debug Menu
#if defined (DEBUG)
- (void)createDebugMenu {
  /*
  id debugMenu = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
  id menu = [[NSMenu alloc] initWithTitle:@"Debug"];
  [menu addItemWithTitle:@"Import 'aete'" action:@selector(importAete:) keyEquivalent:@""];
  [debugMenu setSubmenu:menu];
  [menu release];
  [[NSApp mainMenu] insertItem:debugMenu atIndex:[[NSApp mainMenu] numberOfItems] -1];
  [debugMenu release];
   */
}

#endif

@end
