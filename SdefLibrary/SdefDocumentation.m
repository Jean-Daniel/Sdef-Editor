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
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefDocumentation *copy = [super copyWithZone:aZone];
  copy->sd_content = [sd_content copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_content forKey:@"SDContent"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_content = [[aCoder decodeObjectForKey:@"SDContent"] retain];
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
  [sd_content release];
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

- (NSString *)content {
  return sd_content;
}
- (void)setContent:(NSString *)newContent {
  if (sd_content != newContent) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_content];
    [sd_content release];
    sd_content = [newContent retain];
  }
}

@end
