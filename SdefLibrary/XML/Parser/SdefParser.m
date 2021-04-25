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
#import "SdefXInclude.h"
#import "SdefContents.h"
#import "SdefArguments.h"
#import "SdefDictionary.h"
#import "SdefAccessGroup.h"
#import "SdefClassManager.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

#include <libxml/parser.h>
#include <libxml/xinclude.h>

static 
void _SdefParserUpdatePantherObjects(NSArray *roots);
static
void _SdefParserPostProcessObjects(NSArray *roots, SdefVersion version);

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
/* computed minimum supported version */
static
SdefVersion SdefDocumentVersionFromParserVersion(SdefValidatorVersion vers) {
  if (vers & kSdefParserVersionMountainLion) return kSdefMountainLionVersion;
  if (vers & kSdefParserVersionLeopard) return kSdefLeopardVersion;
  if (vers & kSdefParserVersionTiger) return kSdefTigerVersion;
  /* legacy document support */
  if (vers & kSdefParserVersionPanther) return kSdefPantherVersion;
  
  return kSdefVersionUndefined;
}

static 
NSDictionary *sSdefElementMap = nil;
static
Class _SdefGetObjectClassForElement(NSString *element) {
  return sSdefElementMap[element];
}

/* Check if it is a Panther collection */
static
Boolean _SdefElementIsCollection(NSString *element) {
  static NSSet *sCollection = nil;
  if (!sCollection)
    sCollection = [NSSet setWithObjects: @"types", @"synonyms",
                   @"classes", @"elements", @"properties",
                   @"responds-to-commands", @"responds-to-events", @"commands", @"events", nil];
  return [sCollection containsObject:element];
}

#pragma mark -
@implementation SdefParser

@synthesize delegate = sd_delegate;

+ (void)initialize {
  if ([SdefParser class] == self) {
    xmlInitParser();
    
    sSdefElementMap = @{
                        /* Base */
                        @"dictionary" : [SdefDictionary class],
                        @"suite" : [SdefSuite class],

                        /* Commons */
                        @"documentation" : [SdefDocumentation class],
                        @"synonym" : [SdefSynonym class],
                        @"cocoa" : [SdefImplementation class],
                        @"type" : [SdefType class],
                        @"xref" : [SdefXRef class],

                        /* Verbs */
                        @"command" : [SdefVerb class],
                        //    @"event" : [SdefVerb class],
                        @"direct-parameter" : [SdefDirectParameter class],
                        @"parameter" : [SdefParameter class],
                        @"result" : [SdefResult class],

                        /* Class */
                        @"class" : [SdefClass class],
                        //    @"class-extension" : [SdefClass class],
                        @"contents" : [SdefContents class],
                        @"element" : [SdefElement class],
                        @"accessor" : [SdefAccessorPlaceholder class],
                        @"property" : [SdefProperty class],
                        @"responds-to" : [SdefRespondsTo class],
                        /* Types */
                        @"value-type" : [SdefValue class],
                        @"record-type" : [SdefRecord class],
                        @"enumeration" : [SdefEnumeration class],
                        @"enumerator" : [SdefEnumerator class],
                        /* XInclude */
                        @"include" : [SdefXInclude class],
                        @"access-group" : [SdefAccessGroup class]
                        };
  }
}

#pragma mark -
- (id)init {
  if (self = [super init]) {
    sd_comments = [[NSMutableArray alloc] init];
    sd_xincludes = [[NSMutableArray alloc] init];
    sd_metas = [[NSMutableDictionary alloc] init];
  }
  return self;
}

#pragma mark -
- (void)reset {
  sd_roots = nil;
  [sd_comments removeAllObjects];
  [sd_xincludes removeAllObjects];
  sd_version = kSdefParserVersionUnknown;
  if (sd_metas)
    [sd_metas removeAllObjects];
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
    return [object objectType] == kSdefType_Dictionary ? object : nil;
  }
  return nil;
}

- (BOOL)parseFragment:(xmlNodePtr)aNode parent:(NSString *)parent base:(NSURL *)anURL {
  if (parent)
    [sd_validator startElement:parent];

  SdefDOMParser *parser = [[SdefDOMParser alloc] initWithDelegate:self];
  BOOL ok = [parser parse:aNode];
  
  if (parent)
    [sd_validator endElement:parent];
  
  return ok;
}

