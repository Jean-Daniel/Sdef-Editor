//
//  SdefDocumentation.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDocumentation.h"
#import "SKExtensions.h"

#import "SdefDocument.h"

@implementation SdefDocumentation
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefDocumentation *copy = [super copyWithZone:aZone];
  copy->sd_content = [sd_content copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_content forKey:@"SDContent"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_content = [[aCoder decodeObjectForKey:@"SDContent"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefDocumentationType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"Documentation", @"SdefLibrary", @"Documentation default name");
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
  [sd_content release];
  [super dealloc];
}

- (NSString *)content {
  return sd_content;
}

- (void)setContent:(NSString *)newContent {
  if (sd_content != newContent) {
    //[[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_content];
    [sd_content release];
    sd_content = [newContent retain];
  }
}


#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node = nil;
  if (sd_content != nil) {
    if (node = [super xmlNode]) {
      [node setContent:sd_content];
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
  if (!sd_content) {
    sd_content = [[NSMutableString alloc] init];
  }
  [sd_content appendString:[string stringByUnescapingEntities:nil]];
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
  if ([elementName isEqualToString:[self xmlElementName]]) {
    [self remove];
  }
}

@end
