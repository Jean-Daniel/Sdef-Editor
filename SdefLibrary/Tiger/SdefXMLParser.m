//
//  SdefXMLParser.m
//  Sdef Editor
//
//  Created by Grayfox on 03/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ShadowBase.h"
#import "SKFunctions.h"

#import "SdefXMLBase.h"
#import "SdefXMLParser.h"

#import "SdefDictionary.h"
#import "SdefTypedef.h"
#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefVerb.h"

#import "SdefTigerParser.h"
#import "SdefPantherParser.h"

@implementation SdefXMLParser

- (void)dealloc {
  [sd_dictionary release];
  [super dealloc];
}

#pragma mark -

- (int)parserVersion {
  return kSdefParserBothVersion;
}

- (void)setVersion:(int)version {
  switch (version) {
    case kSdefParserBothVersion:
      break;
    case kSdefParserTigerVersion:
      DLog(@"Switch to Tiger type");
      SKSwizzleIsaPointer(self, [SdefTigerParser class]);
      break;
    case kSdefParserPantherVersion:
      DLog(@"Switch to Panther type");
      SKSwizzleIsaPointer(self, [SdefPantherParser class]);
      break;
  }
}

- (SdefDictionary *)document {
  return sd_dictionary;
}

- (BOOL)parseData:(NSData *)document {
  if (sd_dictionary) {
    [sd_dictionary release];
    sd_dictionary = nil;
  }
  if (!document) return NO;
  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:document];
  [parser setShouldResolveExternalEntities:YES];
  [parser setDelegate:self];
  BOOL result = [parser parse];
  [parser release];
  return result;
}

#pragma mark -
#pragma mark Sdef Parsing
- (void)parser:(NSXMLParser *)parser didStartDictionary:(NSDictionary *)attributes {
  if (sd_dictionary) {
    [sd_dictionary release];
  }
  sd_dictionary = [(SdefObject *)[SdefDictionary alloc] initWithAttributes:attributes];
  sd_parent = sd_dictionary;
}

- (void)parser:(NSXMLParser *)parser didStartCocoa:(NSDictionary *)attributes {
  ShadowTrace();
}

- (void)parser:(NSXMLParser *)parser didStartDocumentation:(NSDictionary *)attributes {
  ShadowTrace();
}

- (void)parser:(NSXMLParser *)parser didStartSynonym:(NSDictionary *)attributes {
  ShadowTrace();
}

#pragma mark -
#pragma mark Suite
- (void)parser:(NSXMLParser *)parser didStartSuite:(NSDictionary *)attributes {
  SdefSuite *suite = [(SdefObject *)[SdefSuite allocWithZone:[self zone]] initWithAttributes:attributes];
  [sd_parent appendChild:suite];
  [suite release];
  sd_node = suite;
  sd_parent = suite;
}

#pragma mark Enumeration
- (void)parser:(NSXMLParser *)parser didStartEnumeration:(NSDictionary *)attributes {
  SdefEnumeration *enumeration = [(SdefObject *)[SdefEnumeration allocWithZone:[self zone]] initWithAttributes:attributes];
  [sd_node appendChild:enumeration];
  [enumeration release];
  sd_node = enumeration;
}

- (void)parser:(NSXMLParser *)parser didStartEnumerator:(NSDictionary *)attributes {
  SdefEnumerator *enumerator = [(SdefObject *)[SdefEnumerator allocWithZone:[self zone]] initWithAttributes:attributes];
  [sd_node appendChild:enumerator];
  [enumerator release];
  sd_node = enumerator;
}

#pragma mark Class
- (void)parser:(NSXMLParser *)parser didStartClass:(NSDictionary *)attributes {
  SdefClass *class = [(SdefObject *)[SdefClass allocWithZone:[self zone]] initWithAttributes:attributes];
  [[sd_parent classes] appendChild:class];
  [class release];
  sd_node = class;
  sd_parent = class;
}

- (void)parser:(NSXMLParser *)parser didStartContents:(NSDictionary *)attributes {
  ShadowTrace();
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSDictionary *)attributes {
  ShadowTrace();
}

- (void)parser:(NSXMLParser *)parser didStartAccessor:(NSDictionary *)attributes {
  ShadowTrace();
}

