//
//  SdefXMLObject.m
//  Sdef Editor
//
//  Created by Grayfox on 01/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefXMLObject.h"
#import "SdefXMLNode.h"
#import "SKExtensions.h"

#import "SdefComment.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

NSMutableArray *sd_childComments;

@implementation SdefObject (SdefXMLManager)

- (id)initWithAttributes:(NSDictionary *)attributes {
  if (self = [self initEmpty]) {
    [self createContent];
    [self setAttributes:attributes];
    if (![self name]) { [self setName:[[self class] defaultName]]; }
  }
  return self;
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node = nil;
  id child = nil;
  id children = nil;
  node = [SdefXMLNode nodeWithElementName:[self xmlElementName]];
  if (node && [node elementName]) {
    NSAssert1([node elementName] != nil, @"%@ return an invalid node", self);
    if (sd_comments)
      [node setComments:[self comments]];
    if ([self hasDocumentation]) {
      id documentation = [sd_documentation xmlNode];
      if (nil != documentation) {
        [node prependChild:documentation];
      }
    }
    if ([self hasSynonyms]) {
      id synonyms = [sd_synonyms xmlNode];
      if (nil != synonyms) {
        [node appendChild:synonyms];
      }
    }
    children = [self childEnumerator];
    while (child = [children nextObject]) {
      id childNode = [child xmlNode];
      if (childNode) {
        NSAssert1([childNode elementName] != nil, @"%@ return an invalid node", child);
        [node appendChild:childNode];
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
- (void)setAttributes:(NSDictionary *)attrs {
  [self setName:[attrs objectForKey:@"name"]];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"documentation"]) {
    SdefDocumentation *documentation = [(SdefObject *)[SdefDocumentation alloc] initWithAttributes:attributeDict];
    [self setDocumentation:documentation];
    [self appendChild:documentation]; /* Append to parse, and remove after */
    [parser setDelegate:documentation];
    [documentation setComments:sd_childComments];
    [documentation release];
  } else if ([elementName isEqualToString:@"synonyms"]) {
    SdefCollection *synonyms = [self synonyms];
    if (synonyms) {
      [self appendChild:synonyms]; /* Append to parse, and remove after */
      [parser setDelegate:synonyms];
      [synonyms setComments:sd_childComments];
    }
  } else if ([elementName isEqualToString:@"cocoa"]) {
    SdefImplementation *cocoa = [self impl];
    if (cocoa) {
      [cocoa setAttributes:attributeDict];
      [cocoa setComments:sd_childComments];
    }
  }
  [sd_childComments release];
  sd_childComments = nil;
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if (![elementName isEqualToString:@"cocoa"]) { /* cocoa isn't handle as a child node, but as an ivar */
    [parser setDelegate:[self parent]];
  }
}

// A comment (Text in a <!-- --> block) is reported to the delegate as a single string
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
  if (nil == sd_childComments) {
    sd_childComments = [[NSMutableArray alloc] init];
  }
  [sd_childComments addObject:[SdefComment commentWithString:[comment stringByUnescapingEntities:nil]]];
}

// ...and this reports a fatal error to the delegate. The parser will stop parsing.
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
  id container = @"class";
  id parent = [self firstParentOfType:kSdefClassType];
  if (!parent) {
    parent = [self suite];
    container = @"suite";
  }
  NSAlert *alert = [NSAlert alertWithMessageText:@"The document could not be opened because it's not a valid sdef file."
                                   defaultButton:@"OK"
                                 alternateButton:nil
                                     otherButton:nil
                       informativeTextWithFormat:@"XMLParser encounter an error in element \"%@\" of %@ \"%@\".",
    [self xmlElementName], container, [parent name]];
  [parser setDelegate:nil];
  [parser abortParsing];
  [alert runModal];
}

@end

#pragma mark -
@implementation SdefCollection (SdefXMLManager)

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  return [self childCount] ? [super xmlNode] : nil;
}

- (NSString *)xmlElementName {
  return [self elementName];
}

#pragma mark -
#pragma mark XML Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  /* Do nothing */
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  /* If valid document, can only be collection content element */
  SdefObject *element = [(SdefObject *)[[self contentType] alloc] initWithAttributes:attributeDict];
  [self appendChild:element];
  [parser setDelegate:element];
  [element release];
  if (sd_childComments) {
    [element setComments:sd_childComments];
    [sd_childComments release];
    sd_childComments = nil;
  }
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
  if ([elementName isEqualToString:@"synonyms"]) {
    [self remove];
  }
}

@end

#pragma mark -
@implementation SdefTerminologyElement (SdefXMLManager)

#pragma mark -
#pragma mark XML Generation
- (SdefXMLNode *)xmlNode {
  id node = [super xmlNode];
  id attr = [self name];
  if (nil != attr)
    [node setAttribute:attr forKey:@"name"];
  attr = [self codeStr];
  if (nil != attr)
    [node setAttribute:attr forKey:@"code"];
  if ([self isHidden])
    [node setAttribute:@"hidden" forKey:@"hidden"];
  attr = [self desc];
  if (nil != attr)
    [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"description"];
  id impl = (sd_impl) ? [[self impl] xmlNode] : nil;
  if (nil != impl) {
    if ([[[node firstChild] elementName] isEqualToString:@"documentation"]) {
      [node insertChild:impl atIndex:1];
    } else {
      [node prependChild:impl];
    }
  }
  [node setEmpty:![node hasChildren]];
  return node;
}

#pragma mark -
#pragma mark XML Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setCodeStr:[attrs objectForKey:@"code"]];
  [self setDesc:[[attrs objectForKey:@"description"] stringByUnescapingEntities:nil]];
  [self setHidden:[attrs objectForKey:@"hidden"] != nil];
}

@end

