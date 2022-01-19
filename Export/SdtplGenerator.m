/*
 *  SdtplGenerator.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdtplGenerator.h"

#import <WonderBox/WBTemplate.h>
#import <WonderBox/NSAlert+WonderBox.h>
#import <WonderBox/NSString+WonderBox.h>

#import "SdefTemplate.h"

#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefSuite.h"
#import "SdefDocument.h"
#import "SdefArguments.h"
#import "SdefDictionary.h"
#import "SdefClassManager.h"
#import "ASDictionaryObject.h"

enum {
  kSdefTemplateFileAsk		= 0,
  kSdefTemplateFileSkip		= 1,
  kSdefTemplateFileReplace	= 2,
};

@interface NSObject (SilentWarning_)
- (void)writeAccessorsStringToStream:(id)stream;
@end

static NSString *SdtplSimplifieName(NSString *name);
static void SdtplSortArrayByName(NSMutableArray *array);
static NSUInteger SdtplDumpSimpleBlock(SdtplGenerator *self, NSEnumerator *enume, WBTemplate *tpl, SEL description);
static NSString *SdtplCopyFormatedString(SdtplGenerator *self, NSString *str, NSString *aVariable, NSString *aBlock);

#pragma mark Variables
/* Defaults */
static NSString * const SdtplVariableDefaultReadOnly = @"[r/o]"; 
static NSString * const SdtplVariableDefaultTypeList = @"a list of";

/* Commons */
static NSString * const SdtplVariableName = @"Name";
static NSString * const SdtplVariableAnchor = @"Anchor";
static NSString * const SdtplVariableDescription = @"Description";
/* Types */
static NSString * const SdtplVariableType = @"Type";
static NSString * const SdtplVariableTypeList = @"Type-List";
/* Properties */
static NSString * const SdtplVariableReadOnly = @"Read-Only";
/* Elements */
static NSString * const SdtplVariableAccessors = @"Accessors";
/* Styles */
static NSString * const SdtplVariableStyleLink = @"Style-Link";
static NSString * const SdtplVariableStyleFile = @"Style-File";
static NSString * const SdtplVariableStyleSheet = @"Style-Sheet";
/* Files */
static NSString * const SdtplVariableTocFile = @"Toc-File";
static NSString * const SdtplVariableIndexFile = @"Index-File";
static NSString * const SdtplVariableSuiteFile = @"Suite-File";
static NSString * const SdtplVariableDictionaryFile = @"Dictionary-File";
/* Anchor */
static NSString * const SdtplVariableSuiteAnchor = @"Suite-Anchor";
static NSString * const SdtplVariableDictionaryAnchor = @"Dictionary-Anchor";
/* Content Links */
static NSString * const SdtplVariableSuiteLink = @"Suite-Link";
static NSString * const SdtplVariableDictionaryLink = @"Dictionary-Link";
/* Content Names */
static NSString * const SdtplVariableSuiteName = @"Suite-Name";
static NSString * const SdtplVariableDictionaryName = @"Dictionary-Name";

#pragma mark Blocks
static NSString * const SdtplBlockStyle = @"Style";

static NSString * const SdtplBlockSuite = @"Suite";

/* Classes */
static NSString * const SdtplBlockClass = @"Class";
static NSString * const SdtplBlockClasses = @"Classes";
/* Superclass & plural */
static NSString * const SdtplBlockPlural = @"Plural";
static NSString * const SdtplBlockSuperclass = @"Superclass";
/* Subclasses */
static NSString * const SdtplBlockSubclass = @"Subclass";
static NSString * const SdtplBlockSubclasses = @"Subclasses";
/* Elements */
static NSString * const SdtplBlockElement = @"Element";
static NSString * const SdtplBlockElements = @"Elements";
/* Property */
static NSString * const SdtplBlockProperty = @"Property";
static NSString * const SdtplBlockProperties = @"Properties";
/* Responds-to- */
static NSString * const SdtplBlockRespondsToCommand = @"Responds-To-Command";
static NSString * const SdtplBlockRespondsToCommands = @"Responds-To-Commands";
static NSString * const SdtplBlockRespondsToEvent = @"Responds-To-Event";
static NSString * const SdtplBlockRespondsToEvents = @"Responds-To-Events";

/* Verbs */
static NSString * const SdtplBlockCommand = @"Command";
static NSString * const SdtplBlockCommands = @"Commands";
static NSString * const SdtplBlockEvent = @"Event";
static NSString * const SdtplBlockEvents = @"Events";
/* Parameters & Result */
static NSString * const SdtplBlockResult = @"Result";
static NSString * const SdtplBlockParameters = @"Parameters";
static NSString * const SdtplBlockDirectParameter = @"Direct-Parameter";
static NSString * const SdtplBlockRequiredParameter = @"Required-Parameter";
static NSString * const SdtplBlockOptionalParameter = @"Optional-Parameter";

/* Toc (extern) */
NSString * const SdtplBlockTableOfContent = @"Toc";

#pragma mark -
@interface SdtplGenerator (Private)
#pragma mark References Generator
- (NSString *)fileForObject:(SdefObject *)anObject;

- (NSString *)anchorForObject:(SdefObject *)obj;
- (NSString *)anchorNameForObject:(SdefObject *)anObject;

- (NSString *)linkForType:(NSString *)aType withString:(NSString *)aString;
- (NSString *)linkForVerb:(NSString *)aVerb withString:(NSString *)aString;
- (NSString *)linkForObject:(SdefObject *)anObject withString:(NSString *)aString;

#pragma mark Misc
- (void)initCache;
- (void)releaseCache;

- (NSString *)formatString:(NSString *)str forVariable:(NSString *)variable inBlock:(NSString *)block;
#pragma mark Generators
- (BOOL)writeDictionary:(SdefDictionary *)aDico usingTemplate:(WBTemplate *)tpl;
- (BOOL)writeSuite:(SdefSuite *)suite usingTemplate:(WBTemplate *)tpl;
- (BOOL)writeClass:(SdefClass *)aClass usingTemplate:(WBTemplate *)tpl;
- (BOOL)writeVerb:(SdefVerb *)verb usingTemplate:(WBTemplate *)tpl;
- (void)writeToc:(SdefDictionary *)dictionary usingTemplate:(WBTemplate *)tpl;
- (BOOL)writeIndex:(SdefDictionary *)theDico usingTemplate:(WBTemplate *)tpl;

- (BOOL)canWriteFileAtPath:(NSString *)path;
- (BOOL)writeTemplate:(WBTemplate *)tpl toFile:(NSString *)path representedObject:(SdefObject *)anObject;

@end

#pragma mark -
/* Must use a macro else "value" is eval before test to know if needed */
#define SdtplSetVariable(tpl, block, name, value)  ({ \
  NSString *__value; \
  if ([tpl containsKey:name] && (__value = value)) { \
    NSString *__varStr = SdtplCopyFormatedString(self, __value, name, block); \
    [tpl setVariable:__varStr forKey:name]; \
  } \
}) 

WB_INLINE
BOOL SdtplShouldCreateLinks(struct _sd_gnFlags flags) {
  return (kSdefTemplateXMLFormat == flags.format && flags.links != 0);
}

WB_INLINE
NSString *SdefEscapedString(NSString *value, NSUInteger format) {
  return ((kSdefTemplateXMLFormat == format) ? [value stringByEscapingEntities:nil] : value);
}

#pragma mark -
@implementation SdtplGenerator

+ (void)initialize {
  if ([SdtplGenerator class] == self) {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
      @(NO), @"SdtplSortSuite",
      @(YES), @"SdtplHTMLLinks",
      @(YES), @"SdtplSortOthers",
      @(NO), @"SdtplSubclasses",
      @(YES), @"SdtplGroupEvents",
      @(NO), @"SdtplIgnoreEvents",
      @(YES), @"SdtplIgnoreRespondsTo",
      @(kSdefTemplateCSSInline), @"SdtplCSSStyle",
      nil]];
  }
}

