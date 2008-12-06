/*
 *  SdefEditor.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

WB_PRIVATE
NSString * const ScriptingDefinitionFileType;
WB_PRIVATE
NSString * const ScriptingDefinitionFileUTI;

WB_PRIVATE
const OSType kScriptingDefinitionHFSType;

WB_PRIVATE
NSString * const CocoaSuiteDefinitionFileType;
WB_PRIVATE
const OSType kCocoaSuiteDefinitionHFSType;

@class SdefImporter;
@interface SdefEditor : NSObject {

}

- (IBAction)openInspector:(id)sender;
- (void)importWithImporter:(SdefImporter *)importer;

@end
