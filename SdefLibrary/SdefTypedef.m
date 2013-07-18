/*
 *  SdefEnumeration.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefTypedef.h"

@implementation SdefEnumeration

@synthesize inlineValue = _inline;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefEnumeration *copy = [super copyWithZone:aZone];
  copy->_inline = _inline;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInt32:_inline forKey:@"SEInline"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _inline = [aCoder decodeInt32ForKey:@"SEInline"];
  }
  return self;
}

#pragma mark Values
+ (SdefObjectType)objectType {
  return kSdefEnumerationType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"enumeration", @"SdefLibrary", @"Enumeration default name");
}

+ (NSString *)defaultIconName {
  return @"Enum";
}

- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.xid = 1;
  sd_soFlags.xrefs = 1;
  sd_soFlags.hasAccessGroup = 1;

  _inline = kSdefInlineAll;
}

#pragma mark Inline
- (void)setInlineValue:(int32_t)value {
  if (value != _inline) {
    [[[self undoManager] prepareWithInvocationTarget:self] setInlineValue:_inline];
    [[self undoManager] setActionName:@"Change Inline"];
    _inline = value;
  }
}

@end

#pragma mark -
@implementation SdefEnumerator
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefEnumerator *copy = [super copyWithZone:aZone];
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

#pragma mark Values
+ (SdefObjectType)objectType {
  return kSdefEnumeratorType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"enumerator", @"SdefLibrary", @"Enumerator default name");
}

+ (NSString *)defaultIconName {
  return @"Enum";
}

- (void)sdefInit {
  [super sdefInit];
  [self setIsLeaf:YES];
  sd_soFlags.hasDocumentation = 0;
}

@end

#pragma mark -
@implementation SdefValue
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefValue *copy = [super copyWithZone:aZone];
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

#pragma mark Values
+ (SdefObjectType)objectType {
  return kSdefValueType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"value", @"SdefLibrary", @"Value default name");
}

+ (NSString *)defaultIconName {
  return @"Value";
}

- (void)sdefInit {
  [super sdefInit];
  [self setIsLeaf:YES];
  sd_soFlags.xid = 1;
  sd_soFlags.xrefs = 1;
  sd_soFlags.hasAccessGroup = 1;
}

@end

#pragma mark -
@implementation SdefRecord
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefRecord *copy = [super copyWithZone:aZone];
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

#pragma mark Values
+ (SdefObjectType)objectType {
  return kSdefRecordType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"record", @"SdefLibrary", @"Record default name");
}

+ (NSString *)defaultIconName {
  return @"Record";
}

- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.xid = 1;
  sd_soFlags.xrefs = 1;
  sd_soFlags.hasAccessGroup = 1;
}

@end
