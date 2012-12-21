/*
 *  SdefParserInternal.c
 *  Sdef Editor
 *
 *  Created by Jean-Daniel Dupas on 30/10/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#include "SdefParserInternal.h"
#include <libxml/xinclude.h>

NSUInteger _SdefXMLAttributeCount(xmlNodePtr node) {
  NSUInteger count = 0;
  xmlAttr *attr = node->properties;
  while (attr) {
    count++;
    attr = attr->next;
  }
  return count;
}

xmlAttr *_SdefXMLAttributeAtIndex(xmlNodePtr node, NSUInteger idx) {
  xmlAttr *attr = node->properties;
  while (idx-- > 0 && attr) {
    attr = attr->next;
  }
  return attr;
}

const xmlChar *_SdefXMLAttributeGetValue(xmlAttr *attr) {
  return attr && attr->children ? attr->children->content : NULL;
}

CFDictionaryRef _SdefXMLCreateDictionaryWithAttributes(xmlAttr *attr, CFStringEncoding encoding) {
  if (!attr) return NULL;
  
  CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, 
                                                          &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  do {
    if (attr->name) {
      /* ignore xml:base attributes (added by xinclude parser) */
      if (!attr->ns || !attr->ns->href || !attr->ns->prefix || 
          (0 != xmlStrcasecmp(attr->ns->href, XML_XML_NAMESPACE) || 0 != xmlStrcasecmp(attr->name, (const xmlChar *)"base"))) {
        const xmlChar *value = _SdefXMLAttributeGetValue(attr);
        if (value) {
          CFStringRef val = CFStringCreateWithCString(kCFAllocatorDefault, (const char *)value, encoding);
          CFStringRef name = CFStringCreateWithCString(kCFAllocatorDefault, (const char *)attr->name, encoding);
          if (val && name)
            CFDictionarySetValue(dict, name, val);
            if (name) CFRelease(name);
          if (val) CFRelease(val);
        }
      } else {
        SPXDebug(@"Ignore attribute: %s:%s", attr->ns->prefix, attr->name);
      }
    }
    attr = attr->next;
  } while (attr);
  
  if (!CFDictionaryGetCount(dict)) {
    CFRelease(dict);
    dict = NULL;
  }
  return dict;
}

#pragma mark -
@implementation SdefDOMParser

- (id)initWithDelegate:(id)aDelegate {
  if (self = [super init]) {
    sd_delegate = aDelegate;
  }
  return self;
}

- (BOOL)parse:(xmlNodePtr)root {
  if (!root) return NO;
  
  sd_current = root;
  NSMutableArray *stack = [[NSMutableArray alloc] init];
  do {
    /* Process node */
    id elt = [sd_delegate parser:self createStructureForNode:sd_current];
    
    if (elt) 
      [sd_delegate parser:self addChild:elt toStructure:[stack lastObject]];
    
    /* if children */
    if (elt && sd_current->children) {
      /* down one level */
      [stack addObject:elt];
      sd_current = sd_current->children;
    } else {
      /* end empty element */
      if (elt)
        [sd_delegate parser:self endStructure:elt];
      
      xmlNodePtr sibling = NULL;
      /* Tant qu'on est pas a la racine, et qu'on a pas trouvé de voisin */
      while (sd_current && sd_current != root && !(sibling = sd_current->next)) {
        /* up one level */
        id parent = [stack lastObject];
        if (parent) {
          [sd_delegate parser:self endStructure:parent];
          [stack removeLastObject];
        }
        sd_current = sd_current->parent;
      }
      sd_current = sibling;
    }
  } while(sd_current && !sd_abort);
  sd_current = NULL;
  [stack release];
  
  return !sd_abort;
}

- (NSInteger)line {
  return sd_current ? sd_current->line : -1;
}
- (NSInteger)location {
  return 0;
}

- (void)abortWithError:(NSInteger)code reason:(NSString *)msg {
  sd_abort = true;
}

- (CFStringEncoding)cfencoding {
  return kCFStringEncodingUTF8;
}

- (NSStringEncoding)nsencoding {
  return NSUTF8StringEncoding;
}

@end

