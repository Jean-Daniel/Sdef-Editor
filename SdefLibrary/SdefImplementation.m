/*
 *  SdefImplementation.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefImplementation.h"
#import "SdefDocument.h"

@implementation SdefImplementation
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefImplementation *copy = [super copyWithZone:aZone];
  copy->sd_key = [sd_key copyWithZone:aZone];
  copy->sd_class = [sd_class copyWithZone:aZone];
  copy->sd_value = [sd_value copyWithZone:aZone];
  copy->sd_method = [sd_method copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_key forKey:@"SIKey"];
  [aCoder encodeObject:sd_class forKey:@"SIClass"];
  [aCoder encodeObject:sd_value forKey:@"SIValue"];
  SKEncodeInteger(aCoder, sd_vtype, @"SIValueType");
  [aCoder encodeObject:sd_method forKey:@"SIMethod"];
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefCocoaType;
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_key = [[aCoder decodeObjectForKey:@"SIKey"] retain];
    sd_class = [[aCoder decodeObjectForKey:@"SIClass"] retain];
    sd_value = [[aCoder decodeObjectForKey:@"SIValue"] retain];
    sd_vtype = (UInt8)SKDecodeInteger(aCoder, @"SIValueType");
    sd_method = [[aCoder decodeObjectForKey:@"SIMethod"] retain];
  }
  return self;
}

- (void)dealloc {
  [sd_key release];
  [sd_class release];
  [sd_value release];
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
    sd_class = [newSdClass copy];
  }
}

- (NSString *)key {
  return sd_key;
}
- (void)setKey:(NSString *)newKey {
  if (sd_key != newKey) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_key];
    [sd_key release];
    sd_key = [newKey copy];
  }
}

- (NSString *)method {
  return sd_method;
}
- (void)setMethod:(NSString *)newMethod {
  if (sd_method != newMethod) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_method];
    [sd_method release];
    sd_method = [newMethod copy];
  }
}

#pragma mark Value
- (id)value {
  return sd_value;
}
- (void)setValue:(id)aValue {
  if (sd_value != aValue) {
    [sd_value release];
    sd_value = [aValue copy];    
  }
}

- (UInt8)valueType {
  return sd_vtype;
}
- (void)setValueType:(UInt8)aType {
  if (sd_vtype != aType) {
    [[[self undoManager] prepareWithInvocationTarget:self] setValueType:sd_vtype];
    NSString *key;
    switch (aType) {
      case kSdefValueTypeString: key = @"textValue"; break;
      case kSdefValueTypeInteger: key = @"integerValue"; break;
      case kSdefValueTypeBoolean: key = @"booleanValue"; break;
      default: key = @"value"; break;
    }
    [self willChangeValueForKey:key];
    sd_vtype = aType;
    /* Cast */
    if (sd_vtype == kSdefValueTypeString && [sd_value isKindOfClass:[NSNumber class]]) {
      [self setValue:[sd_value stringValue]];
    } else if ((sd_vtype == kSdefValueTypeInteger || sd_vtype == kSdefValueTypeBoolean) && 
               (!sd_value || [sd_value isKindOfClass:[NSString class]])) {
      [self setValue:SKInteger(SKIntegerValue(sd_value))];
    }
    [self didChangeValueForKey:key];
  }
}

- (NSString *)textValue {
  return sd_vtype == kSdefValueTypeString ? sd_value : nil;
}
- (void)setTextValue:(NSString *)value {
  [[self undoManager] registerUndoWithTarget:self selector:_cmd object:[self textValue]];
  [self setValue:value];
}

- (NSInteger)integerValue {
  return sd_vtype == kSdefValueTypeInteger ? SKIntegerValue(sd_value) : nil;
}
- (void)setIntegerValue:(NSInteger)value {
  [[[self undoManager] prepareWithInvocationTarget:self] setIntegerValue:[self integerValue]];
  [self setValue:SKInteger(value)];
}

- (BOOL)booleanValue {
  return sd_vtype == kSdefValueTypeBoolean ? [sd_value boolValue] : nil;
}
- (void)setBooleanValue:(BOOL)value {
  [[[self undoManager] prepareWithInvocationTarget:self] setBooleanValue:[self booleanValue]];
  [self setValue:SKBool(value)];
}

@end