- (BOOL)parseData:(NSData *)sdefData base:(NSURL *)baseURL error:(NSError * __autoreleasing *)outError {
  [self reset];
  BOOL result = NO;
  if (outError) *outError = nil;
  
  if (sdefData || baseURL) {
    int flags = XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_NSCLEAN | XML_PARSE_COMPACT;
#if !defined(DEBUG)
    flags |= XML_PARSE_NOWARNING | XML_PARSE_NOERROR;
#endif
    xmlDocPtr document;
    if (sdefData)
      document = xmlReadMemory([sdefData bytes], [sdefData length], [[baseURL absoluteString] UTF8String], NULL, flags);
    else
      document = xmlReadFile([[baseURL absoluteString] UTF8String], NULL, flags);

    if (document) {
      sd_validator = [[SdefXMLValidator alloc] init];
      /* correct doc if needed */
      if (!xmlSearchNs(document, xmlDocGetRootElement(document), (const xmlChar *)"xi")) {
        /* xmlns:xi="http://www.w3.org/2001/XInclude" */
        xmlNsPtr ns = xmlNewNs(xmlDocGetRootElement(document), (const xmlChar *)XINCLUDE_NS, (const xmlChar *)"xi");
        _SdefSetIncludeNamespace(xmlDocGetRootElement(document), ns);
      }
      
      /* process xincludes */
      if (xmlXIncludeProcessFlags(document, flags) < 0) {
        spx_log("#WARNING xinclude processing failed.");
      }
      
      result = [self parseFragment:xmlDocGetRootElement(document) parent:nil base:baseURL];
      sd_version = SdefDocumentVersionFromParserVersion([sd_validator version]);
      if (document) xmlFreeDoc(document);
      sd_validator = nil;
    } else if (outError) {
      xmlErrorPtr error = xmlGetLastError();
      if (error) {
        *outError = [NSError errorWithDomain:NSXMLParserErrorDomain code:error->code userInfo:nil];
      } else {
        *outError = nil;
      }
    }
    
    if ([sd_roots count] > 0) {
      if (sd_version <= kSdefPantherVersion) {
        _SdefParserUpdatePantherObjects(sd_roots);
      } else {
        _SdefParserPostProcessObjects(sd_roots, sd_version);
      }
    }
  }
  return result;
}

- (BOOL)parseContentsOfURL:(NSURL *)anURL error:(NSError * __autoreleasing *)outError {
  return [self parseData:nil base:anURL error:outError];
}

#pragma mark -
- (void)parser:(SdefDOMParser *)parser handleComment:(const xmlChar *)aComment {
  NSString *cmt = [NSString stringWithCString:(const char *)aComment encoding:[parser encoding]];
  if (!cmt)
    return;

  if ([cmt hasPrefix:@" @"]) {
    NSRange start = [cmt rangeOfString:@"("];
    NSRange end = [cmt rangeOfString:@")" options:NSBackwardsSearch];
    if (start.location != NSNotFound && end.location != NSNotFound && (start.location + start.length) < end.location) {
      NSString *key = NULL, *value = NULL;
      key = [cmt substringWithRange:NSMakeRange(2, start.location - 2)];
      start.location += start.length;
      value = [cmt substringWithRange:NSMakeRange(start.location, end.location - start.location)];
      if (key && value)
        sd_metas[key] = value;
      return;
    }
  }
  /* else */
  [sd_comments addObject:cmt];
}

