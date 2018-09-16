/*
 *  SdefDocumentationParser.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefParser.h"
#import "SdefDocumentation.h"
#import "SdefDocumentationParser.h"

@implementation NSMutableString (AppendCString)

- (void)appendCString:(const char *)aString encoding:(NSStringEncoding)encoding {
  CFStringAppendCString(SPXNSToCFMutableString(self), aString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

@end

@interface SdefDocumentationParser ()
- (void)parser:(SdefDOMParser *)parser foundCDATA:(const xmlChar *)data;
- (void)parser:(SdefDOMParser *)parser foundComment:(const xmlChar *)aComment;
- (void)parser:(SdefDOMParser *)parser foundCharacters:(const xmlChar *)string;
- (void)parser:(SdefDOMParser *)parser foundProcessingInstructionWithTarget:(const xmlChar *)target data:(const xmlChar *)data;
@end

@implementation SdefDocumentationParser

- (id)init {
  return [self initWithDocumentation:nil];
}

- (id)initWithDocumentation:(SdefDocumentation *)doc {
  if (self = [super init]) {
    sd_doc = doc;
    sd_content = [[NSMutableString alloc] init];
  }
  return self;
}

#pragma mark Element Handling
- (NSString *)parser:(SdefDOMParser *)parser didStartElement:(xmlNodePtr)element {
  if (sd_html > 0) {
    [sd_content appendString:@"<"];
    [sd_content appendCString:(const char *)element->name encoding:[parser encoding]];
    /* Append attributes */
    NSUInteger count = _SdefXMLAttributeCount(element);
    if (count > 0) {
      for (NSUInteger idx = 0; idx < count; idx++) {
        bool single = false;
        xmlAttr *attr = _SdefXMLAttributeAtIndex(element, idx);
        const xmlChar *value = _SdefXMLAttributeGetValue(attr);
        if (value) {
          /* if value contains a double quote, use simple quote */
          if (xmlStrchr(value, '"')) single = true;
          [sd_content appendString:@" "];
          [sd_content appendCString:(const char *)attr encoding:[parser encoding]];
          if (single)
            [sd_content appendString:@"='"];
          else
            [sd_content appendString:@"=\""];
          [sd_content appendCString:(const char *)value encoding:[parser encoding]];
          if (single)
            [sd_content appendString:@"'"];
          else
            [sd_content appendString:@"\""];
        }
      }
    }
    if (element->children) {
      [sd_content appendString:@">"];
    } else {
      [sd_content appendString:@" />"];
    }
  }
  if (0 == xmlStrcmp(element->name, (const xmlChar *)"html")) {
    /* If open the first html element, reset content */
    if (0 == sd_html)
      [sd_content setString:@""];
    sd_html++;
    [sd_doc setHtml:YES];
  }
  if (element->children)
    return [NSString stringWithCString:(const char *)element->name encoding:[parser encoding]];
  return NULL;
}

