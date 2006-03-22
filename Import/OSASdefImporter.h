/*
 *  OSASdefImporter.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefImporter.h"

@interface OSASdefImporter : SdefImporter {
  NSString *sd_path;
  SdefDictionary *sd_dico;
}

- (id)initWithFile:(NSString *)file;

@end
