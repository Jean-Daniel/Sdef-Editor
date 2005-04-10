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
   if (value && [tpl containsKey:name]) { \
     id __varStr = [self formatString:value forVariable:name]; \
     [tpl setVariable:__varStr forKey:name]; \
   } \
 }
/* 
#define SetVariable(tpl, name, value) \
{ \
  id __varStr = [self formatString:value forVariable:name]; \
    [tpl setVariable:__varStr forKey:name]; \
}
*/
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

#pragma mark Generators
- (BOOL)writeDictionary:(SdefDictionary *)aDico usingTemplate:(SKTemplate *)tpl;
- (BOOL)writeSuite:(SdefSuite *)suite usingTemplate:(SKTemplate *)tpl;
- (BOOL)writeClass:(SdefClass *)aClass usingTemplate:(SKTemplate *)tpl;
- (BOOL)writeVerb:(SdefVerb *)verb usingTemplate:(SKTemplate *)tpl;
- (void)writeToc:(SdefDictionary *)dictionary usingTemplate:(SKTemplate *)tpl;
- (BOOL)writeIndex:(SdefDictionary *)theDico usingTemplate:(SKTemplate *)tpl;

- (BOOL)writeTemplate:(SKTemplate *)tpl toFile:(NSString *)path representedObject:(SdefObject *)anObject;

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
    NSArray *tocKey = [NSArray arrayWithObject:@"toc"];
    [self setKeys:tocKey triggerChangeNotificationsForDependentKey:@"indexToc"];
    [self setKeys:tocKey triggerChangeNotificationsForDependentKey:@"externalToc"];
    [self setKeys:tocKey triggerChangeNotificationsForDependentKey:@"dictionaryToc"];
    [self setKeys:[NSArray arrayWithObject:@"css"] triggerChangeNotificationsForDependentKey:@"externalCss"];
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
  [sd_tocFile release];
  [sd_cssFile release];
  [self releaseCache];
  [super dealloc];
}

#pragma mark -
#pragma mark KVC Accessors

#pragma mark Toc & CSS
- (unsigned)toc {
  return gnflags.toc;
}
- (void)setToc:(unsigned)toc {
  gnflags.toc = toc;
}
- (BOOL)indexToc {
  return (gnflags.toc & kSdefTemplateTOCIndex) != 0;
}
- (BOOL)externalToc {
  return (gnflags.toc & kSdefTemplateTOCExternal) != 0;
}
- (BOOL)dictionaryToc {
  return (gnflags.toc & kSdefTemplateTOCDictionary) != 0;
}

- (unsigned)css {
  return gnflags.css;
}
- (void)setCss:(unsigned)css {
  gnflags.css = css;
}
- (BOOL)externalCss {
  return (gnflags.css & kSdefTemplateCSSExternal) != 0;
}

- (NSString *)tocFile {
  return sd_tocFile ? : (sd_tpl) ? [@"toc" stringByAppendingPathExtension:[sd_tpl extension]] : @"";
}
- (void)setTocFile:(NSString *)aFile {
  if (sd_tocFile != aFile) {
    [sd_tocFile release];
    sd_tocFile = [aFile retain];
  }
}
- (NSString *)cssFile {
  return sd_cssFile ? sd_cssFile : @"style.css";
}
- (void)setCssFile:(NSString *)aFile {
  if (sd_cssFile != aFile) {
    [sd_cssFile release];
    sd_cssFile = [aFile retain];
  }
}

#pragma mark Others Parameters
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
    [self willChangeValueForKey:@"tocFile"];
    [sd_tpl release];
    sd_tpl = [aTemplate retain];
    [self didChangeValueForKey:@"tocFile"];
    if (sd_tpl) {
      gnflags.format = [sd_tpl isHtml] ? kSdefTemplateXMLFormat : kSdefTemplateDefaultFormat;
      [self willChangeValueForKey:@"toc"];
      /* Set default Toc value */
      if ([sd_tpl requiredToc]) {
        gnflags.toc |= kSdefTemplateTOCExternal;
      } else if (![sd_tpl externalToc]) {
        gnflags.toc &= ~kSdefTemplateTOCExternal;
      }
      if (![sd_tpl dictionaryToc]) {
        gnflags.toc &= ~kSdefTemplateTOCDictionary;
      }
      if (![sd_tpl indexToc]) {
        gnflags.toc &= ~kSdefTemplateTOCIndex;
      }
      [self didChangeValueForKey:@"toc"];
      /* Set default CSS value */
      if (gnflags.format != kSdefTemplateXMLFormat) {
        [self setCss:kSdefTemplateCSSNone];
      } else {
        [self setCss:kSdefTemplateCSSInline];
      }
    }
  }
}

