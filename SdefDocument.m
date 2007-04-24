/*
 *  SdefDocument.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefDocument.h"
#import "SdefEditor.h"

#import <ShadowKit/SKFunctions.h>

#import "SdefWindowController.h"
#import "SdefSymbolBrowser.h"
#import "SdefClassManager.h"
#import "SdefDictionary.h"
#import "SdefValidator.h"
#import "SdtplWindow.h"
#import "SdefObjects.h"
#import "SdefSuite.h"

#import "SdefParser.h"
#import "SdefXMLGenerator.h"
#import "SdefExporterController.h"

#import "ASDictionary.h"

@implementation SdefDocument

- (id)init {
  if (self = [super init]) {
    SdefDictionary *dictionary = [[SdefDictionary alloc] init];
    [dictionary appendChild:[SdefSuite node]];
    [self setDictionary:dictionary];
    [dictionary release];
  }
  return self;
}

- (void)dealloc {
  [sd_manager release];
  [sd_dictionary release];
  [super dealloc];
}

#pragma mark -
- (id)windowControllerOfClass:(Class)class {
  
  NSArray *ctrls = [self windowControllers];
  NSUInteger idx = [ctrls count];
  while (idx-- > 0) {
    NSWindow *window = [ctrls objectAtIndex:idx];
    if ([window isKindOfClass:class]) {
      return window;
    }
  }
  return nil;
}

- (SdefValidator *)validator {
  return [self windowControllerOfClass:[SdefValidator class]];
}

- (SdefSymbolBrowser *)symbolBrowser {
  return [self windowControllerOfClass:[SdefSymbolBrowser class]];
}

- (SdefWindowController *)documentWindow {
  return [self windowControllerOfClass:[SdefWindowController class]];
}

- (IBAction)openSymbolBrowser:(id)sender {
  SdefSymbolBrowser *browser = [self symbolBrowser];
  if (!browser) {
    browser = [[SdefSymbolBrowser alloc] init];
    [self addWindowController:browser];
    [browser release];
  }
  [browser showWindow:sender];
}

- (IBAction)openValidator:(id)sender {
  SdefValidator *validator = [self validator];
  if (!validator) {
    validator = [[SdefValidator alloc] init];
    [self addWindowController:validator];
    [validator release];
  }
  [validator showWindow:sender];
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

#if !__LP64__
- (IBAction)exportASDictionary:(id)sender {
  NSSavePanel *panel = [NSSavePanel savePanel];
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
  NSString *file;
  if ((result == NSOKButton) && (file = [aPanel filename])) {
    NSDictionary *dico = nil;
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
#endif

- (IBAction)exportUsingTemplate:(id)sender {
  SdtplWindow *exporter = [[SdtplWindow alloc] initWithDocument:self];
  [exporter setReleasedWhenClosed:YES];
  NSWindow *win = [[self documentWindow] window];
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
  SdefWindowController *controller = [[SdefWindowController alloc] initWithOwner:nil];
  [controller setShouldCloseDocument:YES];
  [self addWindowController:controller];
  [controller release];
}

- (NSData *)dataRepresentationOfType:(NSString *)type {
  NSData *data = nil;
  SdefVersion version = 0;
  if ([type isEqualToString:ScriptingDefinitionFileType]) {
    version = kSdefLeopardVersion;
  } else if ([type isEqualToString:TigerScriptingDefinitionFileType]) {
    version = kSdefTigerVersion;
  } else if ([type isEqualToString:PantherScriptingDefinitionFileType]) {
    version = kSdefPantherVersion;
  }
  if (version) {
    SdefXMLGenerator *gen = [[SdefXMLGenerator alloc] initWithRoot:[self dictionary]];
    //[gen setHeaderComment:@" Sdef Editor "];
    @try {
      data = [gen xmlDataForVersion:version];
    } @catch (id exception) {
      NSBeep();
      SKLogException(exception);
    }
    [gen release];
  }
  return data;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type {
  if ([type isEqualToString:ScriptingDefinitionFileType] ||
      [type isEqualToString:TigerScriptingDefinitionFileType] ||
      [type isEqualToString:PantherScriptingDefinitionFileType]) {
    NSInteger version;
    [self setDictionary:SdefLoadDictionaryData(data, &version, self, NULL)];
    if ([self dictionary] != nil && version < kSdefTigerVersion) {
      NSRunInformationalAlertPanel(@"You have opened a Panther or Tiger Scripting Definition file",
                                   @"This file will be saved using Leopard format. If you want to export it using an older format, choose \"Save as...\" in the File menu",
                                   @"OK", nil, nil);
      [self updateChangeCount:NSChangeDone];
    }
  }
  return [self dictionary] != nil;
}

- (SdefParserOperation)sdefParser:(SdefParser *)parser shouldAddInvalidObject:(id)anObject inNode:(SdefObject *)node {
  switch (NSRunAlertPanel(@"Found an invalid node in Sdef file",
                          @"Found element \"%@\" in %@ element \"%@\" at line %ld. Would you like to preserve this element, delete this element, or abort parsing.",
                          @"Preserve", @"Abort", @"Delete",
                          [anObject objectTypeName], [node objectTypeName], [node name], (long)[parser line])) {
    case NSAlertDefaultReturn:
      return kSdefParserAddNode;
    case NSAlertAlternateReturn:
      return kSdefParserAbort;
    case NSAlertOtherReturn:
      return kSdefParserDeleteNode;
  }
  return NO;
}

- (NSArray *)writableTypesForSaveOperation:(NSSaveOperationType)saveOperation {
  switch(saveOperation) {
    case NSSaveAsOperation:
      return [NSArray arrayWithObjects:
        ScriptingDefinitionFileType, 
        TigerScriptingDefinitionFileType, 
        PantherScriptingDefinitionFileType, nil];
    default:
      return [super writableTypesForSaveOperation:saveOperation];
  }
}

#pragma mark -
#pragma mark SdefDocument Specific
- (SdefObject *)selection {
  NSArray *controllers = [self windowControllers];
  return ([controllers count]) ? [[controllers objectAtIndex:0] selection] : nil;
}

- (SdefDictionary *)dictionary {
  return sd_dictionary;
}

- (void)setDictionary:(SdefDictionary *)newDictionary {
  if (sd_dictionary != newDictionary) {
    [sd_dictionary setDocument:nil];
    if (sd_manager) [sd_manager removeDictionary:sd_dictionary];
    
    [sd_dictionary release];
    sd_dictionary = [newDictionary retain];
    
    [sd_dictionary setDocument:self];
    if (sd_manager) [sd_manager addDictionary:sd_dictionary];
    
    [[self undoManager] removeAllActions];
    [self updateChangeCount:NSChangeCleared];
    /* Update [sd_dictionary classManager] */
    [[self documentWindow] setDictionary:newDictionary];
    [[self symbolBrowser] loadSymbols];
  }
}

