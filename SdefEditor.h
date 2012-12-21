/*
 *  SdefEditor.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

SPX_PRIVATE
NSString * const ScriptingDefinitionFileType;
SPX_PRIVATE
NSString * const ScriptingDefinitionFileUTI;

SPX_PRIVATE
const OSType kScriptingDefinitionHFSType;

SPX_PRIVATE
NSString * const CocoaSuiteDefinitionFileType;
SPX_PRIVATE
const OSType kCocoaSuiteDefinitionHFSType;

@class SdefImporter;
@interface SdefEditor : NSObject {

}

- (IBAction)openInspector:(id)sender;
- (void)importWithImporter:(SdefImporter *)importer;

@end
