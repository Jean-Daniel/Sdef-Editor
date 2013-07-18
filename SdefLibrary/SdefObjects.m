/*
 *  SdefObject.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

#import "SdefType.h"
#import "SdefXRef.h"
#import "SdefSynonym.h"
#import "SdefDocument.h"
#import "SdefAccessGroup.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

#import <WonderBox/WBFunctions.h>

@implementation SdefDocumentedObject
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefDocumentedObject *copy = [super copyWithZone:aZone];
  copy->sd_documentation = [sd_documentation copyWithZone:aZone];
  [copy->sd_documentation setOwner:copy];
  return copy;
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_documentation = [[aCoder decodeObjectForKey:@"SODocumentation"] retain];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_documentation forKey:@"SODocumentation"];
}

#pragma mark -
- (void)dealloc {
  [sd_documentation setOwner:nil];
  [sd_documentation release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {parent: %@, type:%@, name:%@}",
    NSStringFromClass([self class]), self,
    [[self parent] name], NSFileTypeForHFSTypeCode([self objectType]), [self name]];
}

#pragma mark -
- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.hasDocumentation = 1;
}

#pragma mark Accessors
- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  if (recu) {
    [sd_documentation setEditable:flag];
  }
  [super setEditable:flag recursive:recu];
}

#pragma mark Optionals children
- (SdefDocumentation *)documentation {
  if (!sd_documentation && sd_soFlags.hasDocumentation) {
    SdefDocumentation *doc = [[SdefDocumentation allocWithZone:[self zone]] init];
    [self setDocumentation:doc];
    [doc release];
  }
  return sd_documentation;
}

- (void)setDocumentation:(SdefDocumentation *)doc {
  if (sd_documentation != doc) {
    [sd_documentation setOwner:nil];
    [sd_documentation release];
    sd_documentation = [doc retain];
    [sd_documentation setOwner:self];
  }	
}

@end

#pragma mark -
@implementation SdefImplementedObject

- (id)copyWithZone:(NSZone *)aZone {
  SdefImplementedObject *copy = [super copyWithZone:aZone];
  copy->sd_impl = [sd_impl copyWithZone:aZone];
  [copy->sd_impl setOwner:copy];
  copy->_accessGroup = [_accessGroup copyWithZone:aZone];
  [copy->_accessGroup setOwner:copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_impl forKey:@"STImplementation"];
  [aCoder encodeObject:_accessGroup forKey:@"STAccessGroup"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_impl = [[aCoder decodeObjectForKey:@"STImplementation"] retain];
    _accessGroup = [[aCoder decodeObjectForKey:@"STAccessGroup"] retain];
  }
  return self;
}

- (void)dealloc {
  [_accessGroup setOwner:nil];
  [_accessGroup release];
  [sd_impl setOwner:nil];
  [sd_impl release];
  [super dealloc];
}

#pragma mark -
- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.hasImplementation = 1;
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  if (recu) {
    [sd_impl setEditable:flag];
  }
  [super setEditable:flag recursive:recu];
}

- (SdefAccessGroup *)accessGroup {
  if (!_accessGroup && sd_soFlags.hasAccessGroup) {
    SdefAccessGroup *group = [[SdefAccessGroup alloc] init];
    self.accessGroup = group;
    [group release];
  }
  return _accessGroup;
}

- (void)setAccessGroup:(SdefAccessGroup *)accessGroup {
  if (_accessGroup != accessGroup) {
    [_accessGroup setOwner:nil];
    SPXSetterRetain(_accessGroup, accessGroup);
    [_accessGroup setOwner:self];
  }
}

- (SdefImplementation *)impl {
  if (!sd_impl && sd_soFlags.hasImplementation) {
    SdefImplementation *impl = [[SdefImplementation allocWithZone:[self zone]] init];
    [self setImpl:impl];
    [impl release];
  }
  return sd_impl;
}

- (void)setImpl:(SdefImplementation *)newImpl {
  if (sd_impl != newImpl) {
    [sd_impl setOwner:nil];
    [sd_impl release];
    sd_impl = [newImpl retain];
    [sd_impl setOwner:self];
  }
}

#pragma mark -
- (NSString *)cocoaKey {
  return ([[self impl] key]) ? : CocoaNameForSdefName([self name], NO);
}
- (NSString *)cocoaName {
  return ([[self impl] name]) ? : CocoaNameForSdefName([self name], YES);
}

- (NSString *)cocoaClass {
  return [self impl].className ? : CocoaNameForSdefName([self name], YES);
}

- (NSString *)cocoaMethod {
  return ([[self impl] method]) ? : CocoaNameForSdefName([self name], NO);
}

@end

#pragma mark -
@implementation SdefTerminologyObject
#pragma mark Protocols Implementation
- (id)copyWithZone:(NSZone *)aZone {
  SdefTerminologyObject *copy = [super copyWithZone:aZone];
  copy->sd_id = [sd_id copyWithZone:aZone];
  copy->sd_code = [sd_code copyWithZone:aZone];
  copy->sd_desc = [sd_desc copyWithZone:aZone];
  copy->sd_xrefs = [sd_synonyms copyWithZone:aZone];
  copy->sd_synonyms = [sd_synonyms copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_id forKey:@"STID"];
  [aCoder encodeObject:sd_code forKey:@"STCodeStr"];
  [aCoder encodeObject:sd_desc forKey:@"STDescription"];
  [aCoder encodeObject:sd_xrefs forKey:@"STXRefs"];
  [aCoder encodeObject:sd_synonyms forKey:@"STSynonyms"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_id = [[aCoder decodeObjectForKey:@"STID"] retain];
    sd_code = [[aCoder decodeObjectForKey:@"STCodeStr"] retain];
    sd_desc = [[aCoder decodeObjectForKey:@"STDescription"] retain];
    sd_xrefs = [[aCoder decodeObjectForKey:@"STXRefs"] retain];
    sd_synonyms = [[aCoder decodeObjectForKey:@"STSynonyms"] retain];
  }
  return self;
}

- (void)dealloc {
  [sd_id release];
  [sd_code release];
  [sd_desc release];
  [sd_xrefs release];
  [sd_synonyms release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {name:\"%@\" code:'%@' hidden:%@}",
    NSStringFromClass([self class]), self,
    [self name], [self code], self.hidden ? @"YES" : @"NO"];
}

#pragma mark -
- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.hasSynonyms = 1;
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  if (recu) {
    for (SdefObject *item in sd_synonyms) {
      [item setEditable:flag recursive:recu];
    }
  }
  [super setEditable:flag recursive:recu];
}

- (NSString *)xmlid {
  return sd_id;
}
- (void)setXmlid:(NSString *)anId {
  if (sd_id != anId) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_id];
    [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Change ID", @"SdefLibrary", @"Undo Action: Change id.")];
    [sd_id release];
    sd_id = [anId copyWithZone:[self zone]];
  }
}

- (NSString *)code {
  return sd_code;
}

- (void)setCode:(NSString *)str {
  if (sd_code != str) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_code];
    [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Change Code", @"SdefLibrary", @"Undo Action: Change code.")];
    [sd_code release];
    sd_code = [str copyWithZone:[self zone]];
  }
}

- (NSString *)desc {
  return sd_desc;
}

- (void)setDesc:(NSString *)aDescription {
  if (sd_desc != aDescription) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_desc];
    [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Change Description", @"SdefLibrary", @"Undo Action: Change description.")];
    [sd_desc release];
    sd_desc = [aDescription copyWithZone:[self zone]];
  }
}

#pragma mark XRefs KVC
- (NSArray *)xrefs {
  if (!sd_xrefs && [self hasXrefs])
    sd_xrefs = [[NSMutableArray alloc] init];
  return sd_xrefs;
}
- (void)setXrefs:(NSArray *)xrefs {
  if ([self hasXrefs]) {
    if (sd_xrefs != xrefs) {
      [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_xrefs];
      [sd_xrefs release];
      sd_xrefs = [xrefs mutableCopy];
      [sd_xrefs makeObjectsPerformSelector:@selector(setOwner:) withObject:self];
    }
  } else {
    [super setXrefs:xrefs];
  }
}

- (NSUInteger)countOfXrefs {
  return [sd_xrefs count];
}

- (id)objectInXrefsAtIndex:(NSUInteger)anIndex {
  return [sd_xrefs objectAtIndex:anIndex];
}

- (void)addXRef:(SdefXRef *)aRef {
  [self xrefs];
  [self insertObject:aRef inXrefsAtIndex:[self countOfXrefs]];
}

- (void)insertObject:(id)object inXrefsAtIndex:(NSUInteger)anIndex {
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] removeObjectFromXrefsAtIndex:anIndex];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove XRef", @"SdefLibrary", @"Undo Action: Add/Remove xref.")];
  }
  [sd_xrefs insertObject:object atIndex:anIndex];
  [object setOwner:self];
}

- (void)removeObjectFromXrefsAtIndex:(NSUInteger)anIndex {
  SdefXRef *ref = [sd_xrefs objectAtIndex:anIndex];
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] insertObject:ref inXrefsAtIndex:anIndex];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove XRef", @"SdefLibrary", @"Undo Action: Add/Remove xref.")];
  }
  [ref setOwner:nil];
  [sd_xrefs removeObjectAtIndex:anIndex];
}

- (void)replaceObjectInXrefsAtIndex:(NSUInteger)anIndex withObject:(id)object {
  SdefXRef *ref = [sd_xrefs objectAtIndex:anIndex];
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] replaceObjectInXrefsAtIndex:anIndex withObject:ref];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove XRef", @"SdefLibrary", @"Undo Action: Add/Remove xref.")];
  }
  [ref setOwner:nil];
  [sd_xrefs replaceObjectAtIndex:anIndex withObject:object];
  [object setOwner:self];
}

#pragma mark Synonyms KVC
- (NSArray *)synonyms {
  if (!sd_synonyms && [self hasSynonyms]) {
    sd_synonyms = [[NSMutableArray allocWithZone:[self zone]] init];
  }
  return sd_synonyms;
}

- (void)setSynonyms:(NSArray *)synonyms {
  if (sd_synonyms != synonyms) {
    NSUndoManager *undo = [self undoManager];
    if (undo) {
      [undo registerUndoWithTarget:self selector:_cmd object:sd_synonyms];
    }
    [sd_synonyms release];
    sd_synonyms = [synonyms mutableCopy];
    [sd_synonyms makeObjectsPerformSelector:@selector(setOwner:) withObject:self];
  }
}

- (NSUInteger)countOfSynonyms {
  return [sd_synonyms count];
}

- (id)objectInSynonymsAtIndex:(NSUInteger)anIndex {
  return [sd_synonyms objectAtIndex:anIndex];
}

- (void)addSynonym:(SdefSynonym *)aSynonym {
  [self synonyms];
  [self insertObject:aSynonym inSynonymsAtIndex:[self countOfSynonyms]];
}

- (void)insertObject:(id)object inSynonymsAtIndex:(NSUInteger)anIndex {
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] removeObjectFromSynonymsAtIndex:anIndex];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove Synonym", @"SdefLibrary", @"Undo Action: Add/Remove synonym.")];
  }
  [sd_synonyms insertObject:object atIndex:anIndex];
  [object setOwner:self];
}

- (void)removeObjectFromSynonymsAtIndex:(NSUInteger)anIndex {
  SdefSynonym *synonym = [sd_synonyms objectAtIndex:anIndex];
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] insertObject:synonym inSynonymsAtIndex:anIndex];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove Synonym", @"SdefLibrary", @"Undo Action: Add/Remove synonym.")];
  }
  [synonym setOwner:nil];
  [sd_synonyms removeObjectAtIndex:anIndex];
}

- (void)replaceObjectInSynonymsAtIndex:(NSUInteger)anIndex withObject:(id)object {
  SdefSynonym *synonym = [sd_synonyms objectAtIndex:anIndex];
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] replaceObjectInSynonymsAtIndex:anIndex withObject:synonym];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove Synonym", @"SdefLibrary", @"Undo Action: Add/Remove synonym.")];
  }
  [synonym setOwner:nil];
  [sd_synonyms replaceObjectAtIndex:anIndex withObject:object];
  [object setOwner:self];
}

@end

#pragma mark -
@implementation SdefTypedObject
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefTypedObject *copy = [super copyWithZone:aZone];
  copy->sd_types = [sd_types copyWithZone:aZone];
  return copy;
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_types = [[aCoder decodeObjectForKey:@"STTypes"] retain];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_types forKey:@"STTypes"];
}

#pragma mark -
- (id)initWithName:(NSString *)name icon:(NSImage *)icon {
  if (self = [super initWithName:name icon:icon]) {
    sd_types = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [sd_types release];
  [super dealloc];
}

#pragma mark -
- (BOOL)hasType {
  for (NSUInteger idx = 0; idx < [sd_types count]; idx++) {
    if ([[sd_types objectAtIndex:idx] name]) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)hasCustomType {
  NSUInteger count = [sd_types count];
  return count > 1 || (count > 0 && [[sd_types objectAtIndex:0] isList]);
}

- (NSString *)type {
  if ([self hasCustomType]) {
    return SdefTypeStringForTypes(sd_types);
  } else if ([self hasType]) {
    return [[sd_types objectAtIndex:0] name];
  } else return nil;
}
- (void)setType:(NSString *)aType {
  [self setTypes:SdefTypesForTypeString(aType)];
}

- (void)addType:(SdefType *)aType {
  [self insertObject:aType inTypesAtIndex:[self countOfTypes]];
}

#pragma mark -
#pragma mark Types KVC compliance
- (NSArray *)types {
  return sd_types;
}

- (void)setTypes:(NSArray *)objects {
  if (sd_types != objects) {
    NSUndoManager *undo = [self undoManager];
    if (undo) {
      [undo registerUndoWithTarget:self selector:_cmd object:sd_types];
      [undo setActionName:NSLocalizedStringFromTable(@"Change Types", @"SdefLibrary", @"Undo Action: Change type.")];
    }
    [self willChangeValueForKey:@"type"];
    [sd_types release];
    sd_types = [objects mutableCopy];
    [self didChangeValueForKey:@"type"];
    [sd_types makeObjectsPerformSelector:@selector(setOwner:) withObject:self];
  }
}

- (NSUInteger)countOfTypes {
  return [sd_types count];
}

- (id)objectInTypesAtIndex:(NSUInteger)anIndex {
  return [sd_types objectAtIndex:anIndex];
}

- (void)insertObject:(id)object inTypesAtIndex:(NSUInteger)anIndex {
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] removeObjectFromTypesAtIndex:anIndex];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove Type", @"SdefLibrary", @"Undo Action: Add/Remove type.")];
  }
  [self willChangeValueForKey:@"type"];
  [sd_types insertObject:object atIndex:anIndex];
  [self didChangeValueForKey:@"type"];
  [object setOwner:self];
}

- (void)removeObjectFromTypesAtIndex:(NSUInteger)anIndex {
  SdefType *type = [sd_types objectAtIndex:anIndex];
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] insertObject:type inTypesAtIndex:anIndex];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove Type", @"SdefLibrary", @"Undo Action: Add/Remove type.")];
  }
  [type setOwner:nil];
  [self willChangeValueForKey:@"type"];
  [sd_types removeObjectAtIndex:anIndex];
  [self didChangeValueForKey:@"type"];
}

- (void)replaceObjectInTypesAtIndex:(NSUInteger)anIndex withObject:(id)object {
  SdefType *type = [sd_types objectAtIndex:anIndex];
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] replaceObjectInTypesAtIndex:anIndex withObject:type];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove Type", @"SdefLibrary", @"Undo Action: Add/Remove type.")];
  }
  [type setOwner:nil];
  [self willChangeValueForKey:@"type"];
  [sd_types replaceObjectAtIndex:anIndex withObject:object];
  [self didChangeValueForKey:@"type"];
  [object setOwner:self];
}

@end

#pragma mark -
@implementation SdefTypedOrphanObject

@synthesize owner = _owner;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefTypedOrphanObject *copy = [super copyWithZone:aZone];
  copy->_owner = nil;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeConditionalObject:_owner forKey:@"SOOwner"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _owner = [aCoder decodeObjectForKey:@"SOOwner"];
  }
  return self;
}

#pragma mark Owner
/* Note: Must be keeped in sync with SdefLeaf */
//- (void)setOwner:(NSObject<SdefObject> *)anObject {
//  sd_owner = anObject;
  /* inherited flags */
