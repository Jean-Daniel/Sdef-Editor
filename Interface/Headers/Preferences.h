//
//  Preferences.h
//  Sdef Editor
//
//  Created by Grayfox on 03/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SKWindowController.h"

@interface Preferences : SKWindowController {
  NSString *sdp;
  NSString *rez;
  
  struct _sd_prFlags {
    unsigned int sdp:1;
    unsigned int rez:1;
    unsigned int:6;
  } sd_prFlags;
}

- (BOOL)buildInSdp;
- (void)setBuildInSdp:(BOOL)flag;

- (BOOL)buildInRez;
- (void)setBuildInRez:(BOOL)flag;

- (NSString *)sdp;
- (void)setSdp:(NSString *)newSdp;

- (NSString *)rez;
- (void)setRez:(NSString *)newRez;


@end
