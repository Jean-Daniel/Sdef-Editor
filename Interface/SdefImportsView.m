//
//  SdefImportsView.m
//  SDef Editor
//
//  Created by Grayfox on 17/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefImportsView.h"
#import "SdefParser.h"
#import "SdefObject.h"
#import "SdefEditor.h"

@implementation SdefImportsView

- (void)selectObject:(id)obj {
}

- (IBAction)add:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setAllowsMultipleSelection:YES];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanCreateDirectories:NO];
  [openPanel beginSheetForDirectory:nil
                               file:nil
                              types:[NSArray arrayWithObjects:@"sdef", NSFileTypeForHFSTypeCode(kScriptingDefinitionHFSType), nil]
                     modalForWindow:[[self sdefView] window]
                      modalDelegate:self
                     didEndSelector:@selector(openPanelDidEnd:returnCode:context:)
                        contextInfo:nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(unsigned)result context:(id)ctxt {
  if (result == NSCancelButton)
    return;
  id files = [[panel filenames] objectEnumerator];
  id file;
  id parser = [[SdefParser alloc] init];
  while (file = [files nextObject]) {
    id data = [[NSData alloc] initWithContentsOfFile:file];
    if (data && [parser parseData:data]) {
      id dico = [parser document];
      [controller addObject:dico];
      [dico setRemovable:YES];
      [dico setEditable:NO recursive:YES];
    }
    [data release];
  }
  [parser release];
}

@end
