//
//  SdefClass.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefClass.h"
#import "SdefContents.h"
#import "SdefDocument.h"
#import "SdefDocumentation.h"

@implementation SdefClass
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefClass *copy = [super copyWithZone:aZone];
  copy->sd_plural = [sd_plural copyWithZone:aZone];
  copy->sd_inherits = [sd_inherits copyWithZone:aZone];
  copy->sd_contents = [sd_contents copyWithZone:aZone];
  [copy->sd_contents setOwner:copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_plural forKey:@"SCPlural"];
  [aCoder encodeObject:sd_inherits forKey:@"SCInherits"];
  [aCoder encodeObject:sd_contents forKey:@"SCContents"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_plural = [[aCoder decodeObjectForKey:@"SCPlural"] retain];
    sd_inherits = [[aCoder decodeObjectForKey:@"SCInherits"] retain];
    sd_contents = [[aCoder decodeObjectForKey:@"SCContents"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefClassType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"class name", @"SdefLibrary", @"Class default name");
}

+ (NSString *)defaultIconName {
  return @"Class";
}

- (void)dealloc {
  [sd_contents setOwner:nil];
  [sd_plural release];
  [sd_inherits release];
  [sd_contents release];
  [super dealloc];
}

- (void)createContent {
  [super createContent];
  sd_soFlags.hasSynonyms = 1;
  sd_soFlags.hasDocumentation = 1;
  NSZone *zone = [self zone];
  SdefContents *contents = [[SdefContents allocWithZone:zone] init];
  [self setContents:contents];
  [contents release];
  
  id child = [[SdefCollection allocWithZone:zone] initWithName:NSLocalizedStringFromTable(@"Elements", @"SdefLibrary", @"Elements collection default name")];
  [child setContentType:[SdefElement class]];
  [child setElementName:@"elements"];
  [self appendChild:child];
  [child release];
  
  child = [[SdefCollection allocWithZone:zone] initWithName:NSLocalizedStringFromTable(@"Properties", @"SdefLibrary", @"Properties collection default name")];
  [child setContentType:[SdefProperty class]];
  [child setElementName:@"properties"];
  [self appendChild:child];
  [child release];
  
  child = [[SdefCollection allocWithZone:zone] initWithName:NSLocalizedStringFromTable(@"Resp. to Cmds", @"SdefLibrary", @"Responds to Commands collection default name")];
  [child setContentType:[SdefRespondsTo class]];
  [child setElementName:@"responds-to-commands"];
  [self appendChild:child];
  [child release];
  
  child = [[SdefCollection allocWithZone:zone] initWithName:NSLocalizedStringFromTable(@"Resp. to Events", @"SdefLibrary", @"Responds to Events collection default name")];
  [child setContentType:[SdefRespondsTo class]];
  [child setElementName:@"responds-to-events"];
  [self appendChild:child];
  [child release];
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  if (recu) {
    [sd_contents setEditable:flag];
  }
  [super setEditable:flag recursive:recu];
}

#pragma mark -

- (SdefContents *)contents {
  return sd_contents;
}

- (void)setContents:(SdefContents *)contents {
  if (sd_contents != contents) {
    [sd_contents setOwner:nil];
    [sd_contents release];
    sd_contents = [contents retain];
    [sd_contents setOwner:self];
    [sd_contents setEditable:[self isEditable]];
  }
}

- (NSString *)plural {
  return sd_plural;
}

- (void)setPlural:(NSString *)newPlural {
  if (sd_plural != newPlural) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_plural];
    [sd_plural release];
    sd_plural = [newPlural copyWithZone:[self zone]];
  }
}

- (NSString *)inherits {
  return sd_inherits;
}

- (void)setInherits:(NSString *)newInherits {
  if (sd_inherits != newInherits) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_inherits];
    [sd_inherits release];
    sd_inherits = [newInherits copyWithZone:[self zone]];
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

