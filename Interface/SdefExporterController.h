//
//  SdefExporterController.h
//  Sdef Editor
//
//  Created by Grayfox on 22/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SdefDocument;
@interface SdefExporterController : NSWindowController {
  IBOutlet NSArrayController *includes;
  SdefDocument *sd_document;
  
  BOOL includeCore, includeText;
  BOOL resourceFormat, cocoaFormat, rsrcFormat;
}

- (SdefDocument *)sdefDocument;
- (void)setSdefDocument:(SdefDocument *)adocument;

@end
