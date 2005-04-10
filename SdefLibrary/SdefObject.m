//
//  SdefObject.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"
#import "SdefXMLObject.h"

#import "ShadowMacros.h"
#import "SKFunctions.h"
#import "SKExtensions.h"

#import "SdefComment.h"
#import "SdefSynonym.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

NSString * const SdefNewTreeNode = @"SdefNewTreeNode";
NSString * const SdefRemovedTreeNode = @"SdefRemovedTreeNode";
NSString * const SdefObjectDidAppendChildNotification = @"SdefObjectDidAppendChild";
NSString * const SdefObjectWillRemoveChildNotification = @"SdefObjectWillRemoveChild";
NSString * const SdefObjectDidRemoveChildNotification = @"SdefObjectDidRemoveChild";
NSString * const SdefObjectWillRemoveAllChildrenNotification = @"SdefObjectWillRemoveAllChildren";
NSString * const SdefObjectDidRemoveAllChildrenNotification = @"SdefObjectDidRemoveAllChildren";
NSString * const SdefObjectDidSortChildrenNotification = @"SdefObjectDidSortChildren";

NSString * const SdefObjectWillChangeNameNotification = @"SdefObjectWillChangeName";
NSString * const SdefObjectDidChangeNameNotification = @"SdefObjectDidChangeName";

@implementation SdefObject
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefObject *copy = [super copyWithZone:aZone];
  copy->sd_flags = sd_flags;  
  copy->sd_name = [sd_name copyWithZone:aZone];
  copy->sd_icon = [sd_icon copyWithZone:aZone];
  copy->sd_comments = [sd_comments copyWithZone:aZone];
  copy->sd_synonyms = [sd_synonyms copyWithZone:aZone];
  copy->sd_documentation = [sd_documentation copyWithZone:aZone];
  [copy->sd_documentation setOwner:copy];
  return copy;
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    unsigned length;
    const uint8_t*buffer = [aCoder decodeBytesForKey:@"SOFlags" returnedLength:&length];
    memcpy(&sd_flags, buffer, length);

    sd_name = [[aCoder decodeObjectForKey:@"SOName"] retain];
    sd_icon = [[aCoder decodeObjectForKey:@"SOIcon"] retain];
    sd_comments = [[aCoder decodeObjectForKey:@"SOComments"] retain];
    sd_synonyms = [[aCoder decodeObjectForKey:@"SOSynonyms"] retain];
    sd_documentation = [[aCoder decodeObjectForKey:@"SODocumentation"] retain];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeBytes:(const void *)&sd_flags length:sizeof(sd_flags) forKey:@"SOFlags"];
  [aCoder encodeObject:sd_name forKey:@"SOName"];
  [aCoder encodeObject:sd_icon forKey:@"SOIcon"];
  [aCoder encodeObject:sd_comments forKey:@"SOComments"];
  [aCoder encodeObject:sd_synonyms forKey:@"SOSynonyms"];
  [aCoder encodeObject:sd_documentation forKey:@"SODocumentation"];
}

#pragma mark -
+ (void)initialize {
  BOOL tooLate = NO;
  if (!tooLate) {
    [self exposeBinding:@"icon"];
    [self exposeBinding:@"name"];
    tooLate = YES;
  }
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
  return ![key isEqualToString:@"children"] && ![key isEqualToString:@"name"];
}

+ (SdefObjectType)objectType {
  return kSdefUndefinedType;
}

+ (NSString *)defaultName {
  return nil;
}

+ (NSString *)defaultIconName {
  return @"Misc";
}

#pragma mark -
+ (id)emptyNode {
  return [[[self alloc] initEmpty] autorelease];
}

+ (id)nodeWithName:(NSString *)newName {
  return [[[self alloc] initWithName:newName] autorelease];
}

#pragma mark -
- (id)init {
  if (self = [self initEmpty]) {
    [self setName:[[self class] defaultName]];
    [self createContent];
  }
  return self;
}

- (id)initEmpty {
  if (self = [super init]) {
    [self setIcon:[NSImage imageNamed:[[self class] defaultIconName]]];
    [self setRemovable:YES];
    [self setEditable:YES];
  }
  return self;
}

- (id)initWithName:(NSString *)newName {
  if (self = [self init]) {
    [self setName:newName];
  }
  return self;
}

