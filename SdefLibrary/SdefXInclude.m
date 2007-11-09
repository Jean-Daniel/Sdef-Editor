/*
 *  SdefXInclude.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXInclude.h"

@implementation SdefXInclude
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefXInclude *copy = [super copyWithZone:aZone];
  copy->sd_href = [sd_href copyWithZone:aZone];
  copy->sd_pointer = [sd_pointer copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_href forKey:@"SXIncludeHRef"];
  [aCoder encodeObject:sd_pointer forKey:@"SXIncludePointer"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_href = [[aCoder decodeObjectForKey:@"SXIncludeHRef"] retain];
    sd_pointer = [[aCoder decodeObjectForKey:@"SXIncludePointer"] retain];
  }
  return self;
}

- (void)dealloc {
  [sd_pointer release];
  [sd_href release];
  [super dealloc];
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefXIncludeType;
}

+ (NSString *)defaultIconName {
  return @"XInclude";
}

- (NSString *)href {
  return sd_href;
}
- (void)setHref:(NSString *)aRef {
  SKSetterCopy(sd_href, aRef);
}

- (NSString *)pointer {
  return sd_pointer;
}
- (void)setPointer:(NSString *)aPointer {
  SKSetterCopy(sd_pointer, aPointer);
}

@end
