/*
 *  SdefVerb.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefVerb.h"
#import "SdefArguments.h"

@implementation SdefVerb

@synthesize result = _result;
@synthesize directParameter = _direct;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefVerb *copy = [super copyWithZone:aZone];
  copy->_result = [_result copyWithZone:aZone];
  [copy->_result setOwner:copy];
  copy->_direct = [_direct copyWithZone:aZone];
  [copy->_direct setOwner:copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_result forKey:@"SVResult"];
  [aCoder encodeObject:_direct forKey:@"SVDirectParameter"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _result = [[aCoder decodeObjectForKey:@"SVResult"] retain];
    _direct = [[aCoder decodeObjectForKey:@"SVDirectParameter"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefVerbType;
}

- (NSString *)objectTypeName {
  return [self isCommand] ? NSLocalizedStringFromTable(@"Command", @"SdefLibrary", @"Object Type Name.")
  : NSLocalizedStringFromTable(@"Event", @"SdefLibrary", @"Object Type Name.");
}

+ (NSString *)defaultIconName {
  return @"Function";
}

#pragma mark -
+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"method", @"SdefLibrary", @"Verb & Responds To default name.");
}

- (void)dealloc {
  [_result setOwner:nil];
  [_result release];
  [_direct setOwner:nil];
  [_direct release];
  [super dealloc];
}
#pragma mark -

- (BOOL)isCommand {
  SdefSuite *suite = [self suite];
  return suite ? [self parent] == [suite commands] : !sd_soFlags.event;
}
- (void)setCommand:(BOOL)flag {
  SPXFlagSet(sd_soFlags.event, !flag);
}

- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.xid = 1;
  sd_soFlags.xrefs = 1;
}

- (BOOL)hasResult {
  return _result != nil;
}
- (SdefResult *)result {
  if (!_result) {
    _result = [[SdefResult alloc] init];
    [_result setOwner:self];
  }
  return _result;
}
- (void)setResult:(SdefResult *)aResult {
  if (_result != aResult) {
    [_result setOwner:nil];
    [_result release];
    _result = [aResult retain];
    [_result setOwner:self];
  }
}

- (BOOL)hasDirectParameter {
  return _direct != nil;
}
- (SdefDirectParameter *)directParameter {
  if (!_direct) {
    _direct = [[SdefDirectParameter alloc] init];
    [_direct setOwner:self];
  }
  return _direct;
}
- (void)setDirectParameter:(SdefDirectParameter *)aParameter {
  if (_direct != aParameter) {
    [_direct setOwner:nil];
    [_direct release];
    _direct = [aParameter retain];
    [_direct setOwner:self];
  }
}

@end
