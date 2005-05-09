//
//  SdefObject.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObjects.h"

#import "ShadowMacros.h"

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
  return [NSString stringWithFormat:@"<%@ %p> {name:\"%@\" code:'%@' hidden:%@ \n\timpl:%@}",
    NSStringFromClass([self class]), self,
    [self name], [self codeStr], [self isHidden] ? @"YES" : @"NO", [self impl]];
}

#pragma mark -
- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.hasSynonyms = 1;
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  if (recu) {
    [sd_synonyms setEditable:flag recursive:recu];
  }
  [super setEditable:flag recursive:recu];
}

//- (BOOL)validateCodeStr:(id *)ioValue error:(NSError **)error {
//  NSString *str = *ioValue;
//  if ([str length] < 4) {
//    *ioValue = @"****";
//  } else if ([str length] > 4) {
//    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if ([str length] > 4)
//      *ioValue = [str substringToIndex:4];
//    else 
//      *ioValue = str;
//  }
//  return YES;
//}

- (NSString *)codeStr {
  return sd_code;
}

- (void)setCodeStr:(NSString *)str {
  if (sd_code != str) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_code];
    //[[self undoManager] setActionName:@"Code"];
    [sd_code release];
    sd_code = [str copyWithZone:[self zone]];
  }
}

- (NSString *)desc {
  return sd_desc;
}

- (void)setDesc:(NSString *)newDesc {
  if (sd_desc != newDesc) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_desc];
    //[[self undoManager] setActionName:@"Desc"];
    [sd_desc release];
    sd_desc = [newDesc copyWithZone:[self zone]];
  }
}

#pragma mark Synonyms
- (SdefCollection *)synonyms {
  if (!sd_synonyms && sd_soFlags.hasSynonyms) {
    id synonyms = [[SdefCollection allocWithZone:[self zone]] initWithName:NSLocalizedStringFromTable(@"Synonyms", @"SdefLibrary", @"Synonyms Collection name")];
    [synonyms setContentType:[SdefSynonym class]];
    [synonyms setElementName:@"synonyms"];
    [self setSynonyms:synonyms];
    [synonyms release];
  }
  return sd_synonyms;
}

- (void)setSynonyms:(SdefCollection *)synonyms {
  if (sd_synonyms != synonyms) {
    [sd_synonyms release];
    sd_synonyms = [synonyms retain];
    [sd_synonyms setEditable:[self isEditable]];
  }
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
- (void)dealloc {
  [sd_types release];
  [super dealloc];
}

#pragma mark -
- (BOOL)hasType {
  return sd_types != nil;
}

- (id)type {
  return sd_types;
}
- (void)setType:(id)aType {
  if (sd_types != aType) {
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_types];
    [sd_types release];
    sd_types = [aType copyWithZone:[self zone]];
  }
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
  return [[self owner] firstParentOfType:aType];
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
  return [[self owner] firstParentOfType:aType];
}

@end