- (void)loadPreferences {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [self setToc:[defaults integerForKey:@"SdtplTocStyle"]];
  [self setCss:[defaults integerForKey:@"SdtplCSSStyle"]];
  [self setLinks:[defaults boolForKey:@"SdtplHTMLLinks"]];
  [self setTocFile:[defaults objectForKey:@"SdtplTocFile"]];
  [self setCssFile:[defaults objectForKey:@"SdtplCSSFile"]];
  [self setSortSuites:[defaults boolForKey:@"SdtplSortSuite"]];
  [self setSortOthers:[defaults boolForKey:@"SdtplSortOthers"]];
  [self setSubclasses:[defaults boolForKey:@"SdtplSubclasses"]];
  [self setIgnoreEvents:[defaults boolForKey:@"SdtplIgnoreEvents"]];
  [self setIgnoreRespondsTo:[defaults boolForKey:@"SdtplIgnoreRespondsTo"]];
  [self setGroupEventsAndCommands:[defaults boolForKey:@"SdtplGroupEvents"]];
}

- (void)savePreferences {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if (sd_tocFile)
    [defaults setObject:sd_tocFile forKey:@"SdtplTocFile"];
  [defaults setInteger:[self toc] forKey:@"SdtplTocStyle"];
  if (sd_cssFile)
    [defaults setObject:sd_cssFile forKey:@"SdtplCSSFile"];
  [defaults setInteger:[self css] forKey:@"SdtplCSSStyle"];
  
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
  [self savePreferences];;
  [self releaseCache];
}

#pragma mark -
#pragma mark KVC Accessors

#pragma mark Toc & CSS
- (NSUInteger)toc {
  return sd_gnFlags.toc;
}
- (void)setToc:(NSUInteger)toc {
  sd_gnFlags.toc = toc;
}
+ (NSSet *)keyPathsForValuesAffectingIndexToc {
  return [NSSet setWithObject:@"toc"];
}
- (BOOL)indexToc {
  return (sd_gnFlags.toc & kSdefTemplateTOCIndex) != 0;
}
- (void)setIndexToc:(BOOL)flag {
  sd_gnFlags.toc = (flag) ? sd_gnFlags.toc | kSdefTemplateTOCIndex : sd_gnFlags.toc & ~kSdefTemplateTOCIndex;
}
+ (NSSet *)keyPathsForValuesAffectingExternalToc {
  return [NSSet setWithObject:@"toc"];
}
- (BOOL)externalToc {
  return (sd_gnFlags.toc & kSdefTemplateTOCExternal) != 0;
}
- (void)setExternalToc:(BOOL)flag {
  sd_gnFlags.toc = (flag) ? sd_gnFlags.toc | kSdefTemplateTOCExternal : sd_gnFlags.toc & ~kSdefTemplateTOCExternal;
}
+ (NSSet *)keyPathsForValuesAffectingDictionaryToc {
  return [NSSet setWithObject:@"toc"];
}
- (BOOL)dictionaryToc {
  return (sd_gnFlags.toc & kSdefTemplateTOCDictionary) != 0;
}
- (void)setDictionaryToc:(BOOL)flag {
  sd_gnFlags.toc = (flag) ? sd_gnFlags.toc | kSdefTemplateTOCDictionary : sd_gnFlags.toc & ~kSdefTemplateTOCDictionary;
}

- (NSUInteger)css {
  return sd_gnFlags.css;
}
- (void)setCss:(NSUInteger)css {
  sd_gnFlags.css = css;
}
+ (NSSet *)keyPathsForValuesAffectingExternalCss {
  return [NSSet setWithObject:@"css"];
}
- (BOOL)externalCss {
  return (sd_gnFlags.css & kSdefTemplateCSSExternal) != 0;
}

- (NSString *)tocFile {
  return sd_tocFile ? : (sd_tpl) ? [@"toc" stringByAppendingPathExtension:[sd_tpl extension]] : @"";
}
- (void)setTocFile:(NSString *)aFile {
  if (sd_tocFile != aFile) {
    sd_tocFile = aFile;
  }
}
- (NSString *)cssFile {
  return sd_cssFile ? sd_cssFile : @"style.css";
}
- (void)setCssFile:(NSString *)aFile {
  if (sd_cssFile != aFile) {
    sd_cssFile = aFile;
  }
}

#pragma mark Others Parameters
- (BOOL)sortSuites {
  return sd_gnFlags.sortSuites;
}

- (void)setSortSuites:(BOOL)sort {
  sd_gnFlags.sortSuites = sort ? 1 : 0;
}


- (BOOL)sortOthers {
  return sd_gnFlags.sortOthers;
}

- (void)setSortOthers:(BOOL)sort {
  sd_gnFlags.sortOthers = sort ? 1 : 0;
}

- (BOOL)subclasses {
  return sd_gnFlags.subclasses;
}

- (void)setSubclasses:(BOOL)flag {
  sd_gnFlags.subclasses = flag ? 1 : 0;
}

- (BOOL)ignoreEvents {
  return sd_gnFlags.ignoreEvents;
}

- (void)setIgnoreEvents:(BOOL)flag {
  sd_gnFlags.ignoreEvents = flag ? 1 : 0;
}

- (BOOL)groupEventsAndCommands {
  return sd_gnFlags.groupEvents;
}

- (void)setGroupEventsAndCommands:(BOOL)flag {
  sd_gnFlags.groupEvents = flag ? 1 : 0;
}

- (BOOL)ignoreRespondsTo {
  return sd_gnFlags.ignoreRespondsTo;
}

- (void)setIgnoreRespondsTo:(BOOL)flag {
  sd_gnFlags.ignoreRespondsTo = flag ? 1 : 0;
}

- (BOOL)links {
  return sd_gnFlags.links;
}

- (void)setLinks:(BOOL)links {
  sd_gnFlags.links = links ? 1 : 0;
}

- (SdefTemplate *)template {
  return sd_tpl;
}

- (void)setTemplate:(SdefTemplate *)aTemplate {
  if (aTemplate != sd_tpl) {
    [self willChangeValueForKey:@"tocFile"];
    sd_tpl = aTemplate;
    [self didChangeValueForKey:@"tocFile"];
    if (sd_tpl) {
      sd_gnFlags.format = [sd_tpl isHtml] ? kSdefTemplateXMLFormat : kSdefTemplateDefaultFormat;
      [self willChangeValueForKey:@"toc"];
      /* Set default Toc value */
      if ([sd_tpl requiredToc]) {
        sd_gnFlags.toc |= kSdefTemplateTOCExternal;
      } else if (![sd_tpl externalToc]) {
        sd_gnFlags.toc &= ~kSdefTemplateTOCExternal;
      }
      if (![sd_tpl dictionaryToc]) {
        sd_gnFlags.toc &= ~kSdefTemplateTOCDictionary;
      }
      if (![sd_tpl indexToc]) {
        sd_gnFlags.toc &= ~kSdefTemplateTOCIndex;
      }
      [self didChangeValueForKey:@"toc"];
    }
  }
}

