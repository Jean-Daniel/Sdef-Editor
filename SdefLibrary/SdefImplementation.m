/*
 *  SdefImplementation.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefImplementation.h"
#import "SdefDocument.h"

@implementation SdefImplementation
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefImplementation *copy = [super copyWithZone:aZone];
  copy->sd_key = [sd_key copyWithZone:aZone];
  copy->sd_class = [sd_class copyWithZone:aZone];
  copy->sd_method = [sd_method copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_key forKey:@"SIKey"];
  [aCoder encodeObject:sd_class forKey:@"SIClass"];
  [aCoder encodeObject:sd_method forKey:@"SIMethod"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_key = [[aCoder decodeObjectForKey:@"SIKey"] retain];
    sd_class = [[aCoder decodeObjectForKey:@"SIClass"] retain];
    sd_method = [[aCoder decodeObjectForKey:@"SIMethod"] retain];
  }
  return self;
}

- (void)dealloc {
  [sd_key release];
  [sd_class release];
  [sd_method release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {name: %@, key:%@, class:%@ , method:%@}",
    NSStringFromClass([self class]), self,
    [self name], [self key], [self sdClass], [self method]];
}

#pragma mark -
- (NSString *)sdClass {
  return sd_class;
}
- (void)setSdClass:(NSString *)newSdClass {
  if (sd_class != newSdClass) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_class];
    [sd_class release];
    sd_class = [newSdClass copyWithZone:[self zone]];
  }
}

- (NSString *)key {
  return sd_key;
}
- (void)setKey:(NSString *)newKey {
  if (sd_key != newKey) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_key];
    [sd_key release];
    sd_key = [newKey copyWithZone:[self zone]];
  }
}

- (NSString *)method {
  return sd_method;
}
- (void)setMethod:(NSString *)newMethod {
  if (sd_method != newMethod) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_method];
    [sd_method release];
    sd_method = [newMethod copyWithZone:[self zone]];
  }
}

@end
