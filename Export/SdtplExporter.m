//
//  SdtplExporter.m
//  Sdef Editor
//
//  Created by Grayfox on 06/03/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdtplExporter.h"

#import "ASDictionaryObject.h"
#import "SdefDictionary.h"
#import "SKExtensions.h"
#import "SKXMLTemplate.h"
#import "ShadowCFContext.h"

#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefVerb.h"
#import "SdefDocument.h"
#import "SdefTemplate.h"
#import "SdefArguments.h"
#import "SdefClassManager.h"

#define SetVariable(tpl, name, value) \
	{	\
      id __varStr = [self stringWithString:value variable:name]; \
      [tpl setVariable:__varStr forKey:name]; \
    }

__inline__ NSString *EscapedString(NSString *value, SdefTemplateFormat format) {
  return ((kSdefTemplateXMLFormat == format) ? [value stringByEscapingEntities:nil] : value);
}

@implementation SdtplExporter

- (void)dealloc {
  [sd_tpl release];
  [sd_formats release];
  [sd_anchors release];
  [sd_dictionary release];
  [super dealloc];
}

#pragma mark -
- (void)reset {
  [sd_formats release];
  sd_formats = nil;
  bzero(&xd_flags, sizeof (xd_flags));
}

- (SdefTemplate *)template {
  return sd_tpl;
}

- (void)setTemplate:(SdefTemplate *)tpl {
  if (sd_tpl != tpl) {
    [sd_tpl release];
    sd_tpl = [tpl retain];
  }
}

- (void)loadTemplate {
  [self reset];
  if (sd_tpl) {
    sd_formats = [[sd_tpl formats] mutableCopy];
    xd_flags.sort = [sd_tpl sort];
    xd_flags.links = [sd_tpl links];
    sd_format = [sd_tpl html] ? kSdefTemplateXMLFormat : kSdefTemplateDefaultFormat;
  }
}

- (SdefDictionary *)dictionary {
  return sd_dictionary;
}

- (void)setDictionary:(SdefDictionary *)theDictionary {
  if (sd_dictionary != theDictionary) {
    [sd_dictionary release];
    sd_dictionary = [theDictionary retain];
  }
}

- (NSString *)styleSheet {
  NSString *style = nil;
  id css = [[sd_tpl selectedStyle] objectForKey:@"path"];
  if (css) {
    if ([sd_tpl css] == kSdefTemplateCSSInline) {
      style = [NSString stringWithContentsOfFile:css];
    } else {
      style = [NSString stringWithFormat:@"@import \"%@\";", [css lastPathComponent]];
    }
  }
  return style;
}

static NSString *SimplifieName(NSString *name) {
  id data = [name dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  NSMutableString *simple = [[NSMutableString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  [simple replaceOccurrencesOfString:@" " withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [simple length])];  
  return [simple autorelease];
}

- (NSString *)anchorNameForObject:(SdefObject *)obj {
  id key = [[NSValue alloc] initWithBytes:&obj objCType:@encode(id)];
  id anchor = [sd_anchors objectForKey:key];
  if (!anchor) {
    switch ([obj objectType]) {
      case kSdefSuiteType:
        anchor = [NSString stringWithFormat:@"suite_%@", SimplifieName([obj name])];
        break;
      case kSdefClassType:
        anchor = [NSString stringWithFormat:@"%@_%@", SimplifieName([[obj suite] name]), SimplifieName([obj name])];
        break;
      default:
        anchor = nil;
    }
    [sd_anchors setObject:(anchor) ? : [NSNull null] forKey:key];
  }
  [key release];
  return [anchor isMemberOfClass:[NSNull class]] ? nil : anchor;
}

- (NSString *)linkForType:(NSString *)type string:string {
  id link = nil;
  if (![SdefClassManager isBaseType:type]) {
    id mgr = [sd_dictionary classManager];
    id obj = [mgr classWithName:type];
    if (obj) {
      link = [NSString stringWithFormat:@"<a href=\"#%@\">%@</a>", [self anchorNameForObject:obj], string];
    }
  }
  return link ? : string;
}

- (NSString *)anchorForObject:(SdefObject *)obj {
  id name = [self anchorNameForObject:obj];
  if (name) {
    id anchor = [sd_formats objectForKey:@"AnchorFormat"];
    if (!anchor) {
      anchor = @"<a name=\"%@\" />";
      [sd_formats setObject:anchor forKey:@"AnchorFormat"];
    }
    return [NSString stringWithFormat:anchor, name];
  }
  return nil;
}

- (NSString *)stringWithString:(NSString *)str variable:(NSString *)variable {
  id format = [sd_formats objectForKey:variable];
  if (format) {
    return ([format rangeOfString:@"%@"].location != NSNotFound) ? [NSString stringWithFormat:format, str] : format;
  }
  return str;
}

- (void)writeProperty:(SdefProperty *)prop toTemplate:(SKTemplate *)tpl {
  if ([prop name])
    SetVariable(tpl, @"Property_Name", [prop name]);
  if ([prop type]) {
    id type = [prop asDictionaryTypeForType:[prop type] isList:nil];
    if (xd_flags.links)
      type = [self linkForType:[prop type] string:type];
    SetVariable(tpl, @"Property_Type", type);
  }
  if (([prop access] & kSdefAccessWrite) == 0)
    SetVariable(tpl, @"ReadOnly", @"[r/o]");
  if ([prop desc])
    SetVariable(tpl, EscapedString(@"Property_Description", sd_format), [prop desc]);
}

- (void)writeElement:(SdefElement *)elt toTemplate:(SKTemplate *)tpl {
  if ([elt name]) {
    id name = [elt name];
    if (xd_flags.links)
      name = [self linkForType:name string:name];
    SetVariable(tpl, @"Element_Type", name);
  }
  NSAssert1([elt respondsToSelector:@selector(writeAccessorsStringToStream:)],
            @"Element %@ does not responds to writeAccessorsStringToStream:", elt);
  id access = [[NSMutableString alloc] init];
  [elt performSelector:@selector(writeAccessorsStringToStream:) withObject:access];
  SetVariable(tpl, @"Element_Accessors", access);
  [access release];
}

- (void)writeClass:(SdefClass *)class toTemplate:(SKTemplate *)tpl {
  if ([class name]) {
    SetVariable(tpl, @"Class_Name", [class name]);
    if (xd_flags.links)
      SetVariable(tpl, @"Class_Anchor", [self anchorForObject:class]);
  }
  if ([class desc])
    SetVariable(tpl, EscapedString(@"Class_Description", sd_format), [class desc]);
  if ([class plural]) {
    id plural = [tpl blockWithName:@"Plural"];
    SetVariable(plural, @"Plural", [class plural]);
    [plural dumpBlock];
  }
  /* Subclasses */
  if ([tpl blockWithName:@"Subclasses"]) {
    id mgr = [sd_dictionary classManager];
    id items = [mgr subclassesOfClass:class];
    if ([items count]) {
      id item;
      items = [items objectEnumerator];
      id subclass = [tpl blockWithName:@"Subclass"];
      id subclasses = [tpl blockWithName:@"Subclasses"];
      while (item = [items nextObject]) {
        id name = [item name];
        if (xd_flags.links)
          name = [self linkForType:name string:name];
        SetVariable(subclass, @"Subclass", name);
        [subclass dumpBlock];
      }
      [subclasses dumpBlock];
    }
  }
  if (xd_flags.sort) {
    [[class elements] sortByName];
    [[class properties] sortByName];
  }
  /* Elements */
  if ([[class elements] hasChildren]) {
    id elements = [[class elements] childEnumerator];
    id elt;
    id eltBlock = [tpl blockWithName:@"Element"];
    while (elt = [elements nextObject]) {
      [self writeElement:elt toTemplate:eltBlock];
      [eltBlock dumpBlock];
    }
    /* require to generate classes block */
    [[tpl blockWithName:@"Elements"] dumpBlock];
  }
  /* Inherits */
  if ([class inherits] && [tpl blockWithName:@"Superclass"]) {
    id superclass = [tpl blockWithName:@"Superclass"];
    id inherits = [class inherits];
    if (xd_flags.links)
      inherits = [self linkForType:inherits string:inherits];
    SetVariable(superclass, @"Superclass", inherits);
    id desc = [NSString stringWithFormat:@"inherits some of its properties from the %@ class", [class inherits]];
    SetVariable(superclass, @"Superclass_Description", desc);
    [superclass dumpBlock];
  }
  /* Properties */
  /* inner: if superclass is in Properties block, we have to dump it. */
  BOOL inner = [[[[tpl blockWithName:@"Superclass"] parent] name] isEqualToString:@"Properties"];
  if ([[class properties] hasChildren] || ([class inherits] && inner)) {
    id propBlock = [tpl blockWithName:@"Property"];
    id properties = [[class properties] childEnumerator];
    id property;
    while (property = [properties nextObject]) {
      [self writeProperty:property toTemplate:propBlock];
      [propBlock dumpBlock];
    }
    /* require to generate classes block */
    [[tpl blockWithName:@"Properties"] dumpBlock];
  }
}

- (void)writeParameter:(SdefParameter *)param toTemplate:(SKTemplate *)tpl {
  if ([param name])
    SetVariable(tpl, @"Parameter_Name", [param name]);
  if ([param desc])
    SetVariable(tpl, EscapedString(@"Parameter_Description", sd_format), [param desc]);
  BOOL list;
  id type = [param asDictionaryTypeForType:[param type] isList:&list];
  if (list) {
    SetVariable(tpl, @"Parameter_Type_List", @"a list of");
  }
  SetVariable(tpl, @"Parameter_Type", type);
}

- (void)writeVerb:(SdefVerb *)verb toTemplate:(SKTemplate *)tpl {
  if ([verb name])
    SetVariable(tpl, @"Command_Name", [verb name]);
  if ([verb desc])
    SetVariable(tpl, EscapedString(@"Command_Description", sd_format), [verb desc]);
  if (xd_flags.sort) {
    [verb sortByName];
  }
  if ([[verb directParameter] type]) {
    id block = [tpl blockWithName:@"Direct_Parameter"];
    SdefDirectParameter *param = [verb directParameter];
    BOOL list;
    id type = [param asDictionaryTypeForType:[param type] isList:&list];
    if (list) {
      SetVariable(block, @"Direct_Parameter_List", @"a list of");
    }
    SetVariable(block, @"Direct_Parameter", type);
    if ([param desc])
      SetVariable(block, EscapedString(@"Direct_Parameter_Description", sd_format), [param desc]);
    [block dumpBlock];
  }
  if ([[verb result] type]) {
    id block = [tpl blockWithName:@"Result"];
    SdefResult *result = [verb result];
    BOOL list;
    id type = [result asDictionaryTypeForType:[result type] isList:&list];
    if (list) {
      SetVariable(block, @"Result_Type_List", @"a list of");
    }
    SetVariable(block, @"Result_Type", type);
    if ([result desc])
      SetVariable(block, EscapedString(@"Result_Description", sd_format), [result desc]);
    [block dumpBlock];
  }
  if ([verb hasChildren]) {
    SdefParameter *param;
    id params = [verb childEnumerator];
    id block = [tpl blockWithName:@"Required_Parameter"];
    /* Required parameters */
    while (param = [params nextObject]) {
      if (![param isOptional]) {
        [self writeParameter:param toTemplate:block];
        [block dumpBlock];
      }
    }
    
    params = [verb childEnumerator];
    block = [tpl blockWithName:@"Optional_Parameter"];
    /* Optionals parameters */
    while (param = [params nextObject]) {
      if ([param isOptional]) {
        [self writeParameter:param toTemplate:block];
        [block dumpBlock];
      }
    }
    [[tpl blockWithName:@"Parameters"] dumpBlock];
  }
}

- (BOOL)writeToFile:(NSString *)aFile atomically:(BOOL)flag {
  [self loadTemplate];
  /* Use retain instead of copy for key (type is SdefObject *) */
  sd_anchors = (id)CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kSKDictionaryKeyCallBacks, &kSKDictionaryValueCallBacks);
  
  SKTemplate *template = [sd_tpl layoutTemplate];
  
  id style = [self styleSheet];
  if (style)
    [template setVariable:style forKey:@"Style_Sheet"];
  
  SetVariable(template, @"Dictionary_Name", [sd_dictionary name]);
  
  /* Copy dictionary if sort */
  SdefDictionary *dictionary;
  if (xd_flags.sort) {
    dictionary = [sd_dictionary copy];
    [dictionary sortByName];
  } else {
    dictionary = [sd_dictionary retain];
  }
  
  id suites = [dictionary childEnumerator];
  SdefSuite *suite;
  id suiteBlock = [template blockWithName:@"Suite"];
  while (suite = [suites nextObject]) {
    if ([suite name]) {
      SetVariable(suiteBlock, @"Suite_Name", [suite name]);
      if (xd_flags.links)
        SetVariable(suiteBlock, @"Suite_Anchor", [self anchorForObject:suite]);
    }
    if ([suite desc])
      SetVariable(suiteBlock, @"Suite_Description", [suite desc]);
    
    if (xd_flags.sort) {
      [[suite classes] sortByName];
      [[suite commands] sortByName];
      [[suite events] sortByName];
    }
    
    if ([[suite classes] hasChildren]) {
      id classes = [[suite classes] childEnumerator];
      id class;
      id classBlock = [template blockWithName:@"Class"];
      while (class = [classes nextObject]) {
        [self writeClass:class toTemplate:classBlock];
        [classBlock dumpBlock];
      }
      /* require to generate classes block */
      [[template blockWithName:@"Classes"] dumpBlock];
    }
    /* Commands */
    if ([[suite commands] hasChildren] || [[suite events] hasChildren]) {
      id verb;
      id verbBlock = [template blockWithName:@"Command"];
      id verbs = [[suite commands] childEnumerator];
      while (verb = [verbs nextObject]) {
        [self writeVerb:verb toTemplate:verbBlock];
        [verbBlock dumpBlock];
      }
      verbs = [[suite events] childEnumerator];
      while (verb = [verbs nextObject]) {
        [self writeVerb:verb toTemplate:verbBlock];
        [verbBlock dumpBlock];
      }
      /* require to generate classes block */
      [[template blockWithName:@"Commands"] dumpBlock];
    }
    [suiteBlock dumpBlock];
  }
  NSString *result = [template stringRepresentation];
  [template reset];
  [dictionary release];
  [sd_anchors release];
  sd_anchors = nil;
  return [result writeToFile:aFile atomically:flag];
}

@end
