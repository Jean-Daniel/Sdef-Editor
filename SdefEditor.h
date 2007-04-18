/*
 *  SdefEditor.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

SK_PRIVATE
NSString * ScriptingDefinitionFileType;
SK_PRIVATE
NSString * TigerScriptingDefinitionFileType;
SK_PRIVATE
NSString * PantherScriptingDefinitionFileType;

SK_PRIVATE
const OSType kScriptingDefinitionHFSType;

SK_PRIVATE
NSString * CocoaSuiteDefinitionFileType;
SK_PRIVATE
const OSType kCocoaSuiteDefinitionHFSType;

@class SdefImporter;
@interface SdefEditor : NSObject {

}

- (IBAction)openInspector:(id)sender;
- (void)importWithImporter:(SdefImporter *)importer;

@end
