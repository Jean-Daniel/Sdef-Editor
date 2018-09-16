/*
 *  SdefEditor.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefEditor.h"

#import <WonderBox/WBLSFunctions.h>
#import <WonderBox/WBApplication.h>

#import "SdefSuite.h"
#import "Preferences.h"
#import "SdefDocument.h"
#import "AeteImporter.h"
#import "SdefDictionary.h"
#import "ImporterWarning.h"
#import "OSASdefImporter.h"
#import "CocoaSuiteImporter.h"
#import "SdefObjectInspector.h"
#import "ImportApplicationAete.h"

#if defined (DEBUG)
#import <Foundation/NSDebug.h>
#endif

enum {
  kSdefEditorCurrentVersion = 0x010600, /* 1.6.0 */
};

int main(int argc, const char *argv[]) {
#if defined (DEBUG)  
  NSDebugEnabled = YES;
#endif
  return NSApplicationMain(argc, argv);
}

NSString * const ScriptingDefinitionFileType = @"ScriptingDefinition";
NSString * const ScriptingDefinitionFileUTI = @"com.apple.scripting-definition";

const OSType kScriptingDefinitionHFSType = 'Sdef';
NSString * const CocoaSuiteDefinitionFileType = @"AppleScriptSuiteDefinition";
const OSType kCocoaSuiteDefinitionHFSType = 'ScSu';

@interface SdefEditor (DebugFacility)
- (void)createDebugMenu;
@end

@interface SdefDocumentController : NSDocumentController {
}
@end

@implementation SdefEditor

- (id)init {
  if (self = [super init]) {
		/* Assume we are using Xcode 2.5 or later */
//    NSString *sdp = @"/Developer/usr/bin/sdp";
//		NSString *rez = @"/Developer/usr/bin/Rez";
    /* Initialize custom controller */
    SdefDocumentController *ctrl = [[SdefDocumentController alloc] init];
    if ([ctrl respondsToSelector:@selector(setAutosavingDelay:)]) {
      [ctrl setAutosavingDelay:60];
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
     @"SdefOpenAtStartup" : @(YES),
     @"SdefAutoSelectItem" : @(YES),
//      sdp, @"SdefSdpToolPath",
//      rez, @"SdefRezToolPath",
     }];
    [NSApp setDelegate:self];
#if defined (DEBUG)
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
     @"SdefDebugMenu" : @(YES),
     @"SdefPantherExportEnabled" : @(YES),
     // @"YES", @"NSShowNonLocalizedStrings",
      // @"NO", @"NSShowAllViews",
      // @"6", @"NSDragManagerLogLevel",
      // @"YES", @"NSShowNonLocalizableStrings",
      // @"1", @"NSScriptingDebugLogLevel",
     }];
#endif
  } 
  return self;
}

- (void)showWelcome {
  SPXTrace();
}

- (void)awakeFromNib {
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SdefDebugMenu"])
    [self createDebugMenu];
#if __LP64__
  NSMenu *file = [[[NSApp mainMenu] itemWithTag:1] submenu];
  NSMenuItem *export = [file itemWithTag:2];
  if (export) {
    NSMenuItem *item  = [[export submenu] itemAtIndex:0];
    if (item) {
      [[export submenu] removeItem:item]; // WARNING: item lifecycle
      [item setTitle:NSLocalizedString(@"Create Dictionary...", @"Create dictionary 64 bits title")];
      NSInteger idx = [file indexOfItem:export];
      [file removeItem:export];
      [file insertItem:item atIndex:idx];
    }
  }
#endif
  
  NSUInteger version = [[NSUserDefaults standardUserDefaults] integerForKey:@"SdefEditorVersion"];
  if (version < kSdefEditorCurrentVersion) {
    [[NSUserDefaults standardUserDefaults] setInteger:kSdefEditorCurrentVersion forKey:@"SdefEditorVersion"];
    [self showWelcome];
  }
}

- (IBAction)openInspector:(id)sender {
  [[SdefObjectInspector sharedInspector] showWindow:sender];
}

- (IBAction)preferences:(id)sender {
  static Preferences *preferences = nil;
  if (!preferences) {
    preferences = [[Preferences alloc] init];
		[[preferences window] center];
  }
  [preferences showWindow:sender];
}

- (IBAction)releaseNotes:(id)sender {
  [[NSHelpManager sharedHelpManager] openHelpAnchor:@"SdefReleaseNotes" inBook:@"Sdef Editor Help"];
}

- (IBAction)openSuite:(id)sender {
  NSString *suite = nil;
  switch ([sender tag]) {
    case 1:
      suite = @"NSCoreSuite";
      break;
    case 2:
      suite = @"NSTextSuite";
      break;
    case 3:
      suite = @"AppleScriptKit";
      break;
    case 4:
      suite = @"Skeleton";
      break;
  }
  NSString *suitePath = [[NSBundle mainBundle] pathForResource:suite ofType:@"sdef"];
  if (suitePath) {
    NSDocumentController *ctrl = [NSDocumentController sharedDocumentController];
    [ctrl openDocumentWithContentsOfURL:[NSURL fileURLWithPath:suitePath] display:NO
                      completionHandler:
     ^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error) {
       if (document) {
         [document setFileURL:nil];
         [document makeWindowControllers];
         [document showWindows];
       } else if (error) {
         [NSApp presentError:error];
       }
     }];
  }
}

- (IBAction)openSdefReference:(id)sender {
  
}

