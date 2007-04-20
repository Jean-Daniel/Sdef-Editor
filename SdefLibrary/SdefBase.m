/*
 *  SdefBase.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"
#import "SdefComment.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"

@implementation SdefObject
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefObject *copy = [super copyWithZone:aZone];
  copy->sd_soFlags = sd_soFlags;  
  copy->sd_ignore = [sd_ignore copyWithZone:aZone];
  copy->sd_comments = [sd_comments copyWithZone:aZone];
  return copy;
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    NSUInteger length;
    const uint8_t*buffer = [aCoder decodeBytesForKey:@"SOFlags" returnedLength:&length];
    memcpy(&sd_soFlags, buffer, length);    
    sd_ignore = [[aCoder decodeObjectForKey:@"SOIgnore"] retain];
    sd_comments = [[aCoder decodeObjectForKey:@"SOComments"] retain];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeBytes:(const void *)&sd_soFlags length:sizeof(sd_soFlags) forKey:@"SOFlags"];
  [aCoder encodeObject:sd_ignore forKey:@"SOIgnore"];
  [aCoder encodeObject:sd_comments forKey:@"SOComments"];
}

#pragma mark -
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
- (id)init {
  return [self initWithName:[[self class] defaultName] icon:nil];
}

- (id)initWithName:(NSString *)aName icon:(NSImage *)anIcon {
  if (self = [super initWithName:aName icon:[NSImage imageNamed:[[self class] defaultIconName]]]) {
    [self setRegisterUndo:YES];
    [self setRemovable:YES];
    [self setEditable:YES];
    [self setNotify:YES];
    [self sdefInit];
  }
  return self;
}

- (void)dealloc {
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
  SKUITreeNode *parent;
  /* If parent is a Class or an Enumeration and parent != self */
  if (((parent = [self firstParentOfType:kSdefClassType]) ||
       (parent = [self firstParentOfType:kSdefEnumerationType]) || 
       (parent = [self firstParentOfType:kSdefVerbType])) && parent != self) {
    return [NSString stringWithFormat:@"%@:%@", [[self suite] name], [parent name]];
  } else {
    return [[self suite] name];
  }
}

- (id)firstParentOfType:(SdefObjectType)aType {
  id parent = self;
  while (parent && ([parent objectType] != aType)) {
    parent = [parent parent];
  }
  return parent;  
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
    SdefObject *node;
    NSEnumerator *nodes = [self childEnumerator];
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

#pragma mark Optionals Children & Attributes
- (BOOL)hasID {
  return NO;
}
- (NSString *)xmlid {
  return nil;
}
- (void)setXmlid:(NSString *)xmlid {
  // nothing
}

- (BOOL)hasXrefs {
  return sd_soFlags.xrefs;
}
- (NSMutableArray *)xrefs {
  return nil;
}
- (void)setXrefs:(NSArray *)xrefs {
  // does nothing.
  if (![self hasXrefs])
    WLog(@"Try to set xrefs on a invalid item %@", self);
}

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
    for (NSUInteger idx = 0; idx < [comments count]; idx++) {
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

- (void)removeCommentAtIndex:(NSUInteger)anIndex {
  [sd_comments removeObjectAtIndex:anIndex];
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
- (void)removeIgnoreAtIndex:(NSUInteger)anIndex {
  [sd_ignore removeObjectAtIndex:anIndex];
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
