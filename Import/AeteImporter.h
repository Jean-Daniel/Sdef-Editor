/*
 *  AeteImporter.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefImporter.h"

@interface AeteImporter : SdefImporter {
  NSMutableArray *sd_aetes;
  SdefDictionary *sd_dictionary;
}

- (id)initWithSystemSuites;
- (id)initWithFSRef:(FSRef *)aRef;
- (id)initWithApplicationSignature:(OSType)signature;
- (id)initWithApplicationBundleIdentifier:(NSString *)identifier;

@end
