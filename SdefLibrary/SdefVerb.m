//
//  SdefVerb.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefVerb.h"
#import "SdefArguments.h"

@implementation SdefVerb

+ (SDObjectType)objectType {
  return kSDVerbType;
}

+ (NSString *)defaultIconName {
  return @"Function";
}

- (void)dealloc {
  [sd_result release];
  [sd_direct release];
  [super dealloc];
}

- (void)createContent {
  [self createSynonyms];
  [self setResult:[SdefResult node]];
  [self setDocumentation:[SdefDocumentation node]];
  [self setDirectParameter:[SdefDirectParameter node]];
}

- (SdefResult *)result {
  return sd_result;
}
- (void)setResult:(SdefResult *)aResult {
  if (sd_result != aResult) {
    [sd_result release];
    sd_result = [aResult retain];
  }
}

- (SdefDirectParameter *)directParameter {
  return sd_direct;
}
- (void)setDirectParameter:(SdefDirectParameter *)aParameter {
  if (sd_direct != aParameter) {
    [sd_direct release];
    sd_direct = [aParameter retain];
  }
}

#pragma mark -
#pragma mark XML Generation
- (SdefXMLNode *)xmlNode {
  id node;
  if (node = [super xmlNode]) {
    id childNode;
    childNode = [[self result] xmlNode];
    if (nil != childNode) {
      if ([[[node firstChild] elementName] isEqualToString:@"cocoa"]) {
        [[node firstChild] insertSibling:childNode];
      } else {
        [node prependChild:childNode];
      }
    }
    childNode = [[self directParameter] xmlNode];
    if (nil != childNode) {
      if ([[[node firstChild] elementName] isEqualToString:@"cocoa"]) {
        [[node firstChild] insertSibling:childNode];
      } else {
        [node prependChild:childNode];
      }
    }
  }
  return node;
}

#pragma mark -
#pragma mark Parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"parameter"]) {
    SdefParameter *param = [(SdefObject *)[SdefParameter alloc] initWithAttributes:attributeDict];
    [self appendChild:param];
    [parser setDelegate:param];
    [param release];
  } else if ([elementName isEqualToString:@"direct-parameter"]) {
    SdefDirectParameter *param = [self directParameter];
    [param setAttributes:attributeDict];
    if (sd_childComments) {
      [param setComments:sd_childComments];
      [sd_childComments release];
      sd_childComments = nil;
    }
  } else if ([elementName isEqualToString:@"result"]) {
    SdefResult *result = [self result];
    [result setAttributes:attributeDict];
    if (sd_childComments) {
      [result setComments:sd_childComments];
      [sd_childComments release];
      sd_childComments = nil;
    }
  } else {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
  }
  if (sd_childComments && [[parser delegate] parent] == self) {
    [[parser delegate] setComments:sd_childComments];
    [sd_childComments release];
    sd_childComments = nil;
  }
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if (![elementName isEqualToString:@"direct-parameter"] && ![elementName isEqualToString:@"result"]) {
    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
  }
}
@end

#pragma mark -
@implementation SdefCommand

+ (NSString *)defaultName {
  return @"command";
}

#pragma mark -
#pragma mark XML Generation

- (NSString *)xmlElementName {
  return @"command";
}

@end

#pragma mark -
@implementation SdefEvent

+ (NSString *)defaultName {
  return @"event";
}

#pragma mark -
#pragma mark XML Generation

- (NSString *)xmlElementName {
  return @"event";
}

@end