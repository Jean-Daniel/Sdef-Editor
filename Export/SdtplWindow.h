//
//  SdtplWindow.h
//  Sdef Editor
//
//  Created by Grayfox on 25/03/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SKWindowController.h"

@class SdefDocument, SdtplPreview, SdefTemplate, SdtplGenerator;
@interface SdtplWindow : SKWindowController {
  IBOutlet NSPopUpButton *templates;
  IBOutlet SdtplGenerator *generator;
  IBOutlet NSView *generalView, *tocView, *htmlView;
@private
  struct sd_swflags {
    unsigned int links:1;
    unsigned int sortSuites:1;
    unsigned int sortOthers:1;
    unsigned int toc:4;
    unsigned int style:4;
    unsigned int events:4;
    unsigned int :1;
  } swflags;
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
