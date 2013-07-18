/*
 *  SdefSynonym.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefSynonym.h"
#import "SdefBase.h"
#import "SdefImplementation.h"

@implementation SdefSynonym

@synthesize code = _code;
@synthesize impl = _impl;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefSynonym *copy = [super copyWithZone:aZone];
  copy->_code = [_code copy];
  copy->_impl = [_impl copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_code forKey:@"SYCode"];
  [aCoder encodeObject:_impl forKey:@"SYImpl"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _code = [[aCoder decodeObjectForKey:@"SYCode"] retain];
    _impl = [[aCoder decodeObjectForKey:@"SYImpl"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Synonym;
}

- (void)dealloc {
  [_impl release];
  [_code release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {name=%@ code=%@ hidden=%@}", 
    NSStringFromClass([self class]), self,
 [self name], _code, sd_slFlags.hidden ? @"YES" : @"NO"];
}

#pragma mark -
- (SdefImplementation *)impl {
  if (!_impl) {
    SdefImplementation *impl = [[SdefImplementation allocWithZone:[self zone]] init];
    [self setImpl:impl];
    [impl release];
  }
  return _impl;
}
- (void)setImpl:(SdefImplementation *)newImpl {
  if (_impl != newImpl) {
    [_impl setOwner:nil];
    [_impl release];
    _impl = [newImpl retain];
    [_impl setOwner:self];
  }
}

- (void)setCode:(NSString *)code {
  if (code != _code) {
    NSUndoManager *undo = [self undoManager];
    if (undo) {
      [undo registerUndoWithTarget:self selector:_cmd object:_code];
      [undo setActionName:NSLocalizedStringFromTable(@"Change Synonym", @"SdefLibrary", @"Undo Action: Change synonym.")];
    }
    SPXSetterCopy(_code, code);
  }
}

@end
