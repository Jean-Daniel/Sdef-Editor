/*
 *  SdefDocument.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefDocument.h"
#import "SdefEditor.h"

#import WBHEADER(WonderBoxFunctions.h)

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

- (id)initWithType:(NSString *)typeName error:(NSError **)outError {
  if (self = [super initWithType:typeName error:outError]) {
    SdefDictionary *dictionary = [[SdefDictionary alloc] init];
    [dictionary appendChild:[SdefSuite node]];
    [self setDictionary:dictionary];
    [dictionary release];
  }
  return self;
}

- (id)initWithContentsOfURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
  if (self = [super initWithContentsOfURL:absoluteURL ofType:typeName error:outError]) {
    
  }
  return self;
}

- (void)dealloc {
  [sd_center release];
  [sd_manager release];
  [sd_dictionary setDocument:nil];
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
      WBLogException(exception);
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
  SdefWindowController *controller = [[SdefWindowController alloc] init];
  [controller setShouldCloseDocument:YES];
  [self addWindowController:controller];
  [controller release];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
  *outError = nil;
  NSData *data = nil;
  SdefVersion version = 0;
	if (outError) *outError = nil;
  if ([typeName isEqualToString:ScriptingDefinitionFileType] || [typeName isEqualToString:ScriptingDefinitionFileUTI]) {
    version = [[self dictionary] version];
  }
  if (version) {
    SdefXMLGenerator *gen = [[SdefXMLGenerator alloc] initWithRoot:[self dictionary]];
    //[gen setHeaderComment:@" @meta target 10.4 "];
    @try {
      data = [gen xmlDataForVersion:version];
    } @catch (id exception) {
      NSBeep();
      WBLogException(exception);
    }
    [gen release];
  }
  return data;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
  if ([typeName isEqualToString:ScriptingDefinitionFileType] || [typeName isEqualToString:ScriptingDefinitionFileUTI]) {
    NSInteger version;
    [self setDictionary:SdefLoadDictionary(absoluteURL, &version, self, outError)];
    if ([self dictionary] != nil) {
      if (version < kSdefTigerVersion) {
        /* Warning: using deprecated useless format */
        [self updateChangeCount:NSChangeDone];
      }
    } else {
      if (!outError)
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:nil];
    }
  } else if (outError) {
		*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:nil];
	}
  return [self dictionary] != nil;
}

- (BOOL)sdefParser:(SdefParser *)parser shouldIgnoreValidationError:(NSError *)error isFatal:(BOOL)fatal {
  if (fatal) {
    NSRunAlertPanel(@"An unrecoverable error occured while parsing file.",
                    @"%@",
                    @"OK", nil, nil, [error localizedDescription]);
    return NO;
  } else {
    switch (NSRunAlertPanel(@"An sdef validation error occured while parsing file.",
                            @"%@",
                            @"Ignore", @"Abort", nil, [error localizedDescription])) {
      case NSAlertAlternateReturn:
        return NO;
    }
  }
  /* ignore error */
  return YES;
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
- (NSNotificationCenter *)notificationCenter {
  if (!sd_center) {
    sd_center = [[NSNotificationCenter alloc] init];
  }
  return sd_center;
}

#pragma mark -
- (NSDictionary *)fileAttributesToWriteToURL:(NSURL *)absoluteURL
                                      ofType:(NSString *)typeName
                            forSaveOperation:(NSSaveOperationType)saveOperation
                         originalContentsURL:(NSURL *)absoluteOriginalContentsURL 
                                       error:(NSError **)outError {
  NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
  NSArray *documentTypes;
  NSString *creatorCodeString;
  NSNumber *typeCode = nil, *creatorCode = nil;

  NSDictionary *attrs = [super fileAttributesToWriteToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation
                                      originalContentsURL:absoluteOriginalContentsURL error:outError];
  if (!attrs)
    return nil;
  
  // First, set creatorCode to the HFS creator code for the application,
  // if it exists.
  creatorCodeString = [infoPlist objectForKey:@"CFBundleSignature"];
  if(creatorCodeString) {
    creatorCode = WBUInteger(WBOSTypeFromString(creatorCodeString));
  }
  
  // Then, find the matching Info.plist dictionary entry for this type.
  // Use the first associated HFS type code, if any exist.
  documentTypes = [infoPlist objectForKey:@"CFBundleDocumentTypes"];
  if(documentTypes) {
    NSUInteger count = [documentTypes count];
    
    for(NSUInteger i = 0; i < count; i++) {
      NSString *type = [[documentTypes objectAtIndex:i] objectForKey:@"CFBundleTypeName"];
      if(type && [type isEqualToString:typeName]) {
        NSArray *typeCodeStrings = [[documentTypes objectAtIndex:i] objectForKey:@"CFBundleTypeOSTypes"];
        if(typeCodeStrings) { 
          NSString *firstTypeCodeString = [typeCodeStrings objectAtIndex:0];
          if (firstTypeCodeString) {
            typeCode = WBUInteger(WBOSTypeFromString(firstTypeCodeString)); 
          }
        }
        break; 
      } 
    }  
  }
  
  // If neither type nor creator code exist, use the default implementation.
  if(!(typeCode || creatorCode)) {
    return attrs;
  }
  
  // Otherwise, add the type and/or creator to the dictionary.
  NSMutableDictionary *newAttrs = [[attrs mutableCopy] autorelease];
  if(typeCode)
    [newAttrs setObject:typeCode forKey:NSFileHFSTypeCode];
  if(creatorCode)
    [newAttrs setObject:creatorCode forKey:NSFileHFSCreatorCode];
  return newAttrs;  
}

@end

#pragma mark -
SdefDictionary *SdefLoadDictionary(NSURL *file, NSInteger *version, id delegate, NSError **error) {
  //NSData *data = [[NSData alloc] initWithContentsOfURL:file];
  SdefDictionary *dictionary = SdefLoadDictionaryData(nil, file, version, delegate, error);
  //[data release];
  return dictionary;
}

SdefDictionary *SdefLoadDictionaryData(NSData *data, NSURL *base, NSInteger *version, id delegate, NSError **error) {
  SdefDictionary *result = nil;
  if (data || base) {
    SdefParser *parser = [[SdefParser alloc] init];
    [parser setDelegate:delegate];
    if ([parser parseData:data base:base error:error]) {
      result = [[parser dictionary] retain];
      if (version) *version = [parser sdefVersion];
    }
    [parser release];
  }
  return result ? [result autorelease] : nil;
}
