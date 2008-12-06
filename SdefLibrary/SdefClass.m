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

@implementation SdefClass
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefClass *copy = [super copyWithZone:aZone];
  copy->sd_type = [sd_type copyWithZone:aZone];
  copy->sd_plural = [sd_plural copyWithZone:aZone];
  copy->sd_inherits = [sd_inherits copyWithZone:aZone];
  copy->sd_contents = [sd_contents copyWithZone:aZone];
  [copy->sd_contents setOwner:copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_type forKey:@"SCType"];
  [aCoder encodeObject:sd_plural forKey:@"SCPlural"];
  [aCoder encodeObject:sd_inherits forKey:@"SCInherits"];
  [aCoder encodeObject:sd_contents forKey:@"SCContents"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_type = [[aCoder decodeObjectForKey:@"SCType"] retain];
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

- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.xid = 1;
  sd_soFlags.xrefs = 1;
  
  NSZone *zone = [self zone];
  SdefCollection *child = [[SdefCollection allocWithZone:zone] initWithName:NSLocalizedStringFromTable(@"Elements", @"SdefLibrary", @"Elements collection default name")];
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

- (BOOL)isExtension {
  return sd_extension;
}
- (void)setExtension:(BOOL)extension {
  if (extension != sd_extension) {
    [self willChangeValueForKey:@"name"];
    [[[self undoManager] prepareWithInvocationTarget:self] setExtension:sd_extension];
    
    /* should be before sd_extension = ... to avoid multi notifications */
    if (extension && ![self inherits] && [self name])
      [self setInherits:[self name]];
    
    sd_extension = extension;
    [self didChangeValueForKey:@"name"];
    [self setIcon:[NSImage imageNamed:sd_extension ? @"Class-Extension" : @"Class"]];
    /* Nasty: should notify outline view controller */
    [[self notificationCenter] postNotificationName:WBUITreeNodeDidChangeNameNotification object:self];
  }
}

- (SdefContents *)contents {
  if (!sd_contents)
    [self setContents:[[[SdefContents alloc] init] autorelease]];
  
  return sd_contents;
}
- (void)setContents:(SdefContents *)contents {
  if (sd_contents != contents) {
    [sd_contents setOwner:nil];
    [sd_contents release];
    sd_contents = [contents retain];
    [sd_contents setOwner:self];
  }
}

- (NSString *)plural {
  return sd_plural;
}
- (void)setPlural:(NSString *)newPlural {
  if (sd_plural != newPlural) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_plural];
    [sd_plural release];
    sd_plural = [newPlural copyWithZone:[self zone]];
  }
}

- (NSString *)inherits {
  return sd_inherits;
}
- (void)setInherits:(NSString *)newInherits {
  if (sd_inherits != newInherits) {
    if ([self isExtension])
      [self willChangeValueForKey:@"name"];
    
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_inherits];
    [sd_inherits release];
    sd_inherits = [newInherits copyWithZone:[self zone]];
    
    if ([self isExtension]) {
      [self didChangeValueForKey:@"name"];
      /* Nasty: should notify outline view controller */
      [[self notificationCenter] postNotificationName:WBUITreeNodeDidChangeNameNotification object:self];
    }
  }
}

- (NSString *)type {
  return sd_type;
}
- (void)setType:(NSString *)type {
  if (sd_type != type) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_type];
    [sd_type release];
    sd_type = [type copyWithZone:[self zone]];
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
  WBEncodeInteger(aCoder, sd_access, @"SEAccess");
  WBEncodeInteger(aCoder, sd_accessors, @"SEAccessors");
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_access = WBDecodeInteger(aCoder, @"SEAccess");
    sd_accessors = WBDecodeInteger(aCoder, @"SEAccessors");
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
  return @"Element";
}

- (void)sdefInit {
  [super sdefInit];
  [self setLeaf:YES];
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

- (NSUInteger)access {
  return sd_access;
}

- (void)setAccess:(NSUInteger)newAccess {
  if (sd_access != newAccess) {
    [[[self undoManager] prepareWithInvocationTarget:self] setAccess:sd_access];
    sd_access = newAccess;
  }
}

- (NSUInteger)accessors {
  return sd_accessors;
}

- (void)setAccessors:(NSUInteger)accessors {
  if (sd_accessors != accessors) {
    [[[self undoManager] prepareWithInvocationTarget:self] setAccessors:sd_accessors];
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
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefProperty *copy = [super copyWithZone:aZone];
  copy->sd_access = sd_access;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  WBEncodeInteger(aCoder, sd_access, @"SPAccess");
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_access = WBDecodeInteger(aCoder, @"SPAccess");
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
  return @"Property";
}

- (void)sdefInit {
  [super sdefInit];
  [self setLeaf:YES];
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark -
- (NSUInteger)access {
  return sd_access;
}
- (void)setAccess:(NSUInteger)newAccess {
  [[[self undoManager] prepareWithInvocationTarget:self] setAccess:sd_access];
  sd_access = newAccess;
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
  return kSdefRespondsToType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"method", @"SdefLibrary", @"Verb & Responds To default name.");
}
+ (NSString *)defaultIconName {
  return @"Member";
}

- (void)sdefInit {
  [super sdefInit];
  [self setLeaf:YES];
  sd_soFlags.hasDocumentation = 0;
}

@end
