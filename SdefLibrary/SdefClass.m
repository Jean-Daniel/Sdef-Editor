//
//  SdefClass.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefClass.h"
#import "SdefContents.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"
#import "SdefXMLNode.h"
#import "SdefDocument.h"

NSString *SDAccessStringFromFlag(unsigned flag) {
  id str = nil;
  if (flag == (kSDElementRead | kSDElementWrite)) str = @"rw";
  else if (flag == kSDElementRead) str = @"r";
  else if (flag == kSDElementWrite) str = @"w";
  return str;
}

unsigned SDAccessFlagFromString(NSString *str) {
  unsigned flag = 0;
  if (str && [str rangeOfString:@"r"].location != NSNotFound) {
    flag |= kSDElementRead;
  }
  if (str && [str rangeOfString:@"w"].location != NSNotFound) {
    flag |= kSDElementWrite;
  }
  return flag;
}

@implementation SdefClass

+ (SDObjectType)objectType {
  return kSDClassType;
}

+ (NSString *)defaultName {
  return @"class name";
}

+ (NSString *)defaultIconName {
  return @"Class";
}

- (void)dealloc {
  [sd_plural release];
  [sd_inherits release];
  [sd_contents release];
  [super dealloc];
}

- (void)createContent {
  [self createSynonyms];
  [self setDocumentation:[SdefDocumentation node]];
  [self setContents:[SdefContents node]];
  
  id child = [SdefCollection nodeWithName:@"Elements"];
  [child setContentType:[SdefElement class]];
  [child setElementName:@"elements"];
  [self appendChild:child];
  
  child = [SdefCollection nodeWithName:@"Properties"];
  [child setContentType:[SdefProperty class]];
  [child setElementName:@"properties"];
  [self appendChild:child];
  
  child = [SdefCollection nodeWithName:@"Responds to Commands"];
  [child setContentType:[SdefRespondsTo class]];
  [child setElementName:@"responds-to-commands"];
  [self appendChild:child];
  
  child = [SdefCollection nodeWithName:@"Responds to Events"];
  [child setContentType:[SdefRespondsTo class]];
  [child setElementName:@"responds-to-events"];
  [self appendChild:child];
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  if (recu) {
    [sd_contents setEditable:flag];
  }
  [super setEditable:flag recursive:recu];
}

#pragma mark -
- (SdefContents *)contents {
  return sd_contents;
}

- (void)setContents:(SdefContents *)contents {
  if (sd_contents != contents) {
    [sd_contents release];
    sd_contents = [contents retain];
  }
}

- (NSString *)plural {
  return sd_plural;
}

- (void)setPlural:(NSString *)newPlural {
  if (sd_plural != newPlural) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_plural];
    [sd_plural release];
    sd_plural = [newPlural copy];
  }
}

- (NSString *)inherits {
  return sd_inherits;
}

- (void)setInherits:(NSString *)newInherits {
  if (sd_inherits != newInherits) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_inherits];
    [sd_inherits release];
    sd_inherits = [newInherits copy];
  }
}

- (SdefCollection *)elements {
  return [self childAtIndex:0];
}

- (SdefCollection *)properties {
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

- (SdefXMLNode *)xmlNode {
  id node;
  if (node = [super xmlNode]) {
    if ([self plural]) [node setAttribute:[self plural] forKey:@"plural"];
    if ([self inherits]) [node setAttribute:[self inherits] forKey:@"inherits"];
    id contents = [[self contents] xmlNode];
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

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"properties"]) {
    [parser setDelegate:[self properties]];
  } else if ([elementName isEqualToString:@"elements"]) {
    [parser setDelegate:[self elements]];
  } else if ([elementName isEqualToString:@"responds-to-commands"]) {
    [parser setDelegate:[self commands]];
  } else if ([elementName isEqualToString:@"responds-to-events"]) {
    [parser setDelegate:[self events]];
  } else if ([elementName isEqualToString:@"contents"]) {
    id contents = [(SdefObject *)[SdefContents alloc] initWithAttributes:attributeDict];
    [self setContents:contents];
    [self appendChild:contents]; /* will be removed when finish parsing */
    [parser setDelegate:contents];
    [contents release];
  } else {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
  }
  if (sd_childComments && [[parser delegate] parent] == self) {
    [[parser delegate] setComments:sd_childComments];
    [sd_childComments release];
    sd_childComments = nil;
  }
}

@end

#pragma mark -
@implementation SdefElement

+ (SDObjectType)objectType {
  return kSDElementType;
}

+ (NSString *)defaultName {
  return @"element";
}

+ (NSString *)defaultIconName {
  return @"Variable";
}

- (void)dealloc {
  [sd_impl release];
  [desc release];
  [super dealloc];
}