- (void)close {
  [sd_doc setContent:(id)sd_content];
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(SdefDOMParser *)parser didEndElement:(NSString *)element {
  if ([element isEqualToString:@"html"]) {
    sd_html--;
  }
  if (sd_html > 0) {
    [sd_content appendString:@"</"];
    [sd_content appendString:element];
    [sd_content appendString:@">"];
  }
}

#pragma mark Other Objects Handling
- (void)parser:(SdefDOMParser *)parser foundEntity:(const xmlChar *)string {
  if (sd_html > 0) {
    [sd_content appendString:@"&"];
    [sd_content appendCString:(const char *)string encoding:[parser encoding]];
    [sd_content appendString:@";"];
  } else {
    if (strcmp((const char *)string, "amp") == 0) {
      [sd_content appendString:@"&"];
    } else if (strcmp((const char *)string, "lt") == 0) {
      [sd_content appendString:@"<"];
    } else if (strcmp((const char *)string, "gt") == 0) {
      [sd_content appendString:@">"];
    } else if (strcmp((const char *)string, "apos") == 0) {
      [sd_content appendString:@"'>'"];
    } else if (strcmp((const char *)string, "quot") == 0) {
      [sd_content appendString:@"\""];
    } else {
      [sd_content appendString:@"&"];
      [sd_content appendCString:(const char *)string encoding:[parser encoding]];
      [sd_content appendString:@";"];
    }
  }
}

// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run.
// The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
- (void)parser:(SdefDOMParser *)parser foundCharacters:(const xmlChar *)string {
  [sd_content appendCString:(const char *)string encoding:[parser encoding]];
}

// The parser reports ignorable whitespace in the same way as characters it's found.
//- (void)parser:(SdefDOMParser *)parser foundIgnorableWhitespace:(CFStringRef)whitespaceString {
//  if (sd_html > 0 || ![sd_doc isHtml]) {
//    CFStringAppend(sd_content, whitespaceString);
//  }
//}

// The parser reports a processing instruction to you using this method.
// In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"
- (void)parser:(SdefDOMParser *)parser foundProcessingInstructionWithTarget:(const xmlChar *)target data:(const xmlChar *)data {
  if (sd_html > 0) {
    [sd_content appendString:@"<?"];
    [sd_content appendCString:(const char *)target encoding:[parser encoding]];
    [sd_content appendString:@" "];
    if (data)
      [sd_content appendCString:(const char *)data encoding:[parser encoding]];
    [sd_content appendString:@" ?>"];
  }
}

// A comment (Text in a <!-- --> block) is reported to the delegate as a single string
- (void)parser:(SdefDOMParser *)parser foundComment:(const xmlChar *)aComment {
  if (sd_html > 0) {
    [sd_content appendString:@"<!-- "];
    [sd_content appendCString:(const char *)aComment encoding:[parser encoding]];
    [sd_content appendString:@"-->"];
  }
}

// this reports a CDATA block to the delegate.
- (void)parser:(SdefDOMParser *)parser foundCDATA:(const xmlChar *)data {
  if (sd_html > 0) {
    [sd_content appendCString:(const char *)data encoding:[parser encoding]];
  } else {
    spx_log_warning("Encounter a CDData block outside html element");
  }
}

#pragma mark -
#pragma mark Low Level Parsing
- (SdefXMLStructure)parser:(SdefDOMParser *)parser createStructureForNode:(xmlNodePtr)node {
  SdefXMLStructure structure = nil;
  // Use the dataTypeID to determine what to print.
  switch (node->type) {
    case XML_DOCUMENT_NODE:
      break;
    case XML_ELEMENT_NODE:
      structure = [self parser:parser didStartElement:node];
      break;
    case XML_PI_NODE:
      [self parser:parser foundProcessingInstructionWithTarget:node->name data:node->content];
      break;
    case XML_COMMENT_NODE:
      [self parser:parser foundComment:node->content];
      break;
    case XML_TEXT_NODE:
      [self parser:parser foundCharacters:node->content];
      break;
    case XML_CDATA_SECTION_NODE:
      [self parser:parser foundCDATA:node->content];
      break;
    case XML_ENTITY_REF_NODE:
      [self parser:parser foundEntity:node->name];
      break;
      /* should never append */
//    case kCFXMLNodeTypeWhitespace:
//      [self parser:parser foundIgnorableWhitespace:CFXMLNodeGetString(node)];
//      break;
//    case XML_DTD_NODE:
//    case XML_DOCUMENT_TYPE_NODE:
//      SPXDebug(@"Data Type ID: kCFXMLNodeTypeDocumentType (%s)", node->content);
//      break;
    default:
      SPXDebug(@"Unknown Data Type ID: %ld (%s)", (long)node->type, node->name);
  }
  return structure;
}

- (void)parser:(SdefDOMParser *)parser addChild:(SdefXMLStructure)child toStructure:(SdefXMLStructure)parent {
  // ignore
}

- (void)parser:(SdefDOMParser *)parser endStructure:(SdefXMLStructure)structure {
  [self parser:parser didEndElement:(NSString *)structure];
}

@end
