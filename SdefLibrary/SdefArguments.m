//
//  SdefArguments.m
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefArguments.h"
#import "SdefXMLNode.h"

@implementation SdefDirectParameter

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
    [sd_type release];
    sd_type = [newType copy];
  }
}

- (NSString *)desc {
  return sd_desc;
}

- (void)setDesc:(NSString *)newDesc {
  if (sd_desc != newDesc) {
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
    sd_optional = newOptional;
  }
}

- (NSString *)type {
  return sd_type;
}

- (void)setType:(NSString *)newType {
  if (sd_type != newType) {
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
    [sd_type release];
    sd_type = [newType copy];
  }
}

- (NSString *)desc {
  return sd_desc;
}

- (void)setDesc:(NSString *)newDesc {
  if (sd_desc != newDesc) {
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