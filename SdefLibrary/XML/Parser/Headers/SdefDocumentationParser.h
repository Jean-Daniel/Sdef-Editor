/*
 *  SdefDocumentationParser.h
 *  Sdef Editor
 *
 *  Created by Grayfox on 21/04/07.
 *  Copyright 2007 Shadow Lab. All rights reserved.
 */

#import "SdefParser.h"

@class SdefParser, SdefDocumentation;
@interface SdefDocumentationParser : NSObject {
  @private
  NSInteger sd_html;
  SdefDocumentation *sd_doc;
  CFMutableStringRef sd_content;
}

- (id)initWithDocumentation:(SdefDocumentation *)doc;

- (void)close;

- (void *)parser:(CFXMLParserRef)parser createStructureForNode:(CFXMLNodeRef)node;
- (void)parser:(CFXMLParserRef)parser addChild:(void *)child toStructure:(void *)parent;
- (void)parser:(CFXMLParserRef)parser endStructure:(void *)structure;

@end
