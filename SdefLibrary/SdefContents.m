//
//  SdefContents.m
//  SDef Editor
//
//  Created by Grayfox on 04/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefContents.h"
#import "SdefClass.h"
#import "SdefXMLNode.h"
#import "SdefDocument.h"

@implementation SdefContents
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefContents *copy = [super copyWithZone:aZone];
  copy->sd_owner = nil;
  copy->sd_access = sd_access;
  copy->sd_type = [sd_type copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_type forKey:@"SCType"];
  [aCoder encodeInt:sd_access forKey:@"SCAccess"];
  [aCoder encodeConditionalObject:sd_owner forKey:@"SCOwner"];
  
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_access = [aCoder decodeIntForKey:@"SCAccess"];
    sd_type = [[aCoder decodeObjectForKey:@"SCType"] retain];
    sd_owner = [aCoder decodeObjectForKey:@"SCOwner"];
  }
  return self;
}

#pragma mark -
+ (SDObjectType)objectType {
  return kSDContentsType;
}

+ (NSString *)defaultIconName {
  return @"Content";
}

- (id)initEmpty {
  if (self = [super initEmpty]) {
    [self setRemovable:NO];
  }
  return self;
}

- (void)dealloc {
  [sd_type release];
  [super dealloc];
}

#pragma mark -
- (NSString *)type {
  return sd_type;
}

- (void)setType:(NSString *)aType {
  if (sd_type != aType) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_type];
    [sd_type release];
    sd_type = [aType copy];
  }
}

- (unsigned)access {
  return sd_access;
}
- (void)setAccess:(unsigned)newAccess {
  [[[[self document] undoManager] prepareWithInvocationTarget:self] setAccess:sd_access];
  sd_access = newAccess;
}

- (id)owner {
  return sd_owner;
}

- (void)setOwner:(SdefObject *)anObject {
  sd_owner = anObject;
}

- (SdefDocument *)document {
  return [sd_owner document];
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node = nil;
  if (sd_type && (node = [super xmlNode])) {
    id attr = [self type];
    if (nil != attr) [node setAttribute:attr forKey:@"type"];
    if (![self name]) [node setAttribute:@"contents" forKey:@"name"];
    
    if ([self access] == (kSdefAccessRead | kSdefAccessWrite)) attr = @"rw";
    else if ([self access] == kSdefAccessRead) attr = @"r";
    else if ([self access] == kSdefAccessWrite) attr = @"w";
    else attr = nil;
    attr = SDAccessStringFromFlag([self access]);
    if (nil != attr) [node setAttribute:attr forKey:@"access"];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"contents";
}

#pragma mark -
#pragma mark Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  
  [self setType:[attrs objectForKey:@"type"]];
  [self setAccess:SDAccessFlagFromString([attrs objectForKey:@"access"])];
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
  if ([elementName isEqualToString:@"contents"]) {
    [self remove];
  }
}

@end
