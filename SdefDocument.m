//
//  SdefDocument.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDocument.h"

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

@implementation SdefDocument

- (id)init {
  if (self = [super init]) {
    id dictionary = [[SdefDictionary alloc] init];
    [dictionary appendChild:[SdefSuite node]];
    [self setDictionary:dictionary];
    [dictionary release];
//    _imports = [[SdefImports alloc] init];
    _manager = [[SdefClassManager alloc] initWithDocument:self];
/*
    [[NSNotificationCenter defaultCenter] addObserver:_manager
                                             selector:@selector(didAddDictionary:)
                                                 name:SdefObjectDidAppendChildNotification
                                               object:_imports];
    [[NSNotificationCenter defaultCenter] addObserver:_manager
                                             selector:@selector(willRemoveDictionary:)
                                                 name:SdefObjectWillRemoveChildNotification
                                               object:_imports];
 */
  }
  return self;
}

- (void)dealloc {
  [_dictionary release];
//  [_imports release];
  [_manager release];
  [super dealloc];
}

- (IBAction)export:(id)sender {
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

- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo {
  [super canCloseDocumentWithDelegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
}

- (void)makeWindowControllers {
  id controller = [[SdefWindowController alloc] initWithOwner:nil];
  [self addWindowController:controller];
  [controller release];
}

- (NSData *)dataRepresentationOfType:(NSString *)type {
  SdefXMLGenerator *gen = [[SdefXMLGenerator alloc] initWithRoot:[self dictionary]];
  id data = [gen xmlData];
  [gen release];
  return data;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type {
  [_manager removeDictionary:[self dictionary]];
  id parser = [[SdefParser alloc] init];
  BOOL result = [parser parseData:data];
  [self setDictionary:[parser document]];
  [parser release];
  [_manager addDictionary:[self dictionary]];
  return result;
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
    [_dictionary release];
    _dictionary = [newDictionary retain];
    [_dictionary setDocument:self];
  }
}
/*
- (SdefImports *)imports {
  return _imports;
}
*/
- (SdefClassManager *)manager {
  return _manager;
}

#pragma mark -

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  return (nil == item) ? YES : [item firstChild] != nil;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  return (nil == item) ? 1 : [item childCount];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
/*
  if (nil == item) {
    return (index == 0) ? (id)_imports : (id)_dictionary;
  }
  return [item childAtIndex:index];
 */
  return (nil != item) ? [item childAtIndex:index] : _dictionary;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  return item;
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
