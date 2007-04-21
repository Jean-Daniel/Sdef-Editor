/*
 *  SdefExporterController.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class SdefDocument;
@interface SdefExporterController : NSWindowController {
  IBOutlet NSArrayController *includes;
  IBOutlet NSObjectController *controller;
  SdefDocument *sd_document;
  
  NSString *sd_version;
  BOOL includeCore, includeText;
  BOOL resourceFormat, cocoaFormat, rsrcFormat;
}

- (void)compileResourceFile:(NSString *)folder;

- (NSString *)version;
- (void)setVersion:(NSString *)version;

- (SdefDocument *)sdefDocument;
- (void)setSdefDocument:(SdefDocument *)adocument;

@end
