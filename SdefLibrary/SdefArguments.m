//
//  SdefArguments.m
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefArguments.h"
#import "SdefXMLNode.h"
#import "SdefDocument.h"

@implementation SdefDirectParameter
- (id)copyWithZone:(NSZone *)aZone {
  SdefDirectParameter *copy = [super copyWithZone:aZone];
  copy->sd_optional = sd_optional;
  copy->sd_desc = [sd_desc copyWithZone:aZone];
  copy->sd_type = [sd_type copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_type forKey:@"SDType"];
  [aCoder encodeBool:sd_optional forKey:@"SDOptional"];
  [aCoder encodeObject:sd_desc forKey:@"SDDescription"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_type = [[aCoder decodeObjectForKey:@"SDType"] retain];
    sd_optional = [aCoder decodeBoolForKey:@"SDOptional"];
    sd_desc = [[aCoder decodeObjectForKey:@"SDDescription"] retain];
  }
  return self;
}

#pragma mark -
+ (SDObjectType)objectType {
  return kSDDirectParameterType;
}

+ (NSString *)defaultName {
  return @"Direct-Parameter";
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
  return sd_optional;
}

- (void)setOptional:(BOOL)newOptional {
  if (sd_optional != newOptional) {
    sd_optional = newOptional;
  }
}

- (NSString *)type {
  return sd_type;
}

- (void)setType:(NSString *)newType {
  if (sd_type != newType) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_type];
    [sd_type release];
    sd_type = [newType copy];
  }
}

- (NSString *)desc {
  return sd_desc;
}

- (void)setDesc:(NSString *)newDesc {
  if (sd_desc != newDesc) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_desc];
    [sd_desc release];
    sd_desc = [newDesc copy];
  }
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node = nil;
  if ([self type] && (node = [super xmlNode])) {
    id attr;
    if (attr = [self type]) [node setAttribute:attr forKey:@"type"];
    if (attr = [self desc]) [node setAttribute:attr forKey:@"description"];
    if ([self isOptional]) [node setAttribute:@"optional" forKey:@"optional"];
    [node setEmpty:YES];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"direct-parameter";
}

#pragma mark -
#pragma mark Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [self setType:[attrs objectForKey:@"type"]];
  [self setDesc:[attrs objectForKey:@"description"]];
  [self setOptional:[attrs objectForKey:@"optional"] != nil];
}

@end

#pragma mark -
@implementation SdefParameter
- (id)copyWithZone:(NSZone *)aZone {
  SdefParameter *copy = [super copyWithZone:aZone];
  copy->sd_optional = sd_optional;
  copy->sd_type = [sd_type copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_type forKey:@"SDType"];
  [aCoder encodeBool:sd_optional forKey:@"SDOptional"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_type = [[aCoder decodeObjectForKey:@"SDType"] retain];
    sd_optional = [aCoder decodeBoolForKey:@"SDOptional"];
  }
  return self;
}

#pragma mark -
+ (SDObjectType)objectType {
  return kSDParameterType;
}

+ (NSString *)defaultName {
  return @"parameter";
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
  return sd_optional;
}

- (void)setOptional:(BOOL)newOptional {
  if (sd_optional != newOptional) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setOptional:sd_optional];
    sd_optional = newOptional;
  }
}

- (NSString *)type {
  return sd_type;
}

- (void)setType:(NSString *)newType {
  if (sd_type != newType) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_type];
    [sd_type release];
    sd_type = [newType copy];
  }
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node;
  if (node = [super xmlNode]) {
    id attr;
    if (attr = [self type]) [node setAttribute:attr forKey:@"type"];
    if ([self isOptional]) [node setAttribute:@"optional" forKey:@"optional"];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"parameter";
}

#pragma mark -
#pragma mark Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setType:[attrs objectForKey:@"type"]];
  [self setOptional:[attrs objectForKey:@"optional"] != nil];
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
+ (SDObjectType)objectType {
  return kSDResultType;
}

+ (NSString *)defaultName {
  return @"Result";
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
    sd_type = [newType copy];
  }
}

- (NSString *)desc {
  return sd_desc;
}

- (void)setDesc:(NSString *)newDesc {
  if (sd_desc != newDesc) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_desc];
    [sd_desc release];
    sd_desc = [newDesc copy];
  }
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node = nil;
  if ([self type] && (node = [super xmlNode])) {
    id attr;
    if (attr = [self type]) [node setAttribute:attr forKey:@"type"];
    if (attr = [self desc]) [node setAttribute:attr forKey:@"description"];
    [node setEmpty:YES];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"result";
}

#pragma mark -
#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [self setType:[attrs objectForKey:@"type"]];
  [self setDesc:[attrs objectForKey:@"description"]];
}

@end