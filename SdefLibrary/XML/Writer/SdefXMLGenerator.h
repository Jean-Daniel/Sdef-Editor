/*
 *  SdefXMLGenerator.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

@class SdefObject;
@interface SdefXMLGenerator : NSObject {
  CFXMLTreeRef sd_doc;
  CFXMLTreeRef sd_node;
  NSUInteger sd_indent;
  
  BOOL sd_metas;
  SdefObject *sd_root;
  NSString *sd_comment;
}

- (id)initWithRoot:(SdefObject *)dictionary;
- (NSData *)xmlDataForVersion:(SdefVersion)version;

- (SdefObject *)root;
- (void)setRoot:(SdefObject *)anObject;

- (void)setIgnoreMetas:(BOOL)flag;
- (void)setHeaderComment:(NSString *)comment;

@end
