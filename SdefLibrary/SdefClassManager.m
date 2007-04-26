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
#import <ShadowKit/SKFunctions.h>

#import "SdefImplementation.h"
#import "SdefDictionary.h"
#import "SdefDocument.h"
#import "SdefTypedef.h"
#import "SdefSuite.h"
#import "SdefVerb.h"

#pragma mark -
@implementation SdefClassManager

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
    /* Warning do not handle multiple node manipulation */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAppendChild:)
                                                 name:SKUITreeNodeDidInsertChildNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveChild:)
                                                 name:SKUITreeNodeWillRemoveChildNotification
                                               object:nil];
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
  if (aDocument != sd_document) {
    if ([sd_document dictionary])
     
    sd_document = aDocument;
    
    if ([sd_document dictionary])
      [self addDictionary:[sd_document dictionary]];
  }
}

#pragma mark -
- (void)addSuite:(SdefSuite *)aSuite {
  NSParameterAssert(nil != aSuite);
  id classes = [[aSuite classes] children];
  [sd_types addObjectsFromArray:classes];
  [sd_classes addObjectsFromArray:classes];
  [sd_types addObjectsFromArray:[[aSuite types] children]];
  [sd_events addObjectsFromArray:[[aSuite events] children]];
  [sd_commands addObjectsFromArray:[[aSuite commands] children]];
}

- (void)removeSuite:(SdefSuite *)aSuite {
  NSParameterAssert(nil != aSuite);
  id classes = [[aSuite classes] children];
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
  return types;
}

- (NSArray *)sdefTypes {
  return sd_types;
}

- (NSArray *)classes {
  return sd_classes;
}

- (NSArray *)commands {
  return sd_commands;
}

- (NSArray *)events {
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

- (SdefVerb *)verbWithName:(NSString *)name {
  SdefVerb *verb = [self commandWithName:name];
  if (!verb)
    verb = [self eventWithName:name];
  return verb;
}

- (SdefVerb *)commandWithName:(NSString *)name {
  NSUInteger idx = [sd_commands count];
  while (idx-- > 0) {
    SdefVerb *cmd = [sd_commands objectAtIndex:idx];
    if ([[cmd name] isEqualToString:name])
      return cmd;
  }
  return nil;
}

- (SdefVerb *)eventWithName:(NSString *)name {
  NSUInteger idx = [sd_events count];
  while (idx-- > 0) {
    SdefVerb *event = [sd_events objectAtIndex:idx];
    if ([[event name] isEqualToString:name])
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
  if ([self containsDictionary:[node dictionary]] ||
      (sd_document && [node document] == sd_document)) {
    id child = [[aNotification userInfo] objectForKey:SKInsertedChild];
    switch ([child objectType]) {
      case kSdefSuiteType:
        [self addSuite:child];
        break;
      case kSdefValueType:
      case kSdefRecordType:
      case kSdefEnumerationType:
        [sd_types addObject:child];
        break;
      case kSdefClassType:
        [self addClass:child];
        break;
      case kSdefVerbType:
        if ([child isCommand]) {
          [sd_commands addObject:child];
        } else {
          [sd_events addObject:child];
        }
        break;
      default:
        break;
    }
  }
}

- (void)willRemoveChild:(NSNotification *)aNotification {
  SdefObject *node = [aNotification object];
  if ([self containsDictionary:[node dictionary]] ||
      (sd_document && [node document] == sd_document)) {
    id child = [[aNotification userInfo] objectForKey:SKRemovedChild];
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
  [self addDictionary:[[aNotification userInfo] objectForKey:SKInsertedChild]];
}

- (void)willRemoveDictionary:(NSNotification *)aNotification {
  [self removeDictionary:[[aNotification userInfo] objectForKey:SKRemovedChild]];
}

#pragma mark -
#pragma mark Cocoa to Sdef
- (NSString *)sdefTypeForCocoaType:(NSString *)cocoaType {
  if (!cocoaType) return nil;
  
  EqualIMP isEqual;
  SEL cmd = @selector(isEqualToString:);
  isEqual = (EqualIMP)[cocoaType methodForSelector:cmd];
  
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
