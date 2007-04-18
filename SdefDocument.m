/*
 *  SdefDocument.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

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
  [sd_dictionary release];
  [super dealloc];
}

#pragma mark -
- (id)windowControllerOfClass:(Class)class {
  NSWindow *window;
  NSEnumerator *windows = [[self windowControllers] objectEnumerator];
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
  SdefSymbolBrowser *browser = [self symbolBrowser];
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
    NSInteger version;
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
  NSArray *controllers = [self windowControllers];
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
    [[self documentWindow] setDictionary:newDictionary];
    [[self symbolBrowser] loadSymbols];
  }
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
    creatorCode = SKULong(SKOSTypeFromString(creatorCodeString));
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
SdefDictionary *SdefLoadDictionary(NSString *filename, NSInteger *version, id delegate) {
  NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
  SdefDictionary *dictionary = SdefLoadDictionaryData(data, version, delegate);
  [data release];
  return dictionary;
}

SdefDictionary *SdefLoadDictionaryData(NSData *data, NSInteger *version, id delegate) {
  SdefDictionary *result = nil;
  if (data) {
    SdefXMLParser *parser = [[SdefXMLParser alloc] init];
    [parser setDelegate:delegate];
    if ([parser parseData:data]) {
      result = [[parser document] retain];
      if (version) {
        switch ([parser parserVersion]) {
          case kSdefParserPantherVersion:
            *version = kSdefPantherVersion;
            break;
          case kSdefParserTigerVersion:
            *version = kSdefTigerVersion;
            break;
          case kSdefParserLeopardVersion:
            *version = kSdefLeopardVersion;
            break;
        }
      }
    } else {
      NSRunAlertPanel(@"An error occured when loading file!", [parser error], @"OK", nil, nil);
    }
    [parser release];
  }
  return [result autorelease];
}
