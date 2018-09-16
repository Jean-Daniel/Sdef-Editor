/*
 *  SdefXMLValidator.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLValidator.h"

@interface SdefXMLElement : NSObject {
  NSSet *_elements;
  NSSet *_attributes;
}

- (id)initWithElements:(NSString * const __unsafe_unretained *)elements count:(NSUInteger)cnt;

/* Return Leopard if attributes contains 'id' */
/* Return Leopard if element contains 'xref' */
- (SdefValidatorVersion)acceptAttribute:(NSString *)attribute value:(NSString *)value;
- (SdefValidatorVersion)acceptElement:(NSString *)element;

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
NSMutableDictionary *sValidators = nil;

static inline SPX_REQUIRES_NIL_TERMINATION
SdefXMLElement *_ELEMENT(Class cls, NSString *name, ...) {
  NSInteger idx = -1;
  __unsafe_unretained NSString * items[32];

  va_list ap;
  va_start(ap, name);
  do {
    idx++;
    assert(idx < 32);
    items[idx] = va_arg(ap, NSString *);
  } while (items[idx]);
  va_end(ap);

  SdefXMLElement *elt = [[cls alloc] initWithElements:items count:idx];
  sValidators[name] = elt;
  return elt;
}

#define ELEMENT(name, cls, ...) _ELEMENT([cls class], name, ##__VA_ARGS__)
#define EMPTY nil

