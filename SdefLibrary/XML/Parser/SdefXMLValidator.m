/*
 *  SdefXMLValidator.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLValidator.h"

@interface SdefXMLElement : NSObject {
}

- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value;
- (SdefValidatorVersion)acceptElement:(CFStringRef)element;

- (void)setElements:(CFStringRef)element, ...;
- (void)setAttributes:(CFStringRef)attribute, ...;

@end

@interface SdefBaseXMLElement : SdefXMLElement {
  CFSetRef sd_elements;
  CFSetRef sd_attributes;
}

- (void)setElements:(CFStringRef)element, ...;
- (void)setAttributes:(CFStringRef)attribute, ...;

/* Return Leopard if attributes contains 'id' */
/* Return Leopard if element contains 'xref' */
@end

@interface SdefXMLClass : SdefBaseXMLElement {
}
@end

@interface SdefXMLCocoa : SdefBaseXMLElement {
}
@end

@interface SdefXMLEnumeration : SdefBaseXMLElement {
}
@end

@interface SdefXMLProperty : SdefBaseXMLElement {
}
@end

@interface SdefXMLRespondsTo : SdefBaseXMLElement {
}
@end

@interface SdefXMLSuite : SdefBaseXMLElement {
}
@end

@implementation SdefXMLValidator

static 
CFMutableDictionaryRef sValidators = NULL;