#pragma mark -
#pragma mark API
- (BOOL)writeDictionary:(SdefDictionary *)aDico toFile:(NSString *)aFile {
  @autoreleasepool {
    [self initCache];

    sd_path = aFile;
    sd_base = [aFile stringByDeletingLastPathComponent];

    sd_link = sd_formats[@"Links"];

    SdefDictionary *dictionary = aDico;
    sd_manager = [dictionary classManager];

    BOOL bwrite = NO;
    WBTemplate *root = [[sd_tpl templates] objectForKey:SdtplDefinitionDictionaryKey];
    @try {
      bwrite = [self writeDictionary:dictionary usingTemplate:root];
    } @catch (id exception) {
      bwrite = NO;
      spx_log_exception(exception);
    }

    if (bwrite) {
      if (!sd_gnFlags.cancel) {
        root = [[sd_tpl templates] objectForKey:SdtplDefinitionIndexKey];
        if (root) {
          @try {
            [self writeIndex:dictionary usingTemplate:root];
          } @catch (id exception) {
            spx_log_exception(exception);
          }
        }
      }

      if (!sd_gnFlags.cancel) {
        /* Create css file if needed */
        if (kSdefTemplateXMLFormat == sd_gnFlags.format && kSdefTemplateCSSExternal == sd_gnFlags.css) {
          NSString *src = [[sd_tpl selectedStyle] objectForKey:@"path"];
          NSString *dest = [sd_base stringByAppendingPathComponent:[self cssFile]];
          if (src && dest) {
            if ([self canWriteFileAtPath:dest]) {
              [[NSFileManager defaultManager] removeItemAtPath:dest error:NULL];
              [[NSFileManager defaultManager] copyItemAtPath:src toPath:dest error:NULL];
            }
          }
        }
      }

      if (!sd_gnFlags.cancel) {
        /* TOC must be in last position because it may change sd_link and flush cache. */
        if ([self externalToc]) {
          root = [[sd_tpl templates] objectForKey:SdtplDefinitionTocKey];
          if (root) {
            NSString *alink = sd_formats[@"Toc-Links"];
            if (alink && ![alink isEqualToString:sd_link]) {
              sd_link = alink;
              NSResetMapTable(sd_links);
            }
            @try {
              [self writeToc:dictionary usingTemplate:root];
              NSString *file = [self tocFile];
              [self writeTemplate:root toFile:file representedObject:dictionary];
            } @catch (id exception) {
              spx_log_exception(exception);
            }
          }
        }
      }
    }

    /* Delete generated files */
    if (sd_gnFlags.cancel) {
      NSString *file;
      NSFileManager *manager = [NSFileManager defaultManager];
      NSEnumerator *files = [sd_cancel objectEnumerator];
      while (file = [files nextObject]) {
        [manager removeItemAtPath:file error:NULL];
      }
    }

    /* Release resources */
    sd_manager = nil;
    sd_path = nil;
    sd_base = nil;
    sd_link = nil;
    [self releaseCache];

    return bwrite;
  }
}

#pragma mark -
#pragma mark Cache management
- (void)_sdtplAddFormatString:(NSString *)format inBlock:(NSString *)blockName forVariable:(NSString *)variable {
  if ([blockName isEqualToString:@"Parameter"]) {
    [self _sdtplAddFormatString:format inBlock:SdtplBlockOptionalParameter forVariable:variable];
    [self _sdtplAddFormatString:format inBlock:SdtplBlockRequiredParameter forVariable:variable];
  } else {
    NSMutableDictionary *block = sd_formats[blockName];
    if (!block) {
      block = [[NSMutableDictionary alloc] init];
      sd_formats[blockName] = block;
    }
    [block setValue:format forKey:variable];
  }
}

