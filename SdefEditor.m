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
#import "CocoaSuiteImporter.h"
#import "SdefObjectInspector.h"


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
  CocoaSuiteImporter *importer = [[CocoaSuiteImporter alloc] initWithFile:[[openPanel filenames] objectAtIndex:0]];
  SdefSuite *suite = [importer sdefSuite];
  if (suite) {
    SdefDocument *doc = [[NSDocumentController sharedDocumentController] openUntitledDocumentOfType:ScriptingDefinitionFileType display:NO];
    [[doc dictionary] appendChild:suite];
    [doc showWindows];
  } else {
    NSBeep();
  }
  [importer release]; 
}

@end
