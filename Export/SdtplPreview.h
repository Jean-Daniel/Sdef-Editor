//
//  SdtplPreview.h
//  Sdef Editor
//
//  Created by Grayfox on 02/04/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SKWindowController.h"

@class WebView;
@class SdefTemplate, SdtplExporter, SdefDictionary;
@interface SdtplPreview : SKWindowController {
  IBOutlet WebView *view;
  NSString *sd_tmp;
  SdefTemplate *sd_tpl;
  SdtplExporter *sd_exporter;
  struct sd_prflags {
    unsigned int pathChanged:1;
    unsigned int:7;
  } prflags;
}

- (void)refresh;
- (SdefTemplate *)template;
- (void)setTemplate:(SdefTemplate *)template;

@end
