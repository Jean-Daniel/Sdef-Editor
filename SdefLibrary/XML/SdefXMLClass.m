//
//  SdefXMLClass.m
//  Sdef Editor
//
//  Created by Grayfox on 01/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ShadowBase.h"

#import "SdefXMLBase.h"
#import "SdefContents.h"
#import "SdefXMLNode.h"
#import "SdefClass.h"

static NSArray *SdefXMLAccessorStringsFromFlag(unsigned flag) {
  NSMutableArray *strings = [NSMutableArray array];
  if (flag & kSdefAccessorIndex) [strings addObject:@"index"];
  if (flag & kSdefAccessorID) [strings addObject:@"id"];
  if (flag & kSdefAccessorName) [strings addObject:@"name"];
  if (flag & kSdefAccessorRange) [strings addObject:@"range"];
  if (flag & kSdefAccessorRelative) [strings addObject:@"relative"];
  if (flag & kSdefAccessorTest) [strings addObject:@"test"];
  return strings;
}

static unsigned SdefXMLAccessorFlagFromString(NSString *str) {
  unsigned flag = 0;
  if (str && [str rangeOfString:@"index"].location != NSNotFound) {
    flag |= kSdefAccessorIndex;
  } else if (str && [str rangeOfString:@"name"].location != NSNotFound) {
    flag |= kSdefAccessorName;
  } else if (str && [str rangeOfString:@"id"].location != NSNotFound) {
    flag |= kSdefAccessorID;
  } else if (str && [str rangeOfString:@"range"].location != NSNotFound) {
    flag |= kSdefAccessorRange;
  } else if (str && [str rangeOfString:@"relative"].location != NSNotFound) {
    flag |= kSdefAccessorRelative;
  } else if (str && [str rangeOfString:@"test"].location != NSNotFound) {
    flag |= kSdefAccessorTest;
  }
  return flag;
}

#pragma mark -
@implementation SdefClass (SdefXMLManager)
#pragma mark XML Generation

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node;
  if (node = [super xmlNodeForVersion:version]) {
    if ([self plural]) [node setAttribute:[self plural] forKey:@"plural"];
    if ([self inherits]) [node setAttribute:[self inherits] forKey:@"inherits"];
    id contents = [[self contents] xmlNodeForVersion:version];
    if (nil != contents) {
      [node prependChild:contents];
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"class";
}

#pragma mark -
#pragma mark Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setPlural:[attrs objectForKey:@"plural"]];
  [self setInherits:[attrs objectForKey:@"inherits"]];
}

- (int)acceptXMLElement:(NSString *)element {
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[element methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");
  
  /* If a single type => Tiger */
  if (isEqual(element, cmd, @"element") || 
      isEqual(element, cmd, @"property") || 
      isEqual(element, cmd, @"responds-to")) {
    return kSdefParserTigerVersion;
  } else /* If a collection => Panther */
    if (isEqual(element, cmd, @"elements") || 
        isEqual(element, cmd, @"properties") || 
        isEqual(element, cmd, @"responds-to-commands") || 
        isEqual(element, cmd, @"responds-to-events")) {
      return kSdefParserPantherVersion;
    }
  return kSdefParserBothVersion;
}

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//  if ([elementName isEqualToString:@"properties"]) {
//    [parser setDelegate:[self properties]];
//  } else if ([elementName isEqualToString:@"elements"]) {
//    [parser setDelegate:[self elements]];
//  } else if ([elementName isEqualToString:@"responds-to-commands"]) {
//    [parser setDelegate:[self commands]];
//  } else if ([elementName isEqualToString:@"responds-to-events"]) {
//    [parser setDelegate:[self events]];
//  } else if ([elementName isEqualToString:@"contents"]) {
//    SdefContents *contents = [self contents];
//    [contents setAttributes:attributeDict];
//    [self appendChild:contents]; /* will be removed when finish parsing */
//    [parser setDelegate:contents];
//  } else {
//    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
//  }
//  if (sd_childComments && [[parser delegate] parent] == self) {
//    [[parser delegate] setComments:sd_childComments];
//    [sd_childComments release];
//    sd_childComments = nil;
//  }
//}

@end

#pragma mark -
@implementation SdefContents (SdefXMLManager)
#pragma mark XML Generation

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if ([self hasType] && (node = [super xmlNodeForVersion:version])) {
    if (![self name]) [node setAttribute:@"contents" forKey:@"name"];
    
    id attr = SdefXMLAccessStringFromFlag([self access]);
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
  [self setAccess:SdefXMLAccessFlagFromString([attrs objectForKey:@"access"])];
}

// sent when an end tag is encountered. The various parameters are supplied as above.
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//  [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
//  if ([elementName isEqualToString:@"contents"]) {
//    [self remove];
//  }
//}

@end

#pragma mark -
@implementation SdefElement (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node;
  if (node = [super xmlNodeForVersion:version]) {
    [node removeAttributeForKey:@"name"];
    id attr = [self name];
    if (nil != attr) [node setAttribute:attr forKey:@"type"];
    
    attr = SdefXMLAccessStringFromFlag([self access]);
    if (nil != attr) [node setAttribute:attr forKey:@"access"];
    
    /* Accessors */
    id accessors = [SdefXMLAccessorStringsFromFlag([self accessors]) objectEnumerator];
    id acc;
    while (acc = [accessors nextObject]) {
      id accNode = [SdefXMLNode nodeWithElementName:@"accessor"];
      [accNode setAttribute:acc forKey:@"style"];
      [node appendChild:accNode];
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"element";
}

#pragma mark -
#pragma mark Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  
  [self setName:[attrs objectForKey:@"type"]];
  [self setAccess:SdefXMLAccessFlagFromString([attrs objectForKey:@"access"])];
}

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//  if ([elementName isEqualToString:@"accessor"]) {
//    id str = [attributeDict objectForKey:@"style"];
//    if (str)
//      [self setAccessors:[self accessors] | SdefAccessorFlagFromString(str)];
//  } else {
//    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
//  }
//}

// sent when an end tag is encountered. The various parameters are supplied as above.
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//  if (![elementName isEqualToString:@"accessor"]) {
//    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
//  }
//}

@end

#pragma mark -
@implementation SdefProperty (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node;
  if (node = [super xmlNodeForVersion:version]) {
    id attr = SdefXMLAccessStringFromFlag([self access]);
    if (nil != attr) [node setAttribute:attr forKey:@"access"];
    
    if ([self isNotInProperties]) {
      if (kSdefTigerVersion == version) {
        [node setAttribute:@"no" forKey:@"in-properties"];
      } else {
        [node setAttribute:@"not-in-properties" forKey:@"not-in-properties"];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"property";
}

#pragma mark -
#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  
  [self setType:[attrs objectForKey:@"type"]];
  [self setAccess:SdefXMLAccessFlagFromString([attrs objectForKey:@"access"])];
  if ([[attrs objectForKey:@"in-properties"] isEqualToString:@"no"] ||
      (nil != [attrs objectForKey:@"not-in-properties"])) {
    [self setNotInProperties:YES];
  }
}

@end

#pragma mark -
@implementation SdefRespondsTo (SdefXMLManager)

#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node;
  if ([self name] && (node = [super xmlNodeForVersion:version])) {
    [node setAttribute:[self name] forKey:@"name"];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"responds-to";
}

@end
