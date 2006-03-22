//
//  SdefBase.m
//  Sdef Editor
//
//  Created by Grayfox on 09/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefBase.h"
#import "SdefComment.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"

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
  copy->sd_soFlags = sd_soFlags;  
  copy->sd_name = [sd_name copyWithZone:aZone];
  copy->sd_icon = [sd_icon copyWithZone:aZone];
  copy->sd_comments = [sd_comments copyWithZone:aZone];
  return copy;
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    unsigned length;
    const uint8_t*buffer = [aCoder decodeBytesForKey:@"SOFlags" returnedLength:&length];
    memcpy(&sd_soFlags, buffer, length);
    
    sd_name = [[aCoder decodeObjectForKey:@"SOName"] retain];
    sd_icon = [[aCoder decodeObjectForKey:@"SOIcon"] retain];
    sd_comments = [[aCoder decodeObjectForKey:@"SOComments"] retain];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeBytes:(const void *)&sd_soFlags length:sizeof(sd_soFlags) forKey:@"SOFlags"];
  [aCoder encodeObject:sd_name forKey:@"SOName"];
  [aCoder encodeObject:sd_icon forKey:@"SOIcon"];
  [aCoder encodeObject:sd_comments forKey:@"SOComments"];
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

+ (id)nodeWithName:(NSString *)newName {
  return [[[self alloc] initWithName:newName] autorelease];
}

#pragma mark -
- (id)init {
  return [self initWithName:[[self class] defaultName]];
}

- (id)initWithName:(NSString *)newName {
  if (self = [super init]) {
    [self setEditable:YES];
    [self setRemovable:YES];
    [self setIcon:[NSImage imageNamed:[[self class] defaultIconName]]];
    [self sdefInit];
    [self setName:newName];
  }
  return self;
}

- (void)dealloc {
  [sd_icon release];
  [sd_name release];
  [sd_comments release];
  [super dealloc];
}

#pragma mark -
- (void)sdefInit {}

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
- (NSUndoManager *)undoManager {
  return [[self document] undoManager];
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
      return NSLocalizedStringFromTable(@"Undefined", @"SdefLibrary", @"Object Type Name.");
    case kSdefDictionaryType:
      return NSLocalizedStringFromTable(@"Dictionary", @"SdefLibrary", @"Object Type Name.");
    case kSdefSuiteType:
      return NSLocalizedStringFromTable(@"Suite", @"SdefLibrary", @"Object Type Name.");
    case kSdefCollectionType:
      return NSLocalizedStringFromTable(@"Collection", @"SdefLibrary", @"Object Type Name.");
      /* Class */
    case kSdefClassType:
      return NSLocalizedStringFromTable(@"Class", @"SdefLibrary", @"Object Type Name.");
    case kSdefContentsType:
      return NSLocalizedStringFromTable(@"Contents", @"SdefLibrary", @"Object Type Name.");
    case kSdefPropertyType:
      return NSLocalizedStringFromTable(@"Property", @"SdefLibrary", @"Object Type Name.");
    case kSdefElementType:
      return NSLocalizedStringFromTable(@"Element", @"SdefLibrary", @"Object Type Name.");
    case kSdefRespondsToType:
      return NSLocalizedStringFromTable(@"Responds To", @"SdefLibrary", @"Object Type Name.");
      /* Verbs */
    case kSdefVerbType:
      return NSLocalizedStringFromTable(@"Verb", @"SdefLibrary", @"Object Type Name.");
    case kSdefParameterType:
      return NSLocalizedStringFromTable(@"Parameter", @"SdefLibrary", @"Object Type Name.");
    case kSdefDirectParameterType:
      return NSLocalizedStringFromTable(@"Direct Parameter", @"SdefLibrary", @"Object Type Name.");
    case kSdefResultType:
      return NSLocalizedStringFromTable(@"Result", @"SdefLibrary", @"Object Type Name.");
      /* Enumeration */
    case kSdefEnumerationType:
      return NSLocalizedStringFromTable(@"Enumeration", @"SdefLibrary", @"Object Type Name.");
    case kSdefEnumeratorType:
      return NSLocalizedStringFromTable(@"Enumerator", @"SdefLibrary", @"Object Type Name.");
      /* Value */
    case kSdefValueType:
      return NSLocalizedStringFromTable(@"Value", @"SdefLibrary", @"Object Type Name.");
    case kSdefRecordType:
      return NSLocalizedStringFromTable(@"Record", @"SdefLibrary", @"Object Type Name.");
      /* Misc */
    case kSdefCocoaType:
      return NSLocalizedStringFromTable(@"Cocoa", @"SdefLibrary", @"Object Type Name.");
    case kSdefDocumentationType:
      return NSLocalizedStringFromTable(@"Documentation", @"SdefLibrary", @"Object Type Name.");
  }
  return nil;
}

#pragma mark -
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
    [[self undoManager] registerUndoWithTarget:self selector:_cmd object:sd_name];
    [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Change Name", @"SdefLibrary", @"Undo Action: change name.")];
    [self willChangeValueForKey:@"name"];
    [sd_name release];
    sd_name = [newName copyWithZone:[self zone]];
    [self didChangeValueForKey:@"name"];
    [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidChangeNameNotification object:self];
  }
}

- (BOOL)isHidden {
  return sd_soFlags.hidden;
}