- (void)parser:(NSXMLParser *)parser didStartProperty:(NSDictionary *)attributes {
  ShadowTrace();
}

- (void)parser:(NSXMLParser *)parser didStartRespondsTo:(NSDictionary *)attributes {
  ShadowTrace();
}


#pragma mark Verb
- (void)parser:(NSXMLParser *)parser didStartCommand:(NSDictionary *)attributes {
  SdefVerb *command = [(SdefObject *)[SdefVerb allocWithZone:[self zone]] initWithAttributes:attributes];
  [[(SdefSuite *)sd_parent commands] appendChild:command];
  [command release];
  sd_node = command;
  sd_parent = command;
}

- (void)parser:(NSXMLParser *)parser didStartEvent:(NSDictionary *)attributes {
  SdefVerb *event = [(SdefObject *)[SdefVerb allocWithZone:[self zone]] initWithAttributes:attributes];
  [[(SdefSuite *)sd_parent events] appendChild:event];
  [event release];
  sd_node = event;
  sd_parent = event;
}

- (void)parser:(NSXMLParser *)parser didStartDirectParameter:(NSDictionary *)attributes {
  ShadowTrace();
}

- (void)parser:(NSXMLParser *)parser didStartParameter:(NSDictionary *)attributes {
  ShadowTrace();
}

- (void)parser:(NSXMLParser *)parser didStartResult:(NSDictionary *)attributes {
  ShadowTrace();
}

#pragma mark Misc
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)element withAttributes:(NSDictionary *)attributes {
  [NSException raise:@"SdefParserException" format:@"Unknow element %@", element];
}

#pragma mark -
#pragma mark End Element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)element {
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[element methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");
  /* Parent Elements */
  if (isEqual(element, cmd, @"dictionary")) {
    sd_parent = nil;
  } else if (isEqual(element, cmd, @"suite")) {
    sd_parent = [(SdefObject *)sd_parent dictionary];
  } else if (isEqual(element, cmd, @"class") ||
             isEqual(element, cmd, @"command") ||
             isEqual(element, cmd, @"event")) {
    sd_parent = [sd_parent suite];
  }
//  sd_node = [sd_node parent];
}

#pragma mark -
/*
#pragma mark Document Handling
// sent when the parser begins parsing of the document.
- (void)parserDidStartDocument:(NSXMLParser *)parser {
}

// sent when the parser has completed parsing. If this is encountered, the parse was successful.
- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

#pragma mark DTD Handling
 // DTD handling methods for various declarations.
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {
  ShadowTrace();
}
 
- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName {
  ShadowTrace();
}
 
- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue {
  ShadowTrace();
}
 
- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model {
  ShadowTrace();
}
 
- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value {
  ShadowTrace();
}
 
- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {
  ShadowTrace();
}
*/

