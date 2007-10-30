/*
 *  SdefParser.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright (c) 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefParser.h"
#import "SdefXMLBase.h"
#import "SdefXMLValidator.h"
#import "SdefParserInternal.h"
#import "SdefDocumentationParser.h"

#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefSuite.h"
#import "SdefTypedef.h"
#import "SdefContents.h"
#import "SdefArguments.h"
#import "SdefDictionary.h"
#import "SdefClassManager.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

#include <libxml/parser.h>
#include <libxml/xinclude.h>

static 
void _SdefParserUpdatePantherObjects(NSArray *roots);
static
void _SdefParserPostProcessObjects(NSArray *roots);

enum {
  kSdefValidationErrorStatus = 'VErr',
};


static 
void _SdefSetIncludeNamespace(xmlNodePtr a_node, xmlNsPtr ns) {
  for (xmlNode *cur_node = a_node; cur_node; cur_node = cur_node->next) {
    if (cur_node->type == XML_ELEMENT_NODE && 0 == xmlStrcmp(cur_node->name, (const xmlChar *)"include")) {
      xmlSetNs(cur_node, ns);
    }
    
    _SdefSetIncludeNamespace(cur_node->children, ns);
  }
}

@interface SdefXMLPlaceholder : NSObject <SdefXMLObject> {
  @private
  NSString *sd_name;
}

- (id)initWithElementName:(NSString *)name;

@end

enum {
  kSdefTypeAccessor = 'Aces',
};
@interface SdefAccessorPlaceholder : SdefXMLPlaceholder {
  @private
  NSString *sd_style;
}

- (NSString *)style;

@end

@interface SdefCollectionPlaceholder : SdefXMLPlaceholder {
  @private
  id<SdefXMLObject> sd_object;
}

- (void)setObject:(id<SdefXMLObject>)object;

@end

enum {
  kSdefTypeIgnore = 'Igno',
};
@interface SdefInvalidElementPlaceholder : SdefXMLPlaceholder {
}


@end

#pragma mark -
static
SdefVersion SdefDocumentVersionFromParserVersion(SdefParserVersion vers) {
  if (vers & kSdefParserVersionLeopard)
    return kSdefLeopardVersion;
  else if (vers & kSdefParserVersionTiger)
    return kSdefTigerVersion;
  else if (vers & kSdefParserVersionPanther)
    return kSdefPantherVersion;
  else
    return kSdefVersionUndefined;
}

static 
CFMutableDictionaryRef sSdefElementMap = NULL;
static
Class _SdefGetObjectClassForElement(CFStringRef element) {
  return (Class)CFDictionaryGetValue(sSdefElementMap, element);
}

/* Check if it is a Panther collection */
static
Boolean _SdefElementIsCollection(CFStringRef element) {
  return CFEqual(CFSTR("types"), element) || CFEqual(CFSTR("synonyms"), element) ||
  CFEqual(CFSTR("classes"), element) || CFEqual(CFSTR("elements"), element) ||
  CFEqual(CFSTR("properties"), element) || CFEqual(CFSTR("responds-to-commands"), element) ||
  CFEqual(CFSTR("responds-to-events"), element) || CFEqual(CFSTR("commands"), element) || CFEqual(CFSTR("events"), element);
}

#pragma mark -
@implementation SdefParser

