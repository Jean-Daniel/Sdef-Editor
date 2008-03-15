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

#import WBHEADER(WBFunctions.h)

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
    gSortByName = [[NSArray alloc] initWithObjects:desc, nil];
    [desc release];
  }
}

+ (NSArray *)baseTypes {
  static NSArray *types;
  if (nil == types) {
    types = [[NSArray allocWithZone:NSDefaultMallocZone()] initWithObjects:
      @"any",
      @"boolean",
      @"date",
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
      @"type",
      nil];
  }
  return types;
}

+ (BOOL)isBaseType:(NSString *)type {
  return [[self baseTypes] containsObject:type];
}

- (id)init {
  if (self = [super init]) {
    sd_types = [[NSMutableArray allocWithZone:[self zone]] init];
    sd_events = [[NSMutableArray allocWithZone:[self zone]] init];
    sd_classes = [[NSMutableArray allocWithZone:[self zone]] init];
    sd_commands = [[NSMutableArray allocWithZone:[self zone]] init];
  }
  return self;
}

- (id)initWithDocument:(SdefDocument *)aDocument {
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
  [sd_types release];
  [sd_events release];
  [sd_classes release];
  [sd_commands release];
  [super dealloc];
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
  return sd_dicts && aDict && (NSHashGet(sd_dicts, aDict) != nil);
}

- (void)addDictionary:(SdefDictionary *)aDico {
  if (!sd_dicts)
    sd_dicts = NSCreateHashTable(NSNonRetainedObjectHashCallBacks, 0);
  if (!NSHashGet(sd_dicts, aDico)) {
    SdefSuite *suite;
    NSEnumerator *suites = [aDico childEnumerator];
    while (suite = [suites nextObject]) {
      [self addSuite:suite];
    }
    NSHashInsert(sd_dicts, aDico);
  }
}