- (void)dealloc {
  [sd_icon release];
  [sd_name release];
  [sd_synonyms release];
  [sd_comments release];
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
#pragma mark Notifications
- (void)appendChild:(SKTreeNode *)child {
  [[[self document] undoManager] registerUndoWithTarget:child selector:@selector(remove) object:nil];
  //[[[self document] undoManager] setActionName:@"Add Object"];
  NSIndexSet *idxSet = [NSIndexSet indexSetWithIndex:[self childCount]];
  [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:idxSet forKey:@"children"];
  [super appendChild:child];
  [(SdefObject *)child setEditable:[self isEditable]];
  [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:idxSet forKey:@"children"];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidAppendChildNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:child forKey:SdefNewTreeNode]];
}

- (void)prependChild:(SKTreeNode *)child {
  [[[self document] undoManager] registerUndoWithTarget:child selector:@selector(remove) object:nil];
  //[[[self document] undoManager] setActionName:@"Add Object"];
  [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:0] forKey:@"children"];
  [super prependChild:child];
  [(SdefObject *)child setEditable:[self isEditable]];
  [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:0] forKey:@"children"];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidAppendChildNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:child forKey:SdefNewTreeNode]];
}

- (void)insertChild:(id)child atIndex:(unsigned)idx {
  /* Super call prepend or insertSibling, so no need to undo & notify here. */
  [super insertChild:child atIndex:idx];
  //[[[self document] undoManager] setActionName:@"Insert Object"];
}

- (void)insertSibling:(SKTreeNode *)newSibling {
  [[[self document] undoManager] registerUndoWithTarget:newSibling selector:@selector(remove) object:nil];
  //[[[self document] undoManager] setActionName:@"Insert Object"];
  id parent = [self parent];
  id idx = [NSIndexSet indexSetWithIndex:[parent indexOfChild:self] + 1];
  [parent willChange:NSKeyValueChangeInsertion valuesAtIndexes:idx forKey:@"children"];
  [super insertSibling:newSibling];
  [(SdefObject *)newSibling setEditable:[self isEditable]];
  [parent didChange:NSKeyValueChangeInsertion valuesAtIndexes:idx forKey:@"children"];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidAppendChildNotification
                                                      object:[self parent]
                                                    userInfo:[NSDictionary dictionaryWithObject:newSibling forKey:SdefNewTreeNode]];
}

- (void)remove {
  id parent = [self parent];
  unsigned idx = [parent indexOfChild:self];
  [[[[self document] undoManager] prepareWithInvocationTarget:parent] insertChild:self atIndex:idx];
  //[[[self document] undoManager] setActionName:@"Remove Object"];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectWillRemoveChildNotification
                                                      object:[self parent]
                                                    userInfo:[NSDictionary dictionaryWithObject:self forKey:SdefRemovedTreeNode]];
  [parent willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"children"];
  [super remove];
  [parent didChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:@"children"];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidRemoveChildNotification
                                                      object:parent];
}

- (void)removeChildAtIndex:(unsigned)idx {
  /* Super call -remove, so no need to undo & notify here */
  [super removeChildAtIndex:idx];
}

- (void)removeAllChildren {
  id idxes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self childCount])];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectWillRemoveAllChildrenNotification object:self];
  [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:idxes forKey:@"children"];
  [super removeAllChildren];
  [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:idxes forKey:@"children"];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidRemoveAllChildrenNotification object:self];
}

- (void)setSortedChildren:(NSArray *)ordered {
  [[[self document] undoManager] registerUndoWithTarget:self selector:@selector(setSortedChildren:) object:[self children]];
  [[[self document] undoManager] setActionName:@"Sort"];
  id idxes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self childCount])];
  [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:idxes forKey:@"children"];
  [super setSortedChildren:ordered];
  [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:idxes forKey:@"children"];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidSortChildrenNotification object:self];
}

#pragma mark -
- (SdefSuite *)suite {
  return [self firstParentOfType:kSdefSuiteType];
}
- (SdefDictionary *)dictionary {
  return [self firstParentOfType:kSdefDictionaryType];
}

- (NSString *)location {
  id parent;
  /* If parent is a Class or an Enumeration and parent != self */
  if (((parent = [self firstParentOfType:kSdefClassType]) ||
       (parent = [self firstParentOfType:kSdefEnumerationType]) || 
       (parent = [self firstParentOfType:kSdefVerbType])) && parent != self) {
    return [NSString stringWithFormat:@"%@:%@", [(id)[self suite] name], [parent name]];
  } else {
    return [(id)[self suite] name];
  }
}

