/*
 *  ImportApplicationAete.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKWindowController.h>

@class SKApplication;
@interface ImportApplicationAete : SKWindowController {
  IBOutlet NSPopUpButton *popup;
  SKApplication *selection;
}

- (SKApplication *)selection;

@end