- (SdefXMLStructure)parser:(SdefDOMParser *)parser createStructureForElement:(xmlNodePtr)element {
  NSString *error = nil;
  id<SdefXMLObject> object = nil;
  
  NSString *name = [NSString stringWithCString:(const char *)element->name encoding:[parser encoding]];
  NSDictionary *attrs = _SdefXMLCreateDictionaryWithAttributes(element->properties, [parser encoding]);
  SdefValidatorResult result = [sd_validator validateElement:name attributes:attrs error:&error];
  /* include should not be append to the validator stack */
  if (![name isEqualToString:@"include"])
    [sd_validator startElement:name];

  if (kSdefParserVersionUnknown == (result & kSdefValidatorVersionMask)) {
    BOOL skipObject = YES;
    NSString *reason = [NSString stringWithFormat:@"Parser validation error line %ld: %@ (%@, %@)", 
      (long)[parser line], error, name, attrs];
    NSDictionary *info = @{ NSUnderlyingErrorKey : error,
                            NSLocalizedDescriptionKey : reason };
    NSError *anError = [NSError errorWithDomain:NSXMLParserErrorDomain code:NSXMLParserInternalError userInfo:info];
    if ([sd_delegate sdefParser:self shouldIgnoreValidationError:anError isFatal:NO]) {
      /* check if this is an attribute error or an element error */
      switch (result & kSdefValidatorErrorMask) {
        case kSdefValidatorAttributeError:
          skipObject = false;
          break;
        case kSdefValidatorElementError:
        default:
          object = [[SdefInvalidElementPlaceholder alloc] initWithElementName:(id)name];
          break;
      }
    } else {
      [parser abortWithError:kSdefValidationErrorStatus reason:@""];
    }
    if (skipObject)
      return object;
  }
  
  Class class = _SdefGetObjectClassForElement(name);
  if (class) {
    object = [[class alloc] init];
  } else if ([name isEqualToString:@"class-extension"]) {
    object = [[SdefClass alloc] init];
    [(SdefClass *)object setExtension:YES];
  } else if ([name isEqualToString:@"event"]) {
    object = [[SdefVerb alloc] init];
    [(SdefVerb *)object setCommand:NO];
  } else if (_SdefElementIsCollection(name)) {
    object = [[SdefCollectionPlaceholder alloc] initWithElementName:name];
  }
  
  if (object) {
    if (attrs && attrs.count > 0)
      [object setXMLAttributes:attrs];
  }
  return object;
}

#pragma mark Parser Core
- (SdefXMLStructure)parser:(SdefDOMParser *)parser createStructureForNode:(xmlNodePtr)node {
  SdefXMLStructure structure = nil;
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
          spx_debug("Encounter processing instruction: %s", node->name);
          break;
        case XML_COMMENT_NODE:
          [self parser:parser handleComment:node->content];
          break;
        case XML_TEXT_NODE:
          /* probably white-space: skip it */
          //spx_debug("Data Type ID: kCFXMLNodeTypeText (%s)", node->content);
          break;
        case XML_CDATA_SECTION_NODE:
          spx_debug("Data Type ID: kCFXMLDataTypeCDATASection (%s)", node->content);
          break;
        case XML_ENTITY_REF_NODE:
          spx_debug("Data Type ID: kCFXMLNodeTypeEntityReference (%s)", node->name);
          break;
        case XML_DTD_NODE:
        case XML_DOCUMENT_TYPE_NODE:
          spx_debug("Data Type ID: kCFXMLNodeTypeDocumentType (%s)", node->name);
          break;
        case XML_XINCLUDE_START:
          spx_debug("******* Start xinclude *******");
          structure = [self parser:parser createStructureForElement:node];
          [sd_xincludes addObject:structure];
          break;
        case XML_XINCLUDE_END:
          spx_debug("******* End xinclude *******");
          [sd_xincludes removeLastObject];
          break;
//        case kCFXMLNodeTypeWhitespace:
//          /* Ignore white space */
//          break;
        default:
          spx_debug("Unknown Data Type ID: %ld (%s)", (long)node->type, node->name);
          break;
      }
    }
  } @catch (id exception) {
    spx_log_exception(exception);
    [parser abortWithError:kCFXMLErrorMalformedDocument reason:[exception reason]];
  }
  return structure;
}

- (void)sd_addCommentsToObject:(id<SdefXMLObject>)object {
  if ([sd_comments count]) {
    if (object) {
      for (NSString *comment in sd_comments) {
        /* parse meta */
        [object addXMLComment:comment];
      }
    }
    [sd_comments removeAllObjects];
  }
  if (sd_metas && sd_metas.count > 0) {
    [object setXMLMetas:sd_metas];
    [sd_metas removeAllObjects];
  }
}