+ (void)initialize {
  if ([SdefParser class] == self) {
    xmlInitParser();
    
    sSdefElementMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, 
                                                &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    /* Base */
    CFDictionaryAddValue(sSdefElementMap, CFSTR("dictionary"), [SdefDictionary class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("suite"), [SdefSuite class]);
    
    /* Commons */
    CFDictionaryAddValue(sSdefElementMap, CFSTR("documentation"), [SdefDocumentation class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("synonym"), [SdefSynonym class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("cocoa"), [SdefImplementation class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("type"), [SdefType class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("xref"), [SdefXRef class]);

    /* Verbs */
    CFDictionaryAddValue(sSdefElementMap, CFSTR("command"), [SdefVerb class]);
//    CFDictionaryAddValue(sSdefElementMap, CFSTR("event"), [SdefVerb class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("direct-parameter"), [SdefDirectParameter class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("parameter"), [SdefParameter class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("result"), [SdefResult class]);

    /* Class */
    CFDictionaryAddValue(sSdefElementMap, CFSTR("class"), [SdefClass class]);
//    CFDictionaryAddValue(sSdefElementMap, CFSTR("class-extension"), [SdefClass class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("contents"), [SdefContents class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("element"), [SdefElement class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("accessor"), [SdefAccessorPlaceholder class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("property"), [SdefProperty class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("responds-to"), [SdefRespondsTo class]);
    /* Types */
    CFDictionaryAddValue(sSdefElementMap, CFSTR("value-type"), [SdefValue class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("record-type"), [SdefRecord class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("enumeration"), [SdefEnumeration class]);
    CFDictionaryAddValue(sSdefElementMap, CFSTR("enumerator"), [SdefEnumerator class]);
    /* XInclude */
    CFDictionaryAddValue(sSdefElementMap, CFSTR("xi:include"), [SdefXInclude class]);
  }
}

#pragma mark -
- (id)init {
  if (self = [super init]) {
    sd_comments = [[NSMutableArray alloc] init];
    sd_metas = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  }
  return self;
}

- (void)dealloc {
  if (sd_metas) CFRelease(sd_metas);
  [sd_roots release];
  [sd_comments release];
  [sd_validator release];
  [sd_docParser release];
  [super dealloc];
}

#pragma mark -
- (void)reset {
  if (sd_roots) {
    [sd_roots release];
    sd_roots = nil;
  }
  if (sd_includes) {
    [sd_includes release];
    sd_includes = nil;
  }
  [sd_comments removeAllObjects];
  sd_version = kSdefParserVersionUnknown;
  if (sd_metas) CFDictionaryRemoveAllValues(sd_metas);
}

- (NSInteger)line {
  return sd_parser ? [(id)sd_parser line] : -1;
  //return sd_parser ? CFXMLParserGetLineNumber(sd_parser) : -1;
}
- (NSInteger)location {
  return sd_parser ? [(id)sd_parser location] : -1;
  //return sd_parser ? CFXMLParserGetLocation(sd_parser) : -1;
}

- (NSArray *)objects {
  return sd_roots;
}
- (SdefVersion)sdefVersion {
  return sd_version;
}
- (SdefDictionary *)dictionary {
  if ([sd_roots count] == 1) {
    SdefDictionary *object = [sd_roots objectAtIndex:0];
    return [object objectType] == kSdefDictionaryType ? object : nil;
  }
  return nil;
}

- (id)delegate {
  return sd_delegate;
}
- (void)setDelegate:(id)delegate {
  NSParameterAssert(!delegate || [delegate respondsToSelector:@selector(sdefParser:shouldIgnoreValidationError:isFatal:)]);
  sd_delegate = delegate;
}

- (BOOL)parseFragment:(xmlNodePtr)aNode parent:(NSString *)parent base:(NSURL *)anURL {
  
  if (parent)
    [sd_validator startElement:(CFStringRef)parent];

  SdefDOMParser *parser = [[SdefDOMParser alloc] initWithDelegate:self];
  BOOL ok = [parser parse:aNode];
  [parser release];
  
  if (parent)
    [sd_validator endElement:(CFStringRef)parent];
  
  return ok;
}

- (BOOL)parseSdef:(NSData *)sdefData base:(NSURL *)anURL error:(NSError **)outError {
  [self reset];
  BOOL result = NO;
  if (outError) *outError = nil;
  
  if (sd_roots) {
    [sd_roots release];
    sd_roots = nil;
  }
  if (sdefData) {
    [sd_comments removeAllObjects];
    if (sd_metas) CFDictionaryRemoveAllValues(sd_metas);
    
    int flags = XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_NSCLEAN | XML_PARSE_NOCDATA | XML_PARSE_COMPACT /* | XML_PARSE_NOERROR | XML_PARSE_NOWARNING */;
    xmlDocPtr doc = xmlReadMemory([sdefData bytes], [sdefData length],
                                  [[anURL absoluteString] UTF8String], NULL, flags);
    
    if (doc) {
      sd_validator = [[SdefXMLValidator alloc] init];
      /* correct doc if needed */
      if (!xmlSearchNs(doc, xmlDocGetRootElement(doc), (const xmlChar *)"xi")) {
        /* xmlns:xi="http://www.w3.org/2001/XInclude" */
        xmlNsPtr ns = xmlNewNs(xmlDocGetRootElement(doc), (const xmlChar *)"http://www.w3.org/2001/XInclude", (const xmlChar *)"xi");
        _SdefSetIncludeNamespace(xmlDocGetRootElement(doc), ns);
      }
      
      /* process xincludes */
      xmlXIncludeProcessFlags(doc, flags);
      
      result = [self parseFragment:xmlDocGetRootElement(doc) parent:nil base:anURL];
      sd_version = SdefDocumentVersionFromParserVersion([sd_validator version]);
      [sd_validator release];
      sd_validator = nil;
      xmlFreeDoc(doc);
      doc = NULL;
    } else if (outError) {
      xmlErrorPtr error = xmlGetLastError();
      if (error) {
        *outError = [NSError errorWithDomain:NSXMLParserErrorDomain code:error->code userInfo:nil];
      } else {
        *outError = nil;
      }
    }
    
    if ([sd_roots count] > 0) {
      if (sd_version <= kSdefPantherVersion)
        _SdefParserUpdatePantherObjects(sd_roots);
      else 
        _SdefParserPostProcessObjects(sd_roots);
    }
  }
  return result;
}

#pragma mark -
- (void)parser:(SdefDOMParser *)parser handleComment:(const xmlChar *)aComment {
  CFStringRef cmt = CFStringCreateWithCString(kCFAllocatorDefault, (const char *)aComment, [parser cfencoding]);
  if (CFStringHasPrefix(cmt, CFSTR(" @"))) {
    CFRange start, end;
    if (CFStringFindWithOptions(cmt, CFSTR("("), 
                                CFRangeMake(0, CFStringGetLength(cmt)), 0, &start) &&
        CFStringFindWithOptions(cmt, CFSTR(")"), 
                                CFRangeMake(0, CFStringGetLength(cmt)), kCFCompareBackwards, &end) &&
        (start.location + start.length) < end.location) {
      CFStringRef key = NULL, value = NULL;
      key = CFStringCreateWithSubstring(kCFAllocatorDefault, cmt, CFRangeMake(2, start.location - 2));
      start.location += start.length;
      value = CFStringCreateWithSubstring(kCFAllocatorDefault, cmt, CFRangeMake(start.location, end.location - start.location));
      if (key && value)
        CFDictionarySetValue(sd_metas, key, value);
      if (key) CFRelease(key);
      if (value) CFRelease(value);
      
      return;
    }
  } 
  /* else */
  [sd_comments addObject:(id)cmt];
  CFRelease(cmt);
}

- (id)parser:(SdefDOMParser *)parser createStructureForElement:(xmlNodePtr)element {
  NSString *error = nil;
  id<SdefXMLObject> object = nil;
  
  CFStringRef name = CFStringCreateWithCString(kCFAllocatorDefault, (const char *)element->name, [parser cfencoding]);
  CFDictionaryRef attrs = _SdefXMLCreateDictionaryWithAttributes(element->properties, [parser cfencoding]);
  SdefParserVersion version = [sd_validator validateElement:name attributes:attrs error:&error];
  [sd_validator startElement:name];

  if (kSdefParserVersionUnknown == version) {
    NSString *reason = [NSString stringWithFormat:@"Parser validation error line %ld: %@ (%@, %@)", 
      (long)[parser line], error, name, attrs];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
      reason, NSLocalizedDescriptionKey, error, NSUnderlyingErrorKey, nil];
    NSError *anError = [NSError errorWithDomain:NSXMLParserErrorDomain code:NSXMLParserInternalError userInfo:info];
    if ([sd_delegate sdefParser:self shouldIgnoreValidationError:anError isFatal:NO]) {
      id elt = [[SdefInvalidElementPlaceholder alloc] initWithElementName:(id)name];
      if (attrs) CFRelease(attrs);
      CFRelease(name);
      return elt;
    } else {
      [parser abortWithError:kSdefValidationErrorStatus reason:@""];
    }
  }
  
  Class class = _SdefGetObjectClassForElement(name);
  if (class) {
    object = [[class alloc] init];
  } else if (CFEqual(CFSTR("class-extension"), name)) {
    object = [[SdefClass alloc] init];
    [(SdefClass *)object setExtension:YES];
  } else if (CFEqual(CFSTR("event"), name)) {
    object = [[SdefVerb alloc] init];
    [(SdefVerb *)object setCommand:NO];
  } else if (_SdefElementIsCollection(name)) {
    object = [[SdefCollectionPlaceholder alloc] initWithElementName:(id)name];
  }
  
  if (object) {
    if (attrs && CFDictionaryGetCount(attrs) > 0)
      [object setXMLAttributes:(id)attrs];
  }
  if (attrs) CFRelease(attrs);
  CFRelease(name);
  return object;
}

#pragma mark Parser Core
- (void *)parser:(SdefDOMParser *)parser createStructureForNode:(xmlNodePtr)node {
  void *structure = NULL;
  @try {
    if (sd_docParser) {
      structure = [sd_docParser parser:parser createStructureForNode:node];
    } else {
      switch (node->type) {
        case XML_DOCUMENT_NODE:
          structure = @"__document__";
          break;
        case XML_ELEMENT_NODE:
          structure = [self parser:parser createStructureForElement:node];
          break;
        case XML_PI_NODE:
          DLog(@"Encounter processing instruction: %s", node->name);
          break;
        case XML_COMMENT_NODE:
          [self parser:parser handleComment:node->content];
          break;
        case XML_TEXT_NODE:
          /* probably white-space: skip it */
          //DLog(@"Data Type ID: kCFXMLNodeTypeText (%s)", node->content);
          break;
        case XML_CDATA_SECTION_NODE:
          DLog(@"Data Type ID: kCFXMLDataTypeCDATASection (%s)", node->content);
          break;
        case XML_ENTITY_REF_NODE:
          DLog(@"Data Type ID: kCFXMLNodeTypeEntityReference (%s)", node->name);
          break;
        case XML_DTD_NODE:
        case XML_DOCUMENT_TYPE_NODE:
          DLog(@"Data Type ID: kCFXMLNodeTypeDocumentType (%s)", node->name);
          break;
        case XML_XINCLUDE_START:
          sd_xinclude = true;
          DLog(@"Start xinclude");
          break;
        case XML_XINCLUDE_END:
          sd_xinclude = false;
          DLog(@"End xinclude");
          break;
//        case kCFXMLNodeTypeWhitespace:
//          /* Ignore white space */
//          break;
        default:
          DLog(@"Unknown Data Type ID: %ld (%s)", (long)node->type, node->name);
          break;
      }
    }
  } @catch (id exception) {
    SKLogException(exception);
    [parser abortWithError:kCFXMLErrorMalformedDocument reason:[exception reason]];
  }
  return structure;
}

- (void)sd_addCommentsToObject:(id<SdefXMLObject>)object {
  if ([sd_comments count]) {
    if (object) {
      for (NSUInteger i = 0; i < [sd_comments count]; i++) {
        /* parse meta */
        [object addXMLComment:[sd_comments objectAtIndex:i]];
      }
    }
    [sd_comments removeAllObjects];
  }
  if (sd_metas && CFDictionaryGetCount(sd_metas) > 0) {
    [object setXMLMetas:(id)sd_metas];
    CFDictionaryRemoveAllValues(sd_metas);
  }
}

- (void)parser:(SdefDOMParser *)parser addChild:(void *)aChild toStructure:(void *)aStruct {
  if (sd_docParser) {
    [sd_docParser parser:parser addChild:aChild toStructure:aStruct];
  } else {
    id<SdefXMLObject> child = (id)aChild;
    id<SdefXMLObject> parent = (id)aStruct;
    //  DLog(@"=========== %@ -> %@", parent, child);
    if (typeWildCard == [child objectType]) {
      [(id)child setObject:parent];
    } else if (kSdefTypeAccessor == [child objectType]) {
      [(id)parent addXMLAccessor:(NSString *)[(id)child style]];
    } else if (kSdefTypeIgnore == [child objectType]) {
      // invalid object. skip
    } else {
      if (parent) {
        [(id)parent addXMLChild:(id)child];
      } else {
        if (!sd_roots) sd_roots = [[NSMutableArray alloc] init];
        [sd_roots addObject:child];
      }
      
      /* Handle xinclude */
      if (sd_xinclude)
        [child setEditable:NO];
      
      /* Handle comments */
      [self sd_addCommentsToObject:child];
      
      /* Check documentation element */
      if (kSdefDocumentationType == [child objectType]) {
        sd_docParser = [[SdefDocumentationParser alloc] initWithDocumentation:(id)child];
      }
    }
  }
}

- (void)parser:(SdefDOMParser *)parser endStructure:(void *)structure {
  if (sd_docParser) {
    if ([(id)structure isKindOfClass:[SdefDocumentation class]]) {
      [sd_docParser close];
      [sd_docParser release];
      sd_docParser = nil; 
      
      [sd_validator endElement:CFSTR("documentation")];
    } else {
      [sd_docParser parser:parser endStructure:structure];
    }
  } else {
    /* handle special case where class become class extension */
    if ([(id)[sd_validator element] isEqualToString:@"class"] &&
        [[(id)structure xmlElementName] isEqualToString:@"class-extension"])
      [sd_validator endElement:CFSTR("class")]; 
    else
      [sd_validator endElement:(CFStringRef)[(id)structure xmlElementName]]; 
    
    /* Handle comments */
    [self sd_addCommentsToObject:(id)structure];
    
    [(id)structure release];
  }
}

@end

#pragma mark -
#pragma mark Core Foundation Parser
//void *SdefParserCreateStructure(CFXMLParserRef parser, CFXMLNodeRef node, void *info) {
//  if (CFXMLNodeGetTypeCode(node) == kCFXMLNodeTypeDocument) {
//    // handle start document
//    return @"__document__";
//  }
//  
//  SdefParser *delegate = info;
//  return [delegate parser:parser createStructureForNode:node];
//}
//
//void SdefParserAddChild(CFXMLParserRef parser, void *parent, void *child, void *info) {
//  SdefParser *delegate = info;
//  if (![(id)parent isEqual:@"__document__"]) {
//    [delegate parser:parser addChild:child toStructure:parent];
//  } else {
//    [delegate parser:parser addChild:child toStructure:nil];
//  }
//}
//
//void SdefParserEndStructure(CFXMLParserRef parser, void *node, void *info) {
//  if (![(id)node isEqual:@"__document__"]) {
//    SdefParser *delegate = info;
//    [delegate parser:parser endStructure:node];
//  } else {
//    // handle end of document
//  }
//}
//
//CFDataRef SdefParserResolveExternalEntity(CFXMLParserRef parser, CFXMLExternalID *extID, void *info) {
//  ShadowCTrace();
//  return NULL;
//}
///* if handleError returns true, the parser will attempt to recover */
//Boolean SdefParserHandleError(CFXMLParserRef parser, CFXMLParserStatusCode error, void *info) {
//  SdefParser *delegate = info;
//  return [delegate parser:parser handleError:error];
//}

#pragma mark -
#pragma mark Panther Support
#pragma mark Misc
/* Convert old base types */
SK_INLINE
void __SdefParserUpdatePantherObject(id object) {
  if ([object isKindOfClass:[SdefTypedObject class]]) {
    NSArray *types = [object types];
    for (NSUInteger idx = 0; idx < [types count]; idx++) {
      SdefType *type = [types objectAtIndex:idx];
      if ([[type name] isEqualToString:@"string"]) {
        [type setName:@"text"];
      } else if ([[type name] isEqualToString:@"object"]) {
        [type setName:@"specifier"];
      } else if ([[type name] isEqualToString:@"location"]) {
        [type setName:@"location specifier"];
      }
    }
  } else if ([object isKindOfClass:[SdefProperty class]] || [object isKindOfClass:[SdefElement class]]) {
    /* Change property and element cocoa attribute */
    NSString *method = [[object impl] method];
    if (method) {
      [[object impl] setKey:method];
      [[object impl] setMethod:nil];
    }
  }
}

static
void _SdefParserUpdatePantherObjects(NSArray *roots) {
  for (NSUInteger idx = 0; idx < [roots count]; idx++) {
    id child;
    SdefObject *root = [roots objectAtIndex:idx];
    __SdefParserUpdatePantherObject(root);
    NSEnumerator *children = [root deepChildEnumerator];
    while (child = [children nextObject]) {
      __SdefParserUpdatePantherObject(child);
    }
  }
}

SK_INLINE
void __SdefParserPostProcessClass(SdefClass *cls) {
  SdefRespondsTo *cmd;
  NSEnumerator *cmds = [[cls commands] childEnumerator];
  while (cmd = [cmds nextObject]) {
    if ([[cmd classManager] eventWithIdentifier:[cmd name]]) {
      [cmd retain];
      [cmd remove];
      [[cls events] appendChild:cmd];
      [cmd release];
    }
  }
}

/* post process */
SK_INLINE
void __SdefParserPostProcessObject(id object) {
  switch ([object objectType]) {
    case kSdefSuiteType: {
      SdefClass *class;
      NSEnumerator *classes = [[object classes] childEnumerator];
      while (class = [classes nextObject]) {
        __SdefParserPostProcessClass(class);
      }
    }
      break;
    case kSdefClassType:
      __SdefParserPostProcessClass(object);
      break;
    default:
      break;
  }
}

static
void _SdefParserPostProcessObjects(NSArray *roots) {
  for (NSUInteger idx = 0; idx < [roots count]; idx++) {
    id child;
    SdefObject *root = [roots objectAtIndex:idx];
    __SdefParserPostProcessObject(root);
    NSEnumerator *children = [root deepChildEnumerator];
    while (child = [children nextObject]) {
      __SdefParserPostProcessObject(child);
    }
  }
}


#pragma mark -
@implementation SdefXMLPlaceholder

+ (SdefObjectType)objectType {
  return typeWildCard;
}

- (id)initWithElementName:(NSString *)name {
  if (self = [super init]) {
    sd_name = [name retain];
  }
  return self;
}

- (void)dealloc {
  [sd_name release];
  [super dealloc];
}

#pragma mark -
- (SdefObjectType)objectType {
  return [[self class] objectType];
}

- (NSString *)location { return nil; }
- (NSString *)objectTypeName { return nil; }

- (NSImage *)icon { return nil; }
- (NSString *)name { return nil; }

- (BOOL)isEditable { return YES; }
- (void)setEditable:(BOOL)flag {}

- (SdefObject *)container { return nil; }
- (SdefDictionary *)dictionary { return nil; }
- (NSUndoManager *)undoManager { return nil; }
- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType { return nil; }

#pragma mark Parser
- (void)addXMLChild:(id<SdefObject>)node { 
  [NSException raise:NSInternalInconsistencyException 
              format:@"%@ does not support child element", sd_name];
}
- (void)addXMLComment:(NSString *)aComment {
  // ignore comments
}
- (void)setXMLMetas:(NSDictionary *)metas {
  // ignore metas.
}
- (void)setXMLAttributes:(NSDictionary *)attrs { 
  // ignore attributes.
}

#pragma mark Generator
- (NSString *)xmlElementName { return sd_name; }
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version { return nil; }

@end

@implementation SdefCollectionPlaceholder

#pragma mark -
- (void)setObject:(id<SdefXMLObject>)object {
  sd_object = object;
}

- (SdefObjectType)objectType {
  return sd_object ? [sd_object objectType] : [super objectType];
}

- (NSString *)location {
  return sd_object ? [sd_object location] : nil;
}
- (NSString *)objectTypeName {
  return sd_object ? [sd_object objectTypeName] : nil;
}

- (NSImage *)icon {
  return sd_object ? [sd_object icon] : nil;
}
- (NSString *)name {
  return sd_object ? [sd_object name] : nil;
}

- (SdefObject *)container { 
  return [sd_object container];
}
- (SdefDictionary *)dictionary {
  return [sd_object dictionary];
}
- (NSUndoManager *)undoManager {
  return [sd_object undoManager];
}
- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType {
  return sd_object ? [sd_object firstParentOfType:aType] : nil;
}

#pragma mark Parser
- (void)addXMLChild:(id<SdefObject>)node {
  [sd_object addXMLChild:node];
}

@end

@implementation SdefAccessorPlaceholder

+ (SdefObjectType)objectType {
  return kSdefTypeAccessor;
}

- (id)init {
  return [super initWithElementName:@"accessor"];
}

- (void)dealloc {
  [sd_style release];
  [super dealloc];
}

- (NSString *)style {
  return sd_style;
}

- (void)setXMLAttributes:(NSDictionary *)attrs { 
  sd_style = [[attrs objectForKey:@"style"] retain];
}

@end

@implementation SdefInvalidElementPlaceholder

+ (SdefObjectType)objectType {
  return kSdefTypeIgnore;
}

@end