#pragma mark -
#pragma mark API
- (BOOL)writeDictionary:(SdefDictionary *)aDico toFile:(NSString *)aFile {
  id pool = [[NSAutoreleasePool alloc] init];
  SKTimeUnit start, end;
  SKTimeStart(&start);
  [self initCache];
  
  /* Init default formats */
  if (![sd_formats objectForKey:@"Superclass_Description"]) {
    [sd_formats setObject:@"inherits some of its properties from the %@ class" forKey:@"Superclass_Description"];
  }
  if (![sd_formats objectForKey:@"Style_Link"]) {
    [sd_formats setObject:@"<link rel=\"stylesheet\" href=\"%@\" type=\"text/css\">" forKey:@"Style_Link"];
  }
  
  sd_path = [aFile retain];
  sd_base = [[aFile stringByDeletingLastPathComponent] retain];

  SKTimeEnd(&end);
  DLog(@"Init finished :%u ms", SKTimeDeltaMillis(&start, &end));
  
  id dictionary = nil;
  if (gnflags.sortOthers || gnflags.sortSuites || (!gnflags.ignoreEvents && gnflags.groupEvents)) {
    dictionary = [aDico copy];
  } else {
    dictionary = [aDico retain];
  }
  
  sd_manager = [dictionary classManager];
  
  SKTimeEnd(&end);
  DLog(@"Copy finished :%u ms", SKTimeDeltaMillis(&start, &end));
  
  SKTemplate *root = [[sd_tpl templates] objectForKey:SdtplDictionaryDefinitionKey];
  BOOL write = [self writeDictionary:dictionary usingTemplate:root];
  
  SKTimeEnd(&end);
  DLog(@"Main files created :%u ms", SKTimeDeltaMillis(&start, &end));
  
  root = [[sd_tpl templates] objectForKey:SdtplIndexDefinitionKey];
  if (root) {
    [self writeIndex:dictionary usingTemplate:root];
  }
  
  SKTimeEnd(&end);
  DLog(@"Index file created: %u ms", SKTimeDeltaMillis(&start, &end));
  
  /* Create css file if needed */
  if (kSdefTemplateCSSExternal == gnflags.css) {
    NSString *src = [[sd_tpl selectedStyle] objectForKey:@"path"];
    NSString *dest = [sd_base stringByAppendingPathComponent:[self cssFile]];
    if (src && dest) {
      /* can check if exist */
      [[NSFileManager defaultManager] copyPath:src toPath:dest handler:nil];
    }
  }
  
  SKTimeEnd(&end);
  DLog(@"CSS File created: %u ms", SKTimeDeltaMillis(&start, &end));

  /* TOC must be in last position because it may change sd_link and flush cache. */
  if ([self externalToc]) {
    root = [[sd_tpl templates] objectForKey:SdtplTocDefinitionKey];
    if (root) {
      NSString *link = [sd_formats objectForKey:@"Toc_Links"];
      if (link && ![link isEqualToString:sd_link]) {
        sd_link = link;
        CFDictionaryRemoveAllValues(sd_links);
      }
      [self writeToc:dictionary usingTemplate:root];
      NSString *file = [self tocFile];
      [self writeTemplate:root toFile:file representedObject:dictionary];
    }
  }
  
  SKTimeEnd(&end);
  DLog(@"Toc file created: %u ms", SKTimeDeltaMillis(&start, &end));
  
  /* Release resources */
  [dictionary release];
  sd_manager = nil;
  [sd_path release];
  sd_path = nil;
  [sd_base release];
  sd_base = nil;
  [self releaseCache];
  
  SKTimeEnd(&end);
  DLog(@"Template Over :%u ms", SKTimeDeltaMillis(&start, &end));
  
  [pool release];
  return write;
}

