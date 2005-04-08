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

#define LinkForObject(object, value) \
  		(object ? [NSString stringWithFormat:sd_links, [self anchorNameForObject:object], value] : value)

static __inline__ NSString *EscapedString(NSString *value, SdefTemplateFormat format) {
  return ((kSdefTemplateXMLFormat == format) ? [value stringByEscapingEntities:nil] : value);
}

@implementation SdtplExporter

- (void)dealloc {
  [sd_tpl release];
  [sd_formats release];
  [sd_anchors release];
  [sd_dictionary release];
  [sd_linksCache release];
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
    sd_links = [sd_formats objectForKey:@"Links"];
    if (sd_links) {
      CFArrayRef str = CFStringCreateArrayWithFindResults (kCFAllocatorDefault,
                                                           (CFStringRef)sd_links,
                                                           CFSTR("%@"),
                                                           CFRangeMake(0, [sd_links length]),
                                                           0);
      [(id)str autorelease];
      if (!str || CFArrayGetCount(str) != 2) {
        [NSException raise:@"SdefInvalidTemplateException" format:@"\"Links\" must contains exactly two %%@ values."];
      }
    } else {
      sd_links = @"<a href=\"#%@\">%@</a>";
    }
    
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
      case kSdefVerbType:
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

- (NSString *)linkForType:(NSString *)type string:(NSString *)string {
  id link = [sd_linksCache objectForKey:type];
  if (!link) {
    if (![SdefClassManager isBaseType:type]) {
      id class = [[sd_dictionary classManager] classWithName:type];
      link = LinkForObject(class, string);
    }
    link = (link) ? link : string;
    [sd_linksCache setObject:link forKey:type];
  }
  return link;
}

- (NSString *)linkForVerb:(NSString *)verb string:(NSString *)string {
  id mgr = [sd_dictionary classManager];
  SdefObject *object = [mgr commandWithName:verb];
  if (!object) {
    object = [mgr eventWithName:verb];
  }
  return LinkForObject(object, string);
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

- (BOOL)writeToFile:(NSString *)aFile atomically:(BOOL)flag {
  [self loadTemplate];
  /* Use retain instead of copy for key (type is SdefObject *) */
  sd_anchors = (id)CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kSKDictionaryKeyCallBacks, &kSKDictionaryValueCallBacks);
  /* Use retain instead of copy for key (faster) */
  sd_linksCache = (id)CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kSKDictionaryKeyCallBacks, &kSKDictionaryValueCallBacks);
  
  SKTemplate *template = [sd_tpl dictionaryTemplate];
  
  id style = [self styleSheet];
  if (style)
    [template setVariable:style forKey:@"Style_Sheet"];
  
  SetVariable(template, @"Dictionary_Name", [sd_dictionary name]);
  
  /* Copy dictionary if sort */
  SdefDictionary *dictionary;
  if (xd_flags.sort) {
    dictionary = [sd_dictionary copy];
    //[dictionary sortByName];
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
        [self writeClass:class usingTemplate:classBlock];
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
        [self writeVerb:verb usingTemplate:verbBlock];
        [verbBlock dumpBlock];
      }
      verbs = [[suite events] childEnumerator];
      while (verb = [verbs nextObject]) {
        [self writeVerb:verb usingTemplate:verbBlock];
        [verbBlock dumpBlock];
      }
      /* require to generate classes block */
      [[template blockWithName:@"Commands"] dumpBlock];
    }
    [suiteBlock dumpBlock];
  }
  /****** Table Of Content ******/
  if ([sd_tpl toc] != kSdefTemplateTOCNone && [sd_tpl tocTemplate]) {
    if ([sd_tpl tocTemplate] == template) {
      id tocTpl = [template blockWithName:@"Table_Of_Content"];
      [self writeTOC:dictionary usingTemplate:tocTpl];
      [tocTpl dumpBlock];
    } else {
      id tocTpl = [sd_tpl tocTemplate];
      NSString *links = nil;
      if ([sd_tpl toc] == kSdefTemplateTOCExternal) {
        if (style)
          [tocTpl setVariable:style forKey:@"Style_Sheet"];
        links = sd_links;
        sd_links = [sd_formats objectForKey:@"Toc_Links"]; 
        if (!sd_links) {
          sd_links = @"<a href=\"%@#%%@\">%%@</a>";
        }
        sd_links = [NSString stringWithFormat:sd_links, [aFile lastPathComponent]];
        /* Destroye Links cache before External TOC creation */
        [sd_linksCache release];
        sd_linksCache = nil;
      }
      [self writeTOC:dictionary usingTemplate:tocTpl];
      NSString *toc = [tocTpl stringRepresentation];
      switch ([sd_tpl toc]) {
        case kSdefTemplateTOCInline:
          [template setVariable:toc forKey:@"Table_Of_Content"];
          break;
        case kSdefTemplateTOCExternal:
          sd_links = links;
          [self writeToc:toc toFolder:[aFile stringByDeletingLastPathComponent] atomically:flag];
          break;
      }
      [tocTpl reset];
    }
  }
  /****** Write result ******/
  NSString *result = [template stringRepresentation];
  [template reset];
  [dictionary release];
  [sd_anchors release];
  sd_anchors = nil;
  [sd_linksCache release];
  sd_linksCache = nil;
  
  return [result writeToFile:aFile atomically:flag];
}

@end
