//
//  SdefXMLParser.m
//  Sdef Editor
//
//  Created by Grayfox on 03/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ShadowBase.h"
#import "SKFunctions.h"
#import "ShadowCFContext.h"

#import "SdefXMLBase.h"
#import "SdefXMLParser.h"

#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefSuite.h"
#import "SdefSynonym.h"
#import "SdefTypedef.h"
#import "SdefContents.h"
#import "SdefArguments.h"
#import "SdefDictionary.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

#import "SdefTigerParser.h"
#import "SdefPantherParser.h"


static void *SdefParserCreateStructure(CFXMLParserRef parser, CFXMLNodeRef node, void *info);
static void SdefParserAddChild(CFXMLParserRef parser, void *parent, void *child, void *info);
static void SdefParserEndStructure(CFXMLParserRef parser, void *xmlType, void *info);
static CFDataRef SdefParserResolveEntity(CFXMLParserRef parser, CFXMLExternalID *extID, void *info);
static Boolean SdefParserHandleError(CFXMLParserRef parser, CFXMLParserStatusCode error, void *info);

static CFXMLParserCallBacks SdefParserCallBacks = {
  0,
  SdefParserCreateStructure,
  SdefParserAddChild,
  SdefParserEndStructure,
  SdefParserResolveEntity,
  SdefParserHandleError
};

@implementation SdefXMLParser