- (void)initCache {
  if (sd_tpl) {
    sd_formats = [[NSMutableDictionary alloc] init];
    NSDictionary *formats = [sd_tpl formats];
    NSString *key;
    sd_gnFlags.useBlockFormat = 0;
    NSEnumerator *keys = [formats keyEnumerator];
    while (key = [keys nextObject]) {
      NSUInteger separator = [key rangeOfString:@"."].location;
      if (NSNotFound == separator) {
        sd_formats[key] = [formats objectForKey:key];
      } else {
        sd_gnFlags.useBlockFormat = 1;
        [self _sdtplAddFormatString:[formats objectForKey:key]
                            inBlock:[key substringToIndex:separator]
                        forVariable:[key substringFromIndex:separator + 1]];
      }
    }
    
    /* Use retain instead of copy for key (faster) */
    sd_links = [NSMapTable strongToStrongObjectsMapTable];
    sd_files = [NSMapTable strongToStrongObjectsMapTable];
    sd_anchors = [NSMapTable strongToStrongObjectsMapTable];
    
    sd_cancel = [[NSMutableSet alloc] init];
      
    NSDictionary *defs = [sd_tpl definition];
    
    /* Index */
    sd_gnFlags.index = (nil != [defs objectForKey:SdtplDefinitionIndexKey]) ? 1 : 0;
    /* Suite */
    NSDictionary *def = [defs objectForKey:SdtplDefinitionSuitesKey];
    if (def) {
      sd_gnFlags.suites = [[def objectForKey:SdtplDefinitionSingleFileKey] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    } 
    /* Class */
    def = [defs objectForKey:SdtplDefinitionClassesKey];
    if (def) {
      sd_gnFlags.classes = [[def objectForKey:SdtplDefinitionSingleFileKey] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    }
    /* Events */
    def = [defs objectForKey:SdtplDefinitionEventsKey];
    if (def) {
      sd_gnFlags.events = [[def objectForKey:SdtplDefinitionSingleFileKey] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    }
    /* Commands */
    def = [defs objectForKey:SdtplDefinitionCommandsKey];
    if (def) {
      sd_gnFlags.commands = [[def objectForKey:SdtplDefinitionSingleFileKey] boolValue] ? kSdtplSingleFile : kSdtplMultiFiles;
    }
    /* Other reset */
    sd_gnFlags.cancel = 0;
    sd_gnFlags.existingFile = kSdefTemplateFileAsk;
  }
}

- (void)releaseCache {
  sd_link = nil;
  sd_formats = nil;
  
  sd_links = nil;
  sd_files = nil;
  sd_anchors = nil;

  sd_cancel = nil;
  
  sd_gnFlags.suites = kSdtplInline;
  sd_gnFlags.classes = kSdtplInline;
  sd_gnFlags.commands = kSdtplInline;
  sd_gnFlags.events = kSdtplInline;
}

#pragma mark -
- (NSString *)formatString:(NSString *)str forVariable:(NSString *)aVariable inBlock:(NSString *)aBlock {
  NSString *format = nil;
  if (sd_gnFlags.useBlockFormat && (aBlock != nil)) {
    NSDictionary *block = sd_formats[aBlock];
    /* Search var in block */
    if (block) {
      format = [block objectForKey:aVariable];
    }
  }
  /* If var not found in Block */
  if (!format) {
    format = sd_formats[aVariable];
  }
  if (format) {
    return ([format rangeOfString:@"%@"].location != NSNotFound) ? [NSString stringWithFormat:format, str] : format;
  }
  return str;
}

#pragma mark -
#pragma mark References Generator

static NSString * const _kNullPlaceholder = @"__null__";

#pragma mark Files
- (NSString *)fileForObject:(SdefObject *)anObject {
  NSString *file = [sd_files objectForKey:anObject];
  if (!file) {
    int flag = kSdefType_Undefined;
    switch ([anObject objectType]) {
      case kSdefType_Dictionary:
        if (!sd_gnFlags.index) {
          file = [sd_path lastPathComponent];
          break;
        } else {
          file = [NSString stringWithFormat:@"%@.%@", 
            SdtplSimplifieName([anObject name]), [sd_tpl extension]];
          if ([file isEqualToString:[sd_path lastPathComponent]]) {
            file = [NSString stringWithFormat:@"%@_Dictionary.%@", 
              SdtplSimplifieName([anObject name]), [sd_tpl extension]];
          }
        }
        break;
      case kSdefType_Suite:
        /* Si les suites ne sont pas dans un fichier a part */
        switch (sd_gnFlags.suites) {
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
      case kSdefType_Class:
        switch (sd_gnFlags.classes) {
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
      case kSdefType_Command:
        flag = ([(SdefVerb *)anObject isCommand]) ? sd_gnFlags.commands : sd_gnFlags.events;
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
        file = _kNullPlaceholder;
    }
    [sd_files setObject:file forKey:anObject];
  }
  return (file != _kNullPlaceholder) ? file : nil;
}

#pragma mark Anchors
- (NSString *)anchorForObject:(SdefObject *)obj {
  NSString *name = [self anchorNameForObject:obj];
  if (name) {
    NSString *anchor = sd_formats[@"AnchorFormat"];
    return [NSString stringWithFormat:anchor, name];
  }
  return nil;
}

- (NSString *)anchorNameForObject:(SdefObject *)anObject {
  NSString *anchor = [sd_anchors objectForKey:anObject];
  if (!anchor) {
    switch ([anObject objectType]) {
      case kSdefType_Dictionary:
        anchor = [NSString stringWithFormat:@"%@", SdtplSimplifieName([anObject name])];
        break;
      case kSdefType_Suite:
        anchor = [NSString stringWithFormat:@"Suite_%@", SdtplSimplifieName([anObject name])];
        break;
      case kSdefType_Class:
      case kSdefType_Command:
        anchor = [NSString stringWithFormat:@"%@_%@", SdtplSimplifieName([[anObject suite] name]), SdtplSimplifieName([anObject name])];
        break;
      default:
        anchor = _kNullPlaceholder;
    }
    [sd_anchors setObject:anchor forKey:anObject];
  }
  return (anchor != _kNullPlaceholder) ? anchor : nil;
}

#pragma mark Links
- (NSString *)linkForType:(NSString *)aType withString:(NSString *)aString {
  NSString *alink = [sd_links objectForKey:aType];
  if (!alink) {
    alink = aString;
    if (![SdefClassManager isBaseType:aType]) {
      SdefClass *class = [sd_manager classWithName:aType];
      alink = [self linkForObject:class withString:aString];
    }
    [sd_links setObject:alink forKey:aType];
  }
  return alink;
}

- (NSString *)linkForVerb:(NSString *)aVerb withString:(NSString *)aString {
  NSString *alink = [sd_links objectForKey:aVerb];
  if (!alink) {
    SdefObject *object = [sd_manager verbWithIdentifier:aVerb];
    alink = [self linkForObject:object withString:aString];
    [sd_links setObject:alink forKey:aVerb];
  }
  return alink;
}

- (NSString *)linkForObject:(SdefObject *)anObject withString:(NSString *)aString {
  NSString *alink = aString;
  if (anObject) {
    if ([anObject objectType] == kSdefType_RespondsTo) {
      alink = [self linkForVerb:[anObject name] withString:[anObject name]];
    } else {
      NSString *file = [self fileForObject:anObject];
      alink = [NSString stringWithFormat:sd_link, (file) ? : @"", [self anchorNameForObject:anObject], aString];
    }
  }
  return alink;
}

- (NSString *)linkForDictionary:(SdefDictionary *)dictionary withString:(NSString *)aString {
  NSString *alink = [sd_links objectForKey:dictionary];
  if (!alink) {
    alink = [self linkForObject:dictionary withString:aString];
    [sd_links setObject:alink forKey:dictionary];
  }
  return alink;
}

#pragma mark -
#pragma mark Template Generators
#pragma mark Common
- (void)writeReferences:(SdefObject *)anObject usingTemplate:(WBTemplate *)tpl {
  /* Set Style */
  if (kSdefTemplateXMLFormat == sd_gnFlags.format) {
    if ((sd_gnFlags.css != kSdefTemplateCSSNone) && [sd_tpl selectedStyle]) {
      if (kSdefTemplateCSSInline == sd_gnFlags.css && [tpl blockWithName:SdtplBlockStyle]) {
        WBTemplate *block = [tpl blockWithName:SdtplBlockStyle];
        if ([block containsKey:SdtplVariableStyleSheet]) {
          NSString *style = [[NSString alloc] initWithContentsOfFile:[[sd_tpl selectedStyle] objectForKey:@"path"] encoding:NSUTF8StringEncoding error:NULL];
          [block setVariable:style forKey:SdtplVariableStyleSheet];
          [block dumpBlock];
        }
      } else if (kSdefTemplateCSSExternal == sd_gnFlags.css) {
        NSString *file = [self cssFile];
        if (file) {
          SdtplSetVariable(tpl, nil, SdtplVariableStyleFile, file);
          SdtplSetVariable(tpl, nil, SdtplVariableStyleLink, file);
        }
      }
    }
  }

  /* Set References */
  if (sd_gnFlags.index) {
    /* Index path */
    SdtplSetVariable(tpl, nil, SdtplVariableIndexFile, [sd_path lastPathComponent]);
  }
  if ([self externalToc]) {
    /* Toc path */
    SdtplSetVariable(tpl, nil, SdtplVariableTocFile, [self tocFile]);
  }
  /* Dictionary Links */
  SdefObject *obj = nil;
  if ((obj = [anObject dictionary])) {
    SdtplSetVariable(tpl, nil, SdtplVariableDictionaryFile, [self fileForObject:obj]);
    NSString *name = [obj name];
    if (name) {
      SdtplSetVariable(tpl, nil, SdtplVariableDictionaryName, name);
      if (SdtplShouldCreateLinks(sd_gnFlags)) {
        SdtplSetVariable(tpl, nil, SdtplVariableDictionaryAnchor, [self anchorNameForObject:obj]);
        SdtplSetVariable(tpl, nil, SdtplVariableDictionaryLink, [self linkForDictionary:(SdefDictionary *)obj withString:name]);
      }
    }
  }
  /* Suite Links */
  if ((obj = [anObject suite])) {
    SdtplSetVariable(tpl, nil, SdtplVariableSuiteFile, [self fileForObject:obj]);
    NSString *name = [obj name];
    if (name) {
      SdtplSetVariable(tpl, nil, SdtplVariableSuiteName, name);
      if (SdtplShouldCreateLinks(sd_gnFlags)) {
        SdtplSetVariable(tpl, nil, SdtplVariableSuiteAnchor, [self anchorNameForObject:obj]);
        SdtplSetVariable(tpl, nil, SdtplVariableSuiteLink, [self linkForObject:obj withString:name]);
      }
    }
  }
}

- (BOOL)canWriteFileAtPath:(NSString *)path {
  BOOL isDir;
  if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
    if (kSdefTemplateFileSkip == sd_gnFlags.existingFile ) {
      spx_debug("Skip File %@", path);
      return NO;
    } else if (kSdefTemplateFileAsk == sd_gnFlags.existingFile) {
      NSAlert *alert = [NSAlert alertWithMessageText:@"File already exist!"
                                       defaultButton:@"Replace"
                                     alternateButton:@"Don't Replace"
                                         otherButton:@"Cancel"
                           informativeTextWithFormat:@"An file named \"%@\" already exists in the choosen location. Do you want to replace it with the new one?",
        [path lastPathComponent]];
      alert.showsSuppressionButton = YES;
      NSButton *all = alert.suppressionButton;
      all.title = @"Apply to all";
      switch ([alert runModal]) {
        case NSAlertAlternateReturn:
          if (all.state == NSOnState) {
            sd_gnFlags.existingFile = kSdefTemplateFileSkip;
          }
          return NO;
        case NSAlertOtherReturn:
          sd_gnFlags.cancel = 1;
          return NO;
      }
      if ([all state] == NSControlStateValueOn) {
        sd_gnFlags.existingFile = kSdefTemplateFileReplace;
      }
    }
  }
  return YES;
}

- (BOOL)writeTemplate:(WBTemplate *)tpl toFile:(NSString *)path representedObject:(SdefObject *)anObject {
  if (anObject) {
    [self writeReferences:anObject usingTemplate:tpl];
  }
  if (![path isAbsolutePath]) {
    path = [sd_base stringByAppendingPathComponent:path];
  }
  /* File exists already checked */
  if ([path isEqualToString:sd_path]) {
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
  }
  if ([self canWriteFileAtPath:path] && [tpl writeToFile:path atomically:YES andReset:YES]) {
    [sd_cancel addObject:path];
    return YES;
  }
  return NO;
}

#pragma mark Dictionary
- (BOOL)writeDictionary:(SdefDictionary *)aDico usingTemplate:(WBTemplate *)tpl {
  /* Generate Template */
  SdtplSetVariable(tpl, @"Dictionary", SdtplVariableName, [aDico name]);
  if (SdtplShouldCreateLinks(sd_gnFlags))
    SdtplSetVariable(tpl, @"Dictionary", SdtplVariableAnchor, [self anchorForObject:aDico]);
  
  if ([aDico hasChildren]) {
    SdefSuite *suite;
    NSEnumerator *suites = nil;
    NSMutableArray *objects = nil;
    /* Sort suites if needed */
    if (!sd_gnFlags.sortSuites) {
      suites = [aDico childEnumerator];
    } else {
      objects = [[aDico children] mutableCopy];
      SdtplSortArrayByName(objects);
      suites = [objects objectEnumerator];
    }
    /* Search Suite block */
    WBTemplate *suiteTpl = nil;
    WBTemplate *suiteBlock = [tpl blockWithName:SdtplBlockSuite];
    if (kSdtplInline == sd_gnFlags.suites) {
      suiteTpl = suiteBlock;
    } else {
      suiteTpl = [[sd_tpl templates] objectForKey:SdtplDefinitionSuitesKey];
      if (kSdtplSingleFile == sd_gnFlags.suites) {
        suiteTpl = [suiteTpl blockWithName:SdtplBlockSuite];
      }
    }
    /* Dump Suite block */
    while ((suite = [suites nextObject]) && !sd_gnFlags.cancel) {
      if (kSdtplInline != sd_gnFlags.suites) {
        NSString *name = [suite name];
        if (name && SdtplShouldCreateLinks(sd_gnFlags)) 
          name = [self linkForObject:suite withString:name];
        SdtplSetVariable(suiteBlock, [suiteBlock name], SdtplVariableName, name);
        if ([suite desc])
          SdtplSetVariable(suiteBlock, [suiteBlock name], SdtplVariableDescription, SdefEscapedString([suite desc], sd_gnFlags.format));
      }
      if (suiteTpl)
        [self writeSuite:suite usingTemplate:suiteTpl];
      [suiteBlock dumpBlock];
    }
    if (!sd_gnFlags.cancel) {
      /* Create Suite file if needed */
      switch (sd_gnFlags.suites) {
        case kSdtplSingleFile:
          [self writeTemplate:[[sd_tpl templates] objectForKey:SdtplDefinitionSuitesKey]
                       toFile:[self fileForObject:[aDico firstChild]]
            representedObject:aDico];
          break;
      }
    }
  }
  
  /* Create table fo Content if needed */
  if ([self dictionaryToc] && !sd_gnFlags.cancel) {
    WBTemplate *toc = [tpl blockWithName:SdtplBlockTableOfContent];
    if (toc) {
      [self writeToc:aDico usingTemplate:toc];
    }
    [toc dumpBlock];
  }
  /* Write file */
  NSString *file = nil;
  if (sd_gnFlags.index) {
    file = [self fileForObject:aDico];
  } else {
    file = sd_path;
  }
  return (!sd_gnFlags.cancel) ? [self writeTemplate:tpl toFile:file representedObject:aDico] : NO;
}

#pragma mark Suites
- (BOOL)writeSuite:(SdefSuite *)suite usingTemplate:(WBTemplate *)tpl {
  if ([suite name]) {
    SdtplSetVariable(tpl, SdtplBlockSuite, SdtplVariableName, [suite name]);
    if (SdtplShouldCreateLinks(sd_gnFlags))
      SdtplSetVariable(tpl, SdtplBlockSuite, SdtplVariableAnchor, [self anchorForObject:suite]);
  }
  if ([suite desc])
    SdtplSetVariable(tpl, SdtplBlockSuite, SdtplVariableDescription, SdefEscapedString([suite desc], sd_gnFlags.format));
  
  if ([[suite classes] hasChildren]) {
    SdefClass *class;    
    NSEnumerator *classes = nil;
    NSMutableArray *objects = nil;
    if (!sd_gnFlags.sortOthers) {
      classes = [[suite classes] childEnumerator];
    } else {
      objects = [[[suite classes] children] mutableCopy];
      SdtplSortArrayByName(objects);
      classes = [objects objectEnumerator];
    }
    
    WBTemplate *classTpl = nil;
    WBTemplate *classBlock = [tpl blockWithName:SdtplBlockClass];
    if (kSdtplInline == sd_gnFlags.classes) {
      classTpl = classBlock;
    } else {
      classTpl = [[sd_tpl templates] objectForKey:SdtplDefinitionClassesKey];
      if (kSdtplSingleFile == sd_gnFlags.classes) {
        classTpl = [classTpl blockWithName:SdtplBlockClass];
      }
    }
    
    while ((class = [classes nextObject]) && !sd_gnFlags.cancel) {
      if (kSdtplInline != sd_gnFlags.classes) {
        NSString *name = [class name];
        if (name && SdtplShouldCreateLinks(sd_gnFlags))
          name = [self linkForObject:class withString:name];
        SdtplSetVariable(classBlock, [classBlock name], SdtplVariableName, name);
        if ([class desc])
          SdtplSetVariable(classBlock, [classBlock name], SdtplVariableDescription, SdefEscapedString([class desc], sd_gnFlags.format));
      }
      if (classTpl)
        [self writeClass:class usingTemplate:classTpl];
      [classBlock dumpBlock];
    }
    if (!sd_gnFlags.cancel) {
      [[tpl blockWithName:SdtplBlockClasses] dumpBlock];
      switch (sd_gnFlags.classes) {
        case kSdtplSingleFile:
          [self writeTemplate:[[sd_tpl templates] objectForKey:SdtplDefinitionClassesKey]
                       toFile:[self fileForObject:[[suite classes] firstChild]]
            representedObject:suite];
          break;
      }
    }
  }
  if (sd_gnFlags.cancel) return NO;
  
  /* Commands */
  if ([[suite commands] hasChildren] ||
      (sd_gnFlags.groupEvents && !sd_gnFlags.ignoreEvents && [[suite events] hasChildren])) {
    SdefVerb *cmd;
    NSEnumerator *cmds = nil;
    NSMutableArray *objects = nil;
    /* Group events with commands */
    if (sd_gnFlags.groupEvents && !sd_gnFlags.ignoreEvents) {
      objects = [[NSMutableArray alloc] init];
      if ([[suite commands] hasChildren])
        [objects addObjectsFromArray:[[suite commands] children]];
      if ([[suite events] hasChildren])
        [objects addObjectsFromArray:[[suite events] children]];
    }
    
    if (!sd_gnFlags.sortOthers) {
      cmds = (objects) ? [objects objectEnumerator] : [[suite commands] childEnumerator];
    } else {
      if (!objects) {
        objects = [[[suite commands] children] mutableCopy];
      }
      SdtplSortArrayByName(objects);
      cmds = [objects objectEnumerator];
    }
    
    WBTemplate *cmdTpl = nil;
    WBTemplate *cmdBlock = [tpl blockWithName:SdtplBlockCommand];
    if (kSdtplInline == sd_gnFlags.commands) {
      cmdTpl = cmdBlock;
    } else {
      cmdTpl = [[sd_tpl templates] objectForKey:SdtplDefinitionCommandsKey];
      if (kSdtplSingleFile == sd_gnFlags.commands) {
        cmdTpl = [cmdTpl blockWithName:SdtplBlockCommand];
      }
    }
    
    while ((cmd = [cmds nextObject]) && !sd_gnFlags.cancel) {
      if (kSdtplInline != sd_gnFlags.commands) {
        NSString *name = [cmd name];
        if (name && SdtplShouldCreateLinks(sd_gnFlags))
          name = [self linkForObject:cmd withString:name];
        SdtplSetVariable(cmdBlock, [cmdBlock name], SdtplVariableName, name);
        if ([cmd desc])
          SdtplSetVariable(cmdBlock, [cmdBlock name], SdtplVariableDescription, SdefEscapedString([cmd desc], sd_gnFlags.format));
      }
      if (cmdTpl)
        [self writeVerb:cmd usingTemplate:cmdTpl];
      [cmdBlock dumpBlock];
    }
    if (!sd_gnFlags.cancel) {
      [[tpl blockWithName:SdtplBlockCommands] dumpBlock];
      switch (sd_gnFlags.commands) {
        case kSdtplSingleFile:
          [self writeTemplate:[[sd_tpl templates] objectForKey:SdtplDefinitionCommandsKey]
                       toFile:[self fileForObject:[[suite commands] firstChild]]
            representedObject:suite];
          break;
      }
    }
  }
  if (sd_gnFlags.cancel) return NO;
  
  /* Events */
  if (!sd_gnFlags.groupEvents && !sd_gnFlags.ignoreEvents && [[suite events] hasChildren]) {
    SdefVerb *evnt;
    NSEnumerator *evnts = nil;
    NSMutableArray *objects = nil;
    if (!sd_gnFlags.sortOthers) {
      evnts = [[suite events] childEnumerator];
    } else {
      objects = [[[suite events] children] mutableCopy];
      SdtplSortArrayByName(objects);
      evnts = [objects objectEnumerator];
    }
    
    WBTemplate *evntTpl = nil;
    WBTemplate *evntBlock = [tpl blockWithName:SdtplBlockEvent];
    if (kSdtplInline == sd_gnFlags.events) {
      evntTpl = evntBlock;
    } else {
      evntTpl = [[sd_tpl templates] objectForKey:SdtplDefinitionEventsKey];
      if (kSdtplSingleFile == sd_gnFlags.events) {
        evntTpl = [evntTpl blockWithName:SdtplBlockEvent];
      }
    }
    
    while ((evnt = [evnts nextObject]) && !sd_gnFlags.cancel) {
      if (kSdtplInline != sd_gnFlags.events) {
        NSString *name = [evnt name];
        if (name && SdtplShouldCreateLinks(sd_gnFlags))
          name = [self linkForObject:evnt withString:name];
        SdtplSetVariable(evntBlock, [evntBlock name], SdtplVariableName, name);
        if ([evnt desc])
          SdtplSetVariable(evntBlock, [evntBlock name], SdtplVariableDescription, SdefEscapedString([evnt desc], sd_gnFlags.format));
      }
      if (evntTpl)
        [self writeVerb:evnt usingTemplate:evntTpl];
      [evntBlock dumpBlock];
    }
    if (!sd_gnFlags.cancel) {
      [[tpl blockWithName:SdtplBlockEvents] dumpBlock];
      switch (sd_gnFlags.events) {
        case kSdtplSingleFile:
          [self writeTemplate:[[sd_tpl templates] objectForKey:SdtplDefinitionEventsKey]
                       toFile:[self fileForObject:[[suite events] firstChild]]
            representedObject:suite];
          break;
      }
    }
  }
  
  BOOL ok = YES;
  if (!sd_gnFlags.cancel) {
    switch (sd_gnFlags.suites) {
      case kSdtplSingleFile:
        [tpl dumpBlock];
        break;
      case kSdtplMultiFiles:
        ok = [self writeTemplate:tpl toFile:[self fileForObject:suite] representedObject:suite];
        break;
    }
  } else {
    ok = NO;
  }
  return ok;
}

#pragma mark Classes
- (void)writeElement:(SdefElement *)elt usingTemplate:(WBTemplate *)tpl {
  if ([elt name]) {
    NSString *name = [elt name];
    if (SdtplShouldCreateLinks(sd_gnFlags))
      name = [self linkForType:name withString:name];
    SdtplSetVariable(tpl, [tpl name], SdtplVariableType, name);
  }
  NSAssert1([elt respondsToSelector:@selector(writeAccessorsStringToStream:)],
            @"Element %@ does not responds to writeAccessorsStringToStream:", elt);
  NSMutableString *rights = [[NSMutableString alloc] init];
  [elt performSelector:@selector(writeAccessorsStringToStream:) withObject:rights];
  SdtplSetVariable(tpl, [tpl name], SdtplVariableAccessors, rights);
}

- (void)writeProperty:(SdefProperty *)prop usingTemplate:(WBTemplate *)tpl {
  if ([prop name])
    SdtplSetVariable(tpl, [tpl name], SdtplVariableName, [prop name]);
  if ([prop type]) {
    NSString *type = [prop asDictionaryTypeForType:[prop type] isList:nil];
    if (SdtplShouldCreateLinks(sd_gnFlags))
      type = [self linkForType:[prop type] withString:type];
    SdtplSetVariable(tpl, [tpl name], SdtplVariableType, type);
  }
  if (([prop access] & kSdefAccessWrite) == 0)
    SdtplSetVariable(tpl, [tpl name], SdtplVariableReadOnly, SdtplVariableDefaultReadOnly);
  if ([prop desc])
    SdtplSetVariable(tpl, [tpl name], SdtplVariableDescription, SdefEscapedString([prop desc], sd_gnFlags.format));
}

- (BOOL)writeClass:(SdefClass *)aClass usingTemplate:(WBTemplate *)tpl {
  if ([aClass name]) {
    SdtplSetVariable(tpl, SdtplBlockClass, SdtplVariableName, [aClass name]);
    if (SdtplShouldCreateLinks(sd_gnFlags))
      SdtplSetVariable(tpl, SdtplBlockClass, SdtplVariableAnchor, [self anchorForObject:aClass]);
  }
  if ([aClass desc])
    SdtplSetVariable(tpl, SdtplBlockClass, SdtplVariableDescription, SdefEscapedString([aClass desc], sd_gnFlags.format));
  /* Plural */
  if ([aClass plural]) {
    WBTemplate *plural = [tpl blockWithName:SdtplBlockPlural];
    SdtplSetVariable(plural, [plural name], SdtplVariableName, [aClass plural]);
    [plural dumpBlock];
  }
  /* Subclasses */
  if (sd_gnFlags.subclasses && [tpl blockWithName:SdtplBlockSubclasses]) {
    NSArray *subclasses = [sd_manager subclassesOfClass:aClass];
    if ([subclasses count]) {
      WBTemplate *subclass = [tpl blockWithName:SdtplBlockSubclass];
      if (SdtplDumpSimpleBlock(self, [subclasses objectEnumerator], subclass, @selector(name)) > 0) {
        [[tpl blockWithName:SdtplBlockSubclasses] dumpBlock];
      }
    }
  }
  
  /* Elements */
  if ([[aClass elements] hasChildren] && nil != [tpl blockWithName:SdtplBlockElement]) {
    SdefElement *elt;
    NSEnumerator *elements = nil;
    NSMutableArray *objects = nil;
    if (!sd_gnFlags.sortOthers) {
      elements = [[aClass elements] childEnumerator];
    } else {
      objects = [[[aClass elements] children] mutableCopy];
      SdtplSortArrayByName(objects);
      elements = [objects objectEnumerator];
    }
    
    WBTemplate *eltBlock = [tpl blockWithName:SdtplBlockElement];
    while (elt = [elements nextObject]) {
      [self writeElement:elt usingTemplate:eltBlock];
      [eltBlock dumpBlock];
    }
    /* require to generate block */
    [[tpl blockWithName:SdtplBlockElements] dumpBlock];
  }
  /* Superclass */
  if ([aClass inherits] && [tpl blockWithName:SdtplBlockSuperclass]) {
    NSString *inherits = [aClass inherits];
    WBTemplate *superclass = [tpl blockWithName:SdtplBlockSuperclass];
    SdtplSetVariable(superclass, [superclass name], SdtplVariableDescription, inherits);
    if (SdtplShouldCreateLinks(sd_gnFlags))
      inherits = [self linkForType:inherits withString:inherits];
    SdtplSetVariable(superclass, [superclass name], SdtplVariableName, inherits);
    [superclass dumpBlock];
  }
  /* Properties */
  /* inner: if superclass is in Properties block, we have to dump it. */
  BOOL inner = [[[[tpl blockWithName:SdtplBlockSuperclass] parent] name] isEqualToString:SdtplBlockProperties];
  if ([[aClass properties] hasChildren] || ([aClass inherits] && inner)) {
    WBTemplate *propBlock = [tpl blockWithName:SdtplBlockProperty];
    if (propBlock != nil) {
      SdefProperty *property;
      NSEnumerator *properties = nil;
      NSMutableArray *objects = nil;
      if (!sd_gnFlags.sortOthers) {
        properties = [[aClass properties] childEnumerator];
      } else {
        objects = [[[aClass properties] children] mutableCopy];
        SdtplSortArrayByName(objects);
        properties = [objects objectEnumerator];
      }
      
      while (property = [properties nextObject]) {
        [self writeProperty:property usingTemplate:propBlock];
        [propBlock dumpBlock];
      }
    }
    /* require to generate block */
    [[tpl blockWithName:SdtplBlockProperties] dumpBlock];
  }
  
  /* Responds-To */
  if (!sd_gnFlags.ignoreRespondsTo) {

    NSMutableArray *objects = nil;
    /* groups events and commands */
    if (sd_gnFlags.groupEvents && !sd_gnFlags.ignoreEvents) {
      objects = [[NSMutableArray alloc] init];
      if ([[aClass commands] hasChildren])
        [objects addObjectsFromArray:[[aClass commands] children]];
      if ([[aClass events] hasChildren])
        [objects addObjectsFromArray:[[aClass events] children]];
    }
    /* Commands */
    if (([[aClass commands] hasChildren] || [objects count]) && nil != [tpl blockWithName:SdtplBlockRespondsToCommands]) {
      NSEnumerator *cmds = nil;
      if (!sd_gnFlags.sortOthers) {
        cmds = (objects) ? [objects objectEnumerator] : [[aClass commands] childEnumerator];
      } else {
        if (!objects)
          objects = [[[aClass commands] children] mutableCopy];
        SdtplSortArrayByName(objects);
        cmds = [objects objectEnumerator];
      }
      
      WBTemplate *cmdBlock = [tpl blockWithName:SdtplBlockRespondsToCommand];
      if (SdtplDumpSimpleBlock(self, cmds, cmdBlock, @selector(name)) > 0) {
        [[tpl blockWithName:SdtplBlockRespondsToCommands] dumpBlock];
      }
    }
    objects = nil;
    
    /* Events */
    if (!sd_gnFlags.groupEvents && !sd_gnFlags.ignoreEvents && 
        [[aClass events] hasChildren] && [tpl blockWithName:SdtplBlockRespondsToEvents]) {
      NSEnumerator *evnts = nil;
      if (!sd_gnFlags.sortOthers) {
        evnts = [[aClass events] childEnumerator];
      } else {
        objects = [[[aClass events] children] mutableCopy];
        SdtplSortArrayByName(objects);
        evnts = [objects objectEnumerator];
      }
      
      WBTemplate *evntBlock = [tpl blockWithName:SdtplBlockRespondsToEvent];
      if (SdtplDumpSimpleBlock(self, evnts, evntBlock, @selector(name)) > 0) {
        [[tpl blockWithName:SdtplBlockRespondsToEvents] dumpBlock];
      }
    }
  }
  
  BOOL ok = YES;
  switch (sd_gnFlags.classes) {
    case kSdtplSingleFile:
      [tpl dumpBlock];
      break;
    case kSdtplMultiFiles:
      ok = [self writeTemplate:tpl toFile:[self fileForObject:aClass] representedObject:aClass];
      break;
  }
  return !sd_gnFlags.cancel ? ok : NO;
}

#pragma mark Verb
- (void)writeParameter:(SdefParameter *)param usingTemplate:(WBTemplate *)tpl {
  if ([param name])
    SdtplSetVariable(tpl, [tpl name], SdtplVariableName, [param name]);
  if ([param desc])
    SdtplSetVariable(tpl, [tpl name], SdtplVariableDescription, SdefEscapedString([param desc], sd_gnFlags.format));
  if ([param type]) {
    BOOL list;
    NSString *type = [param asDictionaryTypeForType:[param type] isList:&list];
    if (list) {
      SdtplSetVariable(tpl, [tpl name], SdtplVariableTypeList, SdtplVariableDefaultTypeList);
      if (SdtplShouldCreateLinks(sd_gnFlags))
        type = [self linkForType:[[param type] substringFromIndex:8] withString:type];
    } else if (SdtplShouldCreateLinks(sd_gnFlags)) {
      type = [self linkForType:[param type] withString:type];
    }
    SdtplSetVariable(tpl, [tpl name], SdtplVariableType, type);
  }
}

- (BOOL)writeVerb:(SdefVerb *)verb usingTemplate:(WBTemplate *)tpl {
  NSString *blockName = [verb isCommand] ? SdtplBlockCommand : SdtplBlockEvent;
  if ([verb name]) {
      SdtplSetVariable(tpl, blockName, SdtplVariableName, [verb name]);
    if (SdtplShouldCreateLinks(sd_gnFlags))
      SdtplSetVariable(tpl, blockName, SdtplVariableAnchor, [self anchorForObject:verb]);
  }
  if ([verb desc])
    SdtplSetVariable(tpl, blockName, SdtplVariableDescription, SdefEscapedString([verb desc], sd_gnFlags.format));

  /* Direct Parameter */
  if ([[verb directParameter] type]) {
    WBTemplate *block = [tpl blockWithName:SdtplBlockDirectParameter];
    if (block) {
      SdefDirectParameter *param = [verb directParameter];
      if ([param type]) {
        BOOL list;
        NSString *type = [param asDictionaryTypeForType:[param type] isList:&list];
        if (list) {
          SdtplSetVariable(block, [block name], SdtplVariableTypeList, SdtplVariableDefaultTypeList);
          if (SdtplShouldCreateLinks(sd_gnFlags))
            type = [self linkForType:[[param type] substringFromIndex:8] withString:type];
        } else if (SdtplShouldCreateLinks(sd_gnFlags)) {
          type = [self linkForType:[param type] withString:type];
        }
        SdtplSetVariable(block, [block name], SdtplVariableType, type);
      }
      /* Description */
      if ([param desc])
        SdtplSetVariable(block, [block name], SdtplVariableDescription, SdefEscapedString([param desc], sd_gnFlags.format));
      [block dumpBlock];
    }
  }
  /* Result */
  if ([[verb result] type]) {
    WBTemplate *block = [tpl blockWithName:SdtplBlockResult];
    if (block) {
      SdefResult *result = [verb result];
      if ([result type]) {
        BOOL list;
        NSString *type = [result asDictionaryTypeForType:[result type] isList:&list];
        if (list) {
          SdtplSetVariable(block, [block name], SdtplVariableTypeList, SdtplVariableDefaultTypeList);
          if (SdtplShouldCreateLinks(sd_gnFlags))
            type = [self linkForType:[[result type] substringFromIndex:8] withString:type];
        } else if (SdtplShouldCreateLinks(sd_gnFlags)) {
          type = [self linkForType:[result type] withString:type];
        }
        SdtplSetVariable(block, [block name], SdtplVariableType, type);
      }
      /* Description */
      if ([result desc])
        SdtplSetVariable(block, [block name], SdtplVariableDescription, SdefEscapedString([result desc], sd_gnFlags.format));
      [block dumpBlock];
    }
  }
  /* Parameters */
  if ([verb hasChildren] && [tpl blockWithName:SdtplBlockParameters]) {
    SdefParameter *param;
    NSEnumerator *params = nil;
    NSMutableArray *objects = nil;
    
    if (!sd_gnFlags.sortOthers) {
      params = [verb childEnumerator];
    } else {
      objects = [[verb children] mutableCopy];
      SdtplSortArrayByName(objects);
      params = [objects objectEnumerator];
    }
    
    /* Required parameters */
    WBTemplate *block = [tpl blockWithName:SdtplBlockRequiredParameter];
    while (param = [params nextObject]) {
      if (![param isOptional]) {
        [self writeParameter:param usingTemplate:block];
        [block dumpBlock];
      }
    }
    
    /* Optionals parameters */
    block = [tpl blockWithName:SdtplBlockOptionalParameter];
    if (!sd_gnFlags.sortOthers) {
      params = [verb childEnumerator];
    } else {
      params = [objects objectEnumerator];
    }
    while (param = [params nextObject]) {
      if ([param isOptional]) {
        [self writeParameter:param usingTemplate:block];
        [block dumpBlock];
      }
    }
    [[tpl blockWithName:SdtplBlockParameters] dumpBlock];
  }
  
  BOOL ok = YES;
  int flag = [verb isCommand] ? sd_gnFlags.commands : sd_gnFlags.events;
  switch (flag) {
    case kSdtplSingleFile:
      [tpl dumpBlock];
      break;
    case kSdtplMultiFiles:
      ok = [self writeTemplate:tpl toFile:[self fileForObject:verb] representedObject:verb];
      break;
  }
  return !sd_gnFlags.cancel ? ok : NO;
}

#pragma mark Toc
- (void)writeToc:(SdefDictionary *)dictionary usingTemplate:(WBTemplate *)tpl {
  SdtplSetVariable(tpl, SdtplBlockTableOfContent, SdtplVariableName, [dictionary name]);

  /* Suites */
  SdefSuite *suite;
  NSEnumerator *suites = nil;
  NSMutableArray *sortedSuites = nil;
  if (!sd_gnFlags.sortSuites) {
    suites = [dictionary childEnumerator];
  } else {
    sortedSuites = [[dictionary children] mutableCopy];
    SdtplSortArrayByName(sortedSuites);
    suites = [sortedSuites objectEnumerator];
  }
  
  WBTemplate *stpl = [tpl blockWithName:@"Toc-Suite"];
  while (suite = [suites nextObject]) {
    NSString *name = [suite name];
    if (name) {
      if (SdtplShouldCreateLinks(sd_gnFlags))
        name = [self linkForObject:suite withString:name];
      SdtplSetVariable(stpl, [stpl name], SdtplVariableName, name);
      if ([suite desc])
        SdtplSetVariable(stpl, [stpl name], SdtplVariableDescription, [suite desc]);
    }
    /* Classes */
    NSMutableArray *objects = nil;
    if ([[suite classes] hasChildren] && [stpl blockWithName:@"Toc-Class"]) {
      NSEnumerator *classes = nil;
      if (!sd_gnFlags.sortOthers) {
        classes = [[suite classes] childEnumerator];
      } else {
        objects = [[[suite classes] children] mutableCopy];
        SdtplSortArrayByName(objects);
        classes = [objects objectEnumerator];
      }
      
      WBTemplate *ctpl = [stpl blockWithName:@"Toc-Class"];
      if (SdtplDumpSimpleBlock(self, classes, ctpl, @selector(desc)) > 0) {
        [[stpl blockWithName:@"Toc-Classes"] dumpBlock];
      }
    }
    objects = nil;
    
    /* Group Command and events if needed */
    if (sd_gnFlags.groupEvents && !sd_gnFlags.ignoreEvents) {
      objects = [[NSMutableArray alloc] init];
      if ([[suite commands] hasChildren])
        [objects addObjectsFromArray:[[suite commands] children]];
      if ([[suite events] hasChildren])
        [objects addObjectsFromArray:[[suite events] children]];
    }    
    /* Commands */
    if (([[suite commands] hasChildren] || [objects count]) && [stpl blockWithName:@"Toc-Commands"]) {
      NSEnumerator *commands = nil;
      if (!sd_gnFlags.sortOthers) {
        commands = (objects) ? [objects objectEnumerator] : [[suite commands] childEnumerator];
      } else {
        if (!objects)
          objects = [[[suite commands] children] mutableCopy];
        SdtplSortArrayByName(objects);
        commands = [objects objectEnumerator];
      }
      WBTemplate *vtpl = [stpl blockWithName:@"Toc-Command"];
      if (SdtplDumpSimpleBlock(self, commands, vtpl, @selector(desc)) > 0) {
        [[stpl blockWithName:@"Toc-Commands"] dumpBlock];
      }
    }
    objects = nil;
    
    /* Events */
    if (!sd_gnFlags.ignoreEvents && !sd_gnFlags.groupEvents 
        && [[suite events] hasChildren] && [stpl blockWithName:@"Toc-Events"]) {
      NSEnumerator *events = nil;
      if (!sd_gnFlags.sortOthers) {
        events = [[suite events] childEnumerator];
      } else {
        objects = [[[suite events] children] mutableCopy];
        SdtplSortArrayByName(objects);
        events = [objects objectEnumerator];
      }
      WBTemplate *etpl = [stpl blockWithName:@"Toc-Event"];
      if (SdtplDumpSimpleBlock(self, events, etpl, @selector(desc)) > 0) {
        [[stpl blockWithName:@"Toc-Events"] dumpBlock];
      }
    }
    objects = nil;
    
    [stpl dumpBlock];
  }
}

#pragma mark Index
- (BOOL)writeIndex:(SdefDictionary *)theDico usingTemplate:(WBTemplate *)tpl {
  if ([self indexToc]) {
    WBTemplate *toc = [tpl blockWithName:SdtplBlockTableOfContent];
    if (toc) {
      [self writeToc:theDico usingTemplate:toc];
    }
    [toc dumpBlock];
  }
  
  return [self writeTemplate:tpl toFile:sd_path representedObject:theDico];
}

#pragma mark Toc Function
static 
NSUInteger SdtplDumpSimpleBlock(SdtplGenerator *self, NSEnumerator *enume, WBTemplate *tpl, SEL description) {
  NSUInteger dumped = 0;
  id object;
  while (object = [enume nextObject]) {
    NSString *name = [object name];
    if (name) {
      if (SdtplShouldCreateLinks(self->sd_gnFlags))
        name = [self linkForObject:object withString:name];
      SdtplSetVariable(tpl, [tpl name], SdtplVariableName, name);
      if (description) {
        NSString *desc = [object performSelector:description];
        if (desc)
          SdtplSetVariable(tpl, [tpl name], SdtplVariableDescription, desc);
      }
      [tpl dumpBlock];
      dumped++;
    }
  }
  return dumped;
}

static NSString *SdtplCopyFormatedString(SdtplGenerator *self, NSString *str, NSString *aVariable, NSString *aBlock) {
  NSString *format = nil;
  if (self->sd_gnFlags.useBlockFormat && (aBlock != nil)) {
    NSDictionary *block = self->sd_formats[aBlock];
    /* Search var in block */
    if (block) {
      format = [block objectForKey:aVariable];
    }
  }
  /* If var not found in Block */
  if (!format) {
    format = self->sd_formats[aVariable];
  }
  if (format) {
    return ([format rangeOfString:@"%@"].location != NSNotFound) ? [[NSString alloc] initWithFormat:format, str] : format;
  }
  return str;
}

@end

#pragma mark -

static
void SdtplSortArrayByName(NSMutableArray *array) {
  static NSArray *SdtplSortDescriptors = nil;
  if (!SdtplSortDescriptors) {
    NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    SdtplSortDescriptors = @[desc];
  }
  [array sortUsingDescriptors:SdtplSortDescriptors];
}

static NSString *SdtplSimplifieName(NSString *name) {
  NSData *data = [name dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  NSMutableString *simple = [[NSMutableString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  [simple replaceOccurrencesOfString:@" " withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [simple length])];  
  return simple;
}

