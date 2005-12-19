//
//  SdefDocument.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDocument.h"
#import "SdefEditor.h"

#import <ShadowKit/SKFunctions.h>

#import "SdefWindowController.h"
#import "SdefSymbolBrowser.h"
#import "SdefDictionary.h"
#import "SdtplWindow.h"
#import "SdefObjects.h"
#import "SdefSuite.h"

#import "SdefXMLParser.h"
#import "SdefXMLGenerator.h"
#import "SdefExporterController.h"

#import "ASDictionary.h"

NSString * const SdefObjectDragType = @"SdefObjectDragType";

@implementation SdefDocument

- (id)init {
  if (self = [super init]) {
    id dictionary = [[SdefDictionary alloc] init];
    [dictionary appendChild:[SdefSuite node]];
    [self setDictionary:dictionary];
    [dictionary release];
  }
  return self;
}

- (void)dealloc {
  [sd_dictionary release];
  [super dealloc];
}

#pragma mark -
- (id)windowControllerOfClass:(Class)class {
  id windows = [[self windowControllers] objectEnumerator];
  id window;
  while (window = [windows nextObject]) {
    if ([window isKindOfClass:class]) {
      return window;
    }
  }
  return nil;
}

- (SdefSymbolBrowser *)symbolBrowser {
  return [self windowControllerOfClass:[SdefSymbolBrowser class]];
}

- (SdefWindowController *)documentWindow {
  return [self windowControllerOfClass:[SdefWindowController class]];
}

- (IBAction)openSymbolBrowser:(id)sender {
  id browser = [self symbolBrowser];
  if (!browser) {
    browser = [[SdefSymbolBrowser alloc] init];
    [self addWindowController:browser];
    [browser release];
  }
  [browser showWindow:sender];
}

#pragma mark Export Definition
- (IBAction)exportTerminology:(id)sender {
  SdefExporterController *exporter = [[SdefExporterController alloc] init];
  [exporter setSdefDocument:self];
  [NSApp beginSheet:[exporter window]
     modalForWindow:[[[self windowControllers] objectAtIndex:0] window]
      modalDelegate:self
     didEndSelector:@selector(exportSheetDidEnd:returnCode:context:)
        contextInfo:nil];
}
- (void)exportSheetDidEnd:(NSWindow *)aWindow returnCode:(int)resut context:(id)ctxt {
  [[aWindow windowController] autorelease];
}

- (IBAction)exportUsingPantherFormat:(id)sender {
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setCanCreateDirectories:YES];
  [panel setCanSelectHiddenExtension:YES];
  [panel setTreatsFilePackagesAsDirectories:YES];
  [panel beginSheetForDirectory:nil
                           file:[self lastComponentOfFileName]
                 modalForWindow:[[self documentWindow] window]
                  modalDelegate:self
                 didEndSelector:@selector(exportAsPantherDidEnd:result:context:)
                    contextInfo:nil];
}
- (void)exportAsPantherDidEnd:(NSSavePanel *)aPanel result:(int)result context:(id)context {
  NSString *file;
  if ((result == NSOKButton) && (file = [aPanel filename])) {
    NSData *data = nil;
    SdefXMLGenerator *gen = [[SdefXMLGenerator alloc] initWithRoot:[self dictionary]];
    @try {
      data = [gen xmlDataForVersion:kSdefPantherVersion];
    } @catch (id exception) {
      NSBeep();
      SKLogException(exception);
      NSRunAlertPanel(@"An Unknow error prevent file exportation", @"%@", @"OK", nil, nil, [exception reason]);
    }
    [gen release];
    if (data) {
      [data writeToFile:file atomically:YES];
      id attributes = [self fileAttributesToWriteToFile:file
                                                 ofType:ScriptingDefinitionFileType
                                          saveOperation:NSSaveAsOperation];
      if (attributes) {
        [[NSFileManager defaultManager] changeFileAttributes:attributes atPath:file];
      }
    }
  }
}

- (IBAction)exportASDictionary:(id)sender {
  id panel = [NSSavePanel savePanel];
  [panel setCanSelectHiddenExtension:YES];
  [panel setRequiredFileType:@"asdictionary"];
  [panel setTitle:@"Create AppleScript Dictionary."];
  [panel beginSheetForDirectory:nil
                           file:[[self displayName] stringByDeletingPathExtension]
                 modalForWindow:[[self documentWindow] window]
                  modalDelegate:self
                 didEndSelector:@selector(exportASDictionary:returnCode:context:)
                    contextInfo:nil];
}
- (void)exportASDictionary:(NSSavePanel *)aPanel returnCode:(int)result context:(id)ctxt {
  id file;
  if ((result == NSOKButton) && (file = [aPanel filename])) {
    id dico = nil;
    @try {
      dico = AppleScriptDictionaryFromSdefDictionary([self dictionary]);
    } @catch (id exception) {
      dico = nil;
      SKLogException(exception);
    }
    if (!dico || ![NSArchiver archiveRootObject:dico toFile:file]) {
      NSBeginAlertSheet(@"Unable to create ASDictionary!",
                        @"OK", nil, nil,
                        [[self documentWindow] window],
                        nil, nil, nil, nil, @"An unknow error prevent creation.");
    }
  }
}