- (void)parser:(SdefDOMParser *)parser addChild:(SdefXMLStructure)aChild toStructure:(SdefXMLStructure)aStruct {
  if (sd_docParser) {
    [sd_docParser parser:parser addChild:aChild toStructure:aStruct];
  } else {
    id<SdefXMLObject> child = (id)aChild;
    id<SdefXMLObject> parent = (id)aStruct;
    //  spx_debug("=========== %@ -> %@", parent, child);
    OSType type = [child objectType];
    if (typeWildCard == type) {
      [(id)child setObject:parent];
    } else if (kSdefTypeAccessor == type) {
      [(id)parent addXMLAccessor:[(SdefAccessorPlaceholder *)child style]];
    } else if (kSdefTypeIgnore == type) {
      // invalid object. skip
    } else {
      /* Handle xinclude */
      if ([sd_xincludes count] > 0) {
        child.imported = YES;
        SdefXInclude *include = [sd_xincludes lastObject];
        if ((id)[include owner] == parent) {
          spx_debug("add include root: %@", child);
        } 
      }
      
      if (parent) {
        [(id)parent addXMLChild:(id)child];
      } else {
        if (!sd_roots) sd_roots = [[NSMutableArray alloc] init];
        [sd_roots addObject:child];
      }
      
      /* Handle comments */
      [self sd_addCommentsToObject:child];
      
      /* Check documentation element */
      if (kSdefType_Documentation == type) {
        sd_docParser = [[SdefDocumentationParser alloc] initWithDocumentation:(id)child];
      }
    }
  }
}

- (void)parser:(SdefDOMParser *)parser endStructure:(SdefXMLStructure)structure {
  if (sd_docParser) {
    if ([structure isKindOfClass:[SdefDocumentation class]]) {
      [sd_docParser close];
      sd_docParser = nil; 
      
      [sd_validator endElement:@"documentation"];
    } else {
      [sd_docParser parser:parser endStructure:structure];
    }
  } else if (![[structure xmlElementName] isEqualToString:@"xi:include"]) {
    /* handle special case where class become class extension */
    if ([[sd_validator element] isEqualToString:@"class"] &&
        [[structure xmlElementName] isEqualToString:@"class-extension"])
      [sd_validator endElement:@"class"];
    else 
      [sd_validator endElement:[structure xmlElementName]];
    
    /* Handle comments */
    [self sd_addCommentsToObject:structure];
  }
}

@end

#pragma mark -
#pragma mark Panther Support
#pragma mark Misc
/* Convert old base types */
WB_INLINE
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

WB_INLINE
void __SdefParserPostProcessClass(SdefClass *cls) {
  SdefRespondsTo *cmd;
  NSEnumerator *cmds = [[cls commands] childEnumerator];
  while (cmd = [cmds nextObject]) {
    if ([[cmd classManager] eventWithIdentifier:[cmd name]]) {
      [cmd remove]; // FIXME: check if this does not release cmd
      [[cls events] appendChild:cmd];
    }
  }
}

/* post process */
WB_INLINE
void __SdefParserPostProcessObject(SdefObject *object, SdefVersion version) {
  switch ([object objectType]) {
    case kSdefType_Dictionary:
      [(SdefDictionary *)object setVersion:version];
      break;
    case kSdefType_Suite: {
      SdefClass *class;
      NSEnumerator *classes = [[(SdefSuite *)object classes] childEnumerator];
      while (class = [classes nextObject]) {
        __SdefParserPostProcessClass(class);
      }
    }
      break;
    case kSdefType_Class:
      __SdefParserPostProcessClass((SdefClass *)object);
      break;
    default:
      break;
  }
}

static
void _SdefParserPostProcessObjects(NSArray *roots, SdefVersion version) {
  for (NSUInteger idx = 0; idx < [roots count]; idx++) {
    id child;
    SdefObject *root = [roots objectAtIndex:idx];
    __SdefParserPostProcessObject(root, version);
    NSEnumerator *children = [root deepChildEnumerator];
    while (child = [children nextObject]) {
      __SdefParserPostProcessObject(child, version);
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
    sd_name = name;
  }
  return self;
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

- (BOOL)isImported { return NO; }
- (void)setImported:(BOOL)flag {}

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

- (NSString *)style {
  return sd_style;
}

- (void)setXMLAttributes:(NSDictionary *)attrs { 
  sd_style = [attrs objectForKey:@"style"];
}

@end

@implementation SdefInvalidElementPlaceholder

+ (SdefObjectType)objectType {
  return kSdefTypeIgnore;
}

- (void)addXMLChild:(NSObject<SdefObject> *)node { 
  spx_debug("Ignore add '%@' to invalid element '%@'.",
       [node respondsToSelector:@selector(xmlElementName)] ? [(id)node xmlElementName] : [node name],
       [self xmlElementName]);
}

@end
