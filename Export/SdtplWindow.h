//
//  SdtplWindow.h
//  Sdef Editor
//
//  Created by Grayfox on 25/03/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SKWindowController.h"

@class SdefDocument, SdtplPreview;
@class SdefTemplate, SdtplExporter;
@interface SdtplWindow : SKWindowController {
  IBOutlet NSPopUpButton *templates;
  IBOutlet NSObjectController *tplController;
@private
  SdtplPreview *sd_preview;
  SdefDocument *sd_document;
  SdefTemplate *sd_template;
}

- (id)initWithDocument:(SdefDocument *)aDoc;

- (IBAction)export:(id)sender;
- (IBAction)showPreview:(id)sender;
- (IBAction)changeTemplate:(id)sender;

- (BOOL)importTemplate;
- (SdefTemplate *)selectedTemplate;
- (void)setSelectedTemplate:(SdefTemplate *)aTemplate;

@end
