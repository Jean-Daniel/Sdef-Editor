//
//  SdefXMLGenerator.h
//  SDef Editor
//
//  Created by Grayfox on 08/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SdefObject;
@interface SdefXMLGenerator : NSObject {
  CFXMLTreeRef sd_doc;
  CFXMLTreeRef sd_node;
  unsigned sd_indent;
  SdefObject *sd_root;
}

- (id)initWithRoot:(SdefObject *)dictionary;
- (NSData *)xmlData;

- (SdefObject *)root;
- (void)setRoot:(SdefObject *)anObject;

@end