- (void)setHidden:(BOOL)flag {
  flag = flag ? 1 : 0;
  if (sd_soFlags.hidden != flag) {
    [[[self undoManager] prepareWithInvocationTarget:self] setHidden:sd_soFlags.hidden];
    [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Hide/Unhide", @"SdefLibrary", @"Undo Action: change Hidden.")];
    sd_soFlags.hidden = flag;
  }
}

- (BOOL)isEditable {
  return sd_soFlags.editable;
}
- (void)setEditable:(BOOL)flag {
  [self setEditable:flag recursive:NO];
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  sd_soFlags.editable = (flag) ? 1 : 0;
  if (recu) {
    id node;
    id nodes = [self childEnumerator];
    while (node = [nodes nextObject]) {
      [node setEditable:flag recursive:recu];
    }
  }
}

- (BOOL)isRemovable {
  return sd_soFlags.removable;
}
- (void)setRemovable:(BOOL)removable {
  sd_soFlags.removable = (removable) ? 1 : 0;
}

#pragma mark Optionals children
- (BOOL)hasDocumentation {
  return sd_soFlags.hasDocumentation;
}
- (SdefDocumentation *)documentation {
  return nil;
}
- (void)setDocumentation:(SdefDocumentation *)doc {}

- (BOOL)hasSynonyms {
  return sd_soFlags.hasSynonyms;
}
- (NSMutableArray *)synonyms {
  return nil;
}
- (void)setSynonyms:(NSArray *)synonyms {}

- (BOOL)hasImplementation {
  return sd_soFlags.hasImplementation;
}
- (SdefImplementation *)impl {
  return nil;
}
- (void)setImpl:(SdefImplementation *)impl {}

#pragma mark Comments
- (BOOL)hasComments {
  return sd_comments && [sd_comments count] > 0;
}

- (NSMutableArray *)comments {
  if (!sd_comments) {
    sd_comments = [[NSMutableArray allocWithZone:[self zone]] init];
  }
  return sd_comments;
}

- (void)setComments:(NSArray *)comments {
  if (sd_comments != comments) {
    [sd_comments removeAllObjects];
    unsigned idx;
    for (idx=0; idx<[comments count]; idx++) {
      [[self comments] addObject:[comments objectAtIndex:idx]];
    }
  }
}

- (void)addComment:(NSString *)comment {
  if (comment) {
    SdefComment *cmnt = [[SdefComment allocWithZone:[self zone]] initWithString:comment];
    [[self comments] addObject:cmnt];
    [cmnt release];
  }
}

- (void)removeCommentAtIndex:(unsigned)index {
  [sd_comments removeObjectAtIndex:index];
}

#pragma mark Ignore
- (BOOL)hasIgnore {
  return sd_ignore && [sd_ignore count] > 0;
}

- (NSMutableArray *)ignores {
  if (!sd_ignore) {
    sd_ignore = [[NSMutableArray allocWithZone:[self zone]] init];
  }
  return sd_ignore;
}
- (void)addIgnore:(id)anObject {
  [[self ignores] addObject:anObject];
}
- (void)setIgnores:(NSArray *)anArray {
  if (sd_ignore != anArray) {
    [sd_ignore removeAllObjects];
    [[self ignores] addObjectsFromArray:anArray];
  }
}
- (void)removeIgnoreAtIndex:(unsigned)index {
  [sd_ignore removeObjectAtIndex:index];
}

#pragma mark -
#pragma mark Notifications
- (void)appendChild:(SKTreeNode *)child {
  [[self undoManager] registerUndoWithTarget:child selector:@selector(remove) object:nil];
//  [[self undoManager] setActionName:@"Add Object"];
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
  [[self undoManager] registerUndoWithTarget:child selector:@selector(remove) object:nil];
//  [[self undoManager] setActionName:@"Add Object"];
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
//  [[self undoManager] setActionName:@"Insert Object"];
}

- (void)insertSibling:(SKTreeNode *)newSibling {
  [[self undoManager] registerUndoWithTarget:newSibling selector:@selector(remove) object:nil];
//  [[self undoManager] setActionName:@"Insert Object"];
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
  [(SKTreeNode *)[[self undoManager] prepareWithInvocationTarget:parent] insertChild:self atIndex:idx];
//  [[self undoManager] setActionName:@"Delete Object"];
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
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setSortedChildren:) object:[self children]];
  [[self undoManager] setActionName:@"Sort"];
  id idxes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self childCount])];
  [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:idxes forKey:@"children"];
  [super setSortedChildren:ordered];
  [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:idxes forKey:@"children"];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidSortChildrenNotification object:self];
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

- (void)sdefInit {
  [super sdefInit];
  [self setRemovable:NO];
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

- (BOOL)acceptsObjectType:(SdefObjectType)aType {
  return sd_contentType ? [sd_contentType objectType] == aType : NO;
}

@end

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

NSString *SdefNameCreateWithCocoaName(NSString *cocoa) {
  static CFLocaleRef english = nil;
  if (!cocoa) return nil;
  
  CFMutableStringRef sdef = CFStringCreateMutable(kCFAllocatorDefault, 0);
  CFStringAppend(sdef, (CFStringRef)cocoa);
  
  CFCharacterSetRef upper = CFCharacterSetGetPredefined(kCFCharacterSetUppercaseLetter);
  CFRange range = CFRangeMake(0, [cocoa length]);
  CFRange character;
  while (CFStringFindCharacterFromSet(sdef, upper, range, 0, &character) && character.location != kCFNotFound) {
    if (character.location) CFStringInsert(sdef, (character.location++), CFSTR(" "));
    range.location = character.location + character.length;
    range.length = CFStringGetLength(sdef) - range.location;
    if (!range.length)
      break;
  }
  if (!english) english = CFLocaleCreate(kCFAllocatorDefault, CFSTR("English"));
  CFStringLowercase(sdef, english);
  return (id)sdef;
}