- (void)removeDictionary:(SdefDictionary *)aDico {
  if (NSHashGet(sd_dicts, aDico)) {
    SdefSuite *suite;
    NSEnumerator *suites = [aDico childEnumerator];
    while (suite = [suites nextObject]) {
      [self removeSuite:suite];
    }
    NSHashRemove(sd_dicts, aDico);
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
  NSUInteger idx = [sd_types count];
  while (idx-- > 0) {
    SdefObject *type = [sd_types objectAtIndex:idx];
    if ([[type name] isEqualToString:name])
      return type;
  }
  return nil;  
}

- (SdefClass *)classWithName:(NSString *)name {
  NSUInteger idx = [sd_classes count];
  while (idx-- > 0) {
    SdefClass *class = [sd_classes objectAtIndex:idx];
    if ([[class name] isEqualToString:name])
      return class;
  }
  return nil;
}

- (id)typeWithName:(NSString *)name class:(Class)class {
  NSUInteger idx = [sd_types count];
  while (idx-- > 0) {
    SdefObject *type = [sd_types objectAtIndex:idx];
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
  NSUInteger idx = [sd_commands count];
  while (idx-- > 0) {
    SdefVerb *cmd = [sd_commands objectAtIndex:idx];
    if ([[cmd name] isEqualToString:identifier] || 
        [[cmd xmlid] isEqualToString:identifier])
      return cmd;
  }
  return nil;
}

- (SdefVerb *)eventWithIdentifier:(NSString *)identifier {
  NSUInteger idx = [sd_events count];
  while (idx-- > 0) {
    SdefVerb *event = [sd_events objectAtIndex:idx];
    if ([[event name] isEqualToString:identifier] || 
        [[event xmlid] isEqualToString:identifier])
      return event;
  }
  return nil;
}

- (NSArray *)subclassesOfClass:(SdefClass *)class {
  NSUInteger idx = [sd_classes count];
  NSMutableArray *classes = [NSMutableArray array];
  while (idx-- > 0) {
    SdefClass *item = [sd_classes objectAtIndex:idx];
    if ([[item inherits] isEqualToString:[class name]])
      [classes addObject:item];
  }
  return classes;
}

- (SdefClass *)superClassOfClass:(SdefClass *)aClass {
  NSString *parent = [aClass inherits];
  if (parent) {
    NSUInteger idx = [sd_classes count];  
    while (idx-- > 0) {
      SdefClass *class = [sd_classes objectAtIndex:idx];
      if (class != aClass && [[class name] isEqualToString:parent]) {
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
      case kSdefSuiteType:
        [self addSuite:child];
        break;
      case kSdefValueType:
      case kSdefRecordType:
      case kSdefEnumerationType:
        [sd_types addObject:child];
        sd_cmFlags.sortType = 1;
        break;
      case kSdefClassType:
        [self addClass:child];
        sd_cmFlags.sortClass = 1;
        break;
      case kSdefVerbType:
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
      case kSdefSuiteType:
        [self removeSuite:child];
        break;
      case kSdefValueType:
      case kSdefRecordType:
      case kSdefEnumerationType:
        [sd_types removeObject:child];
        break;
      case kSdefClassType:
        [self removeClass:child];
        break;
      case kSdefVerbType:
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
- (NSString *)sdefTypeForCocoaType:(NSString *)cocoaType {
  if (!cocoaType) return nil;
  
  SEL cmd = @selector(isEqualToString:);
  BOOL (*isEqual)(id, SEL, id) = (BOOL(*)(id, SEL, id))[cocoaType methodForSelector:cmd];
  
  if (isEqual(cocoaType, cmd, @"NSNumber<Bool>")) 			return @"boolean";
  if (isEqual(cocoaType, cmd, @"NSString"))  				return @"text";
  if (isEqual(cocoaType, cmd, @"NSNumber<Int>")) 			return @"integer";
  if (isEqual(cocoaType, cmd, @"NSNumber")) 				return @"number";
  if (isEqual(cocoaType, cmd, @"NSObject")) 				return @"any";
  if (isEqual(cocoaType, cmd, @"NSString<FilePath>"))  		return @"file";
  if (isEqual(cocoaType, cmd, @"NSNumber<Float>")) 			return @"real";
  if (isEqual(cocoaType, cmd, @"NSNumber<Double>")) 		return @"real";
  if (isEqual(cocoaType, cmd, @"NSDate"))					return @"date";
  if (isEqual(cocoaType, cmd, @"NSNumber<TypeCode>"))		return @"type";
  if (isEqual(cocoaType, cmd, @"NSDictionary"))				return @"record";
  if (isEqual(cocoaType, cmd, @"NSScriptObjectSpecifier")) 	return @"specifier";
  if (isEqual(cocoaType, cmd, @"NSData<QDPoint>"))			return @"point";
  if (isEqual(cocoaType, cmd, @"NSPositionalSpecifier")) 	return @"location specifier";
  if (isEqual(cocoaType, cmd, @"NSData<QDRect>"))			return @"rectangle";
  if (isEqual(cocoaType, cmd, @"NSArray"))					return @"list of any";
  
  return nil;
}

- (SdefVerb *)verbWithCocoaName:(NSString *)cocoaName inSuite:(NSString *)suite {
  SdefVerb *verb;
  NSEnumerator *verbs = [[[self events] arrayByAddingObjectsFromArray:[self commands]] objectEnumerator];
  while (verb = [verbs nextObject]) {
    if ([cocoaName isEqualToString:[verb cocoaName]]) {
      if (!suite || [suite isEqualToString:[[verb suite] cocoaName]]) {
        return verb;
      }
    }
  }
  return nil;
}

- (SdefObject *)sdefTypeWithCocoaType:(NSString *)cocoaType inSuite:(NSString *)suite {
  SdefEnumeration *enume;
  NSEnumerator *enums = [sd_types objectEnumerator];
  while (enume = [enums nextObject]) {
    if ([cocoaType isEqualToString:[enume cocoaName]]) {
      if (!suite || [suite isEqualToString:[[enume suite] cocoaName]]) {
        return enume;
      }
    }
  }
  return [self sdefClassWithCocoaClass:cocoaType inSuite:suite];
}

- (SdefClass *)sdefClassWithCocoaClass:(NSString *)cocoaClass inSuite:(NSString *)suite {
  SdefClass *class;
  NSEnumerator *classes = [[self classes] objectEnumerator];
  while (class = [classes nextObject]) {
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
    case typeSInt64:
      return @"integer";
    case typeIEEE32BitFloatingPoint:
    case typeIEEE64BitFloatingPoint:
      return @"real";
    case typeWildCard:
      return @"any";
    case typeAlias:
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

- (SdefVerb *)verbWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode {
  SdefVerb *verb;
  NSEnumerator *verbs = [[[self events] arrayByAddingObjectsFromArray:[self commands]] objectEnumerator];
  while (verb = [verbs nextObject]) {
    if (SdefTypeStringEqual(aCode, [verb code])) {
     if (!suiteCode || SdefTypeStringEqual(suiteCode, [[verb suite] code])) {
        return verb;
      }
    }
  }
  return nil;
}

- (SdefClass *)sdefClassWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode {
  SdefClass *class;
  NSEnumerator *classes = [[self classes] objectEnumerator];
  while (class = [classes nextObject]) {
    if (SdefTypeStringEqual(aCode, [class code])) {
      if (!suiteCode || SdefTypeStringEqual(suiteCode, [[class suite] code])) {
        return class;
      }
    }
  }
  return nil;
}

- (SdefObject *)sdefTypeWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode {
  NSUInteger idx = [sd_types count];
  while (idx-- > 0) {
    SdefTerminologyObject *object = [sd_types objectAtIndex:idx];
    if (SdefTypeStringEqual(aCode, [object code])) {
      if (!suiteCode || SdefTypeStringEqual(suiteCode, [[object suite] code])) {
        return object;
      }
    }
  }
  return [self sdefClassWithCode:aCode inSuite:suiteCode];
}

@end
