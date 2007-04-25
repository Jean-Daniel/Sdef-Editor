/*
 *  SdefParser.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefParser.h"
#import "SdefXMLBase.h"
#import "SdefXMLValidator.h"
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

#import <ShadowKit/SKCFContext.h>

static void *SdefParserCreateStructure(CFXMLParserRef parser, CFXMLNodeRef node, void *info);
static void SdefParserAddChild(CFXMLParserRef parser, void *parent, void *child, void *info);
static void SdefParserEndStructure(CFXMLParserRef parser, void *xmlType, void *info);
static CFDataRef SdefParserResolveExternalEntity(CFXMLParserRef parser, CFXMLExternalID *extID, void *info);
static Boolean SdefParserHandleError(CFXMLParserRef parser, CFXMLParserStatusCode error, void *info);

static 
void _SdefParserUpdatePantherDictionary(SdefDictionary *dictionary);
static
void _SdefParserPostProcessDictionary(SdefDictionary *dictionary);

enum {
  kSdefValidationErrorStatus = 'VErr',
};

static
CFXMLParserCallBacks SdefParserCallBacks = {
  0,
  SdefParserCreateStructure,
  SdefParserAddChild,
  SdefParserEndStructure,
  SdefParserResolveExternalEntity,
  SdefParserHandleError
};

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
  }
}

#pragma mark -
- (id)init {
  if (self = [super init]) {
    sd_comments = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [sd_comments release];
  [sd_validator release];
  [sd_docParser release];
  [sd_dictionary release];  
  [super dealloc];
}

#pragma mark -
- (NSInteger)line {
  return sd_parser ? CFXMLParserGetLineNumber(sd_parser) : -1;
}
- (NSInteger)location {
  return sd_parser ? CFXMLParserGetLocation(sd_parser) : -1;
}

- (SdefVersion)sdefVersion {
  return sd_version;
}
- (SdefDictionary *)dictionary {
  return sd_dictionary;
}

- (id)delegate {
  return sd_delegate;
}
- (void)setDelegate:(id)delegate {
  NSParameterAssert(!delegate || [delegate respondsToSelector:@selector(sdefParser:handleValidationError:isFatal:)]);
  sd_delegate = delegate;
}

- (BOOL)parseSdef:(NSData *)sdefData  {
  BOOL result = NO;
  if (sd_dictionary) {
    [sd_dictionary release];
    sd_dictionary = nil;
  }
  if (sdefData) {
    [sd_comments removeAllObjects];
    CFXMLParserContext ctxt = { 0, self, nil, nil, SKCBNSObjectCopyDescription };
    sd_parser = CFXMLParserCreate(kCFAllocatorDefault, (CFDataRef)sdefData, NULL,
                                  kCFXMLParserNoOptions, kCFXMLNodeCurrentVersion,
                                  &SdefParserCallBacks, &ctxt);
    if (sd_parser) {
      sd_validator = [[SdefXMLValidator alloc] init];
      result = CFXMLParserParse(sd_parser);
      sd_version = SdefDocumentVersionFromParserVersion([sd_validator version]);
      [sd_validator release];
      CFRelease(sd_parser);
      sd_validator = nil;
      sd_parser = nil;
    }
    if (sd_dictionary) {
      if (sd_version <= kSdefPantherVersion)
        _SdefParserUpdatePantherDictionary(sd_dictionary);
      else 
        _SdefParserPostProcessDictionary(sd_dictionary);
    }
  }
  return result;
}

#pragma mark -
- (void)parser:(CFXMLParserRef)parser handleComment:(CFStringRef)comment {
  NSString *str = [[NSString alloc] initWithString:(id)comment];
  if (str) {
    [sd_comments addObject:str];
    [str release];
  }
}

- (id)parser:(CFXMLParserRef)parser createStructureForElement:(CFStringRef)element infos:(CFXMLElementInfo *)infos {
  NSString *error = nil;
  SdefParserVersion version = [sd_validator validateElement:element attributes:infos->attributes error:&error];
  [sd_validator startElement:element];
  
  if (kSdefParserVersionUnknown == version) {
    NSString *str = [NSString stringWithFormat:@"Parser validation error line %ld: %@ (%@, %@)", (long)CFXMLParserGetLineNumber(parser),
      error, element, infos->attributes];
    if ([sd_delegate sdefParser:self handleValidationError:str isFatal:NO])
      return [[SdefInvalidElementPlaceholder alloc] initWithElementName:(id)element];
    else
      CFXMLParserAbort(parser, kSdefValidationErrorStatus, CFSTR(""));
  }
  
  id<SdefXMLObject> object = nil;
  Class class = _SdefGetObjectClassForElement(element);
  if (class) {
    object = [[class alloc] init];
  } else if (CFEqual(CFSTR("class-extension"), element)) {
    object = [[SdefClass alloc] init];
    [(SdefClass *)object setExtension:YES];
  } else if (CFEqual(CFSTR("event"), element)) {
    object = [[SdefVerb alloc] init];
    [(SdefVerb *)object setCommand:NO];
  } else if (_SdefElementIsCollection(element)) {
    object = [[SdefCollectionPlaceholder alloc] initWithElementName:(id)element];
  }
  
  if (object) {
    if (infos->attributes && CFDictionaryGetCount(infos->attributes) > 0)
      [object setXMLAttributes:(id)infos->attributes];
  }
  return object;
}

#pragma mark Parser Core
- (void *)parser:(CFXMLParserRef)parser createStructureForNode:(CFXMLNodeRef)node {
  void *structure = NULL;
  @try {
    if (sd_docParser) {
      structure = [sd_docParser parser:parser createStructureForNode:node];
    } else {
      switch (CFXMLNodeGetTypeCode(node)) {
        case kCFXMLNodeTypeElement:
          structure = [self parser:parser createStructureForElement:CFXMLNodeGetString(node) infos:(CFXMLElementInfo *)CFXMLNodeGetInfoPtr(node)];
          break;
        case kCFXMLNodeTypeDocument:
          /* Ignore document info */
          break;
        case kCFXMLNodeTypeProcessingInstruction:
          DLog(@"Encounter processing instruction: %@", CFXMLNodeGetString(node));
          break;
        case kCFXMLNodeTypeComment:
          [self parser:parser handleComment:CFXMLNodeGetString(node)];
          break;
        case kCFXMLNodeTypeText:
          DLog(@"Data Type ID: kCFXMLNodeTypeText (%@)", CFXMLNodeGetString(node));
          break;
        case kCFXMLNodeTypeCDATASection:
          DLog(@"Data Type ID: kCFXMLDataTypeCDATASection (%@)", CFXMLNodeGetString(node));
          break;
        case kCFXMLNodeTypeEntityReference:
          DLog(@"Data Type ID: kCFXMLNodeTypeEntityReference (%@)", CFXMLNodeGetString(node));
          break;
        case kCFXMLNodeTypeDocumentType:
          DLog(@"Data Type ID: kCFXMLNodeTypeDocumentType (%@)", CFXMLNodeGetString(node));
          break;
        case kCFXMLNodeTypeWhitespace:
          /* Ignore white space */
          break;
        default:
          DLog(@"Unknown Data Type ID: %ld (%@)", (long)CFXMLNodeGetTypeCode(node), CFXMLNodeGetString(node));
          break;
      }
    }
  } @catch (id exception) {
    SKLogException(exception);
    CFXMLParserAbort(parser, kCFXMLErrorMalformedDocument, (CFStringRef)[exception reason]);
  }
  return structure;
}

