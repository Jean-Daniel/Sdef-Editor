//
//  SdefClassManager.m
//  SDef Editor
//
//  Created by Grayfox on 17/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefClassManager.h"
#import "SdefXMLObject.h"
#import "SdefClass.h"
#import "SdefSuite.h"
#import "ShadowBase.h"
#import "SKFunctions.h"

#import "SdefImplementation.h"
#import "SdefEnumeration.h"
#import "SdefDictionary.h"
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
      @"location",
      @"number",
      @"object",
      @"point",
      @"real",
      @"record",
      @"rectangle",
      @"string",
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

- (id)initWithDictionary:(SdefDictionary *)aDictionary {
  if (self = [self init]) {
    [self setDictionary:aDictionary];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAppendChild:)
                                                 name:SdefObjectDidAppendChildNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveChild:)
                                                 name:SdefObjectWillRemoveChildNotification
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [sd_types release];
  [sd_events release];
  [sd_classes release];
  [sd_commands release];
  [sd_dictionary release];
  [super dealloc];
}

- (void)setDictionary:(SdefDictionary *)aDico {
  if (sd_dictionary != aDico) {
    if (sd_dictionary) {
      [self removeDictionary:sd_dictionary];
      [sd_dictionary release];
    }
    sd_dictionary = [aDico retain];
    if (sd_dictionary) {
      [self addDictionary:sd_dictionary];
    }
    [self setDocument:[sd_dictionary document]];
  }
}