- (SdefClassManager *)classManager {
  if (!sd_manager) {
    sd_manager = [(SdefClassManager *)[SdefClassManager allocWithZone:[self zone]] initWithDocument:self];
    if (sd_dictionary)
      [sd_manager addDictionary:sd_dictionary];
  }
  return sd_manager;
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
    creatorCode = SKUInt(SKOSTypeFromString(creatorCodeString));
  }
  
  // Then, find the matching Info.plist dictionary entry for this type.
  // Use the first associated HFS type code, if any exist.
  documentTypes = [infoPlist objectForKey:@"CFBundleDocumentTypes"];
  if(documentTypes) {
    NSUInteger count = [documentTypes count];
    
    for(NSUInteger i = 0; i < count; i++) {
      NSString *type = [[documentTypes objectAtIndex:i] objectForKey:@"CFBundleTypeName"];
      if(type && [type isEqualToString:documentTypeName]) {
        NSArray *typeCodeStrings = [[documentTypes objectAtIndex:i] objectForKey:@"CFBundleTypeOSTypes"];
        if(typeCodeStrings) { 
          NSString *firstTypeCodeString = [typeCodeStrings objectAtIndex:0];
          if (firstTypeCodeString) {
            typeCode = SKUInt(SKOSTypeFromString(firstTypeCodeString)); 
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
SdefDictionary *SdefLoadDictionary(NSString *filename, NSInteger *version, id delegate, NSString **error) {
  NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
  SdefDictionary *dictionary = SdefLoadDictionaryData(data, version, delegate, error);
  [data release];
  return dictionary;
}

SdefDictionary *SdefLoadDictionaryData(NSData *data, NSInteger *version, id delegate, NSString **error) {
  SdefDictionary *result = nil;
  if (data) {
    SdefParser *parser = [[SdefParser alloc] init];
    [parser setDelegate:delegate];
    if ([parser parseSdef:data error:error]) {
      result = [[parser dictionary] retain];
      if (version) *version = [parser sdefVersion];
    }
    [parser release];
  }
  return result ? [result autorelease] : nil;
}
