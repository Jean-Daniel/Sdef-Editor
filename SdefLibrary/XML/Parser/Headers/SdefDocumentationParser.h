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
    NSInteger sd_html;
    SdefParser *sd_parent;
    SdefDocumentation *sd_doc;
    CFMutableStringRef sd_content;
}

- (id)initWithDocumentation:(SdefDocumentation *)doc parent:(SdefParser *)theParent;

- (void *)parser:(CFXMLParserRef)parser createStructureForNode:(CFXMLNodeRef)node;
- (void)parser:(CFXMLParserRef)parser addChild:(void *)child toStructure:(void *)parent;
- (void)parser:(CFXMLParserRef)parser endStructure:(void *)structure;

@end
