/*
 *  SdefDictionaryPreview.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKWindowController.h>

@class OSADictionary, OSADictionaryController;
@interface SdefDictionaryPreview : SKWindowController {
  @private
  IBOutlet OSADictionaryController *ibDictionary;
  OSADictionary *sd_dict;
}

@end
