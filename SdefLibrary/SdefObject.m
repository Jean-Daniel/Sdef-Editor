//
//  SdefObject.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"
#import "SdefDocument.h"
#import "SdefDocumentation.h"
#import "SdefXMLGenerator.h"
#import "ShadowMacros.h"
#import "SKFunctions.h"
#import "SdefComment.h"
#import "SdefXMLNode.h"
#import "SdefSynonym.h"
#import "SdefImplementation.h"

NSString * const SdefNewTreeNode = @"SdefNewTreeNode";
NSString * const SdefRemovedTreeNode = @"SdefRemovedTreeNode";
NSString * const SdefObjectDidAppendChildNotification = @"SdefObjectDidAppendChild";
NSString * const SdefObjectWillRemoveChildNotification = @"SdefObjectWillRemoveChild";
NSString * const SdefObjectDidRemoveChildNotification = @"SdefObjectDidRemoveChild";
NSString * const SdefObjectWillRemoveAllChildrenNotification = @"SdefObjectWillRemoveAllChildren";
NSString * const SdefObjectDidRemoveAllChildrenNotification = @"SdefObjectDidRemoveAllChildren";

NSString * const SDTreeNodeWillChangeNameNotification = @"SDTreeNodeWillChangeName";
NSString * const SDTreeNodeDidChangeNameNotification = @"SDTreeNodeDidChangeName";

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
  copy->sd_childComments = [sd_childComments copyWithZone:aZone];
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
  return ![key isEqualToString:@"children"];
}

+ (SDObjectType)objectType {
  return kSDUndefinedType;
}

+ (NSString *)defaultName {
  return nil;
}

+ (NSString *)defaultIconName {
  return @"Misc";
}

+ (id)emptyNode {
  return [[[self alloc] initEmpty] autorelease];
}

+ (id)nodeWithName:(NSString *)newName {
  return [[[self alloc] initWithName:newName] autorelease];
}

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
    sd_comments = [[NSMutableArray alloc] init];
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

- (id)initWithAttributes:(NSDictionary *)attributes {
  if (self = [self initEmpty]) {
    [self createContent];
    [self setAttributes:attributes];
    if (![self name]) { [self setName:[[self class] defaultName]]; }
  }
  return self;
}

- (void)dealloc {
  [sd_icon release];
  [sd_name release];
  [sd_synonyms release];
  [sd_comments release];
  [sd_documentation release];
  [sd_childComments release];
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
  [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:[self childCount]] forKey:@"children"];
  [super appendChild:child];
  [(SdefObject *)child setEditable:[self isEditable]];
  [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:[self childCount]] forKey:@"children"];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidAppendChildNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:child forKey:SdefNewTreeNode]];
}

- (void)prependChild:(SKTreeNode *)child {
  [[[self document] undoManager] registerUndoWithTarget:child selector:@selector(remove) object:nil];
  [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:0] forKey:@"children"];
  [super prependChild:child];
  [(SdefObject *)child setEditable:[self isEditable]];
  [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:0] forKey:@"children"];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidAppendChildNotification
                                                      object:self
                                                    userInfo:[NSDictionary dictionaryWithObject:child forKey:SdefNewTreeNode]];
}

- (void)insertChild:(id)child atIndex:(unsigned)idx {
  /* Super call prepend or insertsibling, so no need to undo & notify here. */
  [super insertChild:child atIndex:idx];
}

- (void)insertSibling:(SKTreeNode *)newSibling {
  [[[self document] undoManager] registerUndoWithTarget:newSibling selector:@selector(remove) object:nil];
  [super insertSibling:newSibling];
  [(SdefObject *)newSibling setEditable:[self isEditable]];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidAppendChildNotification
                                                      object:[self parent]
                                                    userInfo:[NSDictionary dictionaryWithObject:newSibling forKey:SdefNewTreeNode]];
}

- (void)remove {
  id parent = [self parent];
  unsigned idx = [parent indexOfChildren:self];
  [[[[self document] undoManager] prepareWithInvocationTarget:parent] insertChild:self atIndex:idx];
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
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectWillRemoveAllChildrenNotification object:self];
  [super removeAllChildren];
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefObjectDidRemoveAllChildrenNotification object:self];
}

#pragma mark -
- (SdefDocument *)document {
  id root = [self findRoot];
  return (root != self) ? [root document] : nil;
}

- (SDObjectType)objectType {
  return [[self class] objectType];
}

- (void)createContent {
}

