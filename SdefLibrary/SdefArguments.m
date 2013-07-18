/*
 *  SdefArguments.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefArguments.h"
#import "SdefDocument.h"

@implementation SdefDirectParameter

@synthesize requiresAccess = _requiresAccess;

- (id)copyWithZone:(NSZone *)aZone {
  SdefDirectParameter *copy = [super copyWithZone:aZone];
  copy->_requiresAccess = _requiresAccess;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInt32:_requiresAccess forKey:@"SDPRequiresAccess"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _requiresAccess = [aCoder decodeInt32ForKey:@"SDPRequiresAccess"];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_DirectParameter;
}

+ (NSString *)defaultName {
  return nil;
//  return NSLocalizedStringFromTable(@"direct parameter", @"SdefLibrary", @"Direct Parameter default name");
}

+ (NSString *)defaultIconName {
  return @"Param";
}

- (void)sdefInit {
  [super sdefInit];
  [self setIsLeaf:YES];
}

#pragma mark -
- (BOOL)isOptional {
  return sd_soFlags.optional;
}

- (void)setOptional:(BOOL)newOptional {
  newOptional = newOptional ? 1 : 0;
  if (sd_soFlags.optional != newOptional) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setOptional:sd_soFlags.optional];
    sd_soFlags.optional = newOptional;
  }
}

- (void)setRequiresAccess:(uint32_t)requiresAccess {
  if (_requiresAccess != requiresAccess) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setRequiresAccess:_requiresAccess];
    _requiresAccess = requiresAccess;
  }
}

@end

#pragma mark -
@implementation SdefParameter

@synthesize requiresAccess = _requiresAccess;

- (id)copyWithZone:(NSZone *)aZone {
  SdefParameter *copy = [super copyWithZone:aZone];
  copy->_requiresAccess = _requiresAccess;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInt32:_requiresAccess forKey:@"SPRequiresAccess"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _requiresAccess = [aCoder decodeInt32ForKey:@"SPRequiresAccess"];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Parameter;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"parameter", @"SdefLibrary", @"Parameter default name");
}

+ (NSString *)defaultIconName {
  return @"Param";
}

- (void)sdefInit {
  [super sdefInit];
  [self setIsLeaf:YES];
}

#pragma mark -
- (BOOL)isOptional {
  return sd_soFlags.optional;
}

- (void)setOptional:(BOOL)newOptional {
  newOptional = newOptional ? 1 : 0;
  if (sd_soFlags.optional != newOptional) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setOptional:sd_soFlags.optional];
    sd_soFlags.optional = newOptional;
  }
}

- (void)setRequiresAccess:(uint32_t)requiresAccess {
  if (_requiresAccess != requiresAccess) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setRequiresAccess:_requiresAccess];
    _requiresAccess = requiresAccess;
  }
}

@end

#pragma mark -
@implementation SdefResult
- (id)copyWithZone:(NSZone *)aZone {
  SdefResult *copy = [super copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Result;
}

+ (NSString *)defaultName {
  return nil;
//  return NSLocalizedStringFromTable(@"result", @"SdefLibrary", @"Result default name");
}

+ (NSString *)defaultIconName {
  return @"Misc";
}

- (void)sdefInit {
  [super sdefInit];
  [self setIsLeaf:YES];
}

@end