+ (void)initialize {
  if ([SdefXMLValidator class] == self) {
    SdefXMLElement *elt;
    
    sValidators = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, 
                                            &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    /* root */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("dictionary"), nil];
    CFDictionarySetValue(sValidators, CFSTR("__sdef__"), elt);
    [elt release];
    
    /* accessor */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setAttributes:CFSTR("style"), nil];
    CFDictionarySetValue(sValidators, CFSTR("accessor"), elt);
    [elt release];
    
    /* class (custom) */
    elt = [[SdefXMLClass alloc] init];
    [elt setElements:CFSTR("contents"), CFSTR("documentation"), CFSTR("synonym"), CFSTR("xref"), CFSTR("cocoa"), nil];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("hidden"), CFSTR("description"),
      CFSTR("id"), CFSTR("inherits"), CFSTR("plural"), nil];
    CFDictionarySetValue(sValidators, CFSTR("class"), elt);
    [elt release];
    
    /* class-extension (+id) */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("contents"), CFSTR("element"), CFSTR("property"), CFSTR("responds-to"),
      CFSTR("documentation"), CFSTR("synonym"), CFSTR("xref"), CFSTR("cocoa"), CFSTR("type") /* not in DTD */, nil];
    [elt setAttributes:CFSTR("extends"), CFSTR("description"), CFSTR("hidden"), CFSTR("id"), nil];
    CFDictionarySetValue(sValidators, CFSTR("class-extension"), elt);
    [elt release];
    
    /* cocoa (custom) */
    elt = [[SdefXMLCocoa alloc] init];
    [elt setAttributes:CFSTR("class"), CFSTR("key"), CFSTR("method"), CFSTR("name"), nil];
    CFDictionarySetValue(sValidators, CFSTR("cocoa"), elt);
    [elt release];
    
    /* command/event */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("cocoa"), CFSTR("synonym"), CFSTR("documentation"),
      CFSTR("direct-parameter"), CFSTR("parameter"), CFSTR("result"), CFSTR("xref"), nil];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("description"), CFSTR("hidden"), CFSTR("id"), nil];
    CFDictionarySetValue(sValidators, CFSTR("command"), elt);
    CFDictionarySetValue(sValidators, CFSTR("event"), elt);
    [elt release];
    
    /* contents */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("cocoa"), CFSTR("type"), nil];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("description"), CFSTR("hidden"), 
      CFSTR("type"), CFSTR("access"), nil];
    CFDictionarySetValue(sValidators, CFSTR("contents"), elt);
    [elt release];
    
    /* dictionary */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("documentation"), CFSTR("suite"), nil];
    [elt setAttributes:CFSTR("title"), nil];
    CFDictionarySetValue(sValidators, CFSTR("dictionary"), elt);
    [elt release];
    
    /* direct-parameter */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("type"), nil];
    [elt setAttributes:CFSTR("type"), CFSTR("description"), CFSTR("optional"), nil];
    CFDictionarySetValue(sValidators, CFSTR("direct-parameter"), elt);
    [elt release];
    
    /* element */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("cocoa"), CFSTR("accessor"), nil];
    [elt setAttributes:CFSTR("type"), CFSTR("description"), CFSTR("hidden"), CFSTR("access"), nil];
    CFDictionarySetValue(sValidators, CFSTR("element"), elt);
    [elt release];
    
    /* enumeration (custom, +synonym) */
    elt = [[SdefXMLEnumeration alloc] init];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("hidden"), CFSTR("description"), CFSTR("id"), nil];
    [elt setElements:CFSTR("cocoa"), CFSTR("documentation"), CFSTR("synonym"), 
      CFSTR("enumerator"), CFSTR("xref"), nil];
    CFDictionarySetValue(sValidators, CFSTR("enumeration"), elt);
    [elt release];
    
    /* enumerator */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("cocoa"), CFSTR("synonym"), CFSTR("documentation"), nil];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("description"), CFSTR("hidden"), nil];
    CFDictionarySetValue(sValidators, CFSTR("enumerator"), elt);
    [elt release];
    
    /* parameter (+synonym) */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("cocoa"), CFSTR("type"), CFSTR("synonym"), nil];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("description"), CFSTR("hidden"),
      CFSTR("type"), CFSTR("optional"), nil];
    CFDictionarySetValue(sValidators, CFSTR("parameter"), elt);
    [elt release];
    
    /* property (custom) */
    elt = [[SdefXMLProperty alloc] init];
    [elt setElements:CFSTR("cocoa"), CFSTR("type"), CFSTR("synonym"), CFSTR("documentation"), nil];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("hidden"), CFSTR("description"), 
      CFSTR("type"), CFSTR("access"),  nil];
    CFDictionarySetValue(sValidators, CFSTR("property"), elt);
    [elt release];
    
    /* record-type (+id) */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("cocoa"), CFSTR("synonym"), CFSTR("documentation"),
      CFSTR("property"), CFSTR("xref"), nil];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("description"), CFSTR("hidden"), CFSTR("id"), nil];
    CFDictionarySetValue(sValidators, CFSTR("record-type"), elt);
    [elt release];
    
    /* result */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("type"), nil];
    [elt setAttributes:CFSTR("type"), CFSTR("description"), nil];
    CFDictionarySetValue(sValidators, CFSTR("result"), elt);
    [elt release];
    
    /* responds-to (custom) */
    elt = [[SdefXMLRespondsTo alloc] init];
    [elt setElements:CFSTR("cocoa"), nil];
    [elt setAttributes:CFSTR("hidden"), nil];
    CFDictionarySetValue(sValidators, CFSTR("responds-to"), elt);
    [elt release];
    
    /* suite (custom) */
    elt = [[SdefXMLSuite alloc] init];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("hidden"), CFSTR("description"), nil];
    [elt setElements:CFSTR("cocoa"), CFSTR("documentation"), nil];
    CFDictionarySetValue(sValidators, CFSTR("suite"), elt);
    [elt release];
    
    /* synonym */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("cocoa"), nil];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("hidden"), nil];
    CFDictionarySetValue(sValidators, CFSTR("synonym"), elt);
    [elt release];
    
    /* type */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setAttributes:CFSTR("type"), CFSTR("list"), CFSTR("hidden"), nil]; // hidden is in man but not in DTD & iChat uses it.
    CFDictionarySetValue(sValidators, CFSTR("type"), elt);
    [elt release];
    
    /* value-type (+id) */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("cocoa"), CFSTR("synonym"), CFSTR("documentation"), CFSTR("xref"), nil];
    [elt setAttributes:CFSTR("name"), CFSTR("code"), CFSTR("description"), CFSTR("hidden"), CFSTR("plural"), CFSTR("id"), nil];
    CFDictionarySetValue(sValidators, CFSTR("value-type"), elt);
    [elt release];
    
    /* xref */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setAttributes:CFSTR("target"), CFSTR("hidden"), nil];
    CFDictionarySetValue(sValidators, CFSTR("xref"), elt);
    [elt release];
    
    /* xinclude */
    elt = [[SdefBaseXMLElement alloc] init];
    /* base on W3C Working Draft 10 November 2003 */
    [elt setAttributes:CFSTR("href"), CFSTR("parse"), CFSTR("xpointer"), CFSTR("encoding"), 
      CFSTR("accept"), CFSTR("accept-charset"), CFSTR("accept-language"), nil];
    CFDictionarySetValue(sValidators, CFSTR("include"), elt);
    [elt release];
    
    /* ~~~~~~~~~~~~~~ Panther collections ~~~~~~~~~~~~~~ */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("enumeration"), nil];
    CFDictionarySetValue(sValidators, CFSTR("types"), elt);
    [elt release];
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("synonym"), nil];
    CFDictionarySetValue(sValidators, CFSTR("synonyms"), elt);
    [elt release];
    
    /* Class */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("class"), nil];
    CFDictionarySetValue(sValidators, CFSTR("classes"), elt);
    [elt release];
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("element"), nil];
    CFDictionarySetValue(sValidators, CFSTR("elements"), elt);
    [elt release];
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("property"), nil];
    CFDictionarySetValue(sValidators, CFSTR("properties"), elt);
    [elt release];
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("responds-to"), nil];
    CFDictionarySetValue(sValidators, CFSTR("responds-to-commands"), elt);
    [elt release];
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("responds-to"), nil];
    CFDictionarySetValue(sValidators, CFSTR("responds-to-events"), elt);
    [elt release];
    
    /* Verbs */
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("command"), nil];
    CFDictionarySetValue(sValidators, CFSTR("commands"), elt);
    [elt release];
    elt = [[SdefBaseXMLElement alloc] init];
    [elt setElements:CFSTR("event"), nil];
    CFDictionarySetValue(sValidators, CFSTR("events"), elt);
    [elt release];
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
    case kSdefParserVersionMoutainLion:
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

