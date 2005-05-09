//
//  SdefXMLObject.m
//  Sdef Editor
//
//  Created by Grayfox on 01/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefXMLBase.h"
#import "SdefXMLNode.h"
#import "SKExtensions.h"

#import "SdefComment.h"


@implementation SdefObject (SdefXMLManager)

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  id child = nil;
  id children = nil;
  node = [SdefXMLNode nodeWithElementName:[self xmlElementName]];
  NSAssert1(!node || ([node elementName] != nil), @"%@ return an invalid node", self);
  if (node && [node elementName]) {
    if (sd_comments)
      [node setComments:[self comments]];

    children = [self childEnumerator];
    while (child = [children nextObject]) {
      id childNode = [child xmlNodeForVersion:version];
      if (childNode) {
        NSAssert1([childNode elementName] != nil, @"%@ return an invalid node", child);
        [node appendBranch:childNode];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return nil;
}

#pragma mark -
#pragma mark XML Parsing
- (id)initWithAttributes:(NSDictionary *)attributes {
  if (self = [self initWithName:nil]) {
    [self setAttributes:attributes];
    if (![self name]) { [self setName:[[self class] defaultName]]; }
  }
  return self;
}

- (void)setAttributes:(NSDictionary *)attrs {
  [self setName:[attrs objectForKey:@"name"]];
}

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserUnknownVersion;
}

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//  if ([elementName isEqualToString:@"documentation"]) {
//    SdefDocumentation *documentation = [(SdefObject *)[SdefDocumentation allocWithZone:[self zone]] initWithAttributes:attributeDict];
//    [self setDocumentation:documentation];
//    [self appendChild:documentation]; /* Append to parse, and remove after */
//    [parser setDelegate:documentation];
//    [documentation setComments:sd_childComments];
//    [documentation release];
//  } else if ([elementName isEqualToString:@"synonyms"]) {
//    SdefCollection *synonyms = [self synonyms];
//    if (synonyms) {
//      [self appendChild:synonyms]; /* Append to parse, and remove after */
//      [parser setDelegate:synonyms];
//      [synonyms setComments:sd_childComments];
//    }
//  } else if ([elementName isEqualToString:@"cocoa"]) {
//    SdefImplementation *cocoa = [self impl];
//    if (cocoa) {
//      [cocoa setAttributes:attributeDict];
//      [cocoa setComments:sd_childComments];
//    }
//  }
//  [sd_childComments release];
//  sd_childComments = nil;
//}

// sent when an end tag is encountered. The various parameters are supplied as above.
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//  if (![elementName isEqualToString:@"cocoa"]) { /* cocoa isn't handle as a child node, but as an ivar */
//    [parser setDelegate:[self parent]];
//  }
//}

// A comment (Text in a <!-- --> block) is reported to the delegate as a single string
//- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
//  if (nil == sd_childComments) {
//    sd_childComments = [[NSMutableArray allocWithZone:[self zone]] init];
//  }
//  [sd_childComments addObject:[SdefComment commentWithString:[comment stringByUnescapingEntities:nil]]];
//}

// ...and this reports a fatal error to the delegate. The parser will stop parsing.
//- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
//  id container = @"class";
//  id parent = [self firstParentOfType:kSdefClassType];
//  if (!parent) {
//    parent = [self suite];
//    container = @"suite";
//  }
//  NSAlert *alert = [NSAlert alertWithMessageText:@"The document could not be opened because it's not a valid sdef file."
//                                   defaultButton:@"OK"
//                                 alternateButton:nil
//                                     otherButton:nil
//                       informativeTextWithFormat:@"XMLParser encounter an error in element \"%@\" of %@ \"%@\".",
//    [self xmlElementName], container, [parent name]];
//  [parser setDelegate:nil];
//  [parser abortParsing];
//  [alert runModal];
//}

@end

#pragma mark -
@implementation SdefCollection (SdefXMLManager)

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  if (![self hasChildren])
    return nil;
  
  if (kSdefPantherVersion == version) {
    return [super xmlNodeForVersion:version];
  } else if (kSdefTigerVersion == version) {
    SdefXMLNode *children = nil;
    SdefObject *child;
    NSEnumerator *enume = [self childEnumerator];
    while (child = [enume nextObject]) {
      SdefXMLNode *node = [child xmlNodeForVersion:version];
      if (node) {
        if (!children) {
          children = node;
        } else {
          [children insertSibling:node];
        }
      }
    }
    return children;
  }
  return nil;
}

- (NSString *)xmlElementName {
  return [self elementName];
}

#pragma mark -
#pragma mark XML Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  /* Do nothing */
}

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserPantherVersion;
}

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//  /* If valid document, can only be collection content element */
//  SdefObject *element = [(SdefObject *)[[self contentType] allocWithZone:[self zone]] initWithAttributes:attributeDict];
//  [self appendChild:element];
//  [parser setDelegate:element];
//  [element release];
//  if (sd_childComments) {
//    [element setComments:sd_childComments];
//    [sd_childComments release];
//    sd_childComments = nil;
//  }
//}
//
//// sent when an end tag is encountered. The various parameters are supplied as above.
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//  [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
//  if ([elementName isEqualToString:@"synonyms"]) {
//    [self remove];
//  }
//}

@end
