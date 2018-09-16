/*
 *  SdefDocumentationParser.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefParser.h"
#import "SdefParserInternal.h"

@class SdefParser, SdefDocumentation;
@interface SdefDocumentationParser : NSObject {
  @private
  NSInteger sd_html;
  SdefDocumentation *sd_doc;
  NSMutableString *sd_content;
}

- (id)initWithDocumentation:(SdefDocumentation *)doc;

- (void)close;

- (SdefXMLStructure)parser:(SdefDOMParser *)parser createStructureForNode:(xmlNodePtr)node;
- (void)parser:(SdefDOMParser *)parser addChild:(SdefXMLStructure)child toStructure:(SdefXMLStructure)parent;
- (void)parser:(SdefDOMParser *)parser endStructure:(SdefXMLStructure)structure;

@end
