/*
 *  SdefBase.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright ÔøΩ 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"
#import "SdefSuite.h"
#import "SdefComment.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"

static
NSImage *SdefImageNamed(NSString *name) {
  static NSMutableDictionary *sImages = nil;
  if (!sImages) {
    sImages = [[NSMutableDictionary alloc] init];
  }
  NSImage *image = nil;
  if (name) {
    image = [sImages objectForKey:name];
    if (!image) {
      image = [NSImage imageNamed:name];
      if (image)
        [sImages setObject:image forKey:name];
    }
  }
  return image;
}

@implementation SdefObject
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefObject *copy = [super copyWithZone:aZone];
  copy->sd_soFlags = sd_soFlags;  
  copy->sd_comments = [sd_comments copyWithZone:aZone];
  return copy;
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    NSUInteger length;
    const uint8_t*buffer = [aCoder decodeBytesForKey:@"SOFlags" returnedLength:&length];
    memcpy(&sd_soFlags, buffer, length);    
    sd_comments = [aCoder decodeObjectForKey:@"SOComments"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeBytes:(const void *)&sd_soFlags length:sizeof(sd_soFlags) forKey:@"SOFlags"];
  [aCoder encodeObject:sd_comments forKey:@"SOComments"];
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Undefined;
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
  if (self = [super initWithName:aName icon:SdefImageNamed([[self class] defaultIconName])]) {
    [self setRegisterUndo:YES];
    [self setRemovable:YES];
    [self setEditable:YES];
    [self setNotify:YES];
    [self sdefInit];
  }
  return self;
}

#pragma mark -
- (void)sdefInit {}

- (void)setParent:(SdefObject *)parent {
  [super setParent:parent];
  /* set inherited flags */
//  if (parent)
//    [self setEditable:parent.editable recursive:YES];
}

#pragma mark -
- (NSString *)name {
  return [super name];
}
- (NSImage *)icon {
  return [super icon];
}

- (SdefSuite *)suite {
  return (id)[self firstParentOfType:kSdefType_Suite];
}
- (SdefDictionary *)dictionary {
  return (id)[self firstParentOfType:kSdefType_Dictionary];
}

- (NSString *)location {
  id<SdefObject> parent;
  /* If parent is a Class or an Enumeration and parent != self */
  if (((parent = [self firstParentOfType:kSdefType_Class]) ||
       (parent = [self firstParentOfType:kSdefType_Enumeration]) ||
       (parent = [self firstParentOfType:kSdefType_Command])) && parent != self) {
    return [NSString stringWithFormat:@"%@:%@", [[self suite] name], [parent name]];
  } else if ((parent = (id)[self suite])){
    return [parent name];
  } else {
    return [self name];
  }
}

- (SdefObject *)container {
  return self;
}

- (id<SdefObject>)firstParentOfType:(SdefObjectType)aType {
  SdefObject *parent = self;
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
  return [[self document] classManager];
}
- (NSNotificationCenter *)notificationCenter {
  return [[self document] notificationCenter];
}

- (SdefObjectType)objectType {
  return [[self class] objectType];
}
- (NSString *)objectTypeName {
  return SdefObjectTypeName(self.objectType);
}

#pragma mark -
- (BOOL)hidden {
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
  return sd_soFlags.editable && !sd_soFlags.xinclude;
}
- (void)setEditable:(BOOL)flag {
  [self setEditable:flag recursive:NO];
}

- (void)setEditable:(BOOL)flag recursive:(BOOL)recu {
  SPXFlagSet(sd_soFlags.editable, flag);
  if (recu) {
    SdefObject *node;
    NSEnumerator *nodes = [self childEnumerator];
    while (node = [nodes nextObject]) {
      [node setEditable:flag recursive:recu];
    }
  }
}

- (BOOL)isImported {
  return sd_soFlags.xinclude;
}
- (void)setImported:(BOOL)flag {
  SPXFlagSet(sd_soFlags.xinclude, flag);
}

- (BOOL)isRemovable {
  if ([self parent] && ![[self parent] isEditable])
    return NO;
  return sd_soFlags.removable && !sd_soFlags.xinclude;
}
- (void)setRemovable:(BOOL)removable {
  SPXFlagSet(sd_soFlags.removable, removable);
}

#pragma mark Optionals Children & Attributes
- (BOOL)hasID {
  return sd_soFlags.xid;
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
    spx_log("#WARNING Try to set xrefs on a invalid item %@", self);
}

