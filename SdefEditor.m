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

@implementation SdefEditor

- (void)awakeFromNib {
  [NSApp setDelegate:self];
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

- (IBAction)import:(id)sender {
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
  id file = [[openPanel filenames] objectAtIndex:0];
  CocoaSuiteImporter *importer = [[CocoaSuiteImporter alloc] initWithFile:file];
  @try {
    SdefSuite *suite = [importer sdefSuite];
    if (suite) {
      SdefDocument *doc = [[NSDocumentController sharedDocumentController] openUntitledDocumentOfType:ScriptingDefinitionFileType display:NO];
      [[doc dictionary] removeAllChildren];
      [[doc dictionary] appendChild:suite];
      [[doc undoManager] removeAllActions];
      [doc updateChangeCount:NSChangeCleared];
      [doc showWindows];
      if ([importer warnings]) {
        ImporterWarning *alert = [[ImporterWarning alloc] init];
        [alert setWarnings:[importer warnings]];
        [alert showWindow:nil];
      }
    } else {
      NSBeep();
    }
  } @catch (id exception) {
    SKLogException(exception);
    NSBeep();
  }
  [importer release];
}

@end