- (SdefImplementation *)impl {
  return sd_impl;
}
- (void)setImpl:(SdefImplementation *)newImpl {
  if (sd_impl != newImpl) {
    [sd_impl release];
    sd_impl = [newImpl retain];
  }
}

- (unsigned)access {
  return access;
}

- (void)setAccess:(unsigned)newAccess {
  if (access != newAccess) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setAccess:access];
    access = newAccess;
  }
}

- (BOOL)isHidden {
  return hidden;
}

- (void)setHidden:(BOOL)newHidden {
  if (hidden != newHidden) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setHidden:hidden];
    hidden = newHidden;
  }
}

- (NSString *)desc {
  return desc;
}

- (void)setDesc:(NSString *)newDesc {
  if (desc != newDesc) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:desc];
    [desc release];
    desc = [newDesc copy];
  }
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node;
  if (node = [super xmlNode]) {
    id attr = [self name];
    if (nil != attr) [node setAttribute:attr forKey:@"type"];
    
    if ([self access] == (kSDElementRead | kSDElementWrite)) attr = @"rw";
    else if ([self access] == kSDElementRead) attr = @"r";
    else if ([self access] == kSDElementWrite) attr = @"w";
    else attr = nil;
    attr = SDAccessStringFromFlag([self access]);
    if (nil != attr) [node setAttribute:attr forKey:@"access"];
    
    attr = [self desc];
    if (nil != attr) [node setAttribute:attr forKey:@"description"];
    
    if ([self isHidden]) [node setAttribute:@"hidden" forKey:@"hidden"];
    
    id impl = [[self impl] xmlNode];
    if (nil != impl) {
      [node prependChild:impl];
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
  [self setDesc:[attrs objectForKey:@"description"]];
  [self setHidden:[attrs objectForKey:@"hidden"] != nil];
  [self setAccess:SDAccessFlagFromString([attrs objectForKey:@"access"])];
}

#warning TODO: Parse accessor

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if (![elementName isEqualToString:@"accessor"]) {
    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
  }
}

@end

#pragma mark -
@implementation SdefProperty

+ (SDObjectType)objectType {
  return kSDPropertyType;
}

+ (NSString *)defaultName {
  return @"property";
}

+ (NSString *)defaultIconName {
  return @"Variable";
}

- (void)dealloc {
  [sd_type release];
  [super dealloc];
}

- (void)createContent {
  [self createSynonyms];
  [super createContent];
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

- (BOOL)isNotInProperties {
  return sd_notInProperties;
}
- (void)setNotInProperties:(BOOL)flag {
  [[[[self document] undoManager] prepareWithInvocationTarget:self] setNotInProperties:sd_notInProperties];
  sd_notInProperties = flag;
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node;
  if (node = [super xmlNode]) {
    id attr = [self type];
    if (nil != attr) [node setAttribute:attr forKey:@"type"];
    
    if ([self access] == (kSDElementRead | kSDElementWrite)) attr = @"rw";
    else if ([self access] == kSDElementRead) attr = @"r";
    else if ([self access] == kSDElementWrite) attr = @"w";
    else attr = nil;
    attr = SDAccessStringFromFlag([self access]);
    if (nil != attr) [node setAttribute:attr forKey:@"access"];
    
    if ([self isNotInProperties]) [node setAttribute:@"not-in-properties" forKey:@"not-in-properties"];
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
  [self setAccess:SDAccessFlagFromString([attrs objectForKey:@"access"])];
  [self setNotInProperties:[attrs objectForKey:@"not-in-properties"] != nil];
}

@end

#pragma mark -
@implementation SdefRespondsTo

+ (SDObjectType)objectType {
  return kSDRespondsToType;
}

+ (NSString *)defaultName {
  return @"method";
}
+ (NSString *)defaultIconName {
  return @"Member";
}

- (void)dealloc {
  [sd_impl release];
  [super dealloc];
}

- (SdefImplementation *)impl {
  return sd_impl;
}

- (void)setImpl:(SdefImplementation *)newImpl {
  if (sd_impl != newImpl) {
    [sd_impl release];
    sd_impl = [newImpl retain];
  }
}

- (BOOL)isHidden {
  return sd_hidden;
}

- (void)setHidden:(BOOL)newHidden {
  if (sd_hidden != newHidden) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setHidden:sd_hidden];
    sd_hidden = newHidden;
  }
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node;
  if (node = [super xmlNode]) {
    id attr = [self name];
    if (nil != attr) [node setAttribute:attr forKey:@"name"];
    if ([self isHidden]) [node setAttribute:@"hidden" forKey:@"hidden"];
    
    id impl = [[self impl] xmlNode];
    if (nil != impl) {
      [node prependChild:impl];
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"responds-to";
}

#pragma mark -
#pragma mark Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setHidden:[attrs objectForKey:@"hidden"] != nil];
}

@end