#pragma mark Element Handling

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if (sd_node) {
    int version = [sd_node acceptXMLElement:elementName];
    if ([self parserVersion] & version) {
      if ([self parserVersion] != version) [self setVersion:version];
    } else {
      [NSException raise:@"SdefParserException" format:@"Invalid element %@ in %@ for %@ version", elementName,
        [sd_node xmlElementName], 
        ([self parserVersion] == kSdefParserTigerVersion) ? @"Tiger" : ([self parserVersion] == kSdefParserPantherVersion) ? @"Panther" : @"Both"];
      [parser abortParsing];
    }
  }
  
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[elementName methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");
  
  if (isEqual(elementName, cmd, @"dictionary")) {
    [self parser:parser didStartDictionary:attributeDict];
  } else if (isEqual(elementName, cmd, @"suite")) {
    [self parser:parser didStartSuite:attributeDict];
  } else if (isEqual(elementName, cmd, @"cocoa")) {
    [self parser:parser didStartCocoa:attributeDict];
  } else if (isEqual(elementName, cmd, @"documentation")) {
    [self parser:parser didStartDocumentation:attributeDict];
  } else if (isEqual(elementName, cmd, @"synonym")) {
    [self parser:parser didStartSynonym:attributeDict];
  }
  /* Types */
  else if (isEqual(elementName, cmd, @"enumeration")) {
    [self parser:parser didStartEnumeration:attributeDict];
  } else if (isEqual(elementName, cmd, @"enumerator")) {
    [self parser:parser didStartEnumerator:attributeDict];
  }
  /* Class */
  else if (isEqual(elementName, cmd, @"class")) {
    [self parser:parser didStartClass:attributeDict];
  } else if (isEqual(elementName, cmd, @"contents")) {
    [self parser:parser didStartContents:attributeDict];
  } else if (isEqual(elementName, cmd, @"element")) {
    [self parser:parser didStartElement:attributeDict];
  } else if (isEqual(elementName, cmd, @"accessor")) {
    [self parser:parser didStartAccessor:attributeDict];
  } else if (isEqual(elementName, cmd, @"property")) {
    [self parser:parser didStartProperty:attributeDict];
  } else if (isEqual(elementName, cmd, @"responds-to")) {
    [self parser:parser didStartRespondsTo:attributeDict];
  } 
  /* Verb */
  else if (isEqual(elementName, cmd, @"command")) {
    [self parser:parser didStartCommand:attributeDict];
  } else if (isEqual(elementName, cmd, @"event")) {
    [self parser:parser didStartEvent:attributeDict];
  } else if (isEqual(elementName, cmd, @"direct-parameter")) {
    [self parser:parser didStartDirectParameter:attributeDict];
  } else if (isEqual(elementName, cmd, @"parameter")) {
    [self parser:parser didStartParameter:attributeDict];
  } else if (isEqual(elementName, cmd, @"result")) {
    [self parser:parser didStartResult:attributeDict];
  } else {
    [self parser:parser didStartElement:elementName withAttributes:attributeDict];
  }
}


// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  [self parser:parser didEndElement:elementName];
}

/*
#pragma mark Mapping Handling
 // sent when the parser first sees a namespace attribute.
 // In the case of the cvslog tag, before the didStartElement:, you'd get one of these with prefix == @"" and namespaceURI == @"http://xml.apple.com/cvslog" (i.e. the default namespace)
 // In the case of the radar:radar tag, before the didStartElement: you'd get one of these with prefix == @"radar" and namespaceURI == @"http://xml.apple.com/radar"
 - (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
   ShadowTrace();
 }
 
 // sent when the namespace prefix in question goes out of scope.
 - (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {
   ShadowTrace();
 }
 */
/*
#pragma mark Other Objects Handling
 // This returns the string of the characters encountered thus far. You may not necessarily get the longest character run.
 // The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
 - (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
   ShadowTrace();
 }
 
 // The parser reports ignorable whitespace in the same way as characters it's found.
 - (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
   ShadowTrace();
 }
 
 // The parser reports a processing instruction to you using this method.
 // In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"
 - (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data {
   ShadowTrace();
 }
 */

/*
// A comment (Text in a <!-- --> block) is reported to the delegate as a single string
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
    ShadowTrace();
}

 // this reports a CDATA block to the delegate as an NSData.
 - (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
   ShadowTrace();
 }
 
 // this gives the delegate an opportunity to resolve an external entity itself and reply with the resulting data.
 - (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID {
   ShadowTrace();
 }
 */
// ...and this reports a fatal error to the delegate. The parser will stop parsing.
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
  DLog(@"Error: %@, %@", parseError, [parseError userInfo]);
}

// If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
  DLog(@"Error: %@, %@", validationError, [validationError userInfo]);
}

@end

NSString *SdefXMLAccessStringFromFlag(unsigned flag) {
  id str = nil;
  if (flag == (kSdefAccessRead | kSdefAccessWrite)) str = @"rw";
  else if (flag == kSdefAccessRead) str = @"r";
  else if (flag == kSdefAccessWrite) str = @"w";
  return str;
}

unsigned SdefXMLAccessFlagFromString(NSString *str) {
  unsigned flag = 0;
  if (str && [str rangeOfString:@"r"].location != NSNotFound) {
    flag |= kSdefAccessRead;
  }
  if (str && [str rangeOfString:@"w"].location != NSNotFound) {
    flag |= kSdefAccessWrite;
  }
  return flag;
}