- (BOOL)hasXInclude {
  return YES;
}
static inline
NSMutableArray *xincludes(SdefObject *self) {
  if (!self->sd_includes)
    self->sd_includes = [[NSMutableArray alloc] init];
  return self->sd_includes;
}
- (NSArray *)xincludes {
  return xincludes(self);
}
- (void)addXInclude:(id)xinclude {
  [xinclude setOwner:self];
  [xincludes(self) addObject:xinclude];
}
- (BOOL)containsXInclude {
  return sd_includes && [sd_includes count] > 0;
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
- (NSMutableArray *)synonyms { return nil; }
- (void)setSynonyms:(NSArray *)synonyms {}

- (BOOL)hasAccessGroup {
  return sd_soFlags.hasAccessGroup;
}
- (SdefAccessGroup *)accessGroup { return nil; }
- (void)setAccessGroup:(SdefAccessGroup *)accessGroup {}

- (BOOL)hasImplementation {
  return sd_soFlags.hasImplementation;
}
- (SdefImplementation *)impl { return nil; }
- (void)setImpl:(SdefImplementation *)impl {}

#pragma mark Comments
- (BOOL)hasComments {
  return sd_comments && [sd_comments count] > 0;
}

static inline
NSMutableArray *comments(SdefObject *self) {
  if (!self->sd_comments)
    self->sd_comments = [[NSMutableArray alloc] init];
  return self->sd_comments;
}
- (NSArray *)comments {
  return comments(self);
}
- (void)setComments:(NSArray *)cmts {
  if (sd_comments != cmts) {
    [sd_comments removeAllObjects];
    for (NSUInteger idx = 0; idx < [cmts count]; idx++) {
      SdefComment *cmnt = [cmts objectAtIndex:idx];
      [comments(self) addObject:cmnt];
      [cmnt setOwner:self];
    }
  }
}

- (void)addComment:(SdefComment *)comment {
  [comments(self) addObject:comment];
  [comment setOwner:self];
}
- (void)removeCommentAtIndex:(NSUInteger)anIndex {
  SdefComment *cmnt = [sd_comments objectAtIndex:anIndex];
  if (cmnt) {
    [cmnt setOwner:nil];
    [sd_comments removeObjectAtIndex:anIndex];
  }
}

@end

#pragma mark -
@implementation SdefCollection

@synthesize contentType = _contentType;
@synthesize elementName = _elementName;

#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefCollection *copy = [super copyWithZone:aZone];
  copy->_contentType = _contentType;
  copy->_elementName = [_elementName copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_elementName forKey:@"SCElementName"];
  [aCoder encodeObject:NSStringFromClass(_contentType) forKey:@"SCContentType"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    _elementName = [aCoder decodeObjectForKey:@"SCElementName"];
    _contentType = NSClassFromString([aCoder decodeObjectForKey:@"SCContentType"]);
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefType_Collection;
}

+ (NSString *)defaultIconName {
  return @"Folder";
}

- (void)sdefInit {
  [super sdefInit];
  [self setRemovable:NO];
}

#pragma mark -
- (BOOL)hasXInclude {
  return NO;
}

- (BOOL)acceptsObjectType:(SdefObjectType)aType {
  return _contentType ? [_contentType objectType] == aType : NO;
}

@end

#pragma mark -
#pragma mark Publics Functions
NSString *SdefObjectTypeName(SdefObjectType type) {
  switch (type) {
    case kSdefType_Undefined:
      return NSLocalizedStringFromTable(@"Undefined", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Dictionary:
      return NSLocalizedStringFromTable(@"Dictionary", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Suite:
      return NSLocalizedStringFromTable(@"Suite", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Collection:
      return NSLocalizedStringFromTable(@"Collection", @"SdefLibrary", @"Object Type Name.");
      /* Class */
    case kSdefType_Class:
      return NSLocalizedStringFromTable(@"Class", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Contents:
      return NSLocalizedStringFromTable(@"Contents", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Property:
      return NSLocalizedStringFromTable(@"Property", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Element:
      return NSLocalizedStringFromTable(@"Element", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_RespondsTo:
      return NSLocalizedStringFromTable(@"Responds To", @"SdefLibrary", @"Object Type Name.");
      /* Verbs */
    case kSdefType_Command:
      return NSLocalizedStringFromTable(@"Verb", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Parameter:
      return NSLocalizedStringFromTable(@"Parameter", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_DirectParameter:
      return NSLocalizedStringFromTable(@"Direct Parameter", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Result:
      return NSLocalizedStringFromTable(@"Result", @"SdefLibrary", @"Object Type Name.");
      /* Enumeration */
    case kSdefType_Enumeration:
      return NSLocalizedStringFromTable(@"Enumeration", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Enumerator:
      return NSLocalizedStringFromTable(@"Enumerator", @"SdefLibrary", @"Object Type Name.");
      /* Value */
    case kSdefType_ValueType:
      return NSLocalizedStringFromTable(@"Value", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_RecordType:
      return NSLocalizedStringFromTable(@"Record", @"SdefLibrary", @"Object Type Name.");

      /* Leaves */
    case kSdefType_AccessGroup:
      return NSLocalizedStringFromTable(@"Access Group", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Type:
      return NSLocalizedStringFromTable(@"Type", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Synonym:
      return NSLocalizedStringFromTable(@"Synonym", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Comment:
      return NSLocalizedStringFromTable(@"XML Comment", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_XRef:
      return NSLocalizedStringFromTable(@"xref", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_XInclude:
      return NSLocalizedStringFromTable(@"xinclude", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Implementation:
      return NSLocalizedStringFromTable(@"Cocoa", @"SdefLibrary", @"Object Type Name.");
    case kSdefType_Documentation:
      return NSLocalizedStringFromTable(@"Documentation", @"SdefLibrary", @"Object Type Name.");
  }
  return nil;
}

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

NSString *SdefNameFromCocoaName(NSString *cocoa) {
  static CFLocaleRef english = nil;
  if (!cocoa) return nil;
  
  CFMutableStringRef sdef = CFStringCreateMutable(kCFAllocatorDefault, 0);
  CFStringAppend(sdef, (CFStringRef)cocoa);
  
  CFCharacterSetRef upper = CFCharacterSetGetPredefined(kCFCharacterSetUppercaseLetter);
  CFRange range = CFRangeMake(0, [cocoa length]);
  CFRange character;
  while (CFStringFindCharacterFromSet(sdef, upper, range, 0, &character) && character.location != kCFNotFound) {
    if (character.location)
      CFStringInsert(sdef, (character.location++), CFSTR(" "));
    range.location = character.location + character.length;
    range.length = CFStringGetLength(sdef) - range.location;
    if (!range.length)
      break;
  }
  if (!english)
    english = CFLocaleCreate(kCFAllocatorDefault, CFSTR("English"));
  CFStringLowercase(sdef, english);
  return CFAutorelease(sdef);
}
