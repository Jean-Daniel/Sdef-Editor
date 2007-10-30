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

@implementation SdefDocumentationParser

- (id)init {
  return [self initWithDocumentation:nil];
}

- (id)initWithDocumentation:(SdefDocumentation *)doc {
  if (self = [super init]) {
    sd_doc = doc;
    sd_content = CFStringCreateMutable(kCFAllocatorDefault, 0);
  }
  return self;
}

- (void)dealloc {
  if (sd_content) CFRelease(sd_content);
  [super dealloc];
}

#pragma mark Element Handling
- (CFStringRef)parser:(SdefDOMParser *)parser didStartElement:(xmlNodePtr)element {
  if (sd_html > 0) {
    CFStringAppend(sd_content, CFSTR("<"));
    CFStringAppendCString(sd_content, (const char *)element->name, [parser cfencoding]);
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
          CFStringAppend(sd_content, CFSTR(" "));
          CFStringAppendCString(sd_content, (const char *)attr, [parser cfencoding]);
          if (single) CFStringAppend(sd_content, CFSTR("='"));
          else CFStringAppend(sd_content, CFSTR("=\""));
          CFStringAppendCString(sd_content, (const char *)value, [parser cfencoding]);
          if (single) CFStringAppend(sd_content, CFSTR("'"));
          else CFStringAppend(sd_content, CFSTR("\""));
        }
      }
    }
    if (element->children) {
      CFStringAppend(sd_content, CFSTR(">"));
    } else {
      CFStringAppend(sd_content, CFSTR(" />"));
    }
  }
  if (0 == xmlStrcmp(element->name, (const xmlChar *)"html")) {
    /* If open the first html element, reset content */
    if (0 == sd_html) {
      CFStringDelete(sd_content, CFRangeMake(0, CFStringGetLength(sd_content)));
    }
    sd_html++;
    [sd_doc setHtml:YES];
  }
  if (element->children)
    return (CFStringRef)[NSString stringWithCString:(const char *)element->name encoding:[parser nsencoding]];
  return NULL;
}

- (void)close {
  [sd_doc setContent:(id)sd_content];
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(SdefDOMParser *)parser didEndElement:(CFStringRef)element {
  if (CFEqual(element, CFSTR("html"))) {
    sd_html--;
  }
  if (sd_html > 0) {
    CFStringAppend(sd_content, CFSTR("</"));
    CFStringAppend(sd_content, element);
    CFStringAppend(sd_content, CFSTR(">"));
  }
}

#pragma mark Other Objects Handling
- (void)parser:(SdefDOMParser *)parser foundEntity:(const xmlChar *)string {
  if (sd_html > 0) {
    CFStringAppend(sd_content, CFSTR("&"));
    CFStringAppendCString(sd_content, (const char *)string, [parser cfencoding]);
    CFStringAppend(sd_content, CFSTR(";"));
  } else {
    if (CFEqual(string, CFSTR("amp"))) {
      CFStringAppend(sd_content, CFSTR("&"));
    } else if (CFEqual(string, CFSTR("lt"))) {
      CFStringAppend(sd_content, CFSTR("<"));
    } else if (CFEqual(string, CFSTR("gt"))) {
      CFStringAppend(sd_content, CFSTR(">"));
    } else if (CFEqual(string, CFSTR("apos"))) {
      CFStringAppend(sd_content, CFSTR("'"));
    } else if (CFEqual(string, CFSTR("quot"))) {
      CFStringAppend(sd_content, CFSTR("\""));
    } else {
      CFStringAppend(sd_content, CFSTR("&"));
      CFStringAppendCString(sd_content, (const char *)string, [parser cfencoding]);
      CFStringAppend(sd_content, CFSTR(";"));
    }
  }
}

// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run.
// The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
- (void)parser:(SdefDOMParser *)parser foundCharacters:(const xmlChar *)string {
  CFStringAppendCString(sd_content, (const char *)string, [parser cfencoding]);
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
    CFStringAppend(sd_content, CFSTR("<?"));
    CFStringAppendCString(sd_content, (const char *)target, [parser cfencoding]);
    CFStringAppend(sd_content, CFSTR(" "));
    if (data)
      CFStringAppendCString(sd_content, (const char *)data, [parser cfencoding]);
    CFStringAppend(sd_content, CFSTR(" ?>"));
  }
}

// A comment (Text in a <!-- --> block) is reported to the delegate as a single string
- (void)parser:(SdefDOMParser *)parser foundComment:(const xmlChar *)aComment {
  if (sd_html > 0) {
    CFStringAppend(sd_content, CFSTR("<!-- "));
    CFStringAppendCString(sd_content, (const char *)aComment, [parser cfencoding]);
    CFStringAppend(sd_content, CFSTR("-->"));
  }
}

// this reports a CDATA block to the delegate.
- (void)parser:(SdefDOMParser *)parser foundCDATA:(const xmlChar *)data {
  if (sd_html > 0) {
    CFStringAppendCString(sd_content, (const char *)data, [parser cfencoding]);
  } else {
    WLog(@"Encounter a CDData block outside html element");
  }
}

#pragma mark -
#pragma mark Low Level Parsing
- (void *)parser:(SdefDOMParser *)parser createStructureForNode:(xmlNodePtr)node {
  void *structure = nil;
  // Use the dataTypeID to determine what to print.
  switch (node->type) {
    case XML_DOCUMENT_NODE:
      break;
    case XML_ELEMENT_NODE:
      structure = (void *)[self parser:parser didStartElement:node];
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
//      DLog(@"Data Type ID: kCFXMLNodeTypeDocumentType (%s)", node->content);
//      break;
    default:
      DLog(@"Unknown Data Type ID: %ld (%s)", (long)node->type, node->name);
  }
  return structure;
}

- (void)parser:(SdefDOMParser *)parser addChild:(void *)child toStructure:(void *)parent {
  // ignore
}

- (void)parser:(SdefDOMParser *)parser endStructure:(void *)structure {
  if (structure && CFStringGetTypeID() == CFGetTypeID(structure)) {
    [self parser:parser didEndElement:structure];
  }
}

@end
