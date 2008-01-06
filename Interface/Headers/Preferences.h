/*
 *  Preferences.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKWindowController.h>

@interface Preferences : SKWindowController {
  NSString *sdp;
  NSString *rez;
}

- (NSString *)sdp;
- (void)setSdp:(NSString *)newSdp;

- (NSString *)rez;
- (void)setRez:(NSString *)newRez;


@end
