//
//  SdefSuite.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefSuite.h"

#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefEnumeration.h"
#import "SdefDocumentation.h"

@implementation SdefSuite

+ (SDObjectType)objectType {
  return kSDSuiteType;
}

+ (NSString *)defaultName {
  return @"Suite";
}

+ (NSString *)defaultIconName {
  return @"Suite";
}

- (void)createContent {
  [self setDocumentation:[SdefDocumentation node]];
  
  id child = [SdefCollection nodeWithName:@"Types"];
  [child setContentType:[SdefEnumeration class]];
  [child setElementName:@"types"];
  [self appendChild:child];
  
  child = [SdefCollection nodeWithName:@"Classes"];
  [child setContentType:[SdefClass class]];
  [child setElementName:@"classes"];
  [self appendChild:child];
  
  child = [SdefCollection nodeWithName:@"Commands"];
  [child setContentType:[SdefCommand class]];
  [child setElementName:@"commands"];
  [self appendChild:child];
  
  child = [SdefCollection nodeWithName:@"Events"];
  [child setContentType:[SdefEvent class]];
  [child setElementName:@"events"];
  [self appendChild:child];
}

- (SdefCollection *)types {
  return [self childAtIndex:0];
}

- (SdefCollection *)classes {
  return [self childAtIndex:1];
}

- (SdefCollection *)commands {
  return [self childAtIndex:2];
}

- (SdefCollection *)events {
  return [self childAtIndex:3];
}

#pragma mark -
#pragma mark XML Generation

- (NSString *)xmlElementName {
  return @"suite";
}

#pragma mark -
#pragma mark Parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"types"]) {
    [parser setDelegate:[self types]];
  } else if ([elementName isEqualToString:@"classes"]) {
    [parser setDelegate:[self classes]];
  } else if ([elementName isEqualToString:@"commands"]) {
    [parser setDelegate:[self commands]];
  } else if ([elementName isEqualToString:@"events"]) {
    [parser setDelegate:[self events]];
  } else {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
  }
  if (sd_childComments && [[parser delegate] objectType] == kSDCollectionType) {
    [[parser delegate] setComments:sd_childComments];
    [sd_childComments release];
    sd_childComments = nil;
  }
}

@end