- (id)init {
  if (self = [super init]) {
    sd_comments = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [sd_error release];
  [sd_comments release];
  [sd_delegate release];
  [sd_dictionary release];
  [super dealloc];
}

#pragma mark -
- (int)parserVersion {
  return kSdefParserBothVersion;
}

- (void)setVersion:(int)version {
  switch (version) {
    case kSdefParserBothVersion:
      break;
    case kSdefParserTigerVersion:
      DLog(@"Transformation to Tiger Parser");
      SKSwizzleIsaPointer(self, [SdefTigerParser class]);
      break;
    case kSdefParserPantherVersion:
      DLog(@"Transformation to Panther Parser");
      SKSwizzleIsaPointer(self, [SdefPantherParser class]);
      break;
  }
}

- (NSString *)error {
  return sd_error;
}

- (SdefDictionary *)document {
  return sd_dictionary;
}

- (BOOL)parseData:(NSData *)document {
  if (sd_error) {
    [sd_error release];
    sd_error = nil;
  }
  if (sd_dictionary) {
    [sd_dictionary release];
    sd_dictionary = nil;
  }
  if (!document) return NO;
  [sd_comments removeAllObjects];
  
  CFXMLParserContext ctxt = { 0, self, nil, nil, ShadowCFCopyDescription};
  sd_parser = CFXMLParserCreate(kCFAllocatorDefault, (CFDataRef)document, NULL,
                                kCFXMLParserNoOptions, kCFXMLNodeCurrentVersion,
                                &SdefParserCallBacks, &ctxt);
  BOOL result = CFXMLParserParse(sd_parser);
  CFRelease(sd_parser);
  sd_parser = nil;
  return result;
}

#pragma mark -
#pragma mark Sdef Parsing
- (void)parser:(CFXMLParserRef)parser didStartDictionary:(NSDictionary *)attributes {
  if (sd_dictionary) {
    [sd_dictionary release];
  }
  sd_dictionary = [(SdefObject *)[SdefDictionary allocWithZone:[self zone]] initWithAttributes:attributes];
  sd_node = sd_dictionary;
}

- (void)parser:(CFXMLParserRef)parser didStartCocoa:(NSDictionary *)attributes {
  [[sd_node impl] setAttributes:attributes];
}

- (void)parser:(CFXMLParserRef)parser didStartDocumentation:(NSDictionary *)attributes {
  sd_delegate = [[SdefDocumentationParser alloc] initWithDocumentation:[sd_node documentation] parent:self];
}

- (void)parserDidEndDocumentation:(SdefDocumentationParser *)parser {
  [sd_delegate release]; /* sd_delegate == parser */
  sd_delegate = nil;
}

- (void)parser:(CFXMLParserRef)parser didStartSynonym:(NSDictionary *)attributes {
  if (sd_node) {
    SdefSynonym *synonym = [[SdefSynonym allocWithZone:[self zone]] init];
    [synonym setAttributes:attributes];
    [sd_node addSynonym:synonym];
    [synonym release];
    sd_node = synonym;
  }
}

#pragma mark -
#pragma mark Suite
- (void)parser:(CFXMLParserRef)parser didStartSuite:(NSDictionary *)attributes {
  NSAssert([sd_node isKindOfClass:[SdefDictionary class]], @"sd_node should be a dictionary");
  if (sd_node) {
    SdefSuite *suite = [(SdefObject *)[SdefSuite allocWithZone:[self zone]] initWithAttributes:attributes];
    [sd_node appendChild:suite];
    [suite release];
    sd_node = suite;
  }
}

#pragma mark Enumeration
- (void)parser:(CFXMLParserRef)parser didStartEnumeration:(NSDictionary *)attributes {
  NSAssert([[sd_node parent] isKindOfClass:[SdefSuite class]], @"sd_node should be a suite");
  if (sd_node) {
    SdefEnumeration *enumeration = [(SdefObject *)[SdefEnumeration allocWithZone:[self zone]] initWithAttributes:attributes];
    [sd_node appendChild:enumeration];
    [enumeration release];
    sd_node = enumeration;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartEnumerator:(NSDictionary *)attributes {
  NSAssert([sd_node isKindOfClass:[SdefEnumeration class]], @"sd_node should be an enumeration");
  if (sd_node) {
    SdefEnumerator *enumerator = [(SdefObject *)[SdefEnumerator allocWithZone:[self zone]] initWithAttributes:attributes];
    [sd_node appendChild:enumerator];
    [enumerator release];
    sd_node = enumerator;
  }
}

#pragma mark Class
- (void)parser:(CFXMLParserRef)parser didStartClass:(NSDictionary *)attributes {
  NSAssert([[sd_node parent] isKindOfClass:[SdefSuite class]], @"sd_node should be a suite");
  if (sd_node) {
    SdefClass *class = [(SdefObject *)[SdefClass allocWithZone:[self zone]] initWithAttributes:attributes];
    [sd_node appendChild:class];
    [class release];
    sd_node = class;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartContents:(NSDictionary *)attributes {
  NSAssert([sd_node isKindOfClass:[SdefClass class]], @"sd_node should be a class");
  if (sd_node) {
    SdefContents *contents = [sd_node contents];
    [contents setAttributes:attributes];
    sd_node = contents;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartElement:(NSDictionary *)attributes {
  NSAssert([[sd_node parent] isKindOfClass:[SdefClass class]], @"sd_node should be a class");
  if (sd_node) {
    SdefElement *element = [(SdefObject *)[SdefElement allocWithZone:[self zone]] initWithAttributes:attributes];
    [sd_node appendChild:element];
    [element release];
    sd_node = element;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartAccessor:(NSDictionary *)attributes {
  NSAssert([sd_node isKindOfClass:[SdefElement class]], @"sd_node should be an element");
  NSString *accessor = [attributes objectForKey:@"style"];
  if (accessor) {
    [sd_node setAccessors:[sd_node accessors] | SdefXMLAccessorFlagFromString(accessor)];
  }
}

- (void)parser:(CFXMLParserRef)parser didStartProperty:(NSDictionary *)attributes {
  NSAssert([[sd_node parent] isKindOfClass:[SdefClass class]] || [sd_node isKindOfClass:[SdefRecord class]], @"sd_node should be a class or sd_node a record");
  if (sd_node) {
    SdefProperty *property = [(SdefObject *)[SdefProperty allocWithZone:[self zone]] initWithAttributes:attributes];
    [sd_node appendChild:property];
    [property release];
    sd_node = property;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartRespondsTo:(NSDictionary *)attributes {
  NSAssert([[sd_node parent] isKindOfClass:[SdefClass class]], @"sd_node should be a class");
  if (sd_node) {
    SdefRespondsTo *respondsTo = [(SdefObject *)[SdefRespondsTo allocWithZone:[self zone]] initWithAttributes:attributes];
    [sd_node appendChild:respondsTo];
    [respondsTo release];
    sd_node = respondsTo;
  }
}


#pragma mark Verb
- (void)parser:(CFXMLParserRef)parser didStartCommand:(NSDictionary *)attributes {
  NSAssert([[sd_node parent] isKindOfClass:[SdefSuite class]], @"sd_node should be a suite");
  if (sd_node) {
    SdefVerb *command = [(SdefObject *)[SdefVerb allocWithZone:[self zone]] initWithAttributes:attributes];
    [sd_node appendChild:command];
    [command release];
    sd_node = command;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartEvent:(NSDictionary *)attributes {
  NSAssert([[sd_node parent] isKindOfClass:[SdefSuite class]], @"sd_node should be a suite");
  if (sd_node) {
    SdefVerb *event = [(SdefObject *)[SdefVerb allocWithZone:[self zone]] initWithAttributes:attributes];
    [sd_node appendChild:event];
    [event release];
    sd_node = event;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartDirectParameter:(NSDictionary *)attributes {
  NSAssert([sd_node isKindOfClass:[SdefVerb class]], @"sd_node should be a verb");
  if (sd_node) {
    SdefDirectParameter *param = [sd_node directParameter];
    [param setAttributes:attributes];
    sd_node = param;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartParameter:(NSDictionary *)attributes {
  NSAssert([sd_node isKindOfClass:[SdefVerb class]], @"sd_node should be a verb");
  if (sd_node) {
    SdefParameter *param = [(SdefObject *)[SdefParameter allocWithZone:[self zone]] initWithAttributes:attributes];
    [sd_node appendChild:param];
    [param release];
    sd_node = param;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartResult:(NSDictionary *)attributes {
  NSAssert([sd_node isKindOfClass:[SdefVerb class]], @"sd_node should be a verb");
  if (sd_node) {
    SdefResult *result = [sd_node result];
    [result setAttributes:attributes];
    sd_node = result;
  }
}

#pragma mark Misc
- (void)parser:(CFXMLParserRef)parser foundComment:(NSString *)comment {
  id value = [comment copy];
  [sd_comments addObject:value];
  [value release];
}

- (void)parser:(CFXMLParserRef)parser didStartElement:(NSString *)element withAttributes:(NSDictionary *)attributes {
  CFStringRef str = CFStringCreateWithFormat(kCFAllocatorDefault, nil, CFSTR("Line %i: Unknow element %@"),
                                             CFXMLParserGetLineNumber(parser), element);
  CFXMLParserAbort(parser, kCFXMLErrorMalformedDocument, str);
  CFRelease(str);
}

#pragma mark -
#pragma mark End Element
- (void)parser:(CFXMLParserRef)parser didEndElement:(NSString *)element {
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[element methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");

  /* Orphan implemented : direct-parameter, result, contents */
  if (isEqual(element, cmd, @"result") ||
      isEqual(element, cmd, @"synonym") || 
      isEqual(element, cmd, @"contents") ||
      isEqual(element, cmd, @"direct-parameter")) {
    sd_node = [sd_node owner];
  }
  /* Empty elements */ 
  else if (!isEqual(element, cmd, @"accessor") &&
      !isEqual(element, cmd, @"cocoa") &&
      !isEqual(element, cmd, @"documentation") &&
      !isEqual(element, cmd, @"type")) {
    sd_node = [sd_node parent];
  }
}

- (void)parserDidEndDocument:(CFXMLParserRef)parser {
/* Post processing */
}

#pragma mark -
#pragma mark Element Handling
- (void)parser:(CFXMLParserRef)parser didStartElement:(NSString *)elementName infos:(CFXMLElementInfo *)infos {
  if (sd_node) {
    int version = [sd_node acceptXMLElement:elementName];
    if ([self parserVersion] & version) {
      if ([self parserVersion] != version) [self setVersion:version];
    } else {
      NSString *msg = [NSString stringWithFormat:@"Invalid element %@ in %@ for %@ version",  elementName,
        [sd_node xmlElementName], 
        ([self parserVersion] == kSdefParserTigerVersion) ? @"Tiger" : ([self parserVersion] == kSdefParserPantherVersion) ? @"Panther" : @"Both"];
      CFXMLParserAbort(parser, kCFXMLErrorMalformedDocument, (CFStringRef)msg);
    }
  }
  
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[elementName methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");
  
  NSDictionary *attributes = (id)infos->attributes;
  if (isEqual(elementName, cmd, @"dictionary")) {
    [self parser:parser didStartDictionary:attributes];
  } else if (isEqual(elementName, cmd, @"suite")) {
    [self parser:parser didStartSuite:attributes];
  } else if (isEqual(elementName, cmd, @"cocoa")) {
    [self parser:parser didStartCocoa:attributes];
  } else if (isEqual(elementName, cmd, @"documentation")) {
    [self parser:parser didStartDocumentation:attributes];
  } else if (isEqual(elementName, cmd, @"synonym")) {
    [self parser:parser didStartSynonym:attributes];
  }
  /* Types */
  else if (isEqual(elementName, cmd, @"enumeration")) {
    [self parser:parser didStartEnumeration:attributes];
  } else if (isEqual(elementName, cmd, @"enumerator")) {
    [self parser:parser didStartEnumerator:attributes];
  }
  /* Class */
  else if (isEqual(elementName, cmd, @"class")) {
    [self parser:parser didStartClass:attributes];
  } else if (isEqual(elementName, cmd, @"contents")) {
    [self parser:parser didStartContents:attributes];
  } else if (isEqual(elementName, cmd, @"element")) {
    [self parser:parser didStartElement:attributes];
  } else if (isEqual(elementName, cmd, @"accessor")) {
    [self parser:parser didStartAccessor:attributes];
  } else if (isEqual(elementName, cmd, @"property")) {
    [self parser:parser didStartProperty:attributes];
  } else if (isEqual(elementName, cmd, @"responds-to")) {
    [self parser:parser didStartRespondsTo:attributes];
  } 
  /* Verb */
  else if (isEqual(elementName, cmd, @"command")) {
    [self parser:parser didStartCommand:attributes];
  } else if (isEqual(elementName, cmd, @"event")) {
    [self parser:parser didStartEvent:attributes];
  } else if (isEqual(elementName, cmd, @"direct-parameter")) {
    [self parser:parser didStartDirectParameter:attributes];
  } else if (isEqual(elementName, cmd, @"parameter")) {
    [self parser:parser didStartParameter:attributes];
  } else if (isEqual(elementName, cmd, @"result")) {
    [self parser:parser didStartResult:attributes];
  } else {
    [self parser:parser didStartElement:elementName withAttributes:attributes];
  }
  if ([sd_comments count]) {
    [sd_node setComments:sd_comments];
    [sd_comments removeAllObjects];
  }
}

// ...and this reports a fatal error to the delegate. The parser will stop parsing.
- (BOOL)parser:(CFXMLParserRef)parser parseErrorOccurred:(NSError *)parseError {
  sd_error = [[[parseError userInfo] objectForKey:@"SdefParserError"] copy];
  return NO;
}

#pragma mark -
#pragma mark Low Level Parsing
- (id)parser:(CFXMLParserRef)parser didStartXMLNode:(CFXMLNodeRef)aNode {
  if (sd_delegate) {
    return [sd_delegate parser:parser didStartXMLNode:aNode];
  }
  
  id object = nil;
  switch (CFXMLNodeGetTypeCode(aNode)) {
    case kCFXMLNodeTypeElement:
      [self parser:parser didStartElement:(id)CFXMLNodeGetString(aNode) infos:(CFXMLElementInfo *)CFXMLNodeGetInfoPtr(aNode)];
      object = (void *)CFXMLNodeGetString(aNode);
      break;
    case kCFXMLNodeTypeDocument:
      /* Can find comment before first element */
      object = [NSNull null];
      break;
    case kCFXMLNodeTypeProcessingInstruction:
      DLog(@"Data Type ID: kCFXMLNodeTypeProcessingInstruction (%@)", CFXMLNodeGetString(aNode));
      break;
    case kCFXMLNodeTypeComment:
      [self parser:parser foundComment:(id)CFXMLNodeGetString(aNode)];
      break;
    case kCFXMLNodeTypeText:
      DLog(@"Data Type ID: kCFXMLNodeTypeText (%@)", CFXMLNodeGetString(aNode));
      break;
    case kCFXMLNodeTypeCDATASection:
      DLog(@"Data Type ID: kCFXMLDataTypeCDATASection (%@)", CFXMLNodeGetString(aNode));
      break;
    case kCFXMLNodeTypeEntityReference:
      DLog(@"Data Type ID: kCFXMLNodeTypeEntityReference (%@)", CFXMLNodeGetString(aNode));
      break;
    case kCFXMLNodeTypeDocumentType:
      DLog(@"Data Type ID: kCFXMLNodeTypeDocumentType (%@)", CFXMLNodeGetString(aNode));
      break;
    case kCFXMLNodeTypeWhitespace:
      /* Ignore white space */
      break;
    default:
      DLog(@"Unknown Data Type ID: %i (%@)", CFXMLNodeGetTypeCode(aNode), CFXMLNodeGetString(aNode));
      break;
  }
  return object;
}

- (void)parser:(CFXMLParserRef)parser didEndXMLNode:(id)aNode {
  if (sd_delegate) {
    [sd_delegate parser:parser didEndXMLNode:aNode];
    return;
  }

  if ([aNode isKindOfClass:[NSString class]]) {
    [self parser:parser didEndElement:aNode];
    if ([aNode isEqualToString:@"dictionary"]) {
      [self parserDidEndDocument:parser];
    }
  }
}

#pragma mark Core Foundation Parser
void *SdefParserCreateStructure(CFXMLParserRef parser, CFXMLNodeRef node, void *info) {
  SdefXMLParser *delegate = info;
  return [delegate parser:parser didStartXMLNode:node];
}

void SdefParserAddChild(CFXMLParserRef parser, void *parent, void *child, void *info) {}

void SdefParserEndStructure(CFXMLParserRef parser, void *node, void *info) {
  SdefXMLParser *delegate = info;
  [delegate parser:parser didEndXMLNode:node];
}

CFDataRef SdefParserResolveEntity(CFXMLParserRef parser, CFXMLExternalID *extID, void *info) {
  return NULL;
}

Boolean SdefParserHandleError(CFXMLParserRef parser, CFXMLParserStatusCode error, void *info) {
  SdefXMLParser *delegate = info;
  // Get the error description string from the Parser.
  CFStringRef description = CFXMLParserCopyErrorDescription(parser);
  NSDictionary *infos = description ? [NSDictionary dictionaryWithObject:(id)description forKey:@"SdefParserError"] : nil;
  NSError *reason = [NSError errorWithDomain:NSXMLParserErrorDomain code:error userInfo:infos];
  Boolean result = [delegate parser:parser parseErrorOccurred:reason];
  if (description)
    CFRelease(description);
  return result;
}

@end

#pragma mark -
NSString *SdefXMLAccessStringFromFlag(unsigned flag) {
  id str = nil;
  if (flag == (kSdefAccessRead | kSdefAccessWrite)) str = @"rw";
  else if (flag == kSdefAccessRead) str = @"r";
  else if (flag == kSdefAccessWrite) str = @"w";
  return str;
}

unsigned SdefXMLAccessFlagFromString(NSString *str) {
  unsigned flag = 0;
  if (str && [str rangeOfString:@"r"].location != NSNotFound) {
    flag |= kSdefAccessRead;
  }
  if (str && [str rangeOfString:@"w"].location != NSNotFound) {
    flag |= kSdefAccessWrite;
  }
  return flag;
}
