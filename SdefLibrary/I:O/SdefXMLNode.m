//
//  SdefXMLNode.m
//  SDef Editor
//
//  Created by Grayfox on 08/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

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
  [sd_content release];
  [sd_comments release];
  [sd_attrKeys release];
  [sd_attrValues release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {element:%@ attributes:%@}",
    NSStringFromClass([self class]), self,
    sd_name, sd_attrKeys];
}

#pragma mark -
- (BOOL)isEmpty {
  return ![self hasChildren] && ([self content] == nil);
}
- (void)setEmpty:(BOOL)flag {
  if (empty != flag) {
    empty = flag;
  }
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

- (unsigned)attributeCount {
  return [sd_attrKeys count];
}

- (NSArray *)attrKeys {
  return sd_attrKeys;
}
- (NSArray *)attrValues {
  return sd_attrValues;
}

- (id)attributForKey:(NSString *)key {
  unsigned idx = [sd_attrKeys indexOfObject:key];
  if (idx != NSNotFound) {
    return [sd_attrValues objectAtIndex:idx];
  }
  return nil;
}

- (void)setAttribute:(NSString *)value forKey:(NSString *)key {
  unsigned idx = [sd_attrKeys indexOfObject:key];
  if (idx != NSNotFound) {
    [sd_attrValues replaceObjectAtIndex:idx withObject:value];
  } else {
    [sd_attrKeys addObject:key];
    [sd_attrValues addObject:value];
  }
}

- (void)removeAttributeForKey:(NSString *)key {
  unsigned idx = [sd_attrKeys indexOfObject:key];
  if (idx != NSNotFound) {
    [sd_attrKeys removeObjectAtIndex:idx];
    [sd_attrValues removeObjectAtIndex:idx];
  }
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

- (void)removeCommentAtIndex:(unsigned)index {
  [sd_comments removeObjectAtIndex:index];
  if (sd_comments && [sd_comments count] == 0) {
    [sd_comments release];
    sd_comments = nil;
  }
}

@end