+ (void)initialize {
  [self setKeys:[NSArray arrayWithObject:@"name"] triggerChangeNotificationsForDependentKey:@"type"];
  id accessors = [NSArray arrayWithObject:@"accessors"]; 
  [self setKeys:accessors triggerChangeNotificationsForDependentKey:@"accIndex"];
  [self setKeys:accessors triggerChangeNotificationsForDependentKey:@"accId"];
  [self setKeys:accessors triggerChangeNotificationsForDependentKey:@"accName"];
  [self setKeys:accessors triggerChangeNotificationsForDependentKey:@"accRange"];
  [self setKeys:accessors triggerChangeNotificationsForDependentKey:@"accRelative"];
  [self setKeys:accessors triggerChangeNotificationsForDependentKey:@"accTest"];
}

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefElement *copy = [super copyWithZone:aZone];
  copy->sd_access = sd_access;
  copy->sd_accessors = sd_accessors;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInt:sd_access forKey:@"SEAccess"];
  [aCoder encodeInt:sd_accessors forKey:@"SEAccessors"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_access = [aCoder decodeIntForKey:@"SEAccess"];
    sd_accessors = [aCoder decodeIntForKey:@"SEAccessors"];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefElementType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"element", @"SdefLibrary", @"Element default name");
}

+ (NSString *)defaultIconName {
  return @"Variable";
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark -
- (NSString *)type {
  return [self name];
}

- (void)setType:(NSString *)type {
  [super setName:type];
}

- (unsigned)access {
  return sd_access;
}

- (void)setAccess:(unsigned)newAccess {
  if (sd_access != newAccess) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setAccess:sd_access];
    sd_access = newAccess;
  }
}

- (unsigned)accessors {
  return sd_accessors;
}

- (void)setAccessors:(unsigned)accessors {
  if (sd_accessors != accessors) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setAccessors:sd_accessors];
    sd_accessors = accessors;
  }
}

#pragma mark -
#pragma mark Accessors KVC
- (BOOL)accIndex {
  return sd_accessors & kSdefAccessorIndex;
}
- (void)setAccIndex:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorIndex];
  else [self setAccessors:[self accessors] & ~kSdefAccessorIndex];
}

- (BOOL)accId {
  return sd_accessors & kSdefAccessorID;
}
- (void)setAccId:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorID];
  else [self setAccessors:[self accessors] & ~kSdefAccessorID];
}

- (BOOL)accName {
  return sd_accessors & kSdefAccessorName;
}
- (void)setAccName:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorName];
  else [self setAccessors:[self accessors] & ~kSdefAccessorName];
}

- (BOOL)accRange {
  return sd_accessors & kSdefAccessorRange;
}
- (void)setAccRange:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorRange];
  else [self setAccessors:[self accessors] & ~kSdefAccessorRange];
}

- (BOOL)accRelative {
  return sd_accessors & kSdefAccessorRelative;
}
- (void)setAccRelative:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorRelative];
  else [self setAccessors:[self accessors] & ~kSdefAccessorRelative];
}

- (BOOL)accTest {
  return sd_accessors & kSdefAccessorTest;
}
- (void)setAccTest:(BOOL)flag {
  if (flag) [self setAccessors:[self accessors] | kSdefAccessorTest];
  else [self setAccessors:[self accessors] & ~kSdefAccessorTest];
}

@end

#pragma mark -
@implementation SdefProperty
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefProperty *copy = [super copyWithZone:aZone];
  copy->sd_access = sd_access;
  copy->sd_type = [sd_type copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_type forKey:@"SPType"];
  [aCoder encodeInt:sd_access forKey:@"SPAccess"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_access = [aCoder decodeIntForKey:@"SPAccess"];
    sd_type = [[aCoder decodeObjectForKey:@"SPType"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefPropertyType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"property", @"SdefLibrary", @"Property default name");
}

+ (NSString *)defaultIconName {
  return @"Variable";
}

- (void)dealloc {
  [sd_type release];
  [super dealloc];
}

- (void)createContent {
  [super createContent];
  sd_soFlags.hasSynonyms = 1;
}

#pragma mark -
- (NSString *)type {
  return sd_type;
}

- (void)setType:(NSString *)aType {
  if (sd_type != aType) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_type];
    [sd_type release];
    sd_type = [aType copyWithZone:[self zone]];
  }
}

- (unsigned)access {
  return sd_access;
}
- (void)setAccess:(unsigned)newAccess {
  [[[[self document] undoManager] prepareWithInvocationTarget:self] setAccess:sd_access];
  sd_access = newAccess;
}

- (BOOL)isNotInProperties {
  return sd_soFlags.notInProperties;
}
- (void)setNotInProperties:(BOOL)flag {
  flag = flag ? 1 : 0;
  if (flag != sd_soFlags.notInProperties) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setNotInProperties:sd_soFlags.notInProperties];
    sd_soFlags.notInProperties = flag;
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
  return kSdefRespondsToType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"method", @"SdefLibrary", @"Respond-To default name");
}
+ (NSString *)defaultIconName {
  return @"Member";
}

@end
