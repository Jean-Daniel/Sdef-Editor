/*
 *  SdefEditor.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

SK_PRIVATE
NSString * const ScriptingDefinitionFileType;
SK_PRIVATE
NSString * const ScriptingDefinitionFileUTI;

SK_PRIVATE
const OSType kScriptingDefinitionHFSType;

SK_PRIVATE
NSString * const CocoaSuiteDefinitionFileType;
SK_PRIVATE
const OSType kCocoaSuiteDefinitionHFSType;

@class SdefImporter;
@interface SdefEditor : NSObject {

}

- (IBAction)openInspector:(id)sender;
- (void)importWithImporter:(SdefImporter *)importer;

@end
