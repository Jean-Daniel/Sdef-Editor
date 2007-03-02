/*
 *  SdefObject.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"


#import "SdefType.h"
#import "SdefSynonym.h"
#import "SdefDocument.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

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
    [sd_documentation setEditable:[self isEditable]];
  }	
}

@end

#pragma mark -
@implementation SdefImplementedObject
  SdefImplementation *sd_impl;
- (id)copyWithZone:(NSZone *)aZone {
  SdefImplementedObject *copy = [super copyWithZone:aZone];
  copy->sd_impl = [sd_impl copyWithZone:aZone];
  [copy->sd_impl setOwner:copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_impl forKey:@"STImplementation"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_impl = [[aCoder decodeObjectForKey:@"STImplementation"] retain];
  }
  return self;
}

- (void)dealloc {
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
    [sd_impl setEditable:[self isEditable]];
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
  return ([[self impl] sdClass]) ? : CocoaNameForSdefName([self name], YES);
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
  copy->sd_code = [sd_code copyWithZone:aZone];
  copy->sd_desc = [sd_desc copyWithZone:aZone];
  copy->sd_synonyms = [sd_synonyms copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_code forKey:@"STCodeStr"];
  [aCoder encodeObject:sd_desc forKey:@"STDescription"];
  [aCoder encodeObject:sd_synonyms forKey:@"STSynonyms"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_code = [[aCoder decodeObjectForKey:@"STCodeStr"] retain];
    sd_desc = [[aCoder decodeObjectForKey:@"STDescription"] retain];
    sd_synonyms = [[aCoder decodeObjectForKey:@"STSynonyms"] retain];
  }
  return self;
}

- (void)dealloc {
  [sd_code release];
  [sd_desc release];
  [sd_synonyms release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {name:\"%@\" code:'%@' hidden:%@}",
    NSStringFromClass([self class]), self,
    [self name], [self code], [self isHidden] ? @"YES" : @"NO"];
}

#pragma mark -
- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.hasSynonyms = 1;
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  if (recu) {
    id item;
    NSEnumerator *items = [sd_synonyms objectEnumerator];
    while (item = [items nextObject]) {
      [item setEditable:flag recursive:recu];
    }
  }
  [super setEditable:flag recursive:recu];
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

#pragma mark Synonyms KVC
- (NSArray *)synonyms {
  if (!sd_synonyms && sd_soFlags.hasSynonyms) {
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

- (unsigned)countOfSynonyms {
  return [sd_synonyms count];
}

- (id)objectInSynonymsAtIndex:(unsigned)anIndex {
  return [sd_synonyms objectAtIndex:anIndex];
}

- (void)addSynonym:(SdefSynonym *)aSynonym {
  [self synonyms];
  [self insertObject:aSynonym inSynonymsAtIndex:[self countOfSynonyms]];
}

- (void)insertObject:(id)object inSynonymsAtIndex:(unsigned)anIndex {
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] removeObjectFromSynonymsAtIndex:anIndex];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove Synonym", @"SdefLibrary", @"Undo Action: Add/Remove synonym.")];
  }
  [sd_synonyms insertObject:object atIndex:anIndex];
  [object setOwner:self];
}

- (void)removeObjectFromSynonymsAtIndex:(unsigned)anIndex {
  SdefSynonym *synonym = [sd_synonyms objectAtIndex:anIndex];
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] insertObject:synonym inSynonymsAtIndex:anIndex];
    [undo setActionName:NSLocalizedStringFromTable(@"Add/Remove Synonym", @"SdefLibrary", @"Undo Action: Add/Remove synonym.")];
  }
  [synonym setOwner:nil];
  [sd_synonyms removeObjectAtIndex:anIndex];
}

- (void)replaceObjectInSynonymsAtIndex:(unsigned)anIndex withObject:(id)object {
  SdefSynonym *synonym = [sd_synonyms objectAtIndex:anIndex];
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] replaceObjectAtIndex:anIndex withObject:synonym];
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
  unsigned idx;
  for (idx=0; idx<[sd_types count]; idx++) {
    if ([[sd_types objectAtIndex:idx] name] != nil) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)hasCustomType {
  unsigned count = [sd_types count];
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

- (unsigned)countOfTypes {
  return [sd_types count];
}

- (id)objectInTypesAtIndex:(unsigned)anIndex {
  return [sd_types objectAtIndex:anIndex];
}

- (void)insertObject:(id)object inTypesAtIndex:(unsigned)anIndex {
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

- (void)removeObjectFromTypesAtIndex:(unsigned)anIndex {
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

- (void)replaceObjectInTypesAtIndex:(unsigned)anIndex withObject:(id)object {
  SdefType *type = [sd_types objectAtIndex:anIndex];
  NSUndoManager *undo = [self undoManager];
  if (undo) {
    [[undo prepareWithInvocationTarget:self] replaceObjectAtIndex:anIndex withObject:type];
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
@implementation SdefOrphanObject
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefOrphanObject *copy = [super copyWithZone:aZone];
  copy->sd_owner = nil;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeConditionalObject:sd_owner forKey:@"SOOwner"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_owner = [aCoder decodeObjectForKey:@"SOOwner"];
  }
  return self;
}

#pragma mark Owner
- (id)owner {
  return sd_owner;
}

- (void)setOwner:(SdefObject *)anObject {
  sd_owner = anObject;
}

- (id)firstParentOfType:(SdefObjectType)aType {
  return [sd_owner firstParentOfType:aType];
}

@end

#pragma mark -
@implementation SdefTypedOrphanObject
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefTypedOrphanObject *copy = [super copyWithZone:aZone];
  copy->sd_owner = nil;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeConditionalObject:sd_owner forKey:@"SOOwner"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_owner = [aCoder decodeObjectForKey:@"SOOwner"];
  }
  return self;
}

#pragma mark Owner
- (id)owner {
  return sd_owner;
}

- (void)setOwner:(SdefObject *)anObject {
  sd_owner = anObject;
}

- (id)firstParentOfType:(SdefObjectType)aType {
  return [sd_owner firstParentOfType:aType];
}

@end


#pragma mark -
NSString *SdefTypeStringForTypes(NSArray *types) {
  NSMutableString *str = [[NSMutableString alloc] init];
  SdefType *type;
  NSEnumerator *items = [types objectEnumerator];
  while (type = [items nextObject]) {
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

NSArray *SdefTypesForTypeString(NSString *aType) {
  NSString *str;
  NSMutableArray *types = [[NSMutableArray alloc] init];
  NSEnumerator *strings = [[aType componentsSeparatedByString:@"|"] objectEnumerator];
  while (str = [strings nextObject]) {
    unsigned location;
    SdefType *type = nil;
    if ((location = [str rangeOfString:@"list of"].location) != NSNotFound) {
      type = [[SdefType alloc] initWithName:[str substringFromIndex:location + 8]];
      [type setList:YES];
    } else {
      type = [[SdefType alloc] initWithName:str];
    }
    [types addObject:type];
    [type release];
  }
  return [types autorelease];
}
