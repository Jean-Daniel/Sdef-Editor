/*
 *  SdefImplementation.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefImplementation.h"
#import "SdefDocument.h"

@interface SdefImplementation ()
@property(nonatomic, copy) id value;
@end

@implementation SdefImplementation

@synthesize key = _key;
@synthesize method = _method;
@synthesize className = _class;

@synthesize value = _value;
@synthesize valueType = _vtype;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefImplementation *copy = [super copyWithZone:aZone];
  copy->_key = [_key copyWithZone:aZone];
  copy->_class = [_class copyWithZone:aZone];
  copy->_value = [_value copyWithZone:aZone];
  copy->_method = [_method copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_key forKey:@"SIKey"];
  [aCoder encodeObject:_class forKey:@"SIClass"];
  [aCoder encodeObject:_value forKey:@"SIValue"];
  [aCoder encodeInteger:_vtype forKey:@"SIValueType"];
  [aCoder encodeObject:_method forKey:@"SIMethod"];
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefCocoaType;
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _key = [[aCoder decodeObjectForKey:@"SIKey"] retain];
    _class = [[aCoder decodeObjectForKey:@"SIClass"] retain];
    _value = [[aCoder decodeObjectForKey:@"SIValue"] retain];
    _vtype = (UInt8)[aCoder decodeIntegerForKey:@"SIValueType"];
    _method = [[aCoder decodeObjectForKey:@"SIMethod"] retain];
  }
  return self;
}

- (void)dealloc {
  [_key release];
  [_class release];
  [_value release];
  [_method release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> { name: %@, key:%@, class:%@ , method:%@ }",
    NSStringFromClass([self class]), self,
    [self name], [self key], self.className, [self method]];
}

#pragma mark -
- (void)setClassName:(NSString *)newSdClass {
  if (_class != newSdClass) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:_class];
    SPXSetterCopy(_class, newSdClass);
  }
}

- (void)setKey:(NSString *)newKey {
  if (_key != newKey) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:_key];
    SPXSetterCopy(_key, newKey);
  }
}

- (void)setMethod:(NSString *)newMethod {
  if (_method != newMethod) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:_method];
    SPXSetterCopy(_method, newMethod);
  }
}

- (BOOL)insertAtBeginning {
  return sd_slFlags.beginning;
}

- (void)setInsertAtBeginning:(BOOL)flag {
  SPXFlagSet(sd_slFlags.beginning, flag);
}

#pragma mark Value
- (void)setValueType:(UInt8)aType {
  if (_vtype != aType) {
    [[[self undoManager] prepareWithInvocationTarget:self] setValueType:_vtype];
    NSString *key;
    switch (aType) {
      case kSdefValueTypeString: key = @"textValue"; break;
      case kSdefValueTypeInteger: key = @"integerValue"; break;
      case kSdefValueTypeBoolean: key = @"booleanValue"; break;
      default: key = @"value"; break;
    }
    [self willChangeValueForKey:key];
    _vtype = aType;
    /* Cast */
    switch (_vtype) { // target type
      case kSdefValueTypeString:
        if ([_value isKindOfClass:[NSNumber class]])
          [self setValue:[_value stringValue]];
        else
          [self setValue:@""];
        break;
      case kSdefValueTypeInteger:
        if (!_value || [_value isKindOfClass:[NSString class]])
          [self setValue:@([_value integerValue])];
        else
          [self setValue:@(0)];
        break;
      case kSdefValueTypeBoolean:
        if ([_value isKindOfClass:[NSString class]]) {
          if (NSOrderedSame == [_value caseInsensitiveCompare:@"yes"] ||
              NSOrderedSame == [_value caseInsensitiveCompare:@"true"] ||
              [_value integerValue]) {
            [self setValue:@(YES)];
          } else {
            [self setValue:@(NO)];
          }
        } else {
          [self setValue:@(NO)];
        }
        break;
    }
    [self didChangeValueForKey:key];
  }
}

- (NSString *)textValue {
  return _vtype == kSdefValueTypeString ? _value : nil;
}
- (void)setTextValue:(NSString *)value {
  [[self undoManager] registerUndoWithTarget:self selector:_cmd object:[self textValue]];
  [self setValue:value];
}

- (NSInteger)integerValue {
  return _vtype == kSdefValueTypeInteger ? [_value integerValue] : 0;
}
- (void)setIntegerValue:(NSInteger)value {
  [[[self undoManager] prepareWithInvocationTarget:self] setIntegerValue:[self integerValue]];
  [self setValue:@(value)];
}

- (BOOL)booleanValue {
  return _vtype == kSdefValueTypeBoolean ? [_value boolValue] : NO;
}
- (void)setBooleanValue:(BOOL)value {
  [[[self undoManager] prepareWithInvocationTarget:self] setBooleanValue:[self booleanValue]];
  [self setValue:@(value)];
}

@end