//  if (sd_owner)
//    [self setEditable:[sd_owner isEditable]];
//}

- (NSString *)location {
  NSString *owner = [_owner name];
  NSString *loc = [_owner location];
  if (loc && owner) {
    return [loc stringByAppendingFormat:@":%@->%@", owner, [self objectTypeName]];
  } else if (loc) {
    return [loc stringByAppendingFormat:@"->%@", [self objectTypeName]];
  } else if (owner) {
    return [owner stringByAppendingFormat:@"->%@", [self objectTypeName]];
  } 
  return [self objectTypeName];
}

- (SdefObject *)container {
  return [_owner container];
}

- (SdefDictionary *)dictionary {
  return [_owner dictionary];
}

- (NSUndoManager *)undoManager {
  return [_owner undoManager];
}

/* Needed to be owner of an orphan object (like SdefImplementation) */
- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType {
  return [_owner firstParentOfType:aType];
}

@end


#pragma mark -
NSString *SdefTypeStringForTypes(NSArray *types) {
  NSMutableString *str = [[NSMutableString alloc] init];
  NSUInteger count = [types count];
  for (NSUInteger idx = 0; idx < count; idx++) {
    SdefType *type = [types objectAtIndex:idx];
    if ([type name]) {
      if ([str length] > 0) {
        [str appendString:@" | "];
      }
      if ([type isList]) {
        [str appendString:@"list of "];
      }
      [str appendString:[type name]];
    }
  }
  return [str autorelease];
}