- (void)createSynonyms {
  id synonyms = [SdefCollection nodeWithName:NSLocalizedStringFromTable(@"Synonyms", @"SdefLibrary", @"Synonyms Collection name")];
  [synonyms setContentType:[SdefSynonym class]];
  [synonyms setElementName:@"synonyms"];
  [self setSynonyms:synonyms];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:SDTreeNodeWillChangeNameNotification object:self];
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_name];
    [sd_name release];
    sd_name = [newName copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:SDTreeNodeDidChangeNameNotification object:self];
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
    [[self documentation] setEditable:flag];
    [[self synonyms] setEditable:flag recursive:recu];
    id nodes = [self childrenEnumerator];
    id node;
    while (node = [nodes nextObject]) {
      [node setEditable:flag recursive:recu];
    }
  }
}

- (BOOL)isRemovable {
  return sd_flags.removable == 1;
}

- (void)setRemovable:(BOOL)removable {
  sd_flags.removable = (removable) ? 1 : 0;
}

#pragma mark Optionals children
- (BOOL)hasDocumentation {
  return sd_documentation != nil;
}

- (SdefDocumentation *)documentation {
  return sd_documentation;
}

- (void)setDocumentation:(SdefDocumentation *)doc {
  if (sd_documentation != doc) {
    [sd_documentation release];
    sd_documentation = [doc retain];
    [sd_documentation setEditable:[self isEditable]];
  }	
}

- (BOOL)hasSynonyms {
  return sd_synonyms != nil;
}

- (SdefCollection *)synonyms {
  return sd_synonyms;
}

- (void)setSynonyms:(SdefCollection *)synonyms {
  if (sd_synonyms != synonyms) {
    [sd_synonyms release];
    sd_synonyms = [synonyms retain];
    [sd_synonyms setEditable:[self isEditable]];
  }
}


#pragma mark Comments
- (BOOL)hasComments {
  return [sd_comments count] > 0;
}

- (NSArray *)comments {
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
    sd_comments = [[NSMutableArray alloc] init];
  }
  id cmnt = [SdefComment commentWithString:comment];
//  [[[self document] undoManager] registerUndoWithTarget:sd_comments selector:@selector(removeObject:) object:cmnt];
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

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node = nil;
  id child = nil;
  id children = nil;
  node = [SdefXMLNode nodeWithElementName:[self xmlElementName]];
  if (node) {
    NSAssert1([node elementName] != nil, @"%@ return an invalid node", self);
    if ([self hasComments])
      [node setComments:[self comments]];
    id documentation = [[self documentation] xmlNode];
    if (nil != documentation) {
      [node prependChild:documentation];
    }
    id synonyms = [[self synonyms] xmlNode];
    if (nil != synonyms) {
      [node appendChild:synonyms];
    }
    children = [self childrenEnumerator];
    while (child = [children nextObject]) {
      id childNode = [child xmlNode];
      if (childNode) {
        NSAssert1([childNode elementName] != nil, @"%@ return an invalid node", child);
        [node appendChild:childNode];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return nil;
}

- (SdefImplementation *)impl {
  return nil;
}
- (void)setImpl:(SdefImplementation *)impl {
}

#pragma mark -
#pragma mark XML Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [self setName:[attrs objectForKey:@"name"]];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"documentation"]) {
    SdefDocumentation *documentation = [(SdefObject *)[SdefDocumentation alloc] initWithAttributes:attributeDict];
    [self setDocumentation:documentation];
    [self appendChild:documentation]; /* Append to parse, and remove after */
    [parser setDelegate:documentation];
    [documentation setComments:sd_childComments];
    [documentation release];
  } else if ([elementName isEqualToString:@"synonyms"]) {
    SdefCollection *synonyms = [self synonyms];
    [self appendChild:synonyms]; /* Append to parse, and remove after */
    [parser setDelegate:synonyms];
    [synonyms setComments:sd_childComments];
  } else if ([elementName isEqualToString:@"cocoa"]) {
    SdefImplementation *cocoa = [self impl];
    if (cocoa) {
      [cocoa setAttributes:attributeDict];
      [cocoa setComments:sd_childComments];
    }
  }
  [sd_childComments release];
  sd_childComments = nil;
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if (![elementName isEqualToString:@"cocoa"]) { /* cocoa isn't handle as a child node, but as an ivar */
    [parser setDelegate:[self parent]];
  }
}

// A comment (Text in a <!-- --> block) is reported to the delegate as a single string
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
  if (nil == sd_childComments) {
    sd_childComments = [[NSMutableArray alloc] init];
  }
  [sd_childComments addObject:[SdefComment commentWithString:[comment stringByUnescapingEntities:nil]]];
}