- (void)parser:(CFXMLParserRef)parser addChild:(void *)aChild toStructure:(void *)aStruct {
  if (sd_docParser) {
    [sd_docParser parser:parser addChild:aChild toStructure:aStruct];
  } else {
    id<SdefObject> child = (id)aChild;
    id<SdefXMLObject> parent = (id)aStruct;
    //  DLog(@"=========== %@ -> %@", parent, child);
    if (typeWildCard == [child objectType]) {
      [(id)child setObject:parent];
    } else if (kSdefTypeAccessor == [child objectType]) {
      [(id)parent addXMLAccessor:(NSString *)[(id)child style]];
    } else if (kSdefTypeIgnore == [child objectType]) {
      // invalid object. skip
    } else {
      if (parent)
        [(id)parent addXMLChild:(id)child];
      else
        sd_dictionary = [(SdefDictionary *)child retain];
      
      /* Handle comments */
      if ([sd_comments count]) {
        SdefObject *commented = nil;
        if ([(id)child respondsToSelector:@selector(addComment:)]) commented = (id)child;
        else if ([(id)parent respondsToSelector:@selector(addComment:)]) commented = (id)parent;
        if (commented) {
          for (NSUInteger i = 0; i < [sd_comments count]; i++) {
            [commented addComment:[sd_comments objectAtIndex:i]];
          }
        }
        [sd_comments removeAllObjects];
      }
      
      /* Check documentation element */
      if (kSdefDocumentationType == [child objectType]) {
        sd_docParser = [[SdefDocumentationParser alloc] initWithDocumentation:(id)child];
      }
    }
  }
}

