/*
 *  SdtplWindow.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKWindowController.h>

@class SdefDocument, SdefTemplate, SdtplGenerator;
@interface SdtplWindow : SKWindowController {
  IBOutlet NSPopUpButton *templates;
  IBOutlet SdtplGenerator *generator;
  IBOutlet NSView *generalView, *tocView, *htmlView, *infoView;
@private
  SdefDocument *sd_document;
  SdefTemplate *sd_template;
}

- (id)initWithDocument:(SdefDocument *)aDoc;

- (IBAction)export:(id)sender;
- (IBAction)changeTemplate:(id)sender;

- (BOOL)importTemplate;
- (SdefTemplate *)selectedTemplate;
- (void)setSelectedTemplate:(SdefTemplate *)aTemplate;

@end
