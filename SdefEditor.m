//
//  SdefEditor.m
//  Sdef Editor
//
//  Created by Grayfox on 19/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefEditor.h"
#import "SKFunctions.h"
#import "SKExtensions.h"
#import "ShadowMacros.h"
#import "SKApplication.h"

#import "SdefSuite.h"
#import "Preferences.h"
#import "SdefDocument.h"
#import "AeteImporter.h"
#import "SdefDictionary.h"
#import "ImporterWarning.h"
#import "CocoaSuiteImporter.h"
#import "SdefObjectInspector.h"
#import "SdefWindowController.h"
#import "ImportApplicationAete.h"

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
const OSType kScriptingDefinitionHFSType = 'Sdef';
NSString * const CocoaSuiteDefinitionFileType = @"AppleScriptSuiteDefinition";
const OSType kCocoaSuiteDefinitionHFSType = 'ScSu';

#if defined (DEBUG)
@interface SdefEditor (DebugFacility)
- (void)createDebugMenu;
@end
#endif

@interface SdefDocumentController : NSDocumentController {
}
@end

@implementation SdefEditor

- (id)init {
  if (self = [super init]) {
    [[SdefDocumentController alloc] init];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
      SKBool(YES), @"SdefOpenAtStartup",
      SKBool(YES), @"SdefBuildInSdp",
      SKBool(YES), @"SdefBuildInRez",
      SKBool(YES), @"SdefAutoSelectItem",
      @"/Developer/Tools/sdp", @"SdefSdpToolPath",
      @"/Developer/Tools/Rez", @"SdefRezToolPath",
      nil]];
    [NSApp setDelegate:self];
#if defined (DEBUG)
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
      //@"YES", @"NSShowNonLocalizedStrings",
      @"NO", @"NSShowAllViews",
      //@"6", @"NSDragManagerLogLevel",
      //@"YES", @"NSShowNonLocalizableStrings",
      //    @"1", @"NSScriptingDebugLogLevel",
      nil]];
#endif
  }
  return self;
}

- (void)awakeFromNib {
#if defined (DEBUG)
  [self createDebugMenu];
#endif
}

- (IBAction)openInspector:(id)sender {
  [[SdefObjectInspector sharedInspector] showWindow:sender];
}

- (IBAction)preferences:(id)sender {
  static Preferences *preferences = nil;
  if (!preferences) {
    preferences = [[Preferences alloc] init];
  }
  [preferences showWindow:sender];
}

- (IBAction)releaseNotes:(id)sender {
  [[NSHelpManager sharedHelpManager] openHelpAnchor:@"SdefReleaseNotes" inBook:@"Sdef Editor Help"];
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
    case 3:
      suite = @"ASKDictionary";
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
        [alert setReleaseWhenClose:YES];
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

- (void)importCocoaScriptFile:(NSString *)file {
  CocoaSuiteImporter *importer = [[CocoaSuiteImporter alloc] initWithContentsOfFile:file];
  if (![importer terminology]) {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setTreatsFilePackagesAsDirectories:YES];
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
  [self importCocoaScriptFile:file];
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
  switch([openPanel runModalForTypes:nil]) {
    case NSCancelButton:
      return;
  }
  if (![[openPanel filenames] count]) return;
  
  id file = [[openPanel filenames] objectAtIndex:0];
  id aete = [[AeteImporter alloc] initWithContentsOfFile:file];
  [self importWithImporter:aete];
  [aete release];
}

- (IBAction)importApplicationAete:(id)sender {
  ImportApplicationAete *panel = [[ImportApplicationAete alloc] init];
  [panel showWindow:sender];
  [NSApp runModalForWindow:[panel window]];
  SKApplication *appli = [panel selection];
  if (appli) {
    if (![appli isRunning]) {
      [appli launch];
    }
    id aete = nil;
    switch ([appli idType]) {
      case kSKApplicationOSType:
        aete = [[AeteImporter alloc] initWithApplicationSignature:[appli signature]]; 
        break;
      case kSKApplicationBundleIdentifier:
        aete = [[AeteImporter alloc] initWithApplicationBundleIdentifier:[appli identifier]];
        break;
      default:
        aete = nil;
    }
    if (aete) {
      [self importWithImporter:aete];
      [aete release];
    } else {
      NSBeep();
    }
  }
  [panel release];
}

#pragma mark -
#pragma mark Application Delegate
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
  id type = [[NSDocumentController sharedDocumentController] typeFromFileExtension:[filename pathExtension]];
  if ([type isEqualToString:ScriptingDefinitionFileType]) return NO;
  else if ([type isEqualToString:CocoaSuiteDefinitionFileType]) {
    [self importCocoaScriptFile:filename];
    return YES;
  }
  return NO;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
  return [[NSUserDefaults standardUserDefaults] boolForKey:@"SdefOpenAtStartup"];
}

#pragma mark -
#pragma mark Debug Menu
#if defined (DEBUG)
- (void)createDebugMenu {
//  id debugMenu = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
//  id menu = [[NSMenu alloc] initWithTitle:@"Debug"];
//  [menu addItemWithTitle:@"Create XHTML dictionary" action:@selector(SdtplExporter:) keyEquivalent:@""];
//  [debugMenu setSubmenu:menu];
//  [menu release];
//  [[NSApp mainMenu] insertItem:debugMenu atIndex:[[NSApp mainMenu] numberOfItems] -1];
//  [debugMenu release];
}

#endif

@end

@implementation SdefDocumentController

- (void)noteNewRecentDocument:(NSDocument *)aDocument {
  id path = [aDocument fileName];
  if (![path hasPrefix:[[NSBundle mainBundle] bundlePath]]) {
    [super noteNewRecentDocument:aDocument];
  }
}

@end
