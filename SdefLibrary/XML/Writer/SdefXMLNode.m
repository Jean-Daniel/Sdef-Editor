/*
 *  SdefXMLNode.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLNode.h"

@implementation SdefXMLNode

+ (id)nodeWithElementName:(NSString *)aName {
  return [[[self alloc] initWithElementName:aName] autorelease];
}

- (id)init {
  if (self = [super init]) {
    sd_attrKeys = [[NSMutableArray alloc] init];
    sd_attrValues = [[NSMutableArray alloc] init];
  }
  return self;
}

- (id)initWithElementName:(NSString *)name {
  if (self = [self init]) {
    [self setElementName:name];
  }
  return self;
}

- (void)dealloc {
  [sd_name release];
  [sd_metas release];
  [sd_content release];
  [sd_comments release];
  [sd_attrKeys release];
  [sd_postmetas release];
  [sd_attrValues release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {element:%@ attributes:%@}",
    NSStringFromClass([self class]), self,
    sd_name, sd_attrKeys];
}

#pragma mark -
- (BOOL)isList {
  return sd_list;
}

- (void)setList:(BOOL)flag {
  sd_list = flag;
}

- (BOOL)isEmpty {
  return ![self hasChildren] && ![self content] && 0 == [sd_postmetas count];
}
- (void)setEmpty:(BOOL)flag {
  if (sd_empty != flag) {
    sd_empty = flag;
  }
}

- (BOOL)isCDData {
  return sd_cddata;
}
- (void)setCDData:(BOOL)flag {
  sd_cddata = flag;
}

- (NSString *)elementName {
  return sd_name;
}
- (void)setElementName:(NSString *)aName {
  if (sd_name != aName) {
    [sd_name release];
    sd_name = [aName copy];
  }
}

- (NSUInteger)attributeCount {
  return [sd_attrKeys count];
}

- (NSArray *)attrKeys {
  return sd_attrKeys;
}
- (NSArray *)attrValues {
  return sd_attrValues;
}

- (NSString *)attributForKey:(NSString *)key {
  NSUInteger idx = [sd_attrKeys indexOfObject:key];
  if (idx != NSNotFound) {
    return [sd_attrValues objectAtIndex:idx];
  }
  return nil;
}

- (void)setAttribute:(NSString *)value forKey:(NSString *)key {
  NSUInteger idx = [sd_attrKeys indexOfObject:key];
  if (idx != NSNotFound) {
    [sd_attrValues replaceObjectAtIndex:idx withObject:value];
  } else {
    [sd_attrKeys addObject:key];
    [sd_attrValues addObject:value];
  }
}

- (void)addAttributesFromDictionary:(NSDictionary *)dict {
  for (NSString *key in dict) {
    [self setAttribute:[dict objectForKey:key] forKey:key];
  }
}

- (void)removeAttributeForKey:(NSString *)key {
  NSUInteger idx = [sd_attrKeys indexOfObject:key];
  if (idx != NSNotFound) {
    [sd_attrKeys removeObjectAtIndex:idx];
    [sd_attrValues removeObjectAtIndex:idx];
  }
}

- (void)removeAllAttributes {
  [sd_attrKeys removeAllObjects];
  [sd_attrValues removeAllObjects];
}

- (NSString *)content {
  return sd_content;
}

- (void)setContent:(NSString *)newContent {
  if (sd_content != newContent) {
    [sd_content release];
    sd_content = [newContent copy];
  }
}

- (NSArray *)comments {
  return sd_comments;
}

- (void)setComments:(NSArray *)comments {
  if (sd_comments != comments) {
    [sd_comments release];
    sd_comments = [comments mutableCopy];
  }
}

- (void)addComment:(NSString *)comment {
  if (!sd_comments) {
    sd_comments = [[NSMutableArray alloc] init];
  }
  [sd_comments addObject:comment];
}

- (void)removeCommentAtIndex:(NSUInteger)anIndex {
  [sd_comments removeObjectAtIndex:anIndex];
  if (sd_comments && [sd_comments count] == 0) {
    [sd_comments release];
    sd_comments = nil;
  }
}

- (NSDictionary *)metas {
  return sd_metas;
}
- (NSDictionary *)postmetas {
  return sd_postmetas;
}
- (void)setMeta:(NSString *)value forKey:(NSString *)key {
  if (value) {
    if (!sd_metas) sd_metas = [[NSMutableDictionary alloc] init];
    [sd_metas setObject:value forKey:key];
  } else if (sd_metas) {
    [sd_metas removeObjectForKey:key];
  }
}
- (void)setPostMeta:(NSString *)value forKey:(NSString *)key {
  if (value) {
    if (!sd_postmetas) sd_postmetas = [[NSMutableDictionary alloc] init];
    [sd_postmetas setObject:value forKey:key];
  } else if (sd_postmetas) {
    [sd_postmetas removeObjectForKey:key];
  }
}

@end
