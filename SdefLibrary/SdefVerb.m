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
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefVerb *copy = [super copyWithZone:aZone];
  copy->sd_result = [sd_result copyWithZone:aZone];
  [copy->sd_result setOwner:copy];
  copy->sd_direct = [sd_direct copyWithZone:aZone];
  [copy->sd_direct setOwner:copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_result forKey:@"SVResult"];
  [aCoder encodeObject:sd_direct forKey:@"SVDirectParameter"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_result = [[aCoder decodeObjectForKey:@"SVResult"] retain];
    sd_direct = [[aCoder decodeObjectForKey:@"SVDirectParameter"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefVerbType;
}

+ (NSString *)defaultIconName {
  return @"Function";
}

#pragma mark -
+ (NSString *)defaultName {
  return @"method";
}

- (void)dealloc {
  [sd_result setOwner:nil];
  [sd_result release];
  [sd_direct setOwner:nil];
  [sd_direct release];
  [super dealloc];
}

- (void)createContent {
  [super createContent];
  sd_flags.hasSynonyms = 1;
  [self setResult:[SdefResult node]];
  sd_flags.hasDocumentation = 1;
//  [self setDocumentation:[SdefDocumentation node]];
  [self setDirectParameter:[SdefDirectParameter node]];
}

- (SdefResult *)result {
  return sd_result;
}
- (void)setResult:(SdefResult *)aResult {
  if (sd_result != aResult) {
    [sd_result setOwner:nil];
    [sd_result release];
    sd_result = [aResult retain];
    [sd_result setOwner:self];
  }
}

- (SdefDirectParameter *)directParameter {
  return sd_direct;
}
- (void)setDirectParameter:(SdefDirectParameter *)aParameter {
  if (sd_direct != aParameter) {
    [sd_direct setOwner:nil];
    [sd_direct release];
    sd_direct = [aParameter retain];
    [sd_direct setOwner:self];
  }
}

#pragma mark -
#pragma mark XML Generation
- (SdefXMLNode *)xmlNode {
  id node;
  if (node = [super xmlNode]) {
    id childNode;
    unsigned idx = [node childCount] - [self childCount];
    childNode = [[self result] xmlNode];
    if (nil != childNode) {
      [node insertChild:childNode atIndex:idx];
    }
    childNode = [[self directParameter] xmlNode];
    if (nil != childNode) {
      [node insertChild:childNode atIndex:idx];
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  if ([[[self parent] xmlElementName] isEqualToString:@"commands"]) {
    return @"command";
  } else if ([[[self parent] xmlElementName] isEqualToString:@"events"])
    return @"event"; 
  return nil;
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
