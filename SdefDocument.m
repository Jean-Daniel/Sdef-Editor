//
//  SdefDocument.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDocument.h"
#import "SdefEditor.h"

#import "ShadowMacros.h"
#import "SKFunctions.h"

#import "SdefWindowController.h"
#import "SdefClassManager.h"
#import "SdefDictionary.h"
#import "SdefObject.h"
#import "SdefSuite.h"

#import "SdefParser.h"
#import "SdefXMLGenerator.h"
#import "SdefExporterController.h"


NSString * const SdefObjectDragType = @"SdefObjectDragType";

@implementation SdefDocument

- (id)init {
  if (self = [super init]) {
    id dictionary = [[SdefDictionary alloc] init];
    [dictionary appendChild:[SdefSuite node]];
    [self setDictionary:dictionary];
    [dictionary release];
    _manager = [[SdefClassManager alloc] initWithDocument:self];
  }
  return self;
}

- (void)dealloc {
  [_dictionary release];
  [_manager release];
  [super dealloc];
}

#pragma mark -
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

#pragma mark -
#pragma mark NSDocument Methods
- (void)makeWindowControllers {
  id controller = [[SdefWindowController alloc] initWithOwner:nil];
  [self addWindowController:controller];
  [controller release];
}

- (NSData *)dataRepresentationOfType:(NSString *)type {
  id data = nil;
  if ([type isEqualToString:ScriptingDefinitionFileType]) {
    SdefXMLGenerator *gen = [[SdefXMLGenerator alloc] initWithRoot:[self dictionary]];
    data = [gen xmlData];
    [gen release];
  }
  return data;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type {
  BOOL result = NO;
  if (_manager) {
    [_manager release];
  }
  _manager = [[SdefClassManager alloc] initWithDocument:self];
  
  if ([type isEqualToString:ScriptingDefinitionFileType]) {
    id parser = [[SdefParser alloc] init];
    result = [parser parseData:data];
    [self setDictionary:[parser document]];
    [parser release];
  }
  
  [_manager addDictionary:[self dictionary]];
  return result;
}

#pragma mark -
#pragma mark SdefDocument Specific
- (SdefClassManager *)manager {
  return _manager;
}

- (SdefObject *)selection {
  id controllers = [self windowControllers];
  return ([controllers count]) ? [[controllers objectAtIndex:0] selection] : nil;
}

- (SdefDictionary *)dictionary {
  return _dictionary;
}

- (void)setDictionary:(SdefDictionary *)newDictionary {
  if (_dictionary != newDictionary) {
    [_dictionary setDocument:nil];
    [_dictionary release];
    _dictionary = [newDictionary retain];
    [_dictionary setDocument:self];
    [[self undoManager] removeAllActions];
    [self updateChangeCount:NSChangeCleared];
  }
}

#pragma mark -
#pragma mark OutlineView DataSource
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  return (nil == item) ? YES : [item firstChild] != nil;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  return (nil == item) ? 1 : [item childCount];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
  return (nil != item) ? [item childAtIndex:index] : _dictionary;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  return item;
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
  if (srcType != [item objectType]) {
    return NSDragOperationNone;
  }
  
  if (srcType == kSdefCollectionType && [item contentType] != [[object parent] contentType]) {
    return NSDragOperationNone;
  }

  return ([object findRoot] != [self dictionary]) ? NSDragOperationCopy : NSDragOperationMove;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index {
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