#pragma mark -
#pragma mark Cache management
- (void)initCache {
  if (sd_tpl) {
    sd_formats = [[sd_tpl formats] mutableCopy];
    sd_link = [sd_formats objectForKey:@"Links"];
    if (!sd_link) {
      sd_link = @"<a href=\"%@#%@\">%@</a>";
      [sd_formats setObject:sd_link forKey:@"Links"];
    }
    /* Use retain instead of copy for key (faster) */
    sd_links = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kSKDictionaryKeyCallBacks, &kSKDictionaryValueCallBacks);
    sd_files = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kSKDictionaryKeyCallBacks, &kSKDictionaryValueCallBacks);
    sd_anchors = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kSKDictionaryKeyCallBacks, &kSKDictionaryValueCallBacks);
    
    id defs = [sd_tpl definition];
    
    /* Index */
    gnflags.index = (nil != [defs objectForKey:SdtplIndexDefinitionKey]) ? 1 : 0;
    /* Suite */
    id def = [defs objectForKey:SdtplSuitesDefinitionKey];
    if (def) {
      gnflags.suites = [[def objectForKey:@"SingleFile"] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    } 
    /* Class */
    def = [defs objectForKey:SdtplClassesDefinitionKey];
    if (def) {
      gnflags.classes = [[def objectForKey:@"SingleFile"] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    }
    /* Events */
    def = [defs objectForKey:SdtplEventsDefinitionKey];
    if (def) {
      gnflags.events = [[def objectForKey:@"SingleFile"] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    }
    /* Commands */
    def = [defs objectForKey:SdtplCommandsDefinitionKey];
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
- (NSString *)formatString:(NSString *)str forVariable:(NSString *)variable {
  id format = [sd_formats objectForKey:variable];
  if (format) {
    return ([format rangeOfString:@"%@"].location != NSNotFound) ? [NSString stringWithFormat:format, str] : format;
  }
  return str;
}

#pragma mark -
#pragma mark References Generator
#pragma mark Files
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

#pragma mark Anchors
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
      case kSdefDictionaryType:
        anchor = [NSString stringWithFormat:@"%@", SdtplSimplifieName([anObject name])];
        break;
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

#pragma mark Links
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
    NSString *file = [self fileForObject:anObject];
    link = [NSString stringWithFormat:sd_link, (file) ? : @"", [self anchorNameForObject:anObject], aString];
  }
  return link;
}

- (NSString *)linkForDictionary:(SdefDictionary *)dictionary withString:(NSString *)aString {
  id link = (id)CFDictionaryGetValue(sd_links, dictionary);
  if (!link) {
    link = [self linkForObject:dictionary withString:aString];
    //DLog(@"Cache Dictionary: %@ => %@", dictionary, link);
    CFDictionarySetValue(sd_links, dictionary, link);
  }
  return link;
}

#pragma mark -
#pragma mark Template Generators
#pragma mark Common
- (void)writeReferences:(SdefObject *)anObject usingTemplate:(SKTemplate *)tpl {
  
  /* Set Style */
  if (kSdefTemplateXMLFormat == gnflags.format) {
    if ((gnflags.css != kSdefTemplateCSSNone) && [sd_tpl selectedStyle]) {
      if (kSdefTemplateCSSInline == gnflags.css && [tpl blockWithName:@"Style_Inline"]) {
        id block = [tpl blockWithName:@"Style_Inline"];
        if ([block containsKey:@"Style_Sheet"]) {
          NSString *style = [[NSString alloc] initWithContentsOfFile:[[sd_tpl selectedStyle] objectForKey:@"path"]];
          [block setVariable:style forKey:@"Style_Sheet"];
          [style release];
          [block dumpBlock];
        }
      } else if (kSdefTemplateCSSExternal == gnflags.css) {
        SetVariable(tpl, @"Style_Link", [self cssFile]);
      }
    }
  }

  /* Set References */
  if (gnflags.index) {
    [tpl setVariable:[sd_path lastPathComponent] forKey:@"Index_File"];
  }
  if ([self externalToc]) {
    /* Toc path */
    [tpl setVariable:[self tocFile] forKey:@"Toc_File"];
  }
  /* Dictionary Links */
  id obj = nil;
  if (obj = [anObject dictionary]) {
    SetVariable(tpl, @"Dictionary_Name", [obj name]);
    [tpl setVariable:[self fileForObject:obj] forKey:@"Dictionary_File"];
    if ([tpl containsKey:@"Dictionary_Link"])
      [tpl setVariable:[self linkForDictionary:obj withString:[obj name]] forKey:@"Dictionary_Link"];
  }
  /* Suite Links */
  if (obj = [anObject suite]) {
    SetVariable(tpl, @"Suite_Name", [obj name]);
    [tpl setVariable:[self fileForObject:obj] forKey:@"Suite_File"];
    if ([tpl containsKey:@"Suite_Link"])
      [tpl setVariable:[self linkForObject:obj withString:[obj name]] forKey:@"Suite_Link"];
  }
}

- (BOOL)writeTemplate:(SKTemplate *)tpl toFile:(NSString *)path representedObject:(SdefObject *)anObject {
  if (anObject) {
    [self writeReferences:anObject usingTemplate:tpl];
  }
  if (![path isAbsolutePath]) {
    path = [sd_base stringByAppendingPathComponent:path];
  }
  if ([path isEqualToString:sd_path]) {
    [[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
  }
  BOOL isDir;
  if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
    DLog(@"File exists: %@", path);
    //    NSAlert *alert = [NSAlert alertWithMessageText:@"File already exist"
    //                                     defaultButton:@"Replace"
    //                                   alternateButton:@"Continue"
    //                                       otherButton:@"Stop"
    //                         informativeTextWithFormat:@"Would you like replace it, continue or cancel exportation?"];
    //
    //    int result = [alert runModal];
    //    switch (result) {
    //      case NSAlertAlternateReturn:
    //        return;
    //      case NSAlertOtherReturn:
    //        [NSException raise:@"SdefUserCancelException" format:@"Replace TOC file"];
    //        return;
    //    }
  }
  return [tpl writeToFile:path atomically:YES andReset:YES];
}

#pragma mark Dictionary
- (BOOL)writeDictionary:(SdefDictionary *)aDico usingTemplate:(SKTemplate *)tpl {
  /* Generate Template */
  SetVariable(tpl, @"Dictionary_Name", [aDico name]);
  if (gnflags.links)
    SetVariable(tpl, @"Dictionary_Anchor", [self anchorForObject:aDico]);
  
  if (gnflags.sortSuites) 
    [aDico sortByName];
  
  if ([aDico hasChildren]) {
    SdefSuite *suite;
    NSEnumerator *suites = [aDico childEnumerator];
    
    SKTemplate *suiteTpl = nil;
    SKTemplate *suiteBlock = [tpl blockWithName:@"Suite"];
    if (kSdtplInline == gnflags.suites) {
      suiteTpl = suiteBlock;
    } else {
      suiteTpl = [[sd_tpl templates] objectForKey:SdtplSuitesDefinitionKey];
      if (kSdtplSingleFile == gnflags.suites) {
        suiteTpl = [suiteTpl blockWithName:@"Suite"];
      }
    }
    
    while (suite = [suites nextObject]) {
      if (kSdtplInline != gnflags.suites) {
        NSString *name = [suite name];
        if (name && gnflags.links) 
          name = [self linkForObject:suite withString:name];
        [suiteBlock setVariable:name forKey:@"Suite_Name"];
        if ([suite desc])
          SetVariable(suiteBlock, @"Suite_Description", [suite desc]);
      }
      if (suiteTpl)
        [self writeSuite:suite usingTemplate:suiteTpl];
      [suiteBlock dumpBlock];
    }
    switch (gnflags.suites) {
      case kSdtplSingleFile:
        [self writeTemplate:[[sd_tpl templates] objectForKey:SdtplSuitesDefinitionKey]
                     toFile:[self fileForObject:[aDico firstChild]]
          representedObject:aDico];
        break;
    }
  }
  
  if ([self dictionaryToc]) {
    SKTemplate *toc = [tpl blockWithName:@"Table_Of_Content"];
    if (toc) {
      [self writeToc:aDico usingTemplate:toc];
    }
    [toc dumpBlock];
  }
  
  NSString *file = nil;
  if (gnflags.index) {
    file = [self fileForObject:aDico];
  } else {
    file = sd_path;
  }
  return [self writeTemplate:tpl toFile:file representedObject:aDico];
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
      classTpl = [[sd_tpl templates] objectForKey:SdtplClassesDefinitionKey];
      if (kSdtplSingleFile == gnflags.classes) {
        classTpl = [classTpl blockWithName:@"Class"];
      }
    }
    
    while (class = [classes nextObject]) {
      if (kSdtplInline != gnflags.classes) {
        NSString *name = [class name];
        if (name && gnflags.links)
          name = [self linkForObject:class withString:name];
        [classBlock setVariable:name forKey:@"Class_Name"];
        if ([class desc])
          SetVariable(classBlock, @"Class_Description", [class desc]);
      }
      if (classTpl)
        [self writeClass:class usingTemplate:classTpl];
      [classBlock dumpBlock];
    }
    [[tpl blockWithName:@"Classes"] dumpBlock];
    switch (gnflags.classes) {
      case kSdtplSingleFile:
        [self writeTemplate:[[sd_tpl templates] objectForKey:SdtplClassesDefinitionKey]
                     toFile:[self fileForObject:[[suite classes] firstChild]]
          representedObject:suite];
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
      cmdTpl = [[sd_tpl templates] objectForKey:SdtplCommandsDefinitionKey];
      if (kSdtplSingleFile == gnflags.commands) {
        cmdTpl = [cmdTpl blockWithName:@"Command"];
      }
    }
    
    while (cmd = [cmds nextObject]) {
      if (kSdtplInline != gnflags.commands) {
        NSString *name = [cmd name];
        if (name && gnflags.links)
          name = [self linkForObject:cmd withString:name];
        [cmdBlock setVariable:name forKey:@"Command_Name"];
        if ([cmd desc])
          SetVariable(cmdBlock, @"Command_Description", [cmd desc]);
      }
      if (cmdTpl)
        [self writeVerb:cmd usingTemplate:cmdTpl];
      [cmdBlock dumpBlock];
    }
    [[tpl blockWithName:@"Commands"] dumpBlock];
    switch (gnflags.commands) {
      case kSdtplSingleFile:
        [self writeTemplate:[[sd_tpl templates] objectForKey:SdtplCommandsDefinitionKey]
                     toFile:[self fileForObject:[[suite commands] firstChild]]
          representedObject:suite];
        break;
    }
  }
  
  /* Events */
  if (!gnflags.ignoreEvents && [[suite events] hasChildren]) {
    id evnt;
    id evnts = [[suite events] childEnumerator];
    
    SKTemplate *evntTpl = nil;
    SKTemplate *evntBlock = [tpl blockWithName:@"Event"];
    if (kSdtplInline == gnflags.events) {
      evntTpl = evntBlock;
    } else {
      evntTpl = [[sd_tpl templates] objectForKey:SdtplEventsDefinitionKey];
      if (kSdtplSingleFile == gnflags.events) {
        evntTpl = [evntTpl blockWithName:@"Event"];
      }
    }
    
    while (evnt = [evnts nextObject]) {
      if (kSdtplInline != gnflags.events) {
        NSString *name = [evnt name];
        if (name && gnflags.links)
          name = [self linkForObject:evnt withString:name];
        [evntBlock setVariable:name forKey:@"Event_Name"];
        if ([evnt desc])
          SetVariable(evntBlock, @"Event_Description", [evnt desc]);
      }
      if (evntTpl)
        [self writeVerb:evnt usingTemplate:evntTpl];
      [evntBlock dumpBlock];
    }
    [[tpl blockWithName:@"Events"] dumpBlock];
    switch (gnflags.events) {
      case kSdtplSingleFile:
        [self writeTemplate:[[sd_tpl templates] objectForKey:SdtplEventsDefinitionKey]
                     toFile:[self fileForObject:[[suite events] firstChild]]
          representedObject:suite];
        break;
    }
  }
  
  BOOL ok = YES;
  switch (gnflags.suites) {
    case kSdtplSingleFile:
      [tpl dumpBlock];
      break;
    case kSdtplMultiFiles:
      ok = [self writeTemplate:tpl toFile:[self fileForObject:suite] representedObject:suite];
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
  if ([[aClass elements] hasChildren] && nil != [tpl blockWithName:@"Element"]) {
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
    if (propBlock != nil) {
      id properties = [[aClass properties] childEnumerator];
      id property;
      while (property = [properties nextObject]) {
        [self writeProperty:property usingTemplate:propBlock];
        [propBlock dumpBlock];
      }
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
  switch (gnflags.classes) {
    case kSdtplSingleFile:
      [tpl dumpBlock];
      break;
    case kSdtplMultiFiles:
      ok = [self writeTemplate:tpl toFile:[self fileForObject:aClass] representedObject:aClass];
      break;
  }
  return ok;
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
  int flag = [verb isCommand] ? gnflags.commands : gnflags.events;
  switch (flag) {
    case kSdtplSingleFile:
      [tpl dumpBlock];
      break;
    case kSdtplMultiFiles:
      ok = [self writeTemplate:tpl toFile:[self fileForObject:verb] representedObject:verb];
      break;
  }
  return ok;
}

#pragma mark Toc
- (void)writeToc:(SdefDictionary *)dictionary usingTemplate:(SKTemplate *)tpl {
  SetVariable(tpl, @"Toc_Dictionary_Name", [dictionary name]);
  /* Suites */
  SKTemplate *stpl = [tpl blockWithName:@"Toc_Suite"];
  SdefSuite *suite;
  NSEnumerator *suites = [dictionary childEnumerator];
  while (suite = [suites nextObject]) {
    NSString *name = [suite name];
    if (name) {
      if (gnflags.links)
        name = [self linkForObject:suite withString:name];
      SetVariable(stpl, @"Toc_Suite_Name", name);
    }
    /* Classes */
    if ([[suite classes] hasChildren] && [stpl blockWithName:@"Toc_Class"]) {
      SKTemplate *ctpl = [stpl blockWithName:@"Toc_Class"];
      id classes = [[suite classes] childEnumerator];
      SdefClass *class;
      while (class = [classes nextObject]) {
        NSString *name = [class name];
        if (name) {
          if (gnflags.links)
            name = [self linkForType:name withString:name];
          SetVariable(ctpl, @"Toc_Class_Name", name);
        }
        [ctpl dumpBlock];
      }
      [[stpl blockWithName:@"Toc_Classes"] dumpBlock];
    }
    
    /* Commands */
    if ([[suite commands] hasChildren] && [stpl blockWithName:@"Toc_Command"]) {
      SKTemplate *vtpl = [stpl blockWithName:@"Toc_Command"];
      SdefVerb *command;
      NSEnumerator *commands = [[suite commands] childEnumerator];
      while (command = [commands nextObject]) {
        NSString *name = [command name];
        if (name) {
          if (gnflags.links)
            name = [self linkForObject:command withString:name];
          SetVariable(vtpl, @"Toc_Command_Name", name);
        }
        [vtpl dumpBlock];
      }
      [[stpl blockWithName:@"Toc_Commands"] dumpBlock];
    }
    if (!gnflags.ignoreEvents && [[suite events] hasChildren] && [stpl blockWithName:@"Toc_Event"]) {
      SKTemplate *etpl = [stpl blockWithName:@"Toc_Event"];
      SdefVerb *event;
      NSEnumerator *events = [[suite events] childEnumerator];
      while (event = [events nextObject]) {
        NSString *name = [event name];
        if (name) {
          if (gnflags.links)
            name = [self linkForObject:event withString:name];
          SetVariable(etpl, @"Toc_Command_Name", name);
        }
        [etpl dumpBlock];
      }
      /* require to generate classes block */
      [[stpl blockWithName:@"Toc_Events"] dumpBlock];
    }
    [stpl dumpBlock];
  }
}

#pragma mark Index
- (BOOL)writeIndex:(SdefDictionary *)theDico usingTemplate:(SKTemplate *)tpl {
  if ([self indexToc]) {
    SKTemplate *toc = [tpl blockWithName:@"Table_Of_Content"];
    if (toc) {
      [self writeToc:theDico usingTemplate:toc];
    }
    [toc dumpBlock];
  }
  
  return [self writeTemplate:tpl toFile:sd_path representedObject:theDico];
}

@end

#pragma mark -
static NSString *SdtplSimplifieName(NSString *name) {
  id data = [name dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  NSMutableString *simple = [[NSMutableString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  [simple replaceOccurrencesOfString:@" " withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [simple length])];  
  return [simple autorelease];
}