- (IBAction)exportUsingTemplate:(id)sender {
  SdtplWindow *exporter = [[SdtplWindow alloc] initWithDocument:self];
  [exporter setReleaseWhenClose:YES];
  id win = [[self documentWindow] window];
  if (win) {
    [NSApp beginSheet:[exporter window]
       modalForWindow:win
        modalDelegate:nil 
       didEndSelector:nil
          contextInfo:nil];
  }
}

#pragma mark -
#pragma mark NSDocument Methods
- (void)makeWindowControllers {
  id controller = [[SdefWindowController alloc] initWithOwner:nil];
  [controller setShouldCloseDocument:YES];
  [self addWindowController:controller];
  [controller release];
}

- (NSData *)dataRepresentationOfType:(NSString *)type {
  id data = nil;
  if ([type isEqualToString:ScriptingDefinitionFileType]) {
    SdefXMLGenerator *gen = [[SdefXMLGenerator alloc] initWithRoot:[self dictionary]];
    @try {
      data = [gen xmlDataForVersion:kSdefTigerVersion];
    } @catch (id exception) {
      NSBeep();
      SKLogException(exception);
    }
    [gen release];
  }
  return data;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type {
  if ([type isEqualToString:ScriptingDefinitionFileType]) {
    int version;
    [self setDictionary:SdefLoadDictionaryData(data, &version, self)];
    if (version == kSdefPantherVersion) {
      NSRunInformationalAlertPanel(@"You have opened a Panther Scripting Definition file",
                                   @"This file will be saved using Tiger format. If you want to save it using the Panther format, choose \"Export Using old Format\" in the File menu",
                                   @"OK", nil, nil);
      [self updateChangeCount:NSChangeDone];
    }
  }
  return [self dictionary] != nil;
}

- (SdefParserOperation)sdefParser:(SdefXMLParser *)parser shouldAddInvalidObject:(id)anObject inNode:(SdefObject *)node {
  switch (NSRunAlertPanel(@"Found an invalid node in Sdef file",
                          @"Found element \"%@\" in %@ element \"%@\" at line %i. Would you like to preserve this element, delete this element, or abort parsing.",
                          @"Preserve", @"Abort", @"Delete",
                          [anObject objectTypeName], [node objectTypeName], [node name], [parser line])) {
    case NSAlertDefaultReturn:
      return kSdefParserAddNode;
    case NSAlertAlternateReturn:
      return kSdefParserAbort;
    case NSAlertOtherReturn:
      return kSdefParserDeleteNode;
  }
  return NO;
}

#pragma mark -
#pragma mark SdefDocument Specific
- (SdefObject *)selection {
  id controllers = [self windowControllers];
  return ([controllers count]) ? [[controllers objectAtIndex:0] selection] : nil;
}

- (SdefDictionary *)dictionary {
  return sd_dictionary;
}

- (void)setDictionary:(SdefDictionary *)newDictionary {
  if (sd_dictionary != newDictionary) {
    [sd_dictionary setDocument:nil];
    [sd_dictionary release];
    sd_dictionary = [newDictionary retain];
    [sd_dictionary setDocument:self];
    [[self undoManager] removeAllActions];
    [self updateChangeCount:NSChangeCleared];
    /* Update [sd_dictionary classManager] */
  }
}

#pragma mark -
#pragma mark OutlineView DataSource
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  return (nil == item) ? YES : [item hasChildren];
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  return (nil == item) ? 1 : [item childCount];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(SdefObject *)item {
  return (nil == item) ? [self dictionary] : [item childAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  return item;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(SdefObject *)item {
  if (![[item name] isEqualToString:object]) {
    [item setName:object];
  }
}

#pragma mark -
#pragma mark Drag & Drop
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
  id selection = [items objectAtIndex:0];
  if (selection != [self dictionary] && [selection objectType] != kSdefCollectionType && [selection isEditable]) {
    NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pboard declareTypes:[NSArray arrayWithObject:SdefObjectDragType] owner:self];
    id value = [NSData dataWithBytes:&selection length:sizeof(id)];
    [pboard setData:value forType:SdefObjectDragType];
    return YES;
  } else {
    return NO;
  }
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info
                  proposedItem:(id)item proposedChildIndex:(int)index {
  NSPasteboard *pboard = [info draggingPasteboard];
  
  if (item == nil && index < 0)
    return NSDragOperationNone;
  
  if (![[pboard types] containsObject:SdefObjectDragType]) {
    return NSDragOperationNone;
  }
  id value = [pboard dataForType:SdefObjectDragType];
  id *addr = (id *)[value bytes];
  SdefObject *object = addr[0];
  
  SdefObjectType srcType = [[object parent] objectType];  
  
  if ([object objectType] == kSdefPropertyType) {
    /* refuse if not record and not a collection that accept it */
    if ([item objectType] != kSdefRecordType && 
        ([item objectType] != kSdefCollectionType || ![item acceptsObjectType:kSdefPropertyType]))
      return NSDragOperationNone;
  } else {    
    if (srcType != [item objectType]) {
      return NSDragOperationNone;
    }
    if (srcType == kSdefCollectionType && ![item acceptsObjectType:[object objectType]]) {
      return NSDragOperationNone;
    }
  }

  return ([object findRoot] != [self dictionary]) ? NSDragOperationCopy : NSDragOperationMove;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(SdefObject *)item childIndex:(int)index {
  NSPasteboard *pboard = [info draggingPasteboard];
  if (![[pboard types] containsObject:SdefObjectDragType]) {
    return NO;
  }
  id value = [pboard dataForType:SdefObjectDragType];
  id *addr = (id *)[value bytes];
  SdefObject *object = addr[0];
  
  /* if same parent and index -1 */
  if (index < 0 && [object parent] == item) {
    return YES;
  }
  /* If line above */
  if (index >= 0 && index < [item childCount] && object == [item childAtIndex:index]) {
    return YES;
  }
  /* If line belove */
  if (index > 0 && index <= [item childCount] && object == [item childAtIndex:index-1]) {
    return YES;
  }

  unsigned srcIdx = [object index];
  if ([object findRoot] == [self dictionary]) {
    /* Have to check parent before removing object */
    if (([object parent] == item) && (srcIdx <= index)) index--;
    [object retain];
    [object remove];
    if (index < 0)
      [item appendChild:object];
    else {
      [item insertChild:object atIndex:index];
    }
    [object release];
  } else {
    id copy = [object copy];
    if (index < 0)
      [item appendChild:copy];
    else {
      [item insertChild:copy atIndex:index];
    }
    [copy release];
  }
  return YES;
}

#pragma mark -
- (NSDictionary *)fileAttributesToWriteToFile:(NSString *)fullDocumentPath
                                       ofType:(NSString *)documentTypeName
                                saveOperation:(NSSaveOperationType)saveOperationType {
  
  NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
  NSString *creatorCodeString;
  NSArray *documentTypes;
  NSNumber *typeCode, *creatorCode;
  NSMutableDictionary *newAttributes;
  
  typeCode = creatorCode = nil;

  // First, set creatorCode to the HFS creator code for the application,
  // if it exists.
  creatorCodeString = [infoPlist objectForKey:@"CFBundleSignature"];
  if(creatorCodeString) {
    creatorCode = SKULong(SKHFSTypeCodeFromFileType(creatorCodeString));
  }
  
  // Then, find the matching Info.plist dictionary entry for this type.
  // Use the first associated HFS type code, if any exist.
  documentTypes = [infoPlist objectForKey:@"CFBundleDocumentTypes"];
  if(documentTypes) {
    int i, count = [documentTypes count];
    
    for(i = 0; i < count; i++) {
      NSString *type = [[documentTypes objectAtIndex:i] objectForKey:@"CFBundleTypeName"];
      if(type && [type isEqualToString:documentTypeName]) {
        NSArray *typeCodeStrings = [[documentTypes objectAtIndex:i]
                    objectForKey:@"CFBundleTypeOSTypes"];
        if(typeCodeStrings) { 
          NSString *firstTypeCodeString = [typeCodeStrings objectAtIndex:0];
          if (firstTypeCodeString) {
            typeCode = SKULong(SKHFSTypeCodeFromFileType(firstTypeCodeString)); 
          } 
        }
        break; 
      } 
    }  
  }
  
  // If neither type nor creator code exist, use the default implementation.
  if(!(typeCode || creatorCode)) {
    return [super fileAttributesToWriteToFile:fullDocumentPath
                                       ofType:documentTypeName saveOperation:saveOperationType];  
  }
  
  // Otherwise, add the type and/or creator to the dictionary.
  newAttributes = [NSMutableDictionary dictionaryWithDictionary:[super
        fileAttributesToWriteToFile:fullDocumentPath ofType:documentTypeName
                      saveOperation:saveOperationType]];
  if(typeCode)
    [newAttributes setObject:typeCode forKey:NSFileHFSTypeCode];
  if(creatorCode)
    [newAttributes setObject:creatorCode forKey:NSFileHFSCreatorCode];
  return newAttributes;  
}

@end
#pragma mark -
SdefDictionary *SdefLoadDictionary(NSString *filename, int *version, id delegate) {
  NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
  SdefDictionary *dictionary = SdefLoadDictionaryData(data, version, delegate);
  [data release];
  return dictionary;
}

SdefDictionary *SdefLoadDictionaryData(NSData *data, int *version, id delegate) {
  SdefDictionary *result = nil;
  if (data) {
    SdefXMLParser *parser = [[SdefXMLParser alloc] init];
    [parser setDelegate:delegate];
    if ([parser parseData:data]) {
      result = [[parser document] retain];
      if (version) {
        if ([parser parserVersion] == kSdefParserPantherVersion) {
          *version = kSdefPantherVersion;
        } else {
          *version = kSdefTigerVersion;
        }
      }
    } else {
      NSRunAlertPanel(@"An error occured when loading file!", [parser error], @"OK", nil, nil);
    }
    [parser release];
  }
  return [result autorelease];
}