- (void)parser:(CFXMLParserRef)parser endStructure:(void *)structure {
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
    [sd_validator endElement:(CFStringRef)[(id)structure xmlElementName]]; 
    
    /* Handle comments */
    if ([sd_comments count]) {
      SdefObject *commented = nil;
      if ([(id)structure respondsToSelector:@selector(addComment:)]) commented = (id)structure;
      if (commented) {
        for (NSUInteger i = 0; i < [sd_comments count]; i++) {
          [commented addComment:[sd_comments objectAtIndex:i]];
        }
      }
      [sd_comments removeAllObjects];
    }
    
    [(id)structure release];
  }
}

- (Boolean)parser:(CFXMLParserRef)parser handleError:(CFXMLParserStatusCode)error {
  if (kSdefValidationErrorStatus == error)
    return false;
  
  CFIndex line = [self line];
  CFIndex position = CFXMLParserGetLocation(sd_parser);
  CFStringRef description = CFXMLParserCopyErrorDescription(parser);
  NSString *str = [NSString stringWithFormat:@"line %ld, position: %ld:\n %@", (long)line, (long)position, description];
  if (description) CFRelease(description);
  return [sd_delegate sdefParser:self handleValidationError:str isFatal:YES];
}

@end

#pragma mark -
#pragma mark Core Foundation Parser
void *SdefParserCreateStructure(CFXMLParserRef parser, CFXMLNodeRef node, void *info) {
  SdefParser *delegate = info;
  return [delegate parser:parser createStructureForNode:node];
}

void SdefParserAddChild(CFXMLParserRef parser, void *parent, void *child, void *info) {
  SdefParser *delegate = info;
  return [delegate parser:parser addChild:child toStructure:parent];
}

void SdefParserEndStructure(CFXMLParserRef parser, void *node, void *info) {
  SdefParser *delegate = info;
  [delegate parser:parser endStructure:node];
}

CFDataRef SdefParserResolveExternalEntity(CFXMLParserRef parser, CFXMLExternalID *extID, void *info) {
  ShadowCTrace();
  return NULL;
}
/* if handleError returns true, the parser will attempt to recover */
Boolean SdefParserHandleError(CFXMLParserRef parser, CFXMLParserStatusCode error, void *info) {
  SdefParser *delegate = info;
  return [delegate parser:parser handleError:error];
}

#pragma mark -
#pragma mark Panther Support
#pragma mark Misc
/* Convert old base types */
static
void _SdefParserUpdatePantherDictionary(SdefDictionary *dictionary) {
  id child;
  NSEnumerator *children = [dictionary deepChildEnumerator];
  while (child = [children nextObject]) {
    if ([child isKindOfClass:[SdefTypedObject class]]) {
      NSArray *types = [child types];
      for (NSUInteger idx=0; idx<[types count]; idx++) {
        SdefType *type = [types objectAtIndex:idx];
        if ([[type name] isEqualToString:@"string"]) {
          [type setName:@"text"];
        } else if ([[type name] isEqualToString:@"object"]) {
          [type setName:@"specifier"];
        } else if ([[type name] isEqualToString:@"location"]) {
          [type setName:@"location specifier"];
        }
      }
    } else if ([child isKindOfClass:[SdefProperty class]] || 
               [child isKindOfClass:[SdefElement class]]) {
      /* Change property and element cocoa attribute */
      NSString *method = [[child impl] method];
      if (method) {
        [[child impl] setKey:method];
        [[child impl] setMethod:nil];
      }
    }
  }
}

static
void _SdefParserPostProcessDictionary(SdefDictionary *dictionary) {
  SdefSuite *suite;
  NSEnumerator *suites = [dictionary childEnumerator];
  while (suite = [suites nextObject]) {
    SdefClass *class;
    NSEnumerator *classes = [[suite classes] childEnumerator];
    while (class = [classes nextObject]) {
      SdefRespondsTo *cmd;
      NSEnumerator *cmds = [[class commands] childEnumerator];
      while (cmd = [cmds nextObject]) {
        if ([[cmd classManager] eventWithName:[cmd name]]) {
          [cmd retain];
          [cmd remove];
          [[class events] appendChild:cmd];
          [cmd release];
        }
      }
    }
  }
}

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
- (void)setXMLAttributes:(NSDictionary *)attrs { 
  // does not support attributes.
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

- (void) dealloc {
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
