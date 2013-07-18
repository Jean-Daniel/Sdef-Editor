/*
 *  Preferences.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <WonderBox/WBWindowController.h>

@interface Preferences : WBWindowController {
@private
  NSString *_sdp;
  NSString *_rez;
}

@property(nonatomic, copy) NSString *sdp;
@property(nonatomic, copy) NSString *rez;

@end
