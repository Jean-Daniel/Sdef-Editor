/*
 *  SdefEditor.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

extern NSString * const ScriptingDefinitionFileType;
extern const OSType kScriptingDefinitionHFSType;

extern NSString * const CocoaSuiteDefinitionFileType;
extern const OSType kCocoaSuiteDefinitionHFSType;

@class SdefImporter;
@interface SdefEditor : NSObject {

}

- (IBAction)openInspector:(id)sender;
- (void)importWithImporter:(SdefImporter *)importer;

@end
