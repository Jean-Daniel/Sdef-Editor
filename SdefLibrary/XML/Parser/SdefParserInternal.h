/*
 *  SdefParserInternal.h
 *  Sdef Editor
 *
 *  Created by Jean-Daniel Dupas on 30/10/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#import "SdefBase.h"

#include <libxml/tree.h>

@interface SdefDOMParser : NSObject {
  bool sd_abort;
  id sd_delegate;
  xmlNodePtr sd_current;
}

- (id)initWithDelegate:(id)aDelegate;
- (BOOL)parse:(xmlNodePtr)root;

- (NSInteger)line;
- (NSInteger)location;

- (void)abortWithError:(NSInteger)code reason:(NSString *)msg;

- (NSStringEncoding)encoding;

@end

typedef id SdefXMLStructure;
@interface NSObject (SdefDOMParserDelegate)

- (SdefXMLStructure)parser:(SdefDOMParser *)parser createStructureForNode:(xmlNodePtr)node;
- (void)parser:(SdefDOMParser *)parser addChild:(SdefXMLStructure)aChild toStructure:(SdefXMLStructure)aStruct;
- (void)parser:(SdefDOMParser *)parser endStructure:(SdefXMLStructure)structure;

@end

SPX_PRIVATE
NSUInteger _SdefXMLAttributeCount(xmlNodePtr node);

SPX_PRIVATE
xmlAttr *_SdefXMLAttributeAtIndex(xmlNodePtr node, NSUInteger idx);

SPX_PRIVATE
const xmlChar *_SdefXMLAttributeGetValue(xmlAttr *attr);

SPX_PRIVATE
NSDictionary *_SdefXMLCreateDictionaryWithAttributes(xmlAttr *attr, NSStringEncoding encoding);