+ (void)initialize {
  if ([SdefXMLValidator class] == self) {
    sValidators = [[NSMutableDictionary alloc] init];

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
    sValidators[@"event"] = cmd;
    
    /* direct-parameter */
    [ELEMENT(@"direct-parameter", SdefXMLElement, @"type", nil)
     ATTLIST:@"type", @"optional", @"requires-access", @"description", nil];
    
    /* result */
    [ELEMENT(@"result", SdefXMLElement, @"type", nil)
     ATTLIST:@"type", @"description", nil];
    
    /* parameter (+synonym, +documentation) */
    [ELEMENT(@"parameter", SdefXMLElement, @"cocoa", @"type", @"synonym", @"documentation", nil) // @"synonym" is not in the DTD, but sdef(5) says parameter is a terminology element ?
     ATTLIST:@"name", @"code", @"hidden", @"type", @"optional", @"requires-access", @"description", nil];
    
    /* class (custom) */
    [ELEMENT(@"class", SdefXMLClass, @"cocoa", @"access-group", @"contents", @"documentation", @"synonym", @"xref", nil)
     // 10.4: element, property, responds-to
     ATTLIST:@"name", @"id", @"code", @"hidden", @"plural", @"inherits", @"description", nil];
    
    /* contents (+synonym, +documentation) */
    [ELEMENT(@"contents", SdefXMLElement, @"cocoa", @"access-group", @"type", @"synonym", @"documentation", nil)
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

    /* enumeration (custom) */
    [ELEMENT(@"enumeration", SdefXMLEnumeration, @"cocoa", @"documentation", @"enumerator", @"xref", nil)
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
    sd_stack = [[NSMutableArray alloc] init];
  }
  return self;
}

- (SdefValidatorVersion)version {
  return sd_version;
}

- (NSString *)element {
  return sd_stack.lastObject;
}

- (void)startElement:(NSString *)element {
  [sd_stack addObject:element];
}

- (void)endElement:(NSString *)element {
  NSString * last = [self element];
  if (!last || ![element isEqualToString:last]) {
    spx_log_warning("Invalid validator stack state");
  }
  if (last)
    [sd_stack removeLastObject];
}

- (NSString *)invalidAttribute:(NSString *)attribute inElement:(NSString *)element {
  return [NSString stringWithFormat:@"unexpected attribute '%@' found in element '%@'", attribute, element];
}

- (NSString *)invalidAttribute:(NSString *)attribute inElement:(NSString *)element forVersion:(SdefValidatorVersion)version {
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

- (NSString *)invalidElementError:(NSString *)element {
  if (![self element]) {
    return [NSString stringWithFormat:@"unexpected root element %@", element];
  } else {
    return [NSString stringWithFormat:@"unexpected element '%@' found in element '%@'", element, [self element]];
  }
}

- (SdefValidatorVersion)checkAttributes:(NSDictionary *)attributes forElement:(NSString *)element error:(NSString * __autoreleasing *)error {
  SdefValidatorVersion version = sd_version;
  if (attributes && attributes.count > 0) {
    SdefXMLElement *validator = sValidators[element];
    if (validator) {
      for (NSString *attr in attributes) {
        version &= [validator acceptAttribute:attr value:attributes[attr]];
        if (kSdefParserVersionUnknown == version) {
          if (error) *error = [self invalidAttribute:attr inElement:element];
          break;
        }
      }
    }
  }
  return version;
}

- (SdefValidatorResult)validateElement:(NSString *)element attributes:(NSDictionary *)attributes error:(NSString * __autoreleasing *)error {
  if (error) *error = nil;
  SdefXMLElement *validator;
  if ([self element]) {
    validator = sValidators[self.element];
  } else {
    validator = sValidators[@"__sdef__"];
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

- (id)initWithElements:(NSString * const __unsafe_unretained *)elements count:(NSUInteger)cnt {
  if (self = [super init]) {
    if (cnt > 0)
      _elements = [[NSSet alloc] init];
  }
  return self;
}

- (instancetype)ATTLIST:(NSString *)name, ... {
  NSString * items[32];
  items[0] = name;
  
  va_list ap;
  CFIndex idx = 0;
  va_start(ap, name);
  do {
    idx++;
    assert(idx < 32);
    items[idx] = va_arg(ap, NSString *);
  } while (items[idx]);
  va_end(ap);
  
  _attributes = [NSSet setWithObjects:items count:idx];
  return self;
}

- (SdefValidatorVersion)acceptAttribute:(NSString *)attribute value:(NSString *)value {
  if (_attributes && [_attributes containsObject:attribute]) {
    if ([attribute isEqualToString:@"requires-access"]) {
      return kSdefParserVersionMountainLionAndLater;
    }
    return [attribute isEqualToString:@"id"] ? kSdefParserVersionLeopardAndLater : kSdefParserVersionAll;
  }
  return kSdefParserVersionUnknown;
}

- (SdefValidatorVersion)acceptElement:(NSString *)element {
  if (_elements) {
    if ([_elements containsObject:element]) {
      if ([element isEqualToString:@"type"]) {
        /* type element is for Tiger and above */
        return kSdefParserVersionTigerAndLater;
      } else if ([element isEqualToString:@"xref"] || [element isEqualToString:@"include"]) {
        return kSdefParserVersionLeopardAndLater;
      } else if ([element isEqualToString:@"access-group"]) {
        return kSdefParserVersionMountainLionAndLater;
      } else {
        return kSdefParserVersionAll;
      }
    } else if ([element isEqualToString:@"synonyms"] && [_elements containsObject:@"synonym"]) {
      /* special synonyms case */ 
      return kSdefParserVersionPanther;
    }
  }
  if ([element isEqualToString:@"include"])
    return kSdefParserVersionLeopardAndLater;

  return kSdefParserVersionUnknown;
}

@end

#pragma mark -
@implementation SdefXMLCocoa

- (SdefValidatorVersion)acceptAttribute:(NSString *)attribute value:(NSString *)value {
  /* type-values appear in Leopard */
  if ([attribute isEqualToString:@"boolean-value"] ||
      [attribute isEqualToString:@"integer-value"] ||
      [attribute isEqualToString:@"string-value"] ||
      [attribute isEqualToString:@"insert-at-beginning"]) {
    return kSdefParserVersionLeopardAndLater;
  }
  return [super acceptAttribute:attribute value:value];
}

@end


@implementation SdefXMLEnumeration

- (SdefValidatorVersion)acceptAttribute:(NSString *)attribute value:(NSString *)value {
  /* inline appears in Tiger */
  if ([attribute isEqualToString:@"inline"]) {
    return kSdefParserVersionTigerAndLater;
  }
  return [super acceptAttribute:attribute value:value];
}

@end

@implementation SdefXMLProperty

- (SdefValidatorVersion)acceptAttribute:(NSString *)attribute value:(NSString *)value {
  /* in-properties replace not-in-properties in Tiger */
  if ([attribute isEqualToString:@"in-properties"]) {
    return kSdefParserVersionTigerAndLater;
  } else if ([attribute isEqualToString:@"not-in-properties"]) {
    return kSdefParserVersionPanther;
  } 
  return [super acceptAttribute:attribute value:value];
}

@end

@implementation SdefXMLRespondsTo

- (SdefValidatorVersion)acceptAttribute:(NSString *)attribute value:(NSString *)value {
  /* command replace name in Leopard */
  if ([attribute isEqualToString:@"command"]) {
    return kSdefParserVersionLeopardAndLater;
  } else if ([attribute isEqualToString:@"name"]) {
    /* name is supported for compatibility but should not be use is recent suites */
    return kSdefParserVersionAll;
  } 
  return [super acceptAttribute:attribute value:value];
}

@end

#pragma mark -
@implementation SdefXMLClass

- (SdefValidatorVersion)acceptElement:(NSString *)element {
  if ([element isEqualToString:@"element"] ||
      [element isEqualToString:@"property"] ||
      [element isEqualToString:@"responds-to"]) {
    return kSdefParserVersionTigerAndLater;
  } else if ([element isEqualToString:@"elements"] ||
             [element isEqualToString:@"properties"] ||
             [element isEqualToString:@"responds-to-commands"] ||
             [element isEqualToString:@"responds-to-events"]) {
    return kSdefParserVersionPanther;
  } else if ([element isEqualToString:@"type"]) {
    /* Not in DTD */
    return kSdefParserVersionAll;
  }
  return [super acceptElement:element];
}

@end

@implementation SdefXMLSuite

- (SdefValidatorVersion)acceptElement:(NSString *)element {
  if ([element isEqualToString:@"enumeration"] ||
      [element isEqualToString:@"record-type"] ||
      [element isEqualToString:@"value-type"] ||
      [element isEqualToString:@"command"] ||
      [element isEqualToString:@"class"] ||
      [element isEqualToString:@"event"]) {
    return kSdefParserVersionTigerAndLater;
  } else if ([element isEqualToString:@"class-extension"]) {
    return kSdefParserVersionTigerAndLater;
  } else if ([element isEqualToString:@"types"] ||
             [element isEqualToString:@"classes"] ||
             [element isEqualToString:@"commands"] ||
             [element isEqualToString:@"events"]) {
    return kSdefParserVersionPanther;
  } 
  return [super acceptElement:element];
}

@end
