/*
 *  SdefXMLNode.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLNode.h"

@implementation SdefXMLNode

@synthesize content = _content;
@synthesize elementName = _name;

@synthesize list = _list;
@synthesize CDData = _cddata;

+ (id)nodeWithElementName:(NSString *)aName {
  return [[self alloc] initWithElementName:aName];
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

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {element:%@ attributes:%@}",
    NSStringFromClass([self class]), self, _name, sd_attrKeys];
}

#pragma mark -
- (BOOL)isEmpty {
  if (_empty)
    return YES;
  return ![self hasChildren] && ![self content] && 0 == [sd_postmetas count];
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

- (NSArray *)comments {
  return sd_comments;
}

- (void)setComments:(NSArray *)comments {
  if (sd_comments != comments) {
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
