/*
 *  SdefClass.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefClass.h"
#import "SdefContents.h"
#import "SdefDocument.h"
#import "SdefClassManager.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

@implementation SdefClass

@synthesize contents = _contents;

@synthesize type = _type;
@synthesize plural = _plural;
@synthesize inherits = _inherits;

@synthesize extension = _extension;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefClass *copy = [super copyWithZone:aZone];
  copy->_type = [_type copyWithZone:aZone];
  copy->_plural = [_plural copyWithZone:aZone];
  copy->_inherits = [_inherits copyWithZone:aZone];
  copy->_contents = [_contents copyWithZone:aZone];
  [copy->_contents setOwner:copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_type forKey:@"SCType"];
  [aCoder encodeObject:_plural forKey:@"SCPlural"];
  [aCoder encodeObject:_inherits forKey:@"SCInherits"];
  [aCoder encodeObject:_contents forKey:@"SCContents"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _type = [aCoder decodeObjectForKey:@"SCType"];
    _plural = [aCoder decodeObjectForKey:@"SCPlural"];
    _inherits = [aCoder decodeObjectForKey:@"SCInherits"];
    _contents = [aCoder decodeObjectForKey:@"SCContents"];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Class;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"class name", @"SdefLibrary", @"Class default name");
}

+ (NSString *)defaultIconName {
  return @"Class";
}

- (void)dealloc {
  [_contents setOwner:nil];
}

- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.xid = 1;
  sd_soFlags.xrefs = 1;
  sd_soFlags.hasAccessGroup = 1;

  SdefCollection *child = [[SdefCollection alloc] initWithName:NSLocalizedStringFromTable(@"Elements", @"SdefLibrary", @"Elements collection default name")];
  [child setContentType:[SdefElement class]];
  [child setElementName:@"elements"];
  [self appendChild:child];
  
  child = [[SdefCollection alloc] initWithName:NSLocalizedStringFromTable(@"Properties", @"SdefLibrary", @"Properties collection default name")];
  [child setContentType:[SdefProperty class]];
  [child setElementName:@"properties"];
  [self appendChild:child];
  
  child = [[SdefCollection alloc] initWithName:NSLocalizedStringFromTable(@"Resp. to Cmds", @"SdefLibrary", @"Responds to Commands collection default name")];
  [child setContentType:[SdefRespondsTo class]];
  [child setElementName:@"responds-to-commands"];
  [self appendChild:child];
  
  child = [[SdefCollection alloc] initWithName:NSLocalizedStringFromTable(@"Resp. to Events", @"SdefLibrary", @"Responds to Events collection default name")];
  [child setContentType:[SdefRespondsTo class]];
  [child setElementName:@"responds-to-events"];
  [self appendChild:child];
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  if (recu) {
    [_contents setEditable:flag];
  }
  [super setEditable:flag recursive:recu];
}

#pragma mark -
- (NSString *)name {
  if ([self isExtension]) {
    return [self inherits] ? [[self inherits] stringByAppendingString:@"*"] : @"<undefined>";
  } else {
    return [super name];
  }
}
- (void)setName:(NSString *)name {
  if ([self isExtension]) {
    if (name && [name hasSuffix:@"*"])
      name = [name length] > 1 ? [name substringToIndex:[name length] - 1] : nil;
    [self setInherits:name];
  } else {
    [super setName:name];
  }
}

- (void)setExtension:(BOOL)extension {
  if (extension != _extension) {
    [self willChangeValueForKey:@"name"];
    [[[self undoManager] prepareWithInvocationTarget:self] setExtension:_extension];
    
    /* should be before _extension = ... to avoid multi notifications */
    if (extension && ![self inherits] && [self name])
      [self setInherits:[self name]];
    
    _extension = extension;
    [self didChangeValueForKey:@"name"];
    [self setIcon:[NSImage imageNamed:_extension ? @"Class-Extension" : @"Class"]];
    /* Nasty: should notify outline view controller */
    [[self notificationCenter] postNotificationName:WBUITreeNodeDidChangeNameNotification object:self];
  }
}

- (SdefContents *)contents {
  if (!_contents)
    [self setContents:[[SdefContents alloc] init]];
  
  return _contents;
}
- (void)setContents:(SdefContents *)contents {
  if (_contents != contents) {
    [_contents setOwner:nil];
    _contents = contents;
    [_contents setOwner:self];
  }
}

- (void)setPlural:(NSString *)newPlural {
  if (_plural != newPlural) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:_plural];
    SPXSetterCopy(_plural, newPlural);
  }
}

- (void)setInherits:(NSString *)newInherits {
  if (_inherits != newInherits) {
    if ([self isExtension])
      [self willChangeValueForKey:@"name"];
    
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:_inherits];
    SPXSetterCopy(_inherits, newInherits);
    
    if ([self isExtension]) {
      [self didChangeValueForKey:@"name"];
      /* Nasty: should notify outline view controller */
      [[self notificationCenter] postNotificationName:WBUITreeNodeDidChangeNameNotification object:self];
    }
  }
}

- (void)setType:(NSString *)type {
  if (_type != type) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:_type];
    SPXSetterCopy(_type, type);
  }
}

- (SdefCollection *)elements {
  return [self childAtIndex:0];
}

- (SdefCollection *)properties {
  return [self childAtIndex:1];
}

- (SdefCollection *)commands {
  return [self childAtIndex:2];
}

