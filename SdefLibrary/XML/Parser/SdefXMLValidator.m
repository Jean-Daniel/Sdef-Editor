/*
 *  SdefXMLValidator.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLValidator.h"

@interface SdefXMLElement : NSObject {
  CFSetRef _elements;
  CFSetRef _attributes;
}

- (id)initWithElements:(CFStringRef *)attribute count:(NSUInteger)cnt;

/* Return Leopard if attributes contains 'id' */
/* Return Leopard if element contains 'xref' */
- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value;
- (SdefValidatorVersion)acceptElement:(CFStringRef)element;

- (instancetype)ATTLIST:(NSString *)attribute, ... SPX_REQUIRES_NIL_TERMINATION;

@end

@interface SdefXMLClass : SdefXMLElement {
}
@end

@interface SdefXMLCocoa : SdefXMLElement {
}
@end

@interface SdefXMLEnumeration : SdefXMLElement {
}
@end

@interface SdefXMLProperty : SdefXMLElement {
}
@end

@interface SdefXMLRespondsTo : SdefXMLElement {
}
@end

@interface SdefXMLSuite : SdefXMLElement {
}
@end

@implementation SdefXMLValidator

static 
CFMutableDictionaryRef sValidators = NULL;

static inline SPX_REQUIRES_NIL_TERMINATION
SdefXMLElement *_Element(Class cls, NSString *name, ...) {
  NSInteger idx = -1;
  CFStringRef items[32];

  va_list ap;
  va_start(ap, name);
  do {
    idx++;
    assert(idx < 32);
    items[idx] = va_arg(ap, CFStringRef);
  } while (items[idx]);
  va_end(ap);

  SdefXMLElement *elt = [[cls alloc] initWithElements:items count:idx];
  CFDictionarySetValue(sValidators, SPXNSToCFString(name), elt);
  [elt release];

  return elt;
}

#define EMPTY nil
#define ELEMENT(name, cls, ...) _Element([cls class], name, ##__VA_ARGS__)

