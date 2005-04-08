//
//  SdtplGenerator.m
//  Sdef Editor
//
//  Created by Grayfox on 04/04/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdtplGenerator.h"
#import "ShadowCFContext.h"
#import "SKExtensions.h"
#import "SdefTemplate.h"
#import "SKTemplate.h"

#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefSuite.h"
#import "SdefDocument.h"
#import "SdefArguments.h"
#import "SdefDictionary.h"
#import "SdefClassManager.h"
#import "ASDictionaryObject.h"

#define SetVariable(tpl, name, value) \
{ \
  id __varStr = [self formatString:value forVariable:name]; \
    [tpl setVariable:__varStr forKey:name]; \
}

static __inline__ NSString *SdefEscapedString(NSString *value, unsigned int format) {
  return ((kSdefTemplateXMLFormat == format) ? [value stringByEscapingEntities:nil] : value);
}

static NSNull *_null;
static NSString *SdtplSimplifieName(NSString *name);

@interface SdtplGenerator (Private)
#pragma mark References Generator
- (NSString *)fileForObject:(SdefObject *)anObject;

- (NSString *)anchorForObject:(SdefObject *)obj;
- (NSString *)anchorNameForObject:(SdefObject *)anObject;

- (NSString *)linkForType:(NSString *)aType withString:(NSString *)aString;
- (NSString *)linkForVerb:(NSString *)aVerb withString:(NSString *)aString;
- (NSString *)linkForObject:(SdefObject *)anObject withString:(NSString *)aString;

#pragma mark Misc
- (NSString *)formatString:(NSString *)str forVariable:(NSString *)variable;

- (void)initCache;
- (void)releaseCache;

@end

#pragma mark -
@implementation SdtplGenerator

+ (void)initialize {
  static BOOL tooLate = NO;
  if (!tooLate) {
    _null = [NSNull null];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
      SKBool(NO), @"SdtplSortSuite",
      SKBool(YES), @"SdtplHTMLLinks",
      SKBool(YES), @"SdtplSortOthers",
      SKBool(NO), @"SdtplSubclasses",
      SKBool(YES), @"SdtplGroupEvents",
      SKBool(NO), @"SdtplIgnoreEvents",
      SKBool(YES), @"SdtplIgnoreRespondsTo",
      nil]];
    tooLate = YES;
  }
}

- (void)loadPreferences {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [self setLinks:[defaults boolForKey:@"SdtplHTMLLinks"]];
  [self setSortSuites:[defaults boolForKey:@"SdtplSortSuite"]];
  [self setSortOthers:[defaults boolForKey:@"SdtplSortOthers"]];
  [self setSubclasses:[defaults boolForKey:@"SdtplSubclasses"]];
  [self setIgnoreEvents:[defaults boolForKey:@"SdtplIgnoreEvents"]];
  [self setIgnoreRespondsTo:[defaults boolForKey:@"SdtplIgnoreRespondsTo"]];
  [self setGroupEventsAndCommands:[defaults boolForKey:@"SdtplGroupEvents"]];
}

- (void)savePreferences {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:[self links] forKey:@"SdtplHTMLLinks"];
  [defaults setBool:[self sortSuites] forKey:@"SdtplSortSuite"];
  [defaults setBool:[self sortOthers] forKey:@"SdtplSortOthers"];
  [defaults setBool:[self subclasses] forKey:@"SdtplSubclasses"];
  [defaults setBool:[self ignoreEvents] forKey:@"SdtplIgnoreEvents"];
  [defaults setBool:[self ignoreRespondsTo] forKey:@"SdtplIgnoreRespondsTo"];
  [defaults setBool:[self groupEventsAndCommands] forKey:@"SdtplGroupEvents"];
  [defaults synchronize];
}

- (id)init {
  if (self = [super init]) {
    [self loadPreferences];
  }
  return self;
}

- (void)dealloc {
  [self savePreferences];
  [sd_tpl release];
  [sd_path release];
  [sd_base release];
  [self releaseCache];
  [super dealloc];
}

#pragma mark -
- (BOOL)sortSuites {
  return gnflags.sortSuites;
}

- (void)setSortSuites:(BOOL)sort {
  gnflags.sortSuites = sort ? 1 : 0;
}


- (BOOL)sortOthers {
  return gnflags.sortOthers;
}

- (void)setSortOthers:(BOOL)sort {
  gnflags.sortOthers = sort ? 1 : 0;
}

- (BOOL)subclasses {
  return gnflags.subclasses;
}

