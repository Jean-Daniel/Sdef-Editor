/*
 *  SdefClassManager.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefClassManager.h"
#import "SdefClass.h"
#import "SdefSuite.h"

#import "SdefImplementation.h"
#import "SdefDictionary.h"
#import "SdefDocument.h"
#import "SdefTypedef.h"
#import "SdefSuite.h"
#import "SdefVerb.h"

#pragma mark -
static NSArray *gSortByName = nil;

@implementation SdefClassManager

+ (void)initialize {
  if ([SdefClassManager class] == self) {
    NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    gSortByName = @[desc];
  }
}

+ (NSArray *)baseTypes {
  static NSArray *types;
  if (nil == types) {
    types = @[ @"any",
               @"alias",
               @"boolean",
               @"date",
               @"double integer",
               @"file",
               @"integer",
               @"location specifier",
               @"missing value",
               @"number",
               @"specifier",
               @"point",
               @"real",
               @"record",
               @"rectangle",
               @"text",
               @"type" ];
  }
  return types;
}

+ (BOOL)isBaseType:(NSString *)type {
  return [[self baseTypes] containsObject:type];
}

- (id)init {
  if (self = [super init]) {
    sd_types = [[NSMutableArray alloc] init];
    sd_events = [[NSMutableArray alloc] init];
    sd_classes = [[NSMutableArray alloc] init];
    sd_commands = [[NSMutableArray alloc] init];
  }
  return self;
}

- (instancetype)initWithDocument:(SdefDocument *)aDocument {
  if (self = [self init]) {
    [self setDocument:aDocument];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if (sd_dicts) {
    NSFreeHashTable(sd_dicts);
    sd_dicts = nil;
  }
}

- (void)setDocument:(SdefDocument *)aDocument {
  NSAssert(sd_document == nil, @"Does not support document swapping.");
  sd_document = aDocument;
  /* Warning do not handle multiple node manipulation */
  [[sd_document notificationCenter] addObserver:self
                                       selector:@selector(didAppendChild:)
                                           name:WBUITreeNodeDidInsertChildNotification
                                         object:nil];
  [[sd_document notificationCenter] addObserver:self
                                       selector:@selector(willRemoveChild:)
                                           name:WBUITreeNodeWillRemoveChildNotification
                                         object:nil];
}

#pragma mark -
- (void)addSuite:(SdefSuite *)aSuite {
  NSParameterAssert(nil != aSuite);
  NSArray *classes = [[aSuite classes] children];
  [sd_types addObjectsFromArray:classes];
  [sd_classes addObjectsFromArray:classes];
  [sd_types addObjectsFromArray:[[aSuite types] children]];
  [sd_events addObjectsFromArray:[[aSuite events] children]];
  [sd_commands addObjectsFromArray:[[aSuite commands] children]];
  sd_cmFlags.sortType = 1; sd_cmFlags.sortClass = 1; sd_cmFlags.sortEvent = 1; sd_cmFlags.sortCommand = 1;
}

- (void)removeSuite:(SdefSuite *)aSuite {
  NSParameterAssert(nil != aSuite);
  NSArray *classes = [[aSuite classes] children];
  [sd_types removeObjectsInArray:classes];
  [sd_classes removeObjectsInArray:classes];
  [sd_types removeObjectsInArray:[[aSuite types] children]];
  [sd_events removeObjectsInArray:[[aSuite events] children]];
  [sd_commands removeObjectsInArray:[[aSuite commands] children]];
}

- (BOOL)containsDictionary:(SdefDictionary *)aDict {
  return sd_dicts && aDict && [sd_dicts containsObject:aDict];
}

- (void)addDictionary:(SdefDictionary *)aDico {
  if (!sd_dicts) // unretained object (FIXME: is it needed ?)
    sd_dicts = [NSHashTable hashTableWithOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsObjectPersonality];
  if (![sd_dicts containsObject:aDico]) {
    for (SdefSuite *suite in [aDico childEnumerator]) {
      [self addSuite:suite];
    }
    [sd_dicts addObject:aDico];
  }
}

