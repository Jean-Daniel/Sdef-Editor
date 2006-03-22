/*
 *  Preferences.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "Preferences.h"

@implementation Preferences

- (id)init {
  if (self = [super init]) {
    [self setSdp:[[NSUserDefaults standardUserDefaults] stringForKey:@"SdefSdpToolPath"]];
    [self setRez:[[NSUserDefaults standardUserDefaults] stringForKey:@"SdefRezToolPath"]];

    [self setBuildInSdp:[[NSUserDefaults standardUserDefaults] boolForKey:@"SdefBuildInSdp"]];
    [self setBuildInRez:[[NSUserDefaults standardUserDefaults] boolForKey:@"SdefBuildInRez"]];
  }
  return self;
}

- (void)dealloc {
  [sdp release];
  [rez release];
  [super dealloc];
}

- (BOOL)buildInSdp {
  return sd_prFlags.sdp;
}
- (void)setBuildInSdp:(BOOL)flag {
  sd_prFlags.sdp = (flag) ? 1 : 0;
}

- (BOOL)buildInRez {
  return sd_prFlags.rez;
}
- (void)setBuildInRez:(BOOL)flag {
  sd_prFlags.rez = (flag) ? 1 : 0;
}

- (NSString *)sdp {
  return sdp;
}
- (void)setSdp:(NSString *)newSdp {
  if (sdp != newSdp) {
    [sdp release];
    sdp = [newSdp retain];
  }
}

- (NSString *)rez {
  return rez;
}
- (void)setRez:(NSString *)newRez {
  if (rez != newRez) {
    [rez release];
    rez = [newRez retain];
  }
}

#pragma mark -
- (BOOL)windowShouldClose:(id)sender {
  if (![self sdp]) {
    [self setBuildInSdp:YES];
  }
  if (![self rez]) {
    [self setBuildInRez:YES];
  }
  BOOL isDir;
  if (![self buildInSdp] && (![[NSFileManager defaultManager] fileExistsAtPath:[self sdp] isDirectory:&isDir] || isDir)) {
    NSRunAlertPanel(@"The sdp Tool path could not be setted because it is not valid!",
                    @"The path you set for sdp tool is not valid. Choose a valid path or use build-in tool.",
                    @"OK", nil, nil);
    return NO;
  }
  
  if (![self buildInRez] && (![[NSFileManager defaultManager] fileExistsAtPath:[self rez] isDirectory:&isDir] || isDir)) {
    NSRunAlertPanel(@"The Rez Tool path could not be setted because it is not valid!",
                    @"The path you set for Rez tool is not valid. Choose a valid path or use build-in tool.",
                    @"OK", nil, nil);
    return NO;
  }
  
  [[NSUserDefaults standardUserDefaults] setObject:[self sdp] forKey:@"SdefSdpToolPath"];
  [[NSUserDefaults standardUserDefaults] setObject:[self rez] forKey:@"SdefRezToolPath"];
  [[NSUserDefaults standardUserDefaults] setBool:[self buildInSdp] forKey:@"SdefBuildInSdp"];
  [[NSUserDefaults standardUserDefaults] setBool:[self buildInRez] forKey:@"SdefBuildInRez"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  return YES;
}

@end