- (SdefCollection *)events {
  return [self childAtIndex:3];
}

@end

#pragma mark -
@implementation SdefElement

@synthesize access = _access;
@synthesize accessors = _accessors;

static NSSet *sAccessorSet = nil;
static NSSet *sAccessorPropertiesSet = nil;

+ (void)initialize {
  if ([SdefElement class] == self) {
    sAccessorSet = [NSSet setWithObject:@"accessors"];
    sAccessorPropertiesSet = [NSSet setWithObjects:
                              @"accIndex", @"accId", @"accName",
                              @"accRange", @"accRelative", @"accTest",
                              nil];
  }
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
  if ([sAccessorPropertiesSet containsObject:key])
    return sAccessorSet;
  return nil;
}

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefElement *copy = [super copyWithZone:aZone];
  copy->_access = _access;
  copy->_accessors = _accessors;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInt32:_access forKey:@"SEAccess"];
  [aCoder encodeInt32:_accessors forKey:@"SEAccessors"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _access = [aCoder decodeInt32ForKey:@"SEAccess"];
    _accessors = [aCoder decodeInt32ForKey:@"SEAccessors"];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Element;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"element", @"SdefLibrary", @"Element default name");
}

+ (NSString *)defaultIconName {
  return @"Element";
}

- (void)sdefInit {
  [super sdefInit];
  [self setIsLeaf:YES];
}

#pragma mark -
+ (NSSet *)keyPathsForValuesAffectingType {
  return [NSSet setWithObject:@"name"];
}

- (NSString *)type {
  return [self name];
}
- (void)setType:(NSString *)type {
  [super setName:type];
}

- (void)setAccess:(uint32_t)newAccess {
  if (_access != newAccess) {
    [[[self undoManager] prepareWithInvocationTarget:self] setAccess:_access];
    _access = newAccess;
  }
}

- (void)setAccessors:(uint32_t)accessors {
  if (_accessors != accessors) {
    [[[self undoManager] prepareWithInvocationTarget:self] setAccessors:_accessors];
    _accessors = accessors;
  }
}

#pragma mark -
#pragma mark Accessors KVC
- (BOOL)accIndex {
  return _accessors & kSdefAccessorIndex;
}
- (void)setAccIndex:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorIndex];
  else [self setAccessors:[self accessors] & ~kSdefAccessorIndex];
}

- (BOOL)accId {
  return (_accessors & kSdefAccessorID) != 0;
}
- (void)setAccId:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorID];
  else [self setAccessors:[self accessors] & ~kSdefAccessorID];
}

- (BOOL)accName {
  return (_accessors & kSdefAccessorName) != 0;
}
- (void)setAccName:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorName];
  else [self setAccessors:[self accessors] & ~kSdefAccessorName];
}

- (BOOL)accRange {
  return (_accessors & kSdefAccessorRange) != 0;
}
- (void)setAccRange:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorRange];
  else [self setAccessors:[self accessors] & ~kSdefAccessorRange];
}

- (BOOL)accRelative {
  return (_accessors & kSdefAccessorRelative) != 0;
}
- (void)setAccRelative:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorRelative];
  else [self setAccessors:[self accessors] & ~kSdefAccessorRelative];
}

- (BOOL)accTest {
  return (_accessors & kSdefAccessorTest) != 0;
}
- (void)setAccTest:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorTest];
  else [self setAccessors:[self accessors] & ~kSdefAccessorTest];
}

- (NSString *)cocoaKey {
  if (![[self impl] key]) {
    NSString *name = [self name];
    if (name) {
      SdefClass *cls = [[self classManager] classWithName:name];
      if (cls) {
        if ([cls plural]) {
          name = [cls plural];
        } else {
          name = [name stringByAppendingString:@"s"];
        }
      }
    }
    return CocoaNameForSdefName(name, NO);
  }
  return [[self impl] key];
}

@end

#pragma mark -
@implementation SdefProperty

@synthesize access = _access;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefProperty *copy = [super copyWithZone:aZone];
  copy->_access = _access;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInteger:_access forKey:@"SPAccess"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _access = [aCoder decodeInt32ForKey:@"SPAccess"];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Property;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"property", @"SdefLibrary", @"Property default name");
}

+ (NSString *)defaultIconName {
  return @"Property";
}

- (void)sdefInit {
  [super sdefInit];
  [self setIsLeaf:YES];
}

#pragma mark -
- (void)setAccess:(uint32_t)newAccess {
  [[[self undoManager] prepareWithInvocationTarget:self] setAccess:_access];
  _access = newAccess;
}

- (BOOL)isNotInProperties {
  return sd_soFlags.notinproperties;
}
- (void)setNotInProperties:(BOOL)flag {
  flag = flag ? 1 : 0;
  if (flag != sd_soFlags.notinproperties) {
    [[[self undoManager] prepareWithInvocationTarget:self] setNotInProperties:sd_soFlags.notinproperties];
    sd_soFlags.notinproperties = flag;
  }
}

@end

#pragma mark -
@implementation SdefRespondsTo
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefRespondsTo *copy = [super copyWithZone:aZone];
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
  return kSdefType_RespondsTo;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"method", @"SdefLibrary", @"Verb & Responds To default name.");
}
+ (NSString *)defaultIconName {
  return @"Member";
}

- (void)sdefInit {
  [super sdefInit];
  [self setIsLeaf:YES];
  sd_soFlags.hasDocumentation = 0;
}

@end