+ (void)initialize {
  if ([SdefXMLValidator class] == self) {
    sValidators = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, 
                                            &kCFCopyStringDictionaryKeyCallBacks,
                                            &kCFTypeDictionaryValueCallBacks);

    /* xinclude: base on W3C Working Draft 10 November 2003 */
    [ELEMENT(@"include", SdefXMLElement, EMPTY)
     ATTLIST:@"href", @"parse", @"xpointer", @"encoding",
     @"accept", @"accept-charset", @"accept-language", nil];
    
    /* root */
    ELEMENT(@"__sdef__", SdefXMLElement, @"dictionary", nil);
    
    // In the order they are declared in the DTD (for convenience)
    
    /* dictionary */
    [ELEMENT(@"dictionary", SdefXMLElement, @"documentation", @"suite", nil)
     ATTLIST:@"title", nil];
    
    /* xref */
    [ELEMENT(@"xref", SdefXMLElement, EMPTY)
     ATTLIST:@"target", @"hidden", nil];
    
    /* access-group */
    [ELEMENT(@"access-group", SdefXMLElement, EMPTY)
     ATTLIST:@"identifier", @"access", nil];
    
    /* cocoa (custom) */
    [ELEMENT(@"cocoa", SdefXMLCocoa, EMPTY)
     ATTLIST:@"class", @"key", @"method", @"name", nil];
    // insert-at-beginning, boolean-value, integer-value, string-value
    
    /* suite (custom) */
    [ELEMENT(@"suite", SdefXMLSuite, @"cocoa", @"access-group", @"documentation", nil)
     // class | class-extension | command | enumeration | event | record-type | value-type
     ATTLIST:@"name", @"code", @"description", @"hidden", nil];
    
    /* synonym */
    [ELEMENT(@"synonym", SdefXMLElement, @"cocoa", nil)
     ATTLIST:@"name", @"code", @"hidden", nil];
    
    /* type */
    [ELEMENT(@"type", SdefXMLElement, EMPTY)
     ATTLIST:@"type", @"list", @"hidden", nil];
    
    /* command/event */
    SdefXMLElement *cmd =
    [ELEMENT(@"command", SdefXMLElement,
             @"cocoa", @"access-group", @"synonym",
             @"direct-parameter", @"parameter", @"result",
             @"documentation", @"xref", nil)
     ATTLIST:@"name", @"id", @"code", @"description", @"hidden", nil];
    // Ditto for event
    CFDictionarySetValue(sValidators, CFSTR("event"), cmd);
    
    /* direct-parameter */
    [ELEMENT(@"direct-parameter", SdefXMLElement, @"type", nil)
     ATTLIST:@"type", @"optional", @"requires-access", @"description", nil];
    
    /* result */
    [ELEMENT(@"result", SdefXMLElement, @"type", nil)
     ATTLIST:@"type", @"description", nil];
    
    /* parameter (+synonym) */
    [ELEMENT(@"parameter", SdefXMLElement, @"cocoa", @"type", nil) // should we support @"synonym". It is not in the DTD ?
     ATTLIST:@"name", @"code", @"hidden", @"type", @"optional", @"requires-access", @"description", nil];
    
    /* class (custom) */
    [ELEMENT(@"class", SdefXMLClass, @"cocoa", @"access-group", @"contents", @"documentation", @"synonym", @"xref", nil)
     // 10.4: element, property, responds-to
     ATTLIST:@"name", @"id", @"code", @"hidden", @"plural", @"inherits", @"description", nil];
    
    /* contents */
    [ELEMENT(@"contents", SdefXMLElement, @"cocoa", @"access-group", @"type", nil)
     ATTLIST:@"name", @"code", @"type", @"access", @"hidden", @"description", nil];
    
    /* element */
    [ELEMENT(@"element", SdefXMLElement, @"cocoa", @"access-group", @"accessor", nil)
     ATTLIST:@"type", @"access", @"hidden", @"description", nil];
    
    /* accessor */
    [ELEMENT(@"accessor", SdefXMLElement, EMPTY)
     ATTLIST:@"style", nil];
    
    /* property (custom) */
    [ELEMENT(@"property", SdefXMLProperty, @"cocoa", @"access-group", @"type", @"synonym", @"documentation", nil)
     ATTLIST:@"name", @"code", @"hidden", @"type", @"access", @"description",  nil];
    // 10.4: not-in-properties
    // 10.5: in-properties
    
    /* responds-to (custom) */
    [ELEMENT(@"responds-to", SdefXMLRespondsTo, @"cocoa", @"access-group", nil)
     ATTLIST:@"hidden", nil];
    // 10.4: name
    // 10.5: command
    
    /* class-extension (+id) */
    [ELEMENT(@"class-extension", SdefXMLElement, @"cocoa", @"access-group",
             @"contents", @"documentation", @"element", @"property", @"responds-to",
             @"synonym", @"xref", @"type" /* not in DTD */, nil)
     ATTLIST:@"id", @"extends", @"hidden", @"description", nil];
    
    /* value-type (+id) */
    [ELEMENT(@"value-type", SdefXMLElement, @"cocoa", @"synonym", @"documentation", @"xref", nil)
     ATTLIST:@"name", @"id", @"code", @"hidden", @"plural", @"description", nil];
    
    /* record-type (+id) */
    [ELEMENT(@"record-type", SdefXMLElement, @"cocoa", @"synonym", @"documentation", @"property", @"xref", nil)
     ATTLIST:@"name", @"id", @"code", @"hidden", @"plural", @"description", nil];

    /* enumeration (custom, +synonym) */
    [ELEMENT(@"enumeration", SdefXMLEnumeration, @"cocoa", @"documentation", @"enumerator", @"xref", nil) // @"synonym"
     ATTLIST:@"name", @"id", @"code", @"hidden", @"description", nil];
    // 10.4: inline
    
    /* enumerator */
    [ELEMENT(@"enumerator", SdefXMLElement, @"cocoa", @"synonym", @"documentation", nil)
     ATTLIST:@"name", @"code", @"hidden", @"description", nil];
    
    /* ~~~~~~~~~~~~~~ Panther collections ~~~~~~~~~~~~~~ */
    ELEMENT(@"types", SdefXMLElement, @"enumeration", nil);
    ELEMENT(@"synonyms", SdefXMLElement, @"synonym", nil);
    
    /* Class */
    ELEMENT(@"classes", SdefXMLElement, @"class", nil);
    ELEMENT(@"elements", SdefXMLElement, @"element", nil);
    ELEMENT(@"properties", SdefXMLElement, @"property", nil);
    ELEMENT(@"responds-to-commands", SdefXMLElement, @"responds-to", nil);
    ELEMENT(@"responds-to-events", SdefXMLElement, @"responds-to", nil);
    
    /* Verbs */
    ELEMENT(@"commands", SdefXMLElement, @"command", nil);
    ELEMENT(@"events", SdefXMLElement, @"event", nil);
  }
}

- (id)init {
  if (self = [super init]) {
    sd_version = kSdefParserVersionAll;
    sd_stack = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
  }
  return self;
}

- (void)dealloc {
  if (sd_stack) CFRelease(sd_stack);
  [super dealloc];
}

- (SdefValidatorVersion)version {
  return sd_version;
}

- (CFStringRef)element {
  CFIndex count = CFArrayGetCount(sd_stack);
  if (count <= 0) return NULL;
  return CFArrayGetValueAtIndex(sd_stack, count - 1);
}

