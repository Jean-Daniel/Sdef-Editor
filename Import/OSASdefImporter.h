//
//  OSASdefImporter.h
//  Sdef Editor
//
//  Created by Grayfox on 22/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefImporter.h"

@interface OSASdefImporter : SdefImporter {
  NSString *sd_path;
  SdefDictionary *sd_dico;
}

- (id)initWithFile:(NSString *)file;

@end
