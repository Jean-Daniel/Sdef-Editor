/*
 *  SdefDocumentation.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefDocumentation.h"

#import "SdefDocument.h"

@implementation SdefDocumentation

@synthesize content = _content;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefDocumentation *copy = [super copyWithZone:aZone];
  copy->_content = [_content copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_content forKey:@"SDContent"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _content = [[aCoder decodeObjectForKey:@"SDContent"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefDocumentationType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"documentation", @"SdefLibrary", @"Documentation default name");
}

+ (NSString *)defaultIconName {
  return @"Bookmarks";
}

- (id)initWithAttributes:(NSDictionary *)attrs {
  if (self = [super init]) {
  }
  return self;
}

- (void)dealloc {
  [_content release];
  [super dealloc];
}

#pragma mark -
- (BOOL)isHtml {
  return sd_slFlags.html;
}
- (void)setHtml:(BOOL)flag {
  flag = flag ? 1 : 0;
  if (flag != sd_slFlags.html) {
    [[[self undoManager] prepareWithInvocationTarget:self] setHtml:sd_slFlags.html];
    /* Undo */
    sd_slFlags.html = flag;
  }
}

- (void)setContent:(NSString *)newContent {
  if (_content != newContent) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:_content];
    [_content release];
    _content = [newContent copy];
  }
}

@end