- (void)setSubclasses:(BOOL)flag {
  gnflags.subclasses = flag ? 1 : 0;
}

- (BOOL)ignoreEvents {
  return gnflags.ignoreEvents;
}

- (void)setIgnoreEvents:(BOOL)flag {
  gnflags.ignoreEvents = flag ? 1 : 0;
}

- (BOOL)groupEventsAndCommands {
  return gnflags.groupEvents;
}

- (void)setGroupEventsAndCommands:(BOOL)flag {
  gnflags.groupEvents = flag ? 1 : 0;
}

- (BOOL)ignoreRespondsTo {
  return gnflags.ignoreRespondsTo;
}

- (void)setIgnoreRespondsTo:(BOOL)flag {
  gnflags.ignoreRespondsTo = flag ? 1 : 0;
}

- (BOOL)links {
  return gnflags.links;
}

- (void)setLinks:(BOOL)links {
  gnflags.links = links ? 1 : 0;
}

- (SdefTemplate *)template {
  return sd_tpl;
}

- (void)setTemplate:(SdefTemplate *)aTemplate {
  if (aTemplate != sd_tpl) {
    [sd_tpl release];
    sd_tpl = [aTemplate retain];
    gnflags.format = [sd_tpl isHtml] ? kSdefTemplateXMLFormat : kSdefTemplateDefaultFormat;
  }
}

#pragma mark -
#pragma mark Cache management
- (NSString *)formatString:(NSString *)str forVariable:(NSString *)variable {
  id format = [sd_formats objectForKey:variable];
  if (format) {
    return ([format rangeOfString:@"%@"].location != NSNotFound) ? [NSString stringWithFormat:format, str] : format;
  }
  return str;
}