- (void)removeDictionary:(SdefDictionary *)aDico {
  if ([sd_dicts containsObject:aDico]) {
    for (SdefSuite *suite in [aDico childEnumerator]) {
      [self removeSuite:suite];
    }
    [sd_dicts removeObject:aDico];
  }
}

/* explicite remove */
- (void)addClass:(SdefClass *)aClass {
  [sd_types addObject:aClass];
  [sd_classes addObject:aClass];
  sd_cmFlags.sortType = 1; sd_cmFlags.sortClass = 1;
}

- (void)removeClass:(SdefClass *)aClass {
  [sd_types removeObject:aClass];
  [sd_classes removeObject:aClass];
}

#pragma mark -
- (NSArray *)types {
  NSUInteger idx = [sd_types count];
  NSMutableArray *types = [NSMutableArray arrayWithArray:[[self class] baseTypes]];
  while (idx-- > 0) {
    SdefObject *item = [sd_types objectAtIndex:idx];
    if ([item name])
      [types addObject:[item name]];
  }
  [types sortUsingSelector:@selector(caseInsensitiveCompare:)];
  return types;
}

- (NSArray *)sdefTypes {
  if (sd_cmFlags.sortType) {
    [sd_types sortUsingDescriptors:gSortByName];
    sd_cmFlags.sortType = 0;
  }
  return sd_types;
}

- (NSArray *)classes {
  if (sd_cmFlags.sortClass) {
    [sd_classes sortUsingDescriptors:gSortByName];
    sd_cmFlags.sortClass = 0;
  }
  return sd_classes;
}

- (NSArray *)commands {
  if (sd_cmFlags.sortCommand) {
    [sd_commands sortUsingDescriptors:gSortByName];
    sd_cmFlags.sortCommand = 0;
  }
  return sd_commands;
}

- (NSArray *)events {
  if (sd_cmFlags.sortEvent) {
    [sd_events sortUsingDescriptors:gSortByName];
    sd_cmFlags.sortEvent = 0;
  }
  return sd_events;
}

#pragma mark -
- (id)typeWithName:(NSString *)name {
  for (SdefObject *type in sd_types) {
    if ([[type name] isEqualToString:name]) return type;
    else if ([type hasID] && [[type xmlid] isEqualToString:name]) return type;
  }
  return nil;
}

- (SdefClass *)classWithName:(NSString *)name {
  for (SdefClass *class in sd_classes) {
    if ([[class name] isEqualToString:name] || [[class xmlid] isEqualToString:name])
      return class;
  }
  return nil;
}

- (id)typeWithName:(NSString *)name class:(Class)class {
  for (SdefObject *type in sd_types) {
    if ([type isMemberOfClass:class] && [[type name] isEqualToString:name])
      return type;
  }
  return nil;
}

- (SdefValue *)valueWithName:(NSString *)name {
  return [self typeWithName:name class:[SdefValue class]];
}

- (SdefRecord *)recordWithName:(NSString *)name {
  return [self typeWithName:name class:[SdefRecord class]];
}

- (SdefEnumeration *)enumerationWithName:(NSString *)name {
  return [self typeWithName:name class:[SdefEnumeration class]];
}

- (SdefVerb *)verbWithIdentifier:(NSString *)identifier {
  SdefVerb *verb = [self commandWithIdentifier:identifier];
  if (!verb)
    verb = [self eventWithIdentifier:identifier];
  return verb;
}

- (SdefVerb *)commandWithIdentifier:(NSString *)identifier {
  for (SdefVerb *cmd in sd_commands) {
    if ([[cmd name] isEqualToString:identifier] ||
        [[cmd xmlid] isEqualToString:identifier])
      return cmd;
  }
  return nil;
}

- (SdefVerb *)eventWithIdentifier:(NSString *)identifier {
  for (SdefVerb *event in sd_events) {
    if ([[event name] isEqualToString:identifier] ||
        [[event xmlid] isEqualToString:identifier])
      return event;
  }
  return nil;
}

- (NSArray *)subclassesOfClass:(SdefClass *)class {
  NSMutableArray *classes = [NSMutableArray array];
  for (SdefClass *item in sd_classes) {
    if ([[item inherits] isEqualToString:[class name]] || [[item inherits] isEqualToString:[class xmlid]])
      [classes addObject:item];
  }
  return classes;
}