#pragma mark -
#pragma mark Importation
- (IBAction)openApplicationTerminology:(id)sender {
  ImportApplicationAete *panel = [[ImportApplicationAete alloc] initWithWindowNibName:@"ImportApplicationSdef"];
  [panel showWindow:sender];
  [NSApp runModalForWindow:[panel window]];
  WBApplication *appli = [panel selection];
  if (appli) {
    NSURL *url = appli.URL;
    
    SdefImporter *importer = [[OSASdefImporter alloc] initWithURL:url];
    [self importWithImporter:importer];
  }
}

- (void)importWithImporter:(SdefImporter *)importer {
  @try {
    NSArray *suites = [importer sdefSuites];
    SdefDictionary *dico = [importer sdefDictionary];
    if ([dico hasChildren] || [suites count]) {
      NSError *error = nil;
      SdefDocument *doc = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:NO error:&error];
      if (!doc) {
        if (error) [NSApp presentError:error];
      } else if (dico) {
        [doc setDictionary:dico];
      } else if ([suites count]) {
        [[doc dictionary] removeAllChildren];
        
        for (SdefSuite *suite in suites) {
          [[doc dictionary] appendChild:suite];
        }
        [[doc undoManager] removeAllActions];
        [doc updateChangeCount:NSChangeCleared];
      }
      [doc makeWindowControllers];
      [doc showWindows];
      
      if ([importer warnings]) {
        ImporterWarning *alert = [[ImporterWarning alloc] init];
        [alert setDocument:doc];
        [alert setWarnings:[importer warnings]];
        [alert setReleasedWhenClosed:YES];
        [alert showWindow:nil];
      }
    } else {
      NSRunAlertPanel(@"Importation failed!", @"Sdef Editor cannot import this file. Is it in a valid format?", @"OK", nil, nil);
    }
  } @catch (id exception) {
    SPXLogException(exception);
    NSBeep();
  }
}

- (void)importCocoaScriptFile:(NSString *)file {
  CocoaSuiteImporter *importer = [[CocoaSuiteImporter alloc] initWithContentsOfFile:file];
  if ([importer preload]) {
    [self importWithImporter:importer];
  } else {
    NSRunAlertPanel(@"Sorry! Sdef Editor cannot import this definition", @"Try with desdp(1) tools (see 'man desdp')", @"OK", nil, nil);
  }
}

- (IBAction)importCocoaTerminology:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Import"];
  [openPanel setMessage:@"Choose a Cocoa .scriptSuite File"];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setTreatsFilePackagesAsDirectories:YES];
  [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"scriptSuite"]];
  switch([openPanel runModal]) {
    case NSCancelButton:
      return;
  }
  if (![[openPanel URLs] count]) return;
  
  NSURL *file = [[openPanel URLs] objectAtIndex:0];
  [self importCocoaScriptFile:[file path]];
}

- (IBAction)importAete:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Import"];
  [openPanel setMessage:@"Choose an aete Rsrc File"];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setTreatsFilePackagesAsDirectories:YES];
  switch([openPanel runModal]) {
    case NSCancelButton:
      return;
  }
  if (![[openPanel URLs] count]) return;
  
  NSURL *file = [[openPanel URLs] objectAtIndex:0];
  AeteImporter *aete = [[AeteImporter alloc] initWithContentsOfFile:[file path]];
  [self importWithImporter:aete];
}

- (IBAction)importSystemSuites:(id)sender {
  AeteImporter *aete = [[AeteImporter alloc] initWithSystemSuites];
  if (aete)
    [self importWithImporter:aete];
}

- (IBAction)importApplicationAete:(id)sender {
  ImportApplicationAete *panel = [[ImportApplicationAete alloc] init];
  [panel showWindow:sender];
  [NSApp runModalForWindow:[panel window]];
  WBApplication *appli = [panel selection];
  if (appli) {
    if (![appli isRunning]) {
      [appli launch];
    }
    AeteImporter *aete = nil;
    NSString *bid = [appli bundleIdentifier];
    if (bid)
      aete = [[AeteImporter alloc] initWithApplicationBundleIdentifier:bid];
    
    if (aete) {
      [self importWithImporter:aete];
    } else {
      NSBeep();
    }
  }
}

#pragma mark -
#pragma mark Application Delegate
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
  Boolean isapp = false;
  NSString *type = [[NSDocumentController sharedDocumentController] typeFromFileExtension:[filename pathExtension]];
  if ([type isEqualToString:CocoaSuiteDefinitionFileType]) {
    [self importCocoaScriptFile:filename];
    return YES;
  } else {
    NSURL *url = [NSURL fileURLWithPath:filename];
    if ((noErr == WBLSIsApplicationAtURL(SPXNSToCFURL(url), &isapp)) && isapp) {
      SdefImporter *importer = [[OSASdefImporter alloc] initWithURL:url];
      [self importWithImporter:importer];
      return YES;
    }
  }
  /* lets document manager handle it */
  return NO;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
  return [[NSUserDefaults standardUserDefaults] boolForKey:@"SdefOpenAtStartup"];
}

#pragma mark -
#pragma mark Debug Menu
- (void)createDebugMenu {
  NSMenuItem *debugMenu = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
  NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Debug"];
  [menu addItemWithTitle:@"Import System Suites" action:@selector(importSystemSuites:) keyEquivalent:@""];
  [debugMenu setSubmenu:menu];
  [[NSApp mainMenu] insertItem:debugMenu atIndex:[[NSApp mainMenu] numberOfItems] -1];
}

@end

@implementation SdefDocumentController

- (void)noteNewRecentDocument:(NSDocument *)aDocument {
  NSString *path = [[aDocument fileURL] path];
  if (![path hasPrefix:[[NSBundle mainBundle] bundlePath]]) {
    [super noteNewRecentDocument:aDocument];
  }
}

@end
