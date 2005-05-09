//
//  SdefXMLVerb.m
//  Sdef Editor
//
//  Created by Grayfox on 01/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefVerb.h"
#import "SdefSuite.h"
#import "SdefXMLNode.h"
#import "SdefXMLBase.h"
#import "SKExtensions.h"
#import "SdefArguments.h"

@implementation SdefVerb (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node;
  if (node = [super xmlNodeForVersion:version]) {
    id childNode;
    unsigned idx = [node childCount] - [self childCount];
    childNode = [[self result] xmlNodeForVersion:version];
    if (nil != childNode) {
      [node insertChild:childNode atIndex:idx];
    }
    childNode = [[self directParameter] xmlNodeForVersion:version];
    if (nil != childNode) {
      [node insertChild:childNode atIndex:idx];
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  SdefSuite *suite = [self suite];
  if ([self parent] == [suite commands]) {
    return @"command";
  } else if ([self parent] == [suite events])
    return @"event"; 
  return nil;
}

#pragma mark -
#pragma mark Parsing
- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//  if ([elementName isEqualToString:@"parameter"]) {
//    SdefParameter *param = [(SdefObject *)[SdefParameter allocWithZone:[self zone]] initWithAttributes:attributeDict];
//    [self appendChild:param];
//    [parser setDelegate:param];
//    [param release];
//  } else if ([elementName isEqualToString:@"direct-parameter"]) {
//    SdefDirectParameter *param = [self directParameter];
//    [param setAttributes:attributeDict];
//    if (sd_childComments) {
//      [param setComments:sd_childComments];
//      [sd_childComments release];
//      sd_childComments = nil;
//    }
//  } else if ([elementName isEqualToString:@"result"]) {
//    SdefResult *result = [self result];
//    [result setAttributes:attributeDict];
//    if (sd_childComments) {
//      [result setComments:sd_childComments];
//      [sd_childComments release];
//      sd_childComments = nil;
//    }
//  } else {
//    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
//  }
//  if (sd_childComments && [[parser delegate] parent] == self) {
//    [[parser delegate] setComments:sd_childComments];
//    [sd_childComments release];
//    sd_childComments = nil;
//  }
//}
//
//// sent when an end tag is encountered. The various parameters are supplied as above.
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//  if (![elementName isEqualToString:@"direct-parameter"] && ![elementName isEqualToString:@"result"]) {
//    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
//  }
//}

@end

@implementation SdefDirectParameter (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if ([self hasType] && (node = [super xmlNodeForVersion:version])) {
    if ([self isOptional]) {
      if (kSdefTigerVersion == version) {
        [node setAttribute:@"yes" forKey:@"optional"];
      } else {
        [node setAttribute:@"optional" forKey:@"optional"];
      }
    }
    [node setEmpty:YES];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"direct-parameter";
}

#pragma mark -
#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  NSString *optional = [attrs objectForKey:@"optional"];
  if (optional && ![optional isEqualToString:@"no"]) {
    [self setOptional:YES];
  }
}

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

@end

@implementation SdefParameter (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node;
  if (node = [super xmlNodeForVersion:version]) {
    if ([self isOptional]) {
      if (kSdefTigerVersion == version) {
        [node setAttribute:@"yes" forKey:@"optional"];
      } else {
        [node setAttribute:@"optional" forKey:@"optional"];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"parameter";
}

#pragma mark -
#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setType:[attrs objectForKey:@"type"]];
  NSString *optional = [attrs objectForKey:@"optional"];
  if (optional && ![optional isEqualToString:@"no"]) {
    [self setOptional:YES];
  }
}

@end

@implementation SdefResult (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if ([self hasType] && (node = [super xmlNodeForVersion:version])) {
    [node setEmpty:YES];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"result";
}

#pragma mark -
#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
}

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

@end


