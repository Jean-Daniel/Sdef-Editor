/*
 *  SdefXMLGenerator.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

@class SdefObject;
@interface SdefXMLGenerator : NSObject {
  CFXMLTreeRef sd_doc;
  CFXMLTreeRef sd_node;
  NSUInteger sd_indent;
  SdefObject *sd_root;
}

- (id)initWithRoot:(SdefObject *)dictionary;
- (NSData *)xmlDataForVersion:(SdefVersion)version;

- (SdefObject *)root;
- (void)setRoot:(SdefObject *)anObject;

@end
