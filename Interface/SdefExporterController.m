//
//  SdefExporterController.m
//  Sdef Editor
//
//  Created by Grayfox on 22/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefExporterController.h"
#import "ShadowMacros.h"
#import "SdefDocument.h"
#import "SdefProcessor.h"

@implementation SdefExporterController

+ (void)initialize {
  [self setKeys:[NSArray arrayWithObjects:
    @"resourceFormat", @"cocoaFormat", @"rsrcFormat", nil] triggerChangeNotificationsForDependentKey:@"canExport"];
}

- (id)init {
  if (self = [super initWithWindowNibName:@"SdefExport"]) {
    cocoaFormat = YES;
    resourceFormat = YES;
  }
  return self;
}

- (SdefDocument *)sdefDocument {
  return sd_document;
}

- (void)setSdefDocument:(SdefDocument *)aDocument {
  sd_document = aDocument;
}

- (IBAction)close:(id)sender {
  if ([[self window] isSheet]) {
    [NSApp endSheet:[self window]];
  }
  [self close];
}

- (IBAction)export:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:NSLocalizedString(@"Choose", @"Choose an export folder Prompt.")];
  [openPanel setMessage:NSLocalizedString(@"Choose a destination folder", @"Choose an export folder Message.")];
  [openPanel setCanChooseFiles:NO];
  [openPanel setCanCreateDirectories:YES];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setTreatsFilePackagesAsDirectories:YES];
  switch ([openPanel runModalForTypes:nil]) {
    case NSCancelButton:
      return;
  }
  SdefProcessor *proc = [[SdefProcessor alloc] initWithSdefDocument:[self sdefDocument]];
  [proc setOutput:[[openPanel filenames] objectAtIndex:0]];
  
  id defs = [[NSMutableArray alloc] init];
  if ([[includes arrangedObjects] count]) {
    id items = [[includes arrangedObjects] objectEnumerator];
    id item;
    while (item = [items nextObject]) {
      [defs addObject:[item valueForKey:@"path"]];
    }
  }
  if (includeCore) [defs addObject:[[NSBundle mainBundle] pathForResource:@"NSCoreSuite" ofType:@"sdef"]];
  if (includeText) [defs addObject:[[NSBundle mainBundle] pathForResource:@"NSTextSuite" ofType:@"sdef"]];
  
  if ([defs count])
    [proc setIncludes:defs];
  [defs release];
  
  SdefProcessorFormat format = 0;
  if (resourceFormat || rsrcFormat) format |= kSdefResourceFormat;
  if (cocoaFormat) format |= (kSdefScriptSuiteFormat | kSdefScriptTerminologyFormat);
  [proc setFormat:format];
  
  [proc setVersion:@"10.3"];
  
  NSString *result = [proc process];
  if (result) {
    NSRunAlertPanel(NSLocalizedString(@"Warning: Scripting Definition Processor says:", @"sdp return a value: message title"),
                    result,
                    NSLocalizedString(@"OK", @"Default Button"), nil, nil);
  }
  
  if (rsrcFormat) {
    [self compileResourceFile:[proc output]];
    if (!resourceFormat) {
      [[NSFileManager defaultManager] removeFileAtPath:[[proc output] stringByAppendingPathComponent:@"Scripting.r"] handler:nil];
    }
  }
  [proc release];
  [self close:sender];
}

- (void)compileResourceFile:(NSString *)folder {
  NSString *resource = [folder stringByAppendingPathComponent:@"Scripting.r"];
  if (![[NSFileManager defaultManager] fileExistsAtPath:resource]) {
    return;
  }
  NSString *dest = [folder stringByAppendingPathComponent:@"Scripting.rsrc"];
  id rez = [NSTask launchedTaskWithLaunchPath:[[NSBundle mainBundle] pathForResource:@"Rez" ofType:@""]
                                     arguments:[NSArray arrayWithObjects:resource, @"-o", dest, @"-useDF", nil]];
  [rez waitUntilExit];
}

- (IBAction)include:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Include"];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setAllowsMultipleSelection:YES];
  [openPanel setTreatsFilePackagesAsDirectories:YES];
  switch ([openPanel runModalForTypes:[NSArray arrayWithObject:@"sdef"]]) {
    case NSCancelButton:
      return;
  }
  id file;
  id files = [[openPanel filenames] objectEnumerator];
  while (file = [files nextObject]) {
    id dico = [[NSDictionary alloc] initWithObjectsAndKeys:
      file, @"path",
      [[file lastPathComponent] stringByDeletingPathExtension], @"name", nil];
    [includes addObject:dico];
    [dico release];
  }
}

- (BOOL)canExport {
  return resourceFormat | cocoaFormat | rsrcFormat;
}

@end