- (SdefClass *)superClassOfClass:(SdefClass *)aClass {
  NSString *parent = [aClass inherits];
  if (parent) {
    for (SdefClass *class in sd_classes) {
      if (class != aClass && ([[class name] isEqualToString:parent] || [[class xmlid] isEqualToString:parent])) {
        return class;
      }
    }
  }
  return nil;
}

#pragma mark -
#pragma mark Notification Handling
- (void)didAppendChild:(NSNotification *)aNotification {
  SdefObject *node = [aNotification object];
  if ([self containsDictionary:[node dictionary]]) {
    id child = [[aNotification userInfo] objectForKey:WBInsertedChild];
    switch ([child objectType]) {
      case kSdefType_Suite:
        [self addSuite:child];
        break;
      case kSdefType_ValueType:
      case kSdefType_RecordType:
      case kSdefType_Enumeration:
        [sd_types addObject:child];
        sd_cmFlags.sortType = 1;
        break;
      case kSdefType_Class:
        [self addClass:child];
        sd_cmFlags.sortClass = 1;
        break;
      case kSdefType_Command:
        if ([child isCommand]) {
          [sd_commands addObject:child];
          sd_cmFlags.sortCommand = 1;
        } else {
          [sd_events addObject:child];
          sd_cmFlags.sortEvent = 1;
        }
        break;
      default:
        break;
    }
  }
}

- (void)willRemoveChild:(NSNotification *)aNotification {
  SdefObject *node = [aNotification object];
  if ([self containsDictionary:[node dictionary]]) {
    id child = [[aNotification userInfo] objectForKey:WBRemovedChild];
    switch ([child objectType]) {
      case kSdefType_Suite:
        [self removeSuite:child];
        break;
      case kSdefType_ValueType:
      case kSdefType_RecordType:
      case kSdefType_Enumeration:
        [sd_types removeObject:child];
        break;
      case kSdefType_Class:
        [self removeClass:child];
        break;
      case kSdefType_Command:
        if ([child isCommand]) {
          [sd_commands removeObject:child];
        } else {
          [sd_events removeObject:child];
        }
        break;
      default:
        break;
    }
  }
}

- (void)didAddDictionary:(NSNotification *)aNotification {
  [self addDictionary:[[aNotification userInfo] objectForKey:WBInsertedChild]];
}

- (void)willRemoveDictionary:(NSNotification *)aNotification {
  [self removeDictionary:[[aNotification userInfo] objectForKey:WBRemovedChild]];
}

#pragma mark -
#pragma mark Cocoa to Sdef
static inline
NSDictionary *sdefTypeMap() {
  static NSDictionary *sMap = nil;
  if (!sMap) {
    sMap = @{
             @"NSNumber<Bool>"          : @"boolean",
             @"NSString"                : @"text",
             @"NSNumber<Int>"           : @"integer",
             @"NSNumber"                : @"number",
             @"NSObject"                : @"any",
             @"NSString<FilePath>"      : @"file",
             @"NSNumber<Float>"         : @"real",
             @"NSNumber<Double>"        : @"real",
             @"NSDate"                  : @"date",
             @"NSNumber<TypeCode>"      : @"type",
             @"NSDictionary"            : @"record",
             @"NSScriptObjectSpecifier" : @"specifier",
             @"NSData<QDPoint>"         : @"point",
             @"NSPositionalSpecifier"   : @"location specifier",
             @"NSData<QDRect>"          : @"rectangle",
             @"NSArray"                 : @"list of any"
             };
  }
  return sMap;
}

- (NSString *)sdefTypeForCocoaType:(NSString *)cocoaType {
  return cocoaType ? [sdefTypeMap() objectForKey:cocoaType] : nil;
}

static inline
SdefVerb *verbWithCocoaName(NSString *cocoaName, NSString *suite, id<NSFastEnumeration> collection) {
  for (SdefVerb *verb in collection) {
    if ([cocoaName isEqualToString:[verb cocoaName]]) {
      if (!suite || [suite isEqualToString:[[verb suite] cocoaName]]) {
        return verb;
      }
    }
  }
  return nil;
}

