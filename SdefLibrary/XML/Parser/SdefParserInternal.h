/*
 *  SdefParserInternal.h
 *  Sdef Editor
 *
 *  Created by Jean-Daniel Dupas on 30/10/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

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

- (CFStringEncoding)cfencoding;

- (NSStringEncoding)nsencoding;

@end

@interface NSObject (SdefDOMParserDelegate)

- (void *)parser:(SdefDOMParser *)parser createStructureForNode:(xmlNodePtr)node;
- (void)parser:(SdefDOMParser *)parser addChild:(void *)aChild toStructure:(void *)aStruct;
- (void)parser:(SdefDOMParser *)parser endStructure:(void *)structure;

@end

WB_PRIVATE
NSUInteger _SdefXMLAttributeCount(xmlNodePtr node);

WB_PRIVATE
xmlAttr *_SdefXMLAttributeAtIndex(xmlNodePtr node, NSUInteger idx);

WB_PRIVATE
const xmlChar *_SdefXMLAttributeGetValue(xmlAttr *attr);

WB_PRIVATE
CFDictionaryRef _SdefXMLCreateDictionaryWithAttributes(xmlAttr *attr, CFStringEncoding encoding);

