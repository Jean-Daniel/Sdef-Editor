//
//  SdefDocumentation.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDocumentation.h"
#import "SdefXMLGenerator.h"

@implementation SdefDocumentation

+ (SDObjectType)objectType {
  return kSDDocumentationType;
}

+ (NSString *)defaultName {
  return @"Documentation";
}

+ (NSString *)defaultIconName {
  return @"Bookmarks";
}

- (id)initEmpty {
  if (self = [super initEmpty]) {
    [self setRemovable:NO];
  }
  return self;
}

- (id)initWithAttributes:(NSDictionary *)attrs {
  if (self = [super init]) {
  }
  return self;
}

- (void)dealloc {
  [content release];
  [super dealloc];
}

- (NSString *)content {
  return content;
}

- (void)setContent:(NSString *)newContent {
  if (content != newContent) {
    [content release];
    content = [newContent copy];
  }
}


#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node = nil;
  if (content != nil) {
    if (node = [super xmlNode]) {
      [node setContent:content];
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"documentation";
}

#pragma mark -
#pragma mark Parsing

// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run.
// The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if (!content) {
    content = [[NSMutableString alloc] init];
  }
  [content appendString:[string stringByUnescapingEntities:nil]];
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
  if ([elementName isEqualToString:[self xmlElementName]]) {
    [self remove];
  }
}

@end
