//
//  SdefDictionary.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDictionary.h"
#import "ShadowMacros.h"

#import "SdefSuite.h"
#import "SdefXMLNode.h"
#import "SdefDocumentation.h"

@implementation SdefDictionary
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
//  id document = sd_document;
//  sd_document = nil; /* If document != nil => register some undo */
  SdefDictionary *copy = [super copyWithZone:aZone];
//  sd_document = document;
  copy->sd_document = nil;
//  [copy setDocument:sd_document];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeConditionalObject:sd_document forKey:@"SDDocument"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_document = [aCoder decodeObjectForKey:@"SDDocument"];
  }
  return self;
}

#pragma mark -
+ (void)initialize {
  static BOOL tooLate = NO;
  if (!tooLate) {
    [self setKeys:[NSArray arrayWithObject:@"name"] triggerChangeNotificationsForDependentKey:@"title"];
    tooLate = YES;
  }
}

+ (SDObjectType)objectType {
  return kSDDictionaryType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"Dictionary", @"SdefLibrary", @"Dictionary default name");
}


+ (NSString *)defaultIconName {
  return @"Dictionary";
}

- (void)dealloc {
//  ShadowTrace();
  [super dealloc];
}

- (void)createContent {
  [self setDocumentation:[SdefDocumentation node]];
}

- (NSString *)title {
  return [self name];
}

- (void)setTitle:(NSString *)newTitle {
  [self setName:newTitle];
}

- (SdefDocument *)document {
  return sd_document;
}

- (void)setDocument:(SdefDocument *)document {
  sd_document = document;
}

- (NSArray *)suites {
  return [self children];
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node;
  if (node = [super xmlNode]) {
    if ([self name]) [node setAttribute:[self name] forKey:@"title"];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"dictionary";
}

#pragma mark -
#pragma mark Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setName:[attrs objectForKey:@"title"]];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"suite"]) {
    SdefSuite *suite = [(SdefObject *)[SdefSuite alloc] initWithAttributes:attributeDict];
    [self appendChild:suite];
    [parser setDelegate:suite];
    [suite release];
    if (sd_childComments) {
      [suite setComments:sd_childComments];
      [sd_childComments release];
      sd_childComments = nil;
    }
  } else {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
  }
}

@end