- (void)setDocument:(SdefDocument *)aDocument {
  sd_document = aDocument;
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

- (void)addDictionary:(SdefDictionary *)aDico {
  id suites = [aDico childEnumerator];
  SdefSuite *suite;
  while (suite = [suites nextObject]) {
    [self addSuite:suite];
  }
}

- (void)removeDictionary:(SdefDictionary *)aDico {
  id suites = [aDico childEnumerator];
  SdefSuite *suite;
  while (suite = [suites nextObject]) {
    [self removeSuite:suite];
  }
}

#pragma mark -
- (NSArray *)types {
  id types = [NSMutableArray arrayWithArray:[[self class] baseTypes]];
  id items = [sd_types objectEnumerator];
  id item;
  while (item = [items nextObject]) {
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
  id types = [sd_types objectEnumerator];
  id type;
  while (type = [types nextObject]) {
    if ([[type name] isEqualToString:name])
      return type;
  }
  return nil;  
}

- (SdefClass *)classWithName:(NSString *)name {
  id classes = [sd_classes objectEnumerator];
  id class;
  while (class = [classes nextObject]) {
    if ([[class name] isEqualToString:name])
      return class;
  }
  return nil;
}

- (SdefEnumeration *)enumerationWithName:(NSString *)name {
  id types = [sd_types objectEnumerator];
  id enumeration;
  while (enumeration = [types nextObject]) {
    if ([enumeration isMemberOfClass:[SdefEnumeration class]] && [[enumeration name] isEqualToString:name])
      return enumeration;
  }
  return nil;
}

- (SdefVerb *)commandWithName:(NSString *)name {
  id cmds = [sd_commands objectEnumerator];
  id cmd;
  while (cmd = [cmds nextObject]) {
    if ([[cmd name] isEqualToString:name])
      return cmd;
  }
  return nil;
}

- (SdefVerb *)eventWithName:(NSString *)name {
  id events = [sd_events objectEnumerator];
  id event;
  while (event = [events nextObject]) {
    if ([[event name] isEqualToString:name])
      return event;
  }
  return nil;
}

- (NSArray *)subclassesOfClass:(SdefClass *)class {
  id classes = [NSMutableArray array];
  id items = [sd_classes objectEnumerator];
  SdefClass *item;
  while (item = [items nextObject]) {
    if ([[item inherits] isEqualToString:[class name]])
      [classes addObject:item];
  }
  return classes;
}

- (SdefClass *)superClassOfClass:(SdefClass *)aClass {
  NSString *parent = [aClass inherits];
  if (parent) {
    id classes = [sd_classes objectEnumerator];
    id class;
    while (class = [classes nextObject]) {
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
  if ((sd_dictionary && [node dictionary] == sd_dictionary) ||
      (sd_document && [node document] == sd_document)) {
    id child = [[aNotification userInfo] objectForKey:SdefNewTreeNode];
    switch ([child objectType]) {
      case kSdefSuiteType:
        [self addSuite:child];
        break;
      case kSdefEnumerationType:
        [sd_types addObject:child];
        break;
      case kSdefClassType:
        [sd_types addObject:child];
        [sd_classes addObject:child];
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
  if ((sd_dictionary && [node dictionary] == sd_dictionary) ||
      (sd_document && [node document] == sd_document)) {
    id child = [[aNotification userInfo] objectForKey:SdefRemovedTreeNode];
    switch ([child objectType]) {
      case kSdefSuiteType:
        [self removeSuite:child];
        break;
      case kSdefEnumerationType:
        [sd_types removeObject:child];
        break;
      case kSdefClassType:
        [sd_types removeObject:child];
        [sd_classes removeObject:child];
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
  [self addDictionary:[[aNotification userInfo] objectForKey:SdefNewTreeNode]];
}

- (void)willRemoveDictionary:(NSNotification *)aNotification {
  [self removeDictionary:[[aNotification userInfo] objectForKey:SdefRemovedTreeNode]];
}

#pragma mark -
#pragma mark Cocoa to Sdef
- (NSString *)sdefTypeForCocoaType:(NSString *)cocoaType {
  if (!cocoaType) return nil;
  
  EqualIMP isEqual;
  SEL cmd = @selector(isEqualToString:);
  isEqual = (EqualIMP)[cocoaType methodForSelector:cmd];
  
  if (isEqual(cocoaType, cmd, @"NSNumber<Bool>")) 			return @"boolean";
  if (isEqual(cocoaType, cmd, @"NSString"))  				return @"string";
  if (isEqual(cocoaType, cmd, @"NSNumber<Int>")) 			return @"integer";
  if (isEqual(cocoaType, cmd, @"NSNumber")) 				return @"number";
  if (isEqual(cocoaType, cmd, @"NSObject")) 				return @"any";
  if (isEqual(cocoaType, cmd, @"NSString<FilePath>"))  		return @"file";
  if (isEqual(cocoaType, cmd, @"NSNumber<Double>")) 		return @"real";
  if (isEqual(cocoaType, cmd, @"NSDate"))					return @"date";
  if (isEqual(cocoaType, cmd, @"NSNumber<TypeCode>"))		return @"type";
  if (isEqual(cocoaType, cmd, @"NSDictionary"))				return @"record";
  if (isEqual(cocoaType, cmd, @"NSScriptObjectSpecifier")) 	return @"object";
  if (isEqual(cocoaType, cmd, @"NSData<QDPoint>"))			return @"point";
  if (isEqual(cocoaType, cmd, @"NSPositionalSpecifier")) 	return @"location";
  if (isEqual(cocoaType, cmd, @"NSData<QDRect>"))			return @"rectangle";
  if (isEqual(cocoaType, cmd, @"NSArray"))					return @"list of any";
  
  return nil;
}

- (SdefVerb *)verbWithCocoaName:(NSString *)cocoaName inSuite:(NSString *)suite {
  id verbs = [[[self events] arrayByAddingObjectsFromArray:[self commands]] objectEnumerator];
  SdefVerb *verb;
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
  id enums = [sd_types objectEnumerator];
  SdefEnumeration *enume;
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
  id classes = [[self classes] objectEnumerator];
  SdefClass *class;
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
  switch (SKHFSTypeCodeFromFileType(aType)) {
    case typeNull:
      return nil;
    case typeBoolean:
      return @"boolean";
    case typeUnicodeText:
    case typeIntlText:
    case typeUTF8Text:
    case typeCString:
    case typeText:
      return @"string";
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
    case typeFSS:
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
      return @"object";
    case typeQDPoint:
    case typeFixedPoint:
      return @"point";
    case typeInsertionLoc:
      return @"location";
    case typeQDRectangle:
      return @"rectangle";
    case typeLongDateTime:
      return @"date";
  }
  return nil;
}

- (SdefVerb *)verbWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode {
  id verbs = [[[self events] arrayByAddingObjectsFromArray:[self commands]] objectEnumerator];
  SdefVerb *verb;
  while (verb = [verbs nextObject]) {
    if ([aCode isEqualToString:[verb codeStr]]) {
      if (!suiteCode || [suiteCode isEqualToString:[[verb suite] codeStr]]) {
        return verb;
      }
    }
  }
  return nil;
}

- (SdefClass *)sdefClassWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode {
  id classes = [[self classes] objectEnumerator];
  SdefClass *class;
  while (class = [classes nextObject]) {
    if ([aCode isEqualToString:[class codeStr]]) {
      if (!suiteCode || [suiteCode isEqualToString:[[class suite] codeStr]]) {
        return class;
      }
    }
  }
  return nil;
}

- (SdefObject *)sdefTypeWithCode:(NSString *)aCode inSuite:(NSString *)suiteCode {
  id enums = [sd_types objectEnumerator];
  SdefEnumeration *enume;
  while (enume = [enums nextObject]) {
    if ([aCode isEqualToString:[enume codeStr]]) {
      if (!suiteCode || [suiteCode isEqualToString:[[enume suite] codeStr]]) {
        return enume;
      }
    }
  }
  return [self sdefClassWithCode:aCode inSuite:suiteCode];
}

@end
