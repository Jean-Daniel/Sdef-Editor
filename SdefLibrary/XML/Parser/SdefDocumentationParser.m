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
- (CFStringRef)parser:(CFXMLParserRef)parser didStartElement:(CFStringRef)element infos:(CFXMLElementInfo *)infos {
  if (sd_html > 0) {
    CFStringAppend(sd_content, CFSTR("<"));
    CFStringAppend(sd_content, element);
    /* Append attributes */
    CFStringRef attribute;
    NSEnumerator *attrs = [(id)infos->attributeOrder objectEnumerator];
    while (attribute = (CFStringRef)[attrs nextObject]) {
      bool single = false;
      CFStringRef value = CFDictionaryGetValue(infos->attributes, attribute);
      /* if value contains a double quote, use simple quote */
      if (CFStringFind(value, CFSTR("\""), 0).location != kCFNotFound) {
        single = true;
      }
      CFStringAppend(sd_content, CFSTR(" "));
      CFStringAppend(sd_content, attribute);
      if (single) CFStringAppend(sd_content, CFSTR("='"));
      else CFStringAppend(sd_content, CFSTR("=\""));
      CFStringAppend(sd_content, value);
      if (single) CFStringAppend(sd_content, CFSTR("'"));
      else CFStringAppend(sd_content, CFSTR("\""));
    }
    if (infos->isEmpty) {
      CFStringAppend(sd_content, CFSTR(" />"));
    } else {
      CFStringAppend(sd_content, CFSTR(">"));
    }
  }
  if (CFEqual(element, CFSTR("html"))) {
    /* If open the first html element, reset content */
    if (0 == sd_html) {
      CFStringDelete(sd_content, CFRangeMake(0, CFStringGetLength(sd_content)));
    }
    sd_html++;
    [sd_doc setHtml:YES];
  }
  return infos->isEmpty ? NULL : element;
}

- (void)close {
  [sd_doc setContent:(id)sd_content];
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(CFXMLParserRef)parser didEndElement:(CFStringRef)element {
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
- (void)parser:(CFXMLParserRef)parser foundEntity:(CFStringRef)string {
  if (sd_html > 0) {
    CFStringAppend(sd_content, CFSTR("&"));
    CFStringAppend(sd_content, string);
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
      CFStringAppend(sd_content, string);
      CFStringAppend(sd_content, CFSTR(";"));
    }
  }
}

// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run.
// The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
- (void)parser:(CFXMLParserRef)parser foundCharacters:(CFStringRef)string {
  CFStringAppend(sd_content, string);
}

// The parser reports ignorable whitespace in the same way as characters it's found.
- (void)parser:(CFXMLParserRef)parser foundIgnorableWhitespace:(CFStringRef)whitespaceString {
  if (sd_html > 0 || ![sd_doc isHtml]) {
    CFStringAppend(sd_content, whitespaceString);
  }
}

// The parser reports a processing instruction to you using this method.
// In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"
- (void)parser:(CFXMLParserRef)parser foundProcessingInstructionWithTarget:(CFStringRef)target data:(CFXMLProcessingInstructionInfo *)data {
  if (sd_html > 0) {
    CFStringAppend(sd_content, CFSTR("<?"));
    CFStringAppend(sd_content, target);
    CFStringAppend(sd_content, CFSTR(" "));
    if (data && data->dataString)
      CFStringAppend(sd_content, data->dataString);
    CFStringAppend(sd_content, CFSTR(" ?>"));
  }
}

// A comment (Text in a <!-- --> block) is reported to the delegate as a single string
- (void)parser:(CFXMLParserRef)parser foundComment:(CFStringRef)comment {
  if (sd_html > 0) {
    CFStringAppend(sd_content, CFSTR("<!-- "));
    CFStringAppend(sd_content, comment);
    CFStringAppend(sd_content, CFSTR("-->"));
  }
}

// this reports a CDATA block to the delegate.
- (void)parser:(CFXMLParserRef)parser foundCDATA:(CFStringRef)CDATABlock {
  if (sd_html > 0) {
    CFStringAppend(sd_content, CDATABlock);
  } else {
    WLog(@"Encounter a CDData block outside html element");
  }
}

#pragma mark -
#pragma mark Low Level Parsing
- (void *)parser:(CFXMLParserRef)parser createStructureForNode:(CFXMLNodeRef)node {
  void *structure = nil;
  // Use the dataTypeID to determine what to print.
  switch (CFXMLNodeGetTypeCode(node)) {
    case kCFXMLNodeTypeDocument:
      break;
    case kCFXMLNodeTypeElement:
      structure = (void *)[self parser:parser didStartElement:CFXMLNodeGetString(node) infos:(CFXMLElementInfo *)CFXMLNodeGetInfoPtr(node)];
      break;
    case kCFXMLNodeTypeProcessingInstruction:
      [self parser:parser foundProcessingInstructionWithTarget:CFXMLNodeGetString(node)
              data:(CFXMLProcessingInstructionInfo *)CFXMLNodeGetInfoPtr(node)];
      break;
    case kCFXMLNodeTypeComment:
      [self parser:parser foundComment:CFXMLNodeGetString(node)];
      break;
    case kCFXMLNodeTypeText:
      [self parser:parser foundCharacters:CFXMLNodeGetString(node)];
      break;
    case kCFXMLNodeTypeCDATASection:
      [self parser:parser foundCDATA:CFXMLNodeGetString(node)];
      break;
    case kCFXMLNodeTypeEntityReference:
      [self parser:parser foundEntity:CFXMLNodeGetString(node)];
      break;
    case kCFXMLNodeTypeWhitespace:
      [self parser:parser foundIgnorableWhitespace:CFXMLNodeGetString(node)];
      break;
      /* should never append */
    case kCFXMLNodeTypeDocumentType:
      DLog(@"Data Type ID: kCFXMLNodeTypeDocumentType (%@)", CFXMLNodeGetString(node));
      break;
    default:
      DLog(@"Unknown Data Type ID: %ld (%@)", (long)CFXMLNodeGetTypeCode(node), CFXMLNodeGetString(node));
  }
  return structure;
}

- (void)parser:(CFXMLParserRef)parser addChild:(void *)child toStructure:(void *)parent {
  // ignore
}

- (void)parser:(CFXMLParserRef)parser endStructure:(void *)structure {
  if (structure && CFStringGetTypeID() == CFGetTypeID(structure)) {
    [self parser:parser didEndElement:structure];
  }
}

@end
