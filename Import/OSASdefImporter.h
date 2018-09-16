/*
 *  OSASdefImporter.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefImporter.h"

@interface OSASdefImporter : SdefImporter {
  NSURL *sd_url;
  SdefDictionary *sd_dico;
}

- (id)initWithURL:(NSURL *)url;

@end