- (id)firstParentOfType:(SdefObjectType)aType {
  id parent = self;
  while (parent && ([parent objectType] != aType)) {
    parent = [parent parent];
  }
  return parent;  
}

- (void)sortByName {
  static NSArray *sorts = nil;
  if (!sorts) {
    NSSortDescriptor *name = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    sorts = [[NSArray allocWithZone:NSDefaultMallocZone()] initWithObjects:name, nil];
    [name release];
  }
  [self sortUsingDescriptors:sorts];
}

- (SdefDocument *)document {
  return [[self dictionary] document];
}
- (SdefClassManager *)classManager {
  return [[self dictionary] classManager];
}

- (SdefObjectType)objectType {
  return [[self class] objectType];
}
- (NSString *)objectTypeName {
  switch ([self objectType]) {
    case kSdefUndefinedType:
      return @"Undefined";
    case kSdefDictionaryType:
      return @"Dictionary";
    case kSdefSuiteType:
      return @"Suite";
    case kSdefCollectionType:
      return @"Collection";
    case kSdefImportsType:
      return @"Import";
    /* Class */
    case kSdefClassType:
      return @"Class";
    case kSdefContentsType:
      return @"Contents";
    case kSdefPropertyType:
      return @"Property";
    case kSdefElementType:
      return @"Element";
    case kSdefRespondsToType:
      return @"Responds To";
    /* Verbs */
    case kSdefVerbType:
      return @"Verb";
    case kSdefParameterType:
      return @"Parameter";
    case kSdefDirectParameterType:
      return @"Direct Parameter";
    case kSdefResultType:
      return @"Result";
    /* Enumeration */
    case kSdefEnumerationType:
      return @"Enumeration";
    case kSdefEnumeratorType:
      return @"Enumerator";
    /* Value */
    case kSdefValueType:
      return @"Value";
    /* Misc */
    case kSdefCocoaType:
      return @"Cocoa";
    case kSdefSynonymType:
      return @"Synonym";
    case kSdefDocumentationType:
      return @"Documentation";
  }
  return nil;
}

- (void)createContent {
}

#pragma mark -
#pragma mark Accessors
- (NSImage *)icon {
  return sd_icon;
}

- (void)setIcon:(NSImage *)newIcon {
  if (sd_icon != newIcon) {
    [sd_icon release];
    sd_icon = [newIcon retain];
  }
}

- (NSString *)name {
  return sd_name;
}

- (void)setName:(NSString *)newName {
  if (sd_name != newName) {
    [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectWillChangeNameNotification object:self];
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_name];
    //[[[self document] undoManager] setActionName:@"Rename"];
    [self willChangeValueForKey:@"name"];
    [sd_name release];
    sd_name = [newName copyWithZone:[self zone]];
    [self didChangeValueForKey:@"name"];
    [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidChangeNameNotification object:self];
  }
}

- (BOOL)isEditable {
  return sd_flags.editable == 1;
}
- (void)setEditable:(BOOL)flag {
  [self setEditable:flag recursive:NO];
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  sd_flags.editable = (flag) ? 1 : 0;
  if (recu) {
    [sd_documentation setEditable:flag];
    [sd_synonyms setEditable:flag recursive:recu];
    id nodes = [self childEnumerator];
    id node;
    while (node = [nodes nextObject]) {
      [node setEditable:flag recursive:recu];
    }
  }
}

- (BOOL)isRemovable {
  return sd_flags.removable;
}
- (void)setRemovable:(BOOL)removable {
  sd_flags.removable = (removable) ? 1 : 0;
}

#pragma mark Optionals children
- (BOOL)hasDocumentation {
  return sd_flags.hasDocumentation;
}

