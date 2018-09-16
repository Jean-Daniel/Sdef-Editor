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

NSDictionary *_SdefXMLCreateDictionaryWithAttributes(xmlAttr *attr, NSStringEncoding encoding) {
  if (!attr) return NULL;
  
  NSMutableDictionary *dict = NULL;
  do {
    if (attr->name) {
      /* ignore xml:base attributes (added by xinclude parser) */
      if (!attr->ns || !attr->ns->href || !attr->ns->prefix ||
          (0 != xmlStrcasecmp(attr->ns->href, XML_XML_NAMESPACE) || 0 != xmlStrcasecmp(attr->name, (const xmlChar *)"base"))) {
        const xmlChar *value = _SdefXMLAttributeGetValue(attr);
        if (value) {
          NSString *val = [NSString stringWithCString:(const char *)value encoding:encoding];
          NSString *name = [NSString stringWithCString:(const char *)attr->name encoding:encoding];
          if (val && name) {
            if (!dict)
              dict = [[NSMutableDictionary alloc] init];
            dict[name] = val;
          }
        }
      } else {
        SPXDebug(@"Ignore attribute: %s:%s", attr->ns->prefix, attr->name);
      }
    }
    attr = attr->next;
  } while (attr);
  
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
    SdefXMLStructure elt = [sd_delegate parser:self createStructureForNode:sd_current];
    
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

- (NSStringEncoding)encoding {
  return NSUTF8StringEncoding;
}

@end

