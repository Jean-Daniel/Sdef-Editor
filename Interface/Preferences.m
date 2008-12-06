/*
 *  Preferences.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "Preferences.h"

@implementation Preferences

- (id)init {
  if (self = [super init]) {
    [self setSdp:[[NSUserDefaults standardUserDefaults] stringForKey:@"SdefSdpToolPath"]];
    [self setRez:[[NSUserDefaults standardUserDefaults] stringForKey:@"SdefRezToolPath"]];
  }
  return self;
}

- (void)dealloc {
  [sdp release];
  [rez release];
  [super dealloc];
}

- (NSString *)sdp {
  return sdp;
}
- (void)setSdp:(NSString *)newSdp {
	WBSetterCopy(sdp, newSdp);
}

- (NSString *)rez {
  return rez;
}
- (void)setRez:(NSString *)newRez {
	WBSetterCopy(rez, newRez);
}

#pragma mark -
- (BOOL)windowShouldClose:(id)sender {
  BOOL isDir;
  if (![[NSFileManager defaultManager] fileExistsAtPath:[self sdp] isDirectory:&isDir] || isDir) {
    if (NSOKButton != NSRunAlertPanel(@"The sdp Tool path could not be setted because it is not valid!",
																			@"The path you set for sdp tool is not valid. Choose a valid path or use build-in tool.",
																			@"Ignore", @"Change", nil))
			return NO;
  }
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:[self rez] isDirectory:&isDir] || isDir) {
    if (NSOKButton !=  NSRunAlertPanel(@"The Rez Tool path could not be setted because it is not valid!",
																			 @"The path you set for Rez tool is not valid. Choose a valid path or use build-in tool.",
																			 @"Ignore", @"Change", nil))
			return NO;
  }
  
  [[NSUserDefaults standardUserDefaults] setObject:[self sdp] forKey:@"SdefSdpToolPath"];
  [[NSUserDefaults standardUserDefaults] setObject:[self rez] forKey:@"SdefRezToolPath"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  return YES;
}

@end