- (SdefDocumentation *)documentation {
  if (!sd_documentation && sd_flags.hasDocumentation) {
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

- (BOOL)hasSynonyms {
  return sd_flags.hasSynonyms;
}

- (SdefCollection *)synonyms {
  if (!sd_synonyms && sd_flags.hasSynonyms) {
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

- (BOOL)hasImplementation {
  return sd_flags.hasImplementation;
}
- (SdefImplementation *)impl {
  return nil;
}
- (void)setImpl:(SdefImplementation *)impl {
}

#pragma mark Comments
- (BOOL)hasComments {
  return [sd_comments count] > 0;
}

- (NSArray *)comments {
  if (!sd_comments) {
    sd_comments = [[NSMutableArray allocWithZone:[self zone]] init];
  }
  return sd_comments;
}

- (void)setComments:(NSArray *)comments {
  if (sd_comments != comments) {
    [sd_comments release];
    sd_comments = [comments mutableCopy];
  }
}

- (void)addComment:(NSString *)comment {
  if (!sd_comments) {
    sd_comments = [[NSMutableArray allocWithZone:[self zone]] init];
  }
  id cmnt = [SdefComment commentWithString:comment];
  [sd_comments addObject:cmnt];
}

- (void)removeCommentAtIndex:(unsigned)index {
  [sd_comments removeObjectAtIndex:index];
}

#pragma mark -
#pragma mark Children KVC compliance
- (NSArray *)children {
  return [super children];
}

- (void)setChildren:(NSArray *)objects {
  [self willChangeValueForKey:@"children"];
  [self removeAllChildren];
  id children = [objects objectEnumerator];
  id child;
  while (child = [children nextObject]) {
    [self appendChild:child];
  }
  [self didChangeValueForKey:@"children"];
}

- (unsigned)countOfChildren {
  return [self childCount];
}

- (id)objectInChildrenAtIndex:(unsigned)index {
  return [self childAtIndex:index];
}

- (void)insertObject:(id)object inChildrenAtIndex:(unsigned)index {
  [self insertChild:object atIndex:index];
}

- (void)removeObjectFromChildrenAtIndex:(unsigned)index {
  [self removeChildAtIndex:index];
}

- (void)replaceObjectInChildrenAtIndex:(unsigned)index withObject:(id)object {
  [self replaceChildAtIndex:index withChild:object];
}

@end

#pragma mark -
@implementation SdefCollection
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefCollection *copy = [super copyWithZone:aZone];
  copy->sd_contentType = sd_contentType;
  copy->sd_elementName = [sd_elementName copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_elementName forKey:@"SCElementName"];
  [aCoder encodeObject:NSStringFromClass(sd_contentType) forKey:@"SCContentType"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_elementName = [[aCoder decodeObjectForKey:@"SCElementName"] retain];
    sd_contentType = NSClassFromString([aCoder decodeObjectForKey:@"SCContentType"]);
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefCollectionType;
}

+ (NSString *)defaultIconName {
  return @"Folder";
}

- (id)initEmpty {
  if (self = [super initEmpty]) {
    [self setRemovable:NO];
  }
  return self;
}

- (void)dealloc {
  [sd_elementName release];
  [super dealloc];
}

#pragma mark -
- (Class)contentType {
  return sd_contentType;
}

- (void)setContentType:(Class)newContentType {
  if (sd_contentType != newContentType) {
    sd_contentType = newContentType;
  }
}

- (NSString *)elementName {
  return sd_elementName;
}

- (void)setElementName:(NSString *)aName {
  if (sd_elementName != aName) {
    [sd_elementName release];
    sd_elementName = [aName copyWithZone:[self zone]];
  }
}

@end

#pragma mark -
@implementation SdefTerminologyElement
#pragma mark Protocols Implementation
- (id)copyWithZone:(NSZone *)aZone {
  SdefTerminologyElement *copy = [super copyWithZone:aZone];
  copy->sd_code = [sd_code copyWithZone:aZone];
  copy->sd_desc = [sd_desc copyWithZone:aZone];
  copy->sd_impl = [sd_impl copyWithZone:aZone];
  [copy->sd_impl setOwner:copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_code forKey:@"STCodeStr"];
  [aCoder encodeObject:sd_desc forKey:@"STDescription"];
  [aCoder encodeObject:sd_impl forKey:@"STImplementation"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_code = [[aCoder decodeObjectForKey:@"STCodeStr"] retain];
    sd_desc = [[aCoder decodeObjectForKey:@"STDescription"] retain];
    sd_impl = [[aCoder decodeObjectForKey:@"STImplementation"] retain];
  }
  return self;
}

- (void)dealloc {
  [sd_impl setOwner:nil];
  [sd_impl release];
  [sd_code release];
  [sd_desc release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> {name:\"%@\" code:'%@' hidden:%@ \n\timpl:%@}",
    NSStringFromClass([self class]), self,
    [self name], [self codeStr], [self isHidden] ? @"YES" : @"NO", [self impl]];
}

#pragma mark -
- (void)createContent {
  sd_flags.hasImplementation = 1;
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  if (recu) {
    [sd_impl setEditable:flag];
  }
  [super setEditable:flag recursive:recu];
}

- (SdefImplementation *)impl {
  if (!sd_impl && sd_flags.hasImplementation) {
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

- (BOOL)isHidden {
  return sd_flags.hidden;
}

- (void)setHidden:(BOOL)flag {
  flag = flag ? 1 : 0;
  if (sd_flags.hidden != flag) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setHidden:sd_flags.hidden];
    //[[[self document] undoManager] setActionName:@"Hidden"];
    sd_flags.hidden = flag;
  }
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
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_code];
    //[[[self document] undoManager] setActionName:@"Code"];
    [sd_code release];
    sd_code = [str copyWithZone:[self zone]];
  }
}

- (NSString *)desc {
  return sd_desc;
}

- (void)setDesc:(NSString *)newDesc {
  if (sd_desc != newDesc) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_desc];
    //[[[self document] undoManager] setActionName:@"Desc"];
    [sd_desc release];
    sd_desc = [newDesc copyWithZone:[self zone]];
  }
}

#pragma mark -
- (NSString *)cocoaKey {
  return ([[self impl] key] != nil) ? [[self impl] key] : CocoaNameForSdefName([self name], NO);
}
- (NSString *)cocoaName {
  return ([[self impl] name] != nil) ? [[self impl] name] : CocoaNameForSdefName([self name], YES);
}

- (NSString *)cocoaClass {
  return ([[self impl] sdClass] != nil) ? [[self impl] sdClass] : CocoaNameForSdefName([self name], YES);
}

- (NSString *)cocoaMethod {
  return ([[self impl] method] != nil) ? [[self impl] method] : CocoaNameForSdefName([self name], NO);
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

#pragma mark -
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

/*
#pragma mark -
@implementation SdefImports  
#pragma mark Protocols Implementation
- (id)copyWithZone:(NSZone *)aZone {
  SdefImports *copy = [super copyWithZone:aZone];
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
  return kSdefImportsType;
}

+ (NSString *)defaultName {
  return @"Imports";
}

+ (NSString *)defaultIconName {
  return @"Misc";
}

@end
*/
#pragma mark -
#pragma mark Publics Functions
NSString *CocoaNameForSdefName(NSString *sdefName, BOOL isClass) {
  static CFLocaleRef english = nil;
  if (!english) english = CFLocaleCreate(kCFAllocatorDefault, CFSTR("English"));
  if (!sdefName) return nil;
  
  NSMutableString *name = [NSMutableString stringWithString:sdefName];
  CFStringCapitalize((CFMutableStringRef)name, english);
  CFStringTrimWhitespace((CFMutableStringRef)name);
  if (!isClass) {
    NSString *first = [[name substringToIndex:1] lowercaseString];
    [name replaceCharactersInRange:NSMakeRange(0, 1) withString:first];
  }
  
  NSCharacterSet *white = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSRange range = NSMakeRange(0, [name length]);
  NSRange space = [name rangeOfCharacterFromSet:white options:NSLiteralSearch range:range];
  while (space.location != NSNotFound) {
    [name deleteCharactersInRange:space];
    range.location = space.location;
    range.length = [name length] - range.location;
    if (range.length <= 0)
      break;
    space = [name rangeOfCharacterFromSet:white options:NSLiteralSearch range:range];
  }
  
  return name;
}

NSString *SdefNameForCocoaName(NSString *cocoa) {
  static CFLocaleRef english = nil;
  if (!cocoa) return nil;
  
  NSMutableString *sdef = [[NSMutableString alloc] initWithString:cocoa];
  NSCharacterSet *upper = [NSCharacterSet uppercaseLetterCharacterSet];
  NSRange range = NSMakeRange(0, [sdef length]);
  NSRange character = [sdef rangeOfCharacterFromSet:upper options:NSLiteralSearch range:range];
  while (character.location != NSNotFound) {
    if (character.location) [sdef insertString:@" " atIndex:(character.location++)];
    range.location = character.location + character.length;
    range.length = [sdef length] - range.location;
    if (!range.length)
      break;
    character = [sdef rangeOfCharacterFromSet:upper options:NSLiteralSearch range:range];
  }
  if (!english) english = CFLocaleCreate(kCFAllocatorDefault, CFSTR("English"));
  CFStringLowercase((CFMutableStringRef)sdef, english);
  return [sdef autorelease];
}
