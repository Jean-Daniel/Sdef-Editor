//
//  SdefArguments.m
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefArguments.h"
#import "SdefDocument.h"
#import "SKExtensions.h"

@implementation SdefDirectParameter
- (id)copyWithZone:(NSZone *)aZone {
  SdefDirectParameter *copy = [super copyWithZone:aZone];
  copy->sd_desc = [sd_desc copyWithZone:aZone];
  copy->sd_type = [sd_type copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_type forKey:@"SDType"];
  [aCoder encodeObject:sd_desc forKey:@"SDDescription"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_type = [[aCoder decodeObjectForKey:@"SDType"] retain];
    sd_desc = [[aCoder decodeObjectForKey:@"SDDescription"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefDirectParameterType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"Direct Parameter", @"SdefLibrary", @"Direct Parameter default name");
}

+ (NSString *)defaultIconName {
  return @"Variable";
}

- (void)dealloc {
  [sd_desc release];
  [sd_type release];
  [super dealloc];
}

#pragma mark -
- (BOOL)isOptional {
  return sd_flags.optional;
}

- (void)setOptional:(BOOL)newOptional {
  newOptional = newOptional ? 1 : 0;
  if (sd_flags.optional != newOptional) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setOptional:sd_flags.optional];
    sd_flags.optional = newOptional;
  }
}

- (NSString *)type {
  return sd_type;
}

- (void)setType:(NSString *)newType {
  if (sd_type != newType) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_type];
    [sd_type release];
    sd_type = [newType copyWithZone:[self zone]];
  }
}

- (NSString *)desc {
  return sd_desc;
}

- (void)setDesc:(NSString *)newDesc {
  if (sd_desc != newDesc) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_desc];
    [sd_desc release];
    sd_desc = [newDesc copyWithZone:[self zone]];
  }
}

@end

#pragma mark -
@implementation SdefParameter
- (id)copyWithZone:(NSZone *)aZone {
  SdefParameter *copy = [super copyWithZone:aZone];
  copy->sd_type = [sd_type copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_type forKey:@"SDType"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_type = [[aCoder decodeObjectForKey:@"SDType"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefParameterType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"parameter", @"SdefLibrary", @"Parameter default name");
}

+ (NSString *)defaultIconName {
  return @"Param";
}

- (void)dealloc {
  [sd_type release];
  [super dealloc];
}

#pragma mark -
- (BOOL)isOptional {
  return sd_flags.optional;
}

- (void)setOptional:(BOOL)newOptional {
  newOptional = newOptional ? 1 : 0;
  if (sd_flags.optional != newOptional) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setOptional:sd_flags.optional];
    sd_flags.optional = newOptional;
  }
}

- (NSString *)type {
  return sd_type;
}

- (void)setType:(NSString *)newType {
  if (sd_type != newType) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_type];
    [sd_type release];
    sd_type = [newType copyWithZone:[self zone]];
  }
}

@end

#pragma mark -
@implementation SdefResult
- (id)copyWithZone:(NSZone *)aZone {
  SdefResult *copy = [super copyWithZone:aZone];
  copy->sd_desc = [sd_desc copyWithZone:aZone];
  copy->sd_type = [sd_type copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_type forKey:@"SDType"];
  [aCoder encodeObject:sd_desc forKey:@"SDDescription"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_type = [[aCoder decodeObjectForKey:@"SDType"] retain];
    sd_desc = [[aCoder decodeObjectForKey:@"SDDescription"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefResultType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"Result", @"SdefLibrary", @"Result default name");
}

+ (NSString *)defaultIconName {
  return @"Misc";
}

- (void)dealloc {
  [sd_desc release];
  [sd_type release];
  [super dealloc];
}

#pragma mark -
- (NSString *)type {
  return sd_type;
}

- (void)setType:(NSString *)newType {
  if (sd_type != newType) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_type];
    [sd_type release];
    sd_type = [newType copyWithZone:[self zone]];
  }
}

- (NSString *)desc {
  return sd_desc;
}

- (void)setDesc:(NSString *)newDesc {
  if (sd_desc != newDesc) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_desc];
    [sd_desc release];
    sd_desc = [newDesc copyWithZone:[self zone]];
  }
}

@end