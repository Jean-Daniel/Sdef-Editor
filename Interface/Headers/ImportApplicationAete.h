//
//  ImportApplicationAete.h
//  Sdef Editor
//
//  Created by Grayfox on 31/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SKWindowController.h"

@class SKApplication;
@interface ImportApplicationAete : SKWindowController {
  IBOutlet NSPopUpButton *popup;
  SKApplication *selection;
}

- (SKApplication *)selection;

@end