WB_INLINE
SdefType *__SdefTypeFromString(NSString *str) {
  NSUInteger location;
  SdefType *type = nil;
  if ((location = [str rangeOfString:@"list of"].location) != NSNotFound) {
    type = [[SdefType alloc] initWithName:[str substringFromIndex:location + 8]];
    [type setList:YES];
  } else {
    type = [[SdefType alloc] initWithName:str];
  }
  return [type autorelease];
}

NSArray *SdefTypesForTypeString(NSString *aType) {
  NSArray *types = nil;
  if ([aType rangeOfString:@"|"].location != NSNotFound) {
    NSMutableArray *mtypes = [[NSMutableArray alloc] init];
    for (NSString *str in [aType componentsSeparatedByString:@"|"]) {
      [mtypes addObject:__SdefTypeFromString(str)];
    }
    types = mtypes;
  } else {
    types = [[NSArray alloc] initWithObjects:__SdefTypeFromString(aType), nil];
  }
  return [types autorelease];
}

Boolean SdefTypeStringEqual(NSString *c1, NSString *c2) {
  NSUInteger l1 = [c1 length], l2 = [c2 length];
  if (l1 == l2)
    return [c1 isEqualToString:c2];
  return SdefOSTypeFromString(c1) == SdefOSTypeFromString(c2);
}

NSString *SdefStringForOSType(OSType type) {
  char *chrs = (char *)&type;
  NSString *str = WBStringForOSType(type);
  /* If invalid string or contains white space */
  if (!str || isspace(chrs[0]) || isspace(chrs[3])) {
    str = [NSString stringWithFormat:@"0x%.8x", (unsigned int)type];
  }
  return str;
}

OSType SdefOSTypeFromString(NSString *string) {
  switch ([string length]) {
    case 4:
      return WBOSTypeFromString(string);
    case 6:
      if ([string hasPrefix:@"'"] && [string hasSuffix:@"'"])
        return NSHFSTypeCodeFromFileType(string);
      break;
    case 10:
      if ([string hasPrefix:@"0x"]) {
        const char *cstr = [string UTF8String];
        return cstr ? (OSType)strtol(cstr, NULL, 16) : 0;
      }
      break;
  }
  return kLSUnknownType;
}