- (void)setElements:(CFStringRef)attribute, ... {
  [NSException raise:NSInvalidArgumentException format:@"Invalid receiver"];
}
- (void)setAttributes:(CFStringRef)attribute, ... {
  [NSException raise:NSInvalidArgumentException format:@"Invalid receiver"];
}

- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value {
  return kSdefParserVersionUnknown;
}
- (SdefValidatorVersion)acceptElement:(CFStringRef)element {
  if (CFEqual(element, CFSTR("include")))
    return kSdefParserVersionLeopard;
  
  return kSdefParserVersionUnknown;
}

@end

@implementation SdefBaseXMLElement

- (void)setElements:(CFStringRef)element, ... {
  CFStringRef items[32];
  items[0] = element;
  
  va_list ap;
  CFIndex idx = 0;
  va_start(ap, element);
  do {
    idx++;
    assert(idx < 32);
    items[idx] = va_arg(ap, CFStringRef);
  } while (items[idx]);
  va_end(ap);
  
  sd_elements = CFSetCreate(kCFAllocatorDefault, (const void **)items, idx, &kCFTypeSetCallBacks);
}

- (void)setAttributes:(CFStringRef)attribute, ... {
  CFStringRef items[32];
  items[0] = attribute;
  
  va_list ap;
  CFIndex idx = 0;
  va_start(ap, attribute);
  do {
    idx++;
    assert(idx < 32);
    items[idx] = va_arg(ap, CFStringRef);
  } while (items[idx]);
  va_end(ap);
  
  sd_attributes = CFSetCreate(kCFAllocatorDefault, (const void **)items, idx, &kCFTypeSetCallBacks);
}

- (void)dealloc {
  if (sd_elements) CFRelease(sd_elements);
  if (sd_attributes) CFRelease(sd_attributes);
  [super dealloc];
}

- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value {
  if (sd_attributes && CFSetContainsValue(sd_attributes, attribute))
    return CFEqual(attribute, CFSTR("id")) ? kSdefParserVersionLeopard : kSdefParserVersionAll;
  return [super acceptAttribute:attribute value:value];
}
- (SdefValidatorVersion)acceptElement:(CFStringRef)element {
  if (sd_elements) {
    if (CFSetContainsValue(sd_elements, element)) {
      if (CFEqual(element, CFSTR("type"))) {
        /* type element is for Tiger and above */
        return kSdefParserVersionTiger | kSdefParserVersionLeopard;
      } else if (CFEqual(element, CFSTR("xref")) || CFEqual(element, CFSTR("include"))) {
        return kSdefParserVersionLeopard;
      } else {
        return kSdefParserVersionAll;
      }
    } else if (CFEqual(element, CFSTR("synonyms")) && CFSetContainsValue(sd_elements, CFSTR("synonym"))) {
      /* special synonyms case */ 
      return kSdefParserVersionPanther;
    }
  }
  return [super acceptElement:element];
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
    return kSdefParserVersionLeopard;
  }
  return [super acceptAttribute:attribute value:value];
}

@end


@implementation SdefXMLEnumeration

- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value {
  /* inline appears in Tiger */
  if (CFEqual(attribute, CFSTR("inline"))) {
    return kSdefParserVersionTiger | kSdefParserVersionLeopard;
  }
  return [super acceptAttribute:attribute value:value];
}

@end

@implementation SdefXMLProperty

- (SdefValidatorVersion)acceptAttribute:(CFStringRef)attribute value:(CFStringRef)value {
  /* in-properties replace not-in-properties in Tiger */
  if (CFEqual(attribute, CFSTR("in-properties"))) {
    return kSdefParserVersionTiger | kSdefParserVersionLeopard;
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
    return kSdefParserVersionLeopard;
  } else if (CFEqual(attribute, CFSTR("name"))) {
    /* name is tolerate by leopard */
    return kSdefParserVersionPanther | kSdefParserVersionTiger | kSdefParserVersionLeopard;
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
    return kSdefParserVersionTiger | kSdefParserVersionLeopard;
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
    return kSdefParserVersionTiger | kSdefParserVersionLeopard;
  } else if (CFEqual(element, CFSTR("class-extension"))) {
    return kSdefParserVersionTiger | kSdefParserVersionLeopard; /* kSdefParserVersionLeopard; */
  } else if (CFEqual(element, CFSTR("types")) ||
             CFEqual(element, CFSTR("classes")) ||
             CFEqual(element, CFSTR("commands")) ||
             CFEqual(element, CFSTR("events"))) {
    return kSdefParserVersionPanther;
  } 
  return [super acceptElement:element];
}

@end