#pragma mark -
- (void)initCache {
  if (sd_tpl) {
    sd_formats = [[sd_tpl formats] mutableCopy];
    sd_link = [sd_formats objectForKey:@"Links"];
    if (!sd_link) {
      sd_link = @"<a href=\"%@#%@\">%@</a>";
    }
    /* Use retain instead of copy for key (faster) */
    sd_links = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kSKDictionaryKeyCallBacks, &kSKDictionaryValueCallBacks);
    sd_files = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kSKDictionaryKeyCallBacks, &kSKDictionaryValueCallBacks);
    sd_anchors = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kSKDictionaryKeyCallBacks, &kSKDictionaryValueCallBacks);
    
    id defs = [sd_tpl definition];
    /* Toc */
    gnflags.toc = (nil != [defs objectForKey:@"Toc"]) ? 1 : 0;
    /* Index */
    gnflags.index = (nil != [defs objectForKey:@"Index"]) ? 1 : 0;
    /* Suite */
    id def = [defs objectForKey:@"Suites"];
    if (def) {
      gnflags.suites = [[def objectForKey:@"SingleFile"] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    } 
    /* Class */
    def = [defs objectForKey:@"Classes"];
    if (def) {
      gnflags.classes = [[def objectForKey:@"SingleFile"] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    }
    /* Events */
    def = [defs objectForKey:@"Events"];
    if (def) {
      gnflags.events = [[def objectForKey:@"SingleFile"] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    }
    /* Commands */
    def = [defs objectForKey:@"Commands"];
    if (def) {
      gnflags.commands = [[def objectForKey:@"SingleFile"] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    }
  }
}

- (void)releaseCache {
  [sd_formats release];
  sd_formats = nil;
  sd_link = nil;
  if (sd_links) { CFRelease(sd_links); sd_links = nil; }
  if (sd_files) { CFRelease(sd_files); sd_files = nil; }
  if (sd_anchors) { CFRelease(sd_anchors); sd_anchors = nil; }
  
  gnflags.suites = kSdtplInline;
  gnflags.classes = kSdtplInline;
  gnflags.commands = kSdtplInline;
  gnflags.events = kSdtplInline;
}

#pragma mark -
#pragma mark References Generator
- (NSString *)fileForObject:(SdefObject *)anObject {
  id file = (id)CFDictionaryGetValue(sd_files, anObject);
  if (!file) {
    int flag = kSdefUndefinedType;
    switch ([anObject objectType]) {
      case kSdefDictionaryType:
        if (!gnflags.index) {
          file = [sd_path lastPathComponent];
          break;
        } else {
          file = [NSString stringWithFormat:@"%@.%@", 
            SdtplSimplifieName([anObject name]), [sd_tpl extension]];
        }
        break;
      case kSdefSuiteType:
        /* Si les suites ne sont pas dans un fichier a part */
        switch (gnflags.suites) {
          case kSdtplInline:
            return [self fileForObject:[anObject dictionary]];
          case kSdtplSingleFile:
            file = [@"Suites" stringByAppendingPathExtension:[sd_tpl extension]];
            break;
          case kSdtplMultiFiles:
            file = [NSString stringWithFormat:@"%@.%@", 
              SdtplSimplifieName([anObject name]), [sd_tpl extension]];
            break;
        }
        break;
      /* Suite children */
      case kSdefClassType:
        switch (gnflags.classes) {
          case kSdtplInline:
            return [self fileForObject:[anObject suite]];
          case kSdtplSingleFile:
            file = [NSString stringWithFormat:@"%@_Classes.%@", 
              SdtplSimplifieName([[anObject suite] name]), [sd_tpl extension]];
            break;
          case kSdtplMultiFiles:
            file = [NSString stringWithFormat:@"%@_%@.%@",
              SdtplSimplifieName([[anObject suite] name]),
              SdtplSimplifieName([anObject name]), [sd_tpl extension]];
            break;
        }
        break;
      case kSdefVerbType:
        flag = ([(SdefVerb *)anObject isCommand]) ? gnflags.commands : gnflags.events;
        switch (flag) {
          case kSdtplInline:
            return [self fileForObject:[anObject suite]];
          case kSdtplSingleFile:
            file = [NSString stringWithFormat:@"%@_%@.%@", 
              SdtplSimplifieName([[anObject suite] name]),
          [(SdefVerb *)anObject isCommand] ? @"Commands" : @"Events", [sd_tpl extension]];
            break;
          case kSdtplMultiFiles:
            file = [NSString stringWithFormat:@"%@_%@.%@",
              SdtplSimplifieName([[anObject suite] name]),
              SdtplSimplifieName([anObject name]), [sd_tpl extension]];
            break;
        }
        break;
      default:
        file = _null;
    }
    //DLog(@"Cache File: <%@ %p> => %@", NSStringFromClass([anObject class]), anObject, file);
    CFDictionarySetValue(sd_files, anObject, file);
  }
  return (file != _null) ? file : nil;
}

- (NSString *)anchorForObject:(SdefObject *)obj {
  id name = [self anchorNameForObject:obj];
  if (name) {
    id anchor = [sd_formats objectForKey:@"AnchorFormat"];
    if (!anchor) {
      anchor = @"<a name=\"%@\" />";
      [sd_formats setObject:anchor forKey:@"AnchorFormat"];
    }
    return [NSString stringWithFormat:anchor, name];
  }
  return nil;
}

- (NSString *)anchorNameForObject:(SdefObject *)anObject {
  id anchor = (id)CFDictionaryGetValue(sd_anchors, anObject);
  if (!anchor) {
    switch ([anObject objectType]) {
      case kSdefSuiteType:
        anchor = [NSString stringWithFormat:@"suite_%@", SdtplSimplifieName([anObject name])];
        break;
      case kSdefClassType:
      case kSdefVerbType:
        anchor = [NSString stringWithFormat:@"%@_%@", SdtplSimplifieName([[anObject suite] name]), SdtplSimplifieName([anObject name])];
        break;
      default:
        anchor = _null;
    }
    //DLog(@"Cache Anchor: <%@ %p> => %@", NSStringFromClass([anObject class]), anObject, anchor);
    CFDictionarySetValue(sd_anchors, anObject, anchor);
  }
  return (_null == anchor) ? nil : anchor;
}

- (NSString *)linkForType:(NSString *)aType withString:(NSString *)aString {
  id link = (id)CFDictionaryGetValue(sd_links, aType);
  if (!link) {
    link = aString;
    if (![SdefClassManager isBaseType:aType]) {
      id class = [sd_manager classWithName:aType];
      link = [self linkForObject:class withString:aString];
    }
    //DLog(@"Cache Type: %@ => %@", aType, link);
    CFDictionarySetValue(sd_links, aType, link);
  }
  return link;
}

- (NSString *)linkForVerb:(NSString *)aVerb withString:(NSString *)aString {
  id link = (id)CFDictionaryGetValue(sd_links, aVerb);
  if (!link) {
    SdefObject *object = [sd_manager commandWithName:aVerb];
    if (!object) {
      object = [sd_manager eventWithName:aVerb];
    }
    link = [self linkForObject:object withString:aString];
    //DLog(@"Cache Verb: <%@ %p> => %@", NSStringFromClass([aVerb class]), aVerb, link);
    CFDictionarySetValue(sd_links, aVerb, link);
  }
  return link;
}

- (NSString *)linkForObject:(SdefObject *)anObject withString:(NSString *)aString {
  NSString *link = aString;
  if (anObject) {
    id file = [self fileForObject:anObject];
    link = [NSString stringWithFormat:sd_link, (file) ? : @"", [self anchorNameForObject:anObject], aString];
  }
  return link;
}

#pragma mark -

- (void)writeDictionaryToc:(SdefDictionary *)dictionary usingTemplate:(SKTemplate *)tpl {
//  SetVariable(tpl, @"Toc_Dictionary_Name", [dictionary name]);
//  /* Suites */
//  SKTemplate *stpl = [tpl blockWithName:@"Toc_Suite"];
//  id suites = [dictionary childEnumerator];
//  SdefSuite *suite;
//  while (suite = [suites nextObject]) {
//    if ([suite name]) {
//      SetVariable(stpl, @"Toc_Suite_Name", [suite name]);
//    }
//    /* Classes */
//    if ([[suite classes] hasChildren]) {
//      SKTemplate *ctpl = [tpl blockWithName:@"Toc_Class"];
//      id classes = [[suite classes] childEnumerator];
//      SdefClass *class;
//      while (class = [classes nextObject]) {
//        NSString *name = [class name];
//        if (name) {
//          if (gnflags.links)
//            name = [self linkForType:name withString:name];
//          SetVariable(ctpl, @"Toc_Class_Name", name);
//        }
//        [ctpl dumpBlock];
//      }
//      [[tpl blockWithName:@"Toc_Classes"] dumpBlock];
//    }
//    
//    /* Commands */
//    if ([[suite commands] hasChildren] || [[suite events] hasChildren]) {
//      id verb;
//      id vtpl = [tpl blockWithName:@"Toc_Command"];
//      id verbs = [[suite commands] childEnumerator];
//      while (verb = [verbs nextObject]) {
//        NSString *name = [verb name];
//        if (name) {
//          if (gnflags.links)
//            name = [self linkForObject:verb withString:name];
//          SetVariable(vtpl, @"Toc_Command_Name", name);
//        }
//        [vtpl dumpBlock];
//      }
//      verbs = [[suite events] childEnumerator];
//      while (verb = [verbs nextObject]) {
//        NSString *name = [verb name];
//        if (name) {
//          if (gnflags.links)
//            name = [self linkForObject:verb withString:name];
//          SetVariable(vtpl, @"Toc_Command_Name", name);
//        }
//        [vtpl dumpBlock];
//      }
//      /* require to generate classes block */
//      [[tpl blockWithName:@"Toc_Commands"] dumpBlock];
//    }
//    [stpl dumpBlock];
//  }
}

- (BOOL)writeToc:(NSString *)toc toFolder:(NSString *)aFolder {
//  id path = [aFolder stringByAppendingPathComponent:[[sd_tpl tocFile] stringByAppendingPathExtension:[sd_tpl extension]]];
//  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//    NSAlert *alert = [NSAlert alertWithMessageText:@"File already exist"
//                                     defaultButton:@"Replace"
//                                   alternateButton:@"Ignore"
//                                       otherButton:@"Cancel"
//                         informativeTextWithFormat:@"Would you like replace"];
//
//    int result = [alert runModal];
//    switch (result) {
//      case NSAlertAlternateReturn:
//        return;
//      case NSAlertOtherReturn:
//        [NSException raise:@"SdefUserCancelException" format:@"Replace TOC file"];
//        return;
//    }
//  }
//  [toc writeToFile:path atomically:YES];
  return YES;
}

#pragma mark Verb
- (void)writeParameter:(SdefParameter *)param usingTemplate:(SKTemplate *)tpl {
  if ([param name])
    SetVariable(tpl, @"Parameter_Name", [param name]);
  if ([param desc])
    SetVariable(tpl, SdefEscapedString(@"Parameter_Description", gnflags.format), [param desc]);
  BOOL list;
  id type = [param asDictionaryTypeForType:[param type] isList:&list];
  if (list) {
    SetVariable(tpl, @"Parameter_Type_List", @"a list of");
  }
  SetVariable(tpl, @"Parameter_Type", type);
}

- (BOOL)writeVerb:(SdefVerb *)verb usingTemplate:(SKTemplate *)tpl {
  if ([verb name]) {
    SetVariable(tpl, @"Command_Name", [verb name]);
    if (gnflags.links)
      SetVariable(tpl, @"Command_Anchor", [self anchorForObject:verb]);
  }
  if ([verb desc])
    SetVariable(tpl, SdefEscapedString(@"Command_Description", gnflags.format), [verb desc]);
  if (gnflags.sortOthers) {
    [verb sortByName];
  }
  if ([[verb directParameter] type]) {
    id block = [tpl blockWithName:@"Direct_Parameter"];
    SdefDirectParameter *param = [verb directParameter];
    BOOL list;
    id type = [param asDictionaryTypeForType:[param type] isList:&list];
    if (list) {
      SetVariable(block, @"Direct_Parameter_List", @"a list of");
    }
    SetVariable(block, @"Direct_Parameter", type);
    if ([param desc])
      SetVariable(block, SdefEscapedString(@"Direct_Parameter_Description", gnflags.format), [param desc]);
    [block dumpBlock];
  }
  if ([[verb result] type]) {
    id block = [tpl blockWithName:@"Result"];
    SdefResult *result = [verb result];
    BOOL list;
    id type = [result asDictionaryTypeForType:[result type] isList:&list];
    if (list) {
      SetVariable(block, @"Result_Type_List", @"a list of");
    }
    SetVariable(block, @"Result_Type", type);
    if ([result desc])
      SetVariable(block, SdefEscapedString(@"Result_Description", gnflags.format), [result desc]);
    [block dumpBlock];
  }
  if ([verb hasChildren]) {
    SdefParameter *param;
    id params = [verb childEnumerator];
    id block = [tpl blockWithName:@"Required_Parameter"];
    /* Required parameters */
    while (param = [params nextObject]) {
      if (![param isOptional]) {
        [self writeParameter:param usingTemplate:block];
        [block dumpBlock];
      }
    }
    
    params = [verb childEnumerator];
    block = [tpl blockWithName:@"Optional_Parameter"];
    /* Optionals parameters */
    while (param = [params nextObject]) {
      if ([param isOptional]) {
        [self writeParameter:param usingTemplate:block];
        [block dumpBlock];
      }
    }
    [[tpl blockWithName:@"Parameters"] dumpBlock];
  }
  
  BOOL ok = YES;
  NSString *path = nil;
  int flag = [verb isCommand] ? gnflags.commands : gnflags.events;
  switch (flag) {
    case kSdtplSingleFile:
      [tpl dumpBlock];
      break;
    case kSdtplMultiFiles:
      path = [sd_base stringByAppendingPathComponent:[self fileForObject:verb]];
      ok = [tpl writeToFile:path atomically:YES reset:YES];
      break;
  }
  return ok;
}

#pragma mark Classes
- (void)writeElement:(SdefElement *)elt usingTemplate:(SKTemplate *)tpl {
  if ([elt name]) {
    id name = [elt name];
    if (gnflags.links)
      name = [self linkForType:name withString:name];
    SetVariable(tpl, @"Element_Type", name);
  }
  NSAssert1([elt respondsToSelector:@selector(writeAccessorsStringToStream:)],
            @"Element %@ does not responds to writeAccessorsStringToStream:", elt);
  id access = [[NSMutableString alloc] init];
  [elt performSelector:@selector(writeAccessorsStringToStream:) withObject:access];
  SetVariable(tpl, @"Element_Accessors", access);
  [access release];
}

- (void)writeProperty:(SdefProperty *)prop usingTemplate:(SKTemplate *)tpl {
  if ([prop name])
    SetVariable(tpl, @"Property_Name", [prop name]);
  if ([prop type]) {
    id type = [prop asDictionaryTypeForType:[prop type] isList:nil];
    if (gnflags.links)
      type = [self linkForType:[prop type] withString:type];
    SetVariable(tpl, @"Property_Type", type);
  }
  if (([prop access] & kSdefAccessWrite) == 0)
    SetVariable(tpl, @"ReadOnly", @"[r/o]");
  if ([prop desc])
    SetVariable(tpl, SdefEscapedString(@"Property_Description", gnflags.format), [prop desc]);
}

- (BOOL)writeClass:(SdefClass *)aClass usingTemplate:(SKTemplate *)tpl {
  if ([aClass name]) {
    SetVariable(tpl, @"Class_Name", [aClass name]);
    if (gnflags.links)
      SetVariable(tpl, @"Class_Anchor", [self anchorForObject:aClass]);
  }
  if ([aClass desc])
    SetVariable(tpl, SdefEscapedString(@"Class_Description", gnflags.format), [aClass desc]);
  if ([aClass plural]) {
    id plural = [tpl blockWithName:@"Plural"];
    SetVariable(plural, @"Plural", [aClass plural]);
    [plural dumpBlock];
  }
  /* Subclasses */
  if (gnflags.subclasses && [tpl blockWithName:@"Subclasses"]) {
    id items = [sd_manager subclassesOfClass:aClass];
    if ([items count]) {
      id item;
      items = [items objectEnumerator];
      id subclass = [tpl blockWithName:@"Subclass"];
      id subclasses = [tpl blockWithName:@"Subclasses"];
      while (item = [items nextObject]) {
        id name = [item name];
        if (gnflags.links)
          name = [self linkForType:name withString:name];
        SetVariable(subclass, @"Subclass", name);
        [subclass dumpBlock];
      }
      [subclasses dumpBlock];
    }
  }
  /* Group responds To */
  if (gnflags.groupEvents && !gnflags.ignoreEvents && !gnflags.ignoreRespondsTo) {
    id cmds = [aClass commands];
    id events = [aClass events];
    id evnt;
    while (evnt = [events firstChild]) {
      [evnt retain];
      [evnt remove];
      [cmds appendChild:evnt];
      [evnt release];
    }
  }
  
  if (gnflags.sortOthers) {
    [[aClass elements] sortByName];
    [[aClass properties] sortByName];
    if (!gnflags.ignoreRespondsTo) {
      [[aClass commands] sortByName];
      [[aClass events] sortByName];
    }
  }
  
  /* Elements */
  if ([[aClass elements] hasChildren]) {
    id elements = [[aClass elements] childEnumerator];
    id elt;
    id eltBlock = [tpl blockWithName:@"Element"];
    while (elt = [elements nextObject]) {
      [self writeElement:elt usingTemplate:eltBlock];
      [eltBlock dumpBlock];
    }
    /* require to generate block */
    [[tpl blockWithName:@"Elements"] dumpBlock];
  }
  /* Inherits */
  if ([aClass inherits] && [tpl blockWithName:@"Superclass"]) {
    id superclass = [tpl blockWithName:@"Superclass"];
    id inherits = [aClass inherits];
    if (gnflags.links)
      inherits = [self linkForType:inherits withString:inherits];
    SetVariable(superclass, @"Superclass", inherits);
    SetVariable(superclass, @"Superclass_Description", [aClass inherits]);
    [superclass dumpBlock];
  }
  /* Properties */
  /* inner: if superclass is in Properties block, we have to dump it. */
  BOOL inner = [[[[tpl blockWithName:@"Superclass"] parent] name] isEqualToString:@"Properties"];
  if ([[aClass properties] hasChildren] || ([aClass inherits] && inner)) {
    id propBlock = [tpl blockWithName:@"Property"];
    id properties = [[aClass properties] childEnumerator];
    id property;
    while (property = [properties nextObject]) {
      [self writeProperty:property usingTemplate:propBlock];
      [propBlock dumpBlock];
    }
    /* require to generate block */
    [[tpl blockWithName:@"Properties"] dumpBlock];
  }
  
  /* Responds-To */
  if (!gnflags.ignoreRespondsTo) {
    /* Commands */
    if ([[aClass commands] hasChildren] && nil != [tpl blockWithName:@"RespondsTo_Commands"]) {
      id cmd;
      id cmds = [[aClass commands] childEnumerator];
      id cmdBlock = [tpl blockWithName:@"RespondsTo_Command"];
      while (cmd = [cmds nextObject]) {
        NSString *verb = [cmd name];
        if (gnflags.links)
          verb = [self linkForVerb:verb withString:verb];
        SetVariable(cmdBlock, @"RespondsTo_Command", verb);
        [cmdBlock dumpBlock];
      }
      /* require to generate block */
      [[tpl blockWithName:@"RespondsTo_Commands"] dumpBlock];
    }
    
    /* Events */
    if ([[aClass events] hasChildren] && nil != [tpl blockWithName:@"RespondsTo_Events"]) {
      id evnt;
      id evnts = [[aClass commands] childEnumerator];
      id evntBlock = [tpl blockWithName:@"RespondsTo_Event"];
      while (evnt = [evnts nextObject]) {
        NSString *verb = [evnt name];
        if (gnflags.links)
          verb = [self linkForVerb:verb withString:verb];
        SetVariable(evntBlock, @"RespondsTo_Event", verb);
        [evntBlock dumpBlock];
      }
      /* require to generate block */
      [[tpl blockWithName:@"RespondsTo_Events"] dumpBlock];
    }
  }
  
  BOOL ok = YES;
  NSString *path = nil;
  switch (gnflags.classes) {
    case kSdtplSingleFile:
      [tpl dumpBlock];
      break;
    case kSdtplMultiFiles:
      path = [sd_base stringByAppendingPathComponent:[self fileForObject:aClass]];
      ok = [tpl writeToFile:path atomically:YES reset:YES];
      break;
  }
  return ok;
}

#pragma mark Suites
- (BOOL)writeSuite:(SdefSuite *)suite usingTemplate:(SKTemplate *)tpl {
  if ([suite name]) {
    SetVariable(tpl, @"Suite_Name", [suite name]);
    if (gnflags.links)
      SetVariable(tpl, @"Suite_Anchor", [self anchorForObject:suite]);
  }
  if ([suite desc])
    SetVariable(tpl, @"Suite_Description", [suite desc]);
  
  if (gnflags.groupEvents && !gnflags.ignoreEvents) {
    id cmds = [suite commands];
    id events = [suite events];
    id evnt;
    while (evnt = [events firstChild]) {
      [evnt retain];
      [evnt remove];
      [cmds appendChild:evnt];
      [evnt release];
    }
  }

  if (gnflags.sortOthers) {
    [[suite classes] sortByName];
    [[suite commands] sortByName];
    [[suite events] sortByName];
  }
  
  if ([[suite classes] hasChildren]) {
    id class;
    id classes = [[suite classes] childEnumerator];
    
    SKTemplate *classTpl = nil;
    SKTemplate *classBlock = [tpl blockWithName:@"Class"];
    if (kSdtplInline == gnflags.classes) {
      classTpl = classBlock;
    } else {
      classTpl = [[sd_tpl templates] objectForKey:@"Classes"];
    }
    
    while (class = [classes nextObject]) {
      if (kSdtplInline == gnflags.classes) {
        [classBlock setVariable:[self linkForObject:class withString:[class name]] forKey:@"Class_Name"];
      }
      [self writeClass:class usingTemplate:classTpl];
      [classBlock dumpBlock];
    }
    switch (gnflags.classes) {
      case kSdtplInline:
        [[tpl blockWithName:@"Classes"] dumpBlock];
        break;
      case kSdtplSingleFile:
        [classTpl writeToFile:[self fileForObject:[[suite classes] firstChild]] atomically:YES reset:YES];
        break;
    }
  }
  
  /* Commands */
  if ([[suite commands] hasChildren]) {
    id cmd;
    id cmds = [[suite commands] childEnumerator];
    
    SKTemplate *cmdTpl = nil;
    SKTemplate *cmdBlock = [tpl blockWithName:@"Command"];
    if (kSdtplInline == gnflags.commands) {
      cmdTpl = cmdBlock;
    } else {
      cmdTpl = [[sd_tpl templates] objectForKey:@"Commands"];
    }
    
    while (cmd = [cmds nextObject]) {
      if (kSdtplInline == gnflags.commands) {
        [cmdBlock setVariable:[self linkForObject:cmd withString:[cmd name]] forKey:@"Command_Name"];
      }
      [self writeVerb:cmd usingTemplate:cmdTpl];
      [cmdBlock dumpBlock];
    }
    switch (gnflags.commands) {
      case kSdtplInline:
        [[tpl blockWithName:@"Commands"] dumpBlock];
        break;
      case kSdtplSingleFile:
        [cmdTpl writeToFile:[self fileForObject:[[suite commands] firstChild]] atomically:YES reset:YES];
        break;
    }
  }
  
  if (!gnflags.ignoreEvents && [[suite events] hasChildren]) {
    id evnt;
    id evnts = [[suite events] childEnumerator];
    
    SKTemplate *evntTpl = nil;
    SKTemplate *evntBlock = [tpl blockWithName:@"Event"];
    if (kSdtplInline == gnflags.events) {
      evntTpl = evntBlock;
    } else {
      evntTpl = [[sd_tpl templates] objectForKey:@"Events"];
    }
    
    while (evnt = [evnts nextObject]) {
      if (kSdtplInline == gnflags.commands) {
        [evntBlock setVariable:[self linkForObject:evnt withString:[evnt name]] forKey:@"Event_Name"];
      }
      [self writeVerb:evnt usingTemplate:evntTpl];
      [evntBlock dumpBlock];
    }
    switch (gnflags.events) {
      case kSdtplInline:
        [[tpl blockWithName:@"Events"] dumpBlock];
        break;
      case kSdtplSingleFile:
        [evntTpl writeToFile:[self fileForObject:[[suite events] firstChild]] atomically:YES reset:YES];
        break;
    }
  }
  
  BOOL ok = YES;
  NSString *path = nil;
  switch (gnflags.suites) {
    case kSdtplSingleFile:
      [tpl dumpBlock];
      break;
    case kSdtplMultiFiles:
      path = [sd_base stringByAppendingPathComponent:[self fileForObject:suite]];
      ok = [tpl writeToFile:path atomically:YES reset:YES];
      break;
  }
  return ok;
}

#pragma mark Dictionary
- (BOOL)writeDictionary:(SdefDictionary *)aDico usingTemplate:(SKTemplate *)tpl {
  NSString *file = nil;
  if (gnflags.index) {
    file = [sd_base stringByAppendingPathComponent:[self fileForObject:aDico]];
  } else {
    file = sd_path;
  }

  /* Generate Template */
  if (gnflags.sortSuites) 
    [aDico sortByName];
  
  SdefSuite *suite;
  NSEnumerator *suites = [aDico childEnumerator];
  
  SKTemplate *suiteTpl = nil;
  SKTemplate *suiteBlock = [tpl blockWithName:@"Suite"];
  if (kSdtplInline == gnflags.suites) {
    suiteTpl = suiteBlock;
  } else {
    suiteTpl = [[sd_tpl templates] objectForKey:@"Suites"];
  }
  
  while (suite = [suites nextObject]) {
    if (kSdtplInline == gnflags.suites) {
      [suiteBlock setVariable:[self linkForObject:suite withString:[suite name]] forKey:@"Suite_Name"];
    }
    [self writeSuite:suite usingTemplate:suiteTpl];
    [suiteBlock dumpBlock];
  }
  
  return [tpl writeToFile:file atomically:YES reset:YES];
}

#pragma mark Index
- (BOOL)writeIndex:(SdefDictionary *)theDico usingTemplate:(SKTemplate *)tpl {
  [self writeReferences:theDico usingTemplate:tpl];
  return [tpl writeToFile:sd_path atomically:YES reset:YES];
}

#pragma mark Common
- (void)writeReferences:(SdefDictionary *)theDico usingTemplate:(SKTemplate *)tpl {
  
  /* Set Style */
  /***************/
  
  if (gnflags.index) {
    [tpl setVariable:[sd_path lastPathComponent] forKey:@"Index_Link"];
  }
  if (gnflags.toc) {
    /* Toc path */
    //[tpl setVariable:<#(NSString *)aValue#> forKey:@"Toc_Link"];
  }
  [tpl setVariable:[self fileForObject:theDico] forKey:@"Dictionary_Link"];
}

#pragma mark -
- (BOOL)writeDictionary:(SdefDictionary *)aDico toFile:(NSString *)aFile {
  id pool = [[NSAutoreleasePool alloc] init];
  [self initCache];
  
  if (![sd_formats objectForKey:@"Superclass_Description"]) {
    [sd_formats setObject:@"inherits some of its properties from the %@ class" forKey:@"Superclass_Description"];
  }
  
  sd_path = [aFile retain];
  sd_base = [[aFile stringByDeletingLastPathComponent] retain];
//  sd_manager = [aDico classManager];
  id dictionary = nil;
  if (gnflags.sortOthers || gnflags.sortSuites || gnflags.groupEvents) {
    dictionary = [aDico copy];
  } else {
    dictionary = [aDico retain];
  }
  
  sd_manager = [dictionary classManager];
  
  SKTemplate *root = [[sd_tpl templates] objectForKey:@"Dictionary"];
  BOOL write = [self writeDictionary:dictionary usingTemplate:root];
  
  root = [[sd_tpl templates] objectForKey:@"Toc"];
  if (root) {
    [self writeDictionaryToc:dictionary usingTemplate:root];
  }
  
  root = [[sd_tpl templates] objectForKey:@"Index"];
  if (root) {
    [self writeIndex:dictionary usingTemplate:root];
  }
  
  [dictionary release];
  sd_manager = nil;
  [sd_path release];
  sd_path = nil;
  [sd_base release];
  sd_base = nil;
  [self releaseCache];
  [pool release];
  return write;
}

@end

#pragma mark -
static NSString *SdtplSimplifieName(NSString *name) {
  id data = [name dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  NSMutableString *simple = [[NSMutableString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  [simple replaceOccurrencesOfString:@" " withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [simple length])];  
  return [simple autorelease];
}