- (void)startElement:(CFStringRef)element {
  CFArrayAppendValue(sd_stack, element);
}

- (void)endElement:(CFStringRef)element {
  CFStringRef last = [self element];
  if (!last || !CFEqual(element, last)) {
    spx_log_warning("Invalid validator stack state");
  }
  if (last)
    CFArrayRemoveValueAtIndex(sd_stack, CFArrayGetCount(sd_stack) - 1);
}

- (NSString *)invalidAttribute:(NSString *)attribute inElement:(NSString *)element {
  return [NSString stringWithFormat:@"unexpected attribute '%@' found in element '%@'", attribute, element];
}

- (NSString *)invalidAttribute:(CFStringRef)attribute inElement:(CFStringRef)element forVersion:(SdefValidatorVersion)version {
  NSString *os = @"unknown";
  switch (version) {
    case kSdefParserVersionTiger:
      os = @"Tiger";
      break;
    case kSdefParserVersionPanther:
      os = @"Panther";
      break;
    case kSdefParserVersionLeopard:
      os = @"Leopard";
      break;
    case kSdefParserVersionMountainLion:
      os = @"Moutain Lion";
      break;
  }
  return [NSString stringWithFormat:@"unexpected attribute '%@' found in element '%@' for %@ sdef format.", attribute, element, os];
}

- (NSString *)invalidElementError:(CFStringRef)element {
  if (![self element]) {
    return [NSString stringWithFormat:@"unexpected root element %@", element];
  } else {
    return [NSString stringWithFormat:@"unexpected element '%@' found in element '%@'", element, [self element]];
  }
}

- (SdefValidatorVersion)checkAttributes:(CFDictionaryRef)attributes forElement:(CFStringRef)element error:(NSString **)error {
  SdefValidatorVersion version = sd_version;
  if (attributes && CFDictionaryGetCount(attributes) > 0) {
    SdefXMLElement *validator = (id)CFDictionaryGetValue(sValidators, element);
    if (validator) {
      for (NSString *attr in SPXCFToNSDictionary(attributes)) {
        version &= [validator acceptAttribute:(CFStringRef)attr value:CFDictionaryGetValue(attributes, attr)];
        if (kSdefParserVersionUnknown == version) {
          if (error) *error = [self invalidAttribute:attr inElement:(id)element];
          break;
        }
      }
    }
  }
  return version;
}

- (SdefValidatorResult)validateElement:(CFStringRef)element attributes:(CFDictionaryRef)attributes error:(NSString **)error {
  if (error) *error = nil;
  SdefXMLElement *validator;
  if ([self element]) {
    validator = (id)CFDictionaryGetValue(sValidators, [self element]);
  } else {
    validator = (id)CFDictionaryGetValue(sValidators, CFSTR("__sdef__"));
  }
  if (validator) {
    SdefValidatorVersion version = [validator acceptElement:element];
    if ((version & sd_version) == 0) {
      if (error) *error = [self invalidElementError:element];
      return kSdefParserVersionUnknown | kSdefValidatorElementError;
    } else {
      sd_version &= version;
      version = [self checkAttributes:attributes forElement:element error:error];
      if ((version & sd_version) == 0) {
        return kSdefParserVersionUnknown | kSdefValidatorAttributeError;
      } else {
        sd_version &= version;
      }
    }
  } else {
    sd_version = kSdefParserVersionUnknown;
    SPXDebug(@"Invalid validator for element '%@' !", [self element]);
  }

  return sd_version;
}

@end

#pragma mark -
@implementation SdefXMLElement

- (id)initWithElements:(CFStringRef *)elements count:(NSUInteger)cnt {
  if (self = [super init]) {
    if (cnt > 0)
      _elements = CFSetCreate(kCFAllocatorDefault, (const void **)elements, cnt, &kCFTypeSetCallBacks);
  }
  return self;
}

- (instancetype)ATTLIST:(NSString *)name, ... {
  CFStringRef items[32];
  items[0] = SPXNSToCFString(name);
  
  va_list ap;
  CFIndex idx = 0;
  va_start(ap, name);
  do {
    idx++;
    assert(idx < 32);
    items[idx] = va_arg(ap, CFStringRef);
  } while (items[idx]);
  va_end(ap);
  
  _attributes = CFSetCreate(kCFAllocatorDefault, (const void **)items, idx, &kCFTypeSetCallBacks);
  return self;
}

- (void)dealloc {
  SPXCFRelease(_attributes);
  SPXCFRelease(_elements);
  [super dealloc];
}

- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value {
  if (_attributes && CFSetContainsValue(_attributes, attribute)) {
    if (CFEqual(attribute, CFSTR("requires-access"))) {
      return kSdefParserVersionMountainLionAndLater;
    }
    return CFEqual(attribute, CFSTR("id")) ? kSdefParserVersionLeopardAndLater : kSdefParserVersionAll;
  }
  return kSdefParserVersionUnknown;
}
- (SdefValidatorVersion)acceptElement:(CFStringRef)element {
  if (_elements) {
    if (CFSetContainsValue(_elements, element)) {
      if (CFEqual(element, CFSTR("type"))) {
        /* type element is for Tiger and above */
        return kSdefParserVersionTigerAndLater;
      } else if (CFEqual(element, CFSTR("xref")) || CFEqual(element, CFSTR("include"))) {
        return kSdefParserVersionLeopardAndLater;
      } else if (CFEqual(element, CFSTR("access-group"))) {
        return kSdefParserVersionMountainLionAndLater;
      } else {
        return kSdefParserVersionAll;
      }
    } else if (CFEqual(element, CFSTR("synonyms")) && CFSetContainsValue(_elements, CFSTR("synonym"))) {
      /* special synonyms case */ 
      return kSdefParserVersionPanther;
    }
  }
  if (CFEqual(element, CFSTR("include")))
    return kSdefParserVersionLeopardAndLater;

  return kSdefParserVersionUnknown;
}

@end

#pragma mark -
@implementation SdefXMLCocoa

- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value {
  /* type-values appear in Leopard */
  if (CFEqual(attribute, CFSTR("boolean-value")) || 
      CFEqual(attribute, CFSTR("integer-value")) ||
      CFEqual(attribute, CFSTR("string-value")) ||
      CFEqual(attribute, CFSTR("insert-at-beginning"))) {
    return kSdefParserVersionLeopardAndLater;
  }
  return [super acceptAttribute:attribute value:value];
}

@end


@implementation SdefXMLEnumeration

- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value {
  /* inline appears in Tiger */
  if (CFEqual(attribute, CFSTR("inline"))) {
    return kSdefParserVersionTigerAndLater;
  }
  return [super acceptAttribute:attribute value:value];
}

@end

@implementation SdefXMLProperty

- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value {
  /* in-properties replace not-in-properties in Tiger */
  if (CFEqual(attribute, CFSTR("in-properties"))) {
    return kSdefParserVersionTigerAndLater;
  } else if (CFEqual(attribute, CFSTR("not-in-properties"))) {
    return kSdefParserVersionPanther;
  } 
  return [super acceptAttribute:attribute value:value];
}

@end

@implementation SdefXMLRespondsTo

- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value {
  /* command replace name in Leopard */
  if (CFEqual(attribute, CFSTR("command"))) {
    return kSdefParserVersionLeopardAndLater;
  } else if (CFEqual(attribute, CFSTR("name"))) {
    /* name is supported for compatibility but should not be use is recent suites */
    return kSdefParserVersionAll;
  } 
  return [super acceptAttribute:attribute value:value];
}

@end

#pragma mark -
@implementation SdefXMLClass

- (SdefValidatorVersion)acceptElement:(CFStringRef)element {
  if (CFEqual(element, CFSTR("element")) ||
      CFEqual(element, CFSTR("property")) ||
      CFEqual(element, CFSTR("responds-to"))) {
    return kSdefParserVersionTigerAndLater;
  } else if (CFEqual(element, CFSTR("elements")) ||
             CFEqual(element, CFSTR("properties")) ||
             CFEqual(element, CFSTR("responds-to-commands")) ||
             CFEqual(element, CFSTR("responds-to-events"))) {
    return kSdefParserVersionPanther;
  } else if (CFEqual(element, CFSTR("type"))) {
    /* Not in DTD */
    return kSdefParserVersionAll;
  }
  return [super acceptElement:element];
}

@end

@implementation SdefXMLSuite

- (SdefValidatorVersion)acceptElement:(CFStringRef)element {
  if (CFEqual(element, CFSTR("enumeration")) ||
      CFEqual(element, CFSTR("record-type")) ||
      CFEqual(element, CFSTR("value-type")) ||
      CFEqual(element, CFSTR("command")) ||
      CFEqual(element, CFSTR("class")) ||
      CFEqual(element, CFSTR("event"))) {
    return kSdefParserVersionTigerAndLater;
  } else if (CFEqual(element, CFSTR("class-extension"))) {
    return kSdefParserVersionTigerAndLater;
  } else if (CFEqual(element, CFSTR("types")) ||
             CFEqual(element, CFSTR("classes")) ||
             CFEqual(element, CFSTR("commands")) ||
             CFEqual(element, CFSTR("events"))) {
    return kSdefParserVersionPanther;
  } 
  return [super acceptElement:element];
}

@end