// ...and this reports a fatal error to the delegate. The parser will stop parsing.
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
  DLog(@"Parse error in %@: %@", [self name], parseError);
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
+ (SDObjectType)objectType {
  return kSDCollectionType;
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
    sd_elementName = [aName copy];
  }
}

- (void)dealloc {
  [sd_elementName release];
  [super dealloc];
}

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  return [self childCount] ? [super xmlNode] : nil;
}

- (NSString *)xmlElementName {
  return [self elementName];
}

#pragma mark -
#pragma mark XML Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  /* Do nothing */
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  /* If valid document, can only be collection content element */
  SdefObject *element = [(SdefObject *)[[self contentType] alloc] initWithAttributes:attributeDict];
  [self appendChild:element];
  [parser setDelegate:element];
  [element release];
  if (sd_childComments) {
    [element setComments:sd_childComments];
    [sd_childComments release];
    sd_childComments = nil;
  }
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
  if ([elementName isEqualToString:@"synonyms"]) {
    [self remove];
  }
}

@end

#pragma mark -
@implementation SdefTerminologyElement
#pragma mark Protocols Implementation
- (id)copyWithZone:(NSZone *)aZone {
  SdefTerminologyElement *copy = [super copyWithZone:aZone];
  copy->sd_hidden = sd_hidden;
  copy->sd_code = [sd_code copyWithZone:aZone];
  copy->sd_desc = [sd_desc copyWithZone:aZone];
  copy->sd_impl = [sd_impl copyWithZone:aZone];
  [copy->sd_impl setOwner:copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeBool:sd_hidden forKey:@"STHidden"];
  [aCoder encodeObject:sd_code forKey:@"STCodeStr"];
  [aCoder encodeObject:sd_desc forKey:@"STDescription"];
  [aCoder encodeObject:sd_impl forKey:@"STImplementation"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_hidden = [aCoder decodeBoolForKey:@"STHidden"];
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

#pragma mark -
- (void)createContent {
  [self setImpl:[SdefImplementation node]];
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  if (recu) {
    [sd_impl setEditable:flag];
  }
  [super setEditable:flag recursive:recu];
}

- (SdefImplementation *)impl {
  return sd_impl;
}

- (void)setImpl:(SdefImplementation *)newImpl {
  if (sd_impl != newImpl) {
    [sd_impl release];
    sd_impl = [newImpl retain];
    [sd_impl setOwner:self];
    [sd_impl setEditable:[self isEditable]];
  }
}

- (BOOL)isHidden {
  return sd_hidden;
}

- (void)setHidden:(BOOL)newHidden {
  if (sd_hidden != newHidden) {
    [[[[self document] undoManager] prepareWithInvocationTarget:self] setHidden:sd_hidden];
    sd_hidden = newHidden;
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
    [sd_code release];
    sd_code = [str copy];
  }
}

- (NSString *)desc {
  return sd_desc;
}

- (void)setDesc:(NSString *)newDesc {
  if (sd_desc != newDesc) {
    [[[self document] undoManager] registerUndoWithTarget:self selector:_cmd object:sd_desc];
    [sd_desc release];
    sd_desc = [newDesc copy];
  }
}

#pragma mark -
#pragma mark XML Generation
- (SdefXMLNode *)xmlNode {
  id node = [super xmlNode];
  id attr = [self name];
  if (nil != attr)
    [node setAttribute:attr forKey:@"name"];
  attr = [self codeStr];
  if (nil != attr)
    [node setAttribute:attr forKey:@"code"];
  if ([self isHidden])
    [node setAttribute:@"hidden" forKey:@"hidden"];
  attr = [self desc];
  if (nil != attr)
    [node setAttribute:attr forKey:@"description"];
  id impl = [[self impl] xmlNode];
  if (nil != impl) {
    if ([[[node firstChild] elementName] isEqualToString:@"documentation"]) {
      [node insertChild:impl atIndex:1];
    } else {
      [node prependChild:impl];
    }
  }
  [node setEmpty:![node hasChildren]];
  return node;
}

#pragma mark -
#pragma mark XML Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setCodeStr:[attrs objectForKey:@"code"]];
  [self setDesc:[attrs objectForKey:@"description"]];
  [self setHidden:[attrs objectForKey:@"hidden"] != nil];
}

@end

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
+ (SDObjectType)objectType {
  return kSDImportsType;
}

+ (NSString *)defaultName {
  return @"Imports";
}

+ (NSString *)defaultIconName {
  return @"Misc";
}

@end

