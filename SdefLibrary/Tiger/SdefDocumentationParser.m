/*
 *  SdefDocumentationParser.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefXMLParser.h"
#import "SdefDocumentation.h"

@implementation SdefDocumentationParser

- (id)init {
  return [self initWithDocumentation:nil parent:nil];
}

- (id)initWithDocumentation:(SdefDocumentation *)doc parent:(id)theParent {
  if (self = [super init]) {
    sd_doc = doc;
    sd_parent = theParent;
    sd_content = [[NSMutableString alloc] init];
  }
  return self;
}

- (void)dealloc {
  [sd_content release];
  [super dealloc];
}

#pragma mark Element Handling
- (id)parser:(CFXMLParserRef)parser didStartElement:(NSString *)elementName infos:(CFXMLElementInfo *)infos {
  if (sd_html > 0) {
    [sd_content appendString:@"<"];
    [sd_content appendString:elementName];
    id attribute;
    id attrs = [(id)infos->attributeOrder objectEnumerator];
    while (attribute = [attrs nextObject]) {
      [sd_content appendString:@" "];
      [sd_content appendString:attribute];
      [sd_content appendString:@"=\""];
      [sd_content appendString:[(id)infos->attributes objectForKey:attribute]];
      [sd_content appendString:@"\""];
    }
    if (infos->isEmpty) {
      [sd_content appendString:@"/>"];
    } else {
      [sd_content appendString:@">"];
    }
  }
  if ([elementName isEqualToString:@"html"]) {
    /* If open the first html element, reset content */
    if (0 == sd_html) {
      [sd_content deleteCharactersInRange:NSMakeRange(0, [sd_content length])];
    }
    sd_html++;
    [sd_doc setHtml:YES];
  }
  return infos->isEmpty ? nil : elementName;
}


// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(CFXMLParserRef)parser didEndElement:(NSString *)elementName {
  if ([elementName isEqualToString:@"documentation"]) {
    [sd_doc setContent:sd_content];
    [sd_parent parserDidEndDocumentation:self];
  } else if ([elementName isEqualToString:@"html"]) {
    sd_html--;
  }
  if (sd_html > 0) {
    [sd_content appendString:@"</"];
    [sd_content appendString:elementName];
    [sd_content appendString:@">"];
  }
}

#pragma mark Other Objects Handling
- (void)parser:(CFXMLParserRef)parser foundEntity:(NSString *)string {
  if (sd_html > 0) {
    [sd_content appendString:@"&"];
    [sd_content appendString:string];
    [sd_content appendString:@";"];
  } else {
    if ([string isEqualToString:@"amp"]) {
      [sd_content appendString:@"&"];
    } else if ([string isEqualToString:@"lt"]) {
      [sd_content appendString:@"<"];
    } else if ([string isEqualToString:@"gt"]) {
      [sd_content appendString:@">"];
    } else if ([string isEqualToString:@"apos"]) {
      [sd_content appendString:@"'"];
    } else if ([string isEqualToString:@"quot"]) {
      [sd_content appendString:@"\""];
    } else {
      [sd_content appendString:@"&"];
      [sd_content appendString:string];
      [sd_content appendString:@";"];
    }
  }
}

// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run.
// The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
- (void)parser:(CFXMLParserRef)parser foundCharacters:(NSString *)string {
  [sd_content appendString:string];
}

// The parser reports ignorable whitespace in the same way as characters it's found.
- (void)parser:(CFXMLParserRef)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
  if (sd_html > 0 || ![sd_doc isHtml]) {
    [sd_content appendString:whitespaceString];
  }
}

// The parser reports a processing instruction to you using this method.
// In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"
- (void)parser:(CFXMLParserRef)parser foundProcessingInstructionWithTarget:(NSString *)target data:(CFXMLProcessingInstructionInfo *)data {
  ShadowTrace();
  if (sd_html > 0) {
    [sd_content appendString:@"<?"];
    [sd_content appendString:target];
    [sd_content appendString:@" "];
    if (data && data->dataString)
      [sd_content appendString:(id)data->dataString];
    [sd_content appendString:@" ?>"];
  }
}

// A comment (Text in a <!-- --> block) is reported to the delegate as a single string
- (void)parser:(CFXMLParserRef)parser foundComment:(NSString *)comment {
  if (sd_html > 0) {
    [sd_content appendString:@"<!-- "];
    [sd_content appendString:comment];
    [sd_content appendString:@"-->"];
  }
}

// this reports a CDATA block to the delegate.
- (void)parser:(CFXMLParserRef)parser foundCDATA:(NSString *)CDATABlock {
  if (sd_html > 0) {
    [sd_content appendString:CDATABlock];
  } else {
    WLog(@"Encounter a CDData block outside html element");
  }
}

// ...and this reports a fatal error to the delegate. The parser will stop parsing.
- (void)parser:(CFXMLParserRef)parser parseErrorOccurred:(NSError *)parseError {
  DLog(@"Error: %@, %@", parseError, [parseError userInfo]);
}

#pragma mark -
#pragma mark Low Level Parsing
- (id)parser:(CFXMLParserRef)parser didStartXMLNode:(CFXMLNodeRef)node {
  void *structure = nil;
  // Use the dataTypeID to determine what to print.
  switch (CFXMLNodeGetTypeCode(node)) {
    case kCFXMLNodeTypeDocument:
      break;
    case kCFXMLNodeTypeElement:
      structure = [self parser:parser didStartElement:(id)CFXMLNodeGetString(node) infos:(CFXMLElementInfo *)CFXMLNodeGetInfoPtr(node)];
      break;
    case kCFXMLNodeTypeProcessingInstruction:
      [self parser:parser foundProcessingInstructionWithTarget:(id)CFXMLNodeGetString(node)
              data:(CFXMLProcessingInstructionInfo *)CFXMLNodeGetInfoPtr(node)];
      break;
    case kCFXMLNodeTypeComment:
      [self parser:parser foundComment:(id)CFXMLNodeGetString(node)];
      break;
    case kCFXMLNodeTypeText:
      [self parser:parser foundCharacters:(id)CFXMLNodeGetString(node)];
      break;
    case kCFXMLNodeTypeCDATASection:
      [self parser:parser foundCDATA:(id)CFXMLNodeGetString(node)];
      break;
    case kCFXMLNodeTypeEntityReference:
      [self parser:parser foundEntity:(id)CFXMLNodeGetString(node)];
      break;
    case kCFXMLNodeTypeDocumentType:
      DLog(@"Data Type ID: kCFXMLNodeTypeDocumentType (%@)", CFXMLNodeGetString(node));
      break;
    case kCFXMLNodeTypeWhitespace:
      [self parser:parser foundIgnorableWhitespace:(id)CFXMLNodeGetString(node)];
      break;
    default:
      DLog(@"Unknown Data Type ID: %ld (%@)", (long)CFXMLNodeGetTypeCode(node), CFXMLNodeGetString(node));
  }
  return structure;
}

- (void)parser:(CFXMLParserRef)parser didEndXMLNode:(id)node {
  if ([node isKindOfClass:[NSString class]]) {
    [self parser:parser didEndElement:node];
  }
}

@end
