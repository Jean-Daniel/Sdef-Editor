//
//  AeteImporter.h
//  Sdef Editor
//
//  Created by Grayfox on 30/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefImporter.h"

@interface AeteImporter : SdefImporter {
  NSMutableArray *sd_aetes;
}

- (id)initWithFSRef:(FSRef *)aRef;
- (id)initWithApplicationSignature:(OSType)signature;
- (id)initWithApplicationBundleIdentifier:(NSString *)identifier;

@end