- (SdefVerb *)verbWithCocoaName:(NSString *)cocoaName inSuite:(NSString *)suite {
  SdefVerb *verb = verbWithCocoaName(cocoaName, suite, [self commands]);
  if (!verb)
    verb = verbWithCocoaName(cocoaName, suite, [self events]);
  return verb;
}

- (SdefObject *)sdefTypeWithCocoaType:(NSString *)cocoaType inSuite:(NSString *)suite {
  for (SdefImplementedObject *type in sd_types) {
    if ([cocoaType isEqualToString:[type cocoaName]]) {
      if (!suite || [suite isEqualToString:[[type suite] cocoaName]]) {
        return type;
      }
    }
  }
  return [self sdefClassWithCocoaClass:cocoaType inSuite:suite];
}

- (SdefClass *)sdefClassWithCocoaClass:(NSString *)cocoaClass inSuite:(NSString *)suite {
  for (SdefClass *class in [self classes]) {
    if ([cocoaClass isEqualToString:[class cocoaClass]]) {
      if (!suite || [suite isEqualToString:[[class suite] cocoaName]]) {
        return class;
      }
    }
  }
  return nil;
}

#pragma mark -
#pragma mark 'aete' to Sdef

- (NSString *)sdefTypeForAeteType:(NSString *)aType {
  if (!aType) return nil;
  switch (SdefOSTypeFromString(aType)) {
    case typeNull:
      return nil;
    case typeBoolean:
      return @"boolean";
    case typeUnicodeText:
    case typeIntlText:
    case typeUTF8Text:
    case typeCString:
    case typeText:
      return @"text";
    case 'nmbr':
      return @"number";
    case typeSInt16:
    case typeSInt32:
    case typeUInt32:
      return @"integer";
    case typeSInt64:
    case typeUInt64:
      return @"double integer";
    case typeIEEE32BitFloatingPoint:
    case typeIEEE64BitFloatingPoint:
      return @"real";
    case typeWildCard:
      return @"any";
    case typeAlias:
      return @"alias";
#if __LP64__
    case 'fss ':
#else
    case typeFSS:
#endif
    case typeFSRef:
    case typeFileURL:
    case 'file':
      return @"file";
    case typeType:
    case typeKeyword:
      return @"type";
    case typeAERecord:
    case typeEventRecord:
      return @"record";
    case typeObjectSpecifier:
      return @"specifier";
    case typeQDPoint:
    case typeFixedPoint:
      return @"point";
    case typeInsertionLoc:
      return @"location specifier";
    case typeQDRectangle:
      return @"rectangle";
    case typeLongDateTime:
      return @"date";
  }
  return nil;
}

static inline
SdefVerb *verbWithCode(NSString *aCode, NSString *suiteCode, id<NSFastEnumeration> collection) {
  for (SdefVerb *verb in collection) {
    if (SdefTypeStringEqual(aCode, [verb code])) {
      if (!suiteCode || SdefTypeStringEqual(suiteCode, [[verb suite] code])) {
        return verb;
      }
    }
  }
  return nil;
}

- (SdefVerb *)verbWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode {
  SdefVerb *verb = verbWithCode(aCode, suiteCode, [self commands]);
  if (!verb)
    verb = verbWithCode(aCode, suiteCode, [self events]);
  return verb;
}

- (SdefClass *)sdefClassWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode {
  for (SdefClass *class in [self classes]) {
    if (SdefTypeStringEqual(aCode, [class code])) {
      if (!suiteCode || SdefTypeStringEqual(suiteCode, [[class suite] code])) {
        return class;
      }
    }
  }
  return nil;
}

- (SdefObject *)sdefTypeWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode {
  for (SdefTerminologyObject *object in sd_types) {
    if (SdefTypeStringEqual(aCode, [object code])) {
      if (!suiteCode || SdefTypeStringEqual(suiteCode, [[object suite] code])) {
        return object;
      }
    }
  }
  return [self sdefClassWithCode:aCode inSuite:suiteCode];
}

@end
