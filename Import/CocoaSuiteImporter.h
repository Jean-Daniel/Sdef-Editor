/*
 *  CocoaSuiteImporter.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefImporter.h"

@class SdefSuite ;
@interface CocoaSuiteImporter : SdefImporter {
  @private
  NSMutableArray *sd_roots;
  NSMutableArray *sd_suites;
  NSMutableArray *sd_terminologies;

  NSMutableSet *sd_cache;
  
  BOOL sd_std, sd_scpt;
}

- (id)initWithContentsOfFile:(NSString *)file;

- (void)addSuite:(NSDictionary *)suite terminology:(NSDictionary *)terminology;

- (SdefSuite *)sdefSuite;

- (BOOL)preload;

/* private */
- (void)preloadSuite:(NSDictionary *)dictionary;

@end

