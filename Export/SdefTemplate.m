//
//  SdefTemplate.m
//  Sdef Editor
//
//  Created by Grayfox on 28/03/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefTemplate.h"
#import "ShadowMacros.h"
#import "SKFSFunctions.h"

#import "SKTemplate.h"
#import "SKXMLTemplate.h"

/* Specials Keys */
NSString * const StdplVariableLinks = @"Links";
NSString * const StdplVariableStyleLink = @"Style-Link";
NSString * const StdplVariableAnchorFormat = @"AnchorFormat";

/* Misc */
NSString * const SdefInvalidTemplateException = @"SdefInvalidTemplate";
NSString * const SdefTemplateDidChangeNotification = @"SdefTemplateDidChange";

static NSString * const kSdefTemplateExtension = @"sdtpl";
static NSString * const kSdefTemplateFolder = @"Sdef Editor/Templates/";

static NSArray *SdefTemplatePaths();
static NSDictionary *SdefTemplatesAtPath(NSString *path);

static NSString * const kSdtplVersion = @"Version"; /* Number */
static NSString * const kSdtplDisplayName = @"DisplayName"; /* NSString */
static NSString * const kSdtplStyleSheets = @"HTMLStyleSheets"; /* NSDictionary */
static NSString * const kSdtplTemplateFormat = @"TemplateFormat"; /* NSString */
static NSString * const kSdtplRequireFileType = @"RequireFileType"; /* NSString */
static NSString * const kSdtplTemplateStrings = @"TemplateStrings"; /* NSArray */

/* Definition Keys */
NSString * const SdtplDefinitionFileKey = @"File";
NSString * const SdtplDefinitionSingleFileKey = @"SingleFile";
NSString * const SdtplDefinitionRemoveBlockLine = @"RemoveBlockLines"; /* Boolean */

NSString * const SdtplDefinitionTocKey = @"Toc";
NSString * const SdtplDefinitionIndexKey = @"Index";
NSString * const SdtplDefinitionDictionaryKey = @"Dictionary";
NSString * const SdtplDefinitionSuitesKey = @"Suites";
NSString * const SdtplDefinitionClassesKey = @"Classes";
NSString * const SdtplDefinitionCommandsKey = @"Commands";
NSString * const SdtplDefinitionEventsKey = @"Events";

@implementation SdefTemplate

+ (NSDictionary *)findAllTemplates {
  NSString *path;
  NSArray *paths = SdefTemplatePaths();
  /* Add entries will replace existing entries, so use a reverse enumerator */
  NSEnumerator *enume = [paths reverseObjectEnumerator];
  id templates = [[NSMutableDictionary alloc] init];
  while (path = [enume nextObject]) {
    [templates addEntriesFromDictionary:SdefTemplatesAtPath(path)];
  }
  return [templates autorelease];
}

- (id)initWithPath:(NSString *)aPath {
  if (self = [super init]) {
    @try {
      [self setPath:aPath];
    } @catch (NSException *exception) {
      [self release];
      self = nil;
      [exception raise];
    }
  }
  return self;
}

- (void)dealloc {
  [sd_def release];
  [sd_tpls release];
  [sd_path release];
  [sd_name release];
  [sd_infos release];
  [sd_styles release];
  [super dealloc];
}

#pragma mark -
- (void)reset {
  [sd_def release];
  sd_def = nil;
  [sd_tpls release];
  sd_tpls = nil;
  [sd_path release];
  sd_path = nil;
  [sd_name release];
  sd_name = nil;
  [sd_infos release];
  sd_infos = nil;
  [sd_styles release];
  sd_styles = nil;
  sd_selectedStyle = nil;
  bzero(&tp_flags, sizeof(tp_flags));
}

- (void)loadInfo:(NSFileWrapper *)tpl {
  NSData *fileData = [[[tpl fileWrappers] objectForKey:@"Info.plist"] regularFileContents];
  if (fileData) {
    sd_infos = [NSPropertyListSerialization propertyListFromData:fileData
                                                mutabilityOption:NSPropertyListMutableContainers
                                                          format:nil
                                                errorDescription:nil];
  }
  if (!sd_infos) {
    [NSException raise:SdefInvalidTemplateException format:@"%@ doesn't contains a valid Info.plist file.", [sd_path lastPathComponent]];
    return;
  }
  [sd_infos retain];
  
  /* Set format */
  if ([sd_infos objectForKey:kSdtplTemplateFormat]) {
    tp_flags.html = [[sd_infos objectForKey:kSdtplTemplateFormat] caseInsensitiveCompare:@"html"] == 0;
  }
  
  /* Set Defaults Strings: AddValue set value if key does not exist, else do nothing */
  CFMutableDictionaryRef formats = (CFMutableDictionaryRef)[sd_infos objectForKey:kSdtplTemplateStrings];
  if (!formats) {
    formats = (CFMutableDictionaryRef)[[NSMutableDictionary alloc] init];
    [sd_infos setObject:(id)formats forKey:kSdtplTemplateStrings];
    [(id)formats release];
  }
  CFDictionaryAddValue(formats, StdplVariableLinks, @"<a href=\"%@#%@\">%@</a>");  
  CFDictionaryAddValue(formats, StdplVariableAnchorFormat, @"<a name=\"%@\" />");
  CFDictionaryAddValue(formats, StdplVariableStyleLink, @"<link rel=\"stylesheet\" type=\"text/css\" href=\"%@\" />");
//  CFDictionaryAddValue(formats, @"Superclass.Description", @"inherits some of its properties from the %@ class");
  
  /* Check CSS */
  NSDictionary *styles = [sd_infos objectForKey:kSdtplStyleSheets];
  if (tp_flags.html && [styles count]) {
    tp_flags.css = kSdefTemplateCSSInline | kSdefTemplateCSSExternal;
    /* Load CSS */
    sd_styles = [[NSMutableArray alloc] initWithCapacity:[styles count]];
    id keys = [styles keyEnumerator];
    id key;
    while (key = [keys nextObject]) {
      id style = [NSDictionary dictionaryWithObjectsAndKeys:
        key, @"name",
        [sd_path stringByAppendingPathComponent:[styles objectForKey:key]], @"path",
        nil];
      [(NSMutableArray *)sd_styles addObject:style];
    }
    [self setSelectedStyle:[sd_styles objectAtIndex:0]];
  } else {
    [self setSelectedStyle:nil];
    tp_flags.css = kSdefTemplateCSSNone;
  }
}

- (void)loadDefinition:(NSFileWrapper *)tpl {
  NSData *fileData = [[[tpl fileWrappers] objectForKey:@"Definition.plist"] regularFileContents];
  if (fileData) {
    sd_def = [NSPropertyListSerialization propertyListFromData:fileData
                                           mutabilityOption:NSPropertyListImmutable
                                                     format:nil
                                           errorDescription:nil];
  }
  if (!sd_def) {
    [NSException raise:SdefInvalidTemplateException format:@"%@ doesn't contains a valid Definition.plist file.", [sd_path lastPathComponent]];
    return;
  }
  if (![sd_def objectForKey:SdtplDefinitionDictionaryKey]) {
    [NSException raise:SdefInvalidTemplateException format:@"%@ Definition does not contains a valid \"DictionaryTemplate\" key.", [sd_path lastPathComponent]];
    return;
  } else {
    [sd_def retain];
    Class tplClass = tp_flags.html ? [SKXMLTemplate class] : [SKTemplate class];
    sd_tpls = [[NSMutableDictionary alloc] initWithCapacity:[sd_def count]];
    NSString *key;
    id keys = [sd_def keyEnumerator];
    while (key = [keys nextObject]) {
      NSDictionary *tplDef = [sd_def objectForKey:key];
      SKTemplate *tpl = [[tplClass alloc] initWithContentsOfFile:
        [sd_path stringByAppendingPathComponent:[tplDef objectForKey:SdtplDefinitionFileKey]]];
      [tpl setRemoveBlockLine:[[tplDef objectForKey:SdtplDefinitionRemoveBlockLine] boolValue]];
      [sd_tpls setObject:tpl forKey:key];
      [tpl release];
    }
  }
  
  tp_flags.toc = kSdefTemplateTOCNone;
  NSDictionary *toc = [sd_def objectForKey:SdtplDefinitionTocKey];
  if (toc) {
    tp_flags.toc |= kSdefTemplateTOCExternal;
    if ([[toc objectForKey:@"Required"] boolValue])
      tp_flags.toc |= kSdefTemplateTOCRequired;
  }
  if ([[sd_tpls objectForKey:SdtplDefinitionDictionaryKey] blockWithName:@"Table_Of_Content"]) {
    tp_flags.toc |= kSdefTemplateTOCDictionary;  
  }
  if ([[sd_tpls objectForKey:SdtplDefinitionIndexKey] blockWithName:@"Table_Of_Content"]) {
    tp_flags.toc |= kSdefTemplateTOCIndex;  
  }
}

- (NSString *)path {
  return sd_path;
}

- (void)setPath:(NSString *)path {
  [self reset];
  NSFileWrapper *template = [[NSFileWrapper alloc] initWithPath:path];
  if (template && [template isDirectory]) {
    sd_path = [path copy];
    [self loadInfo:template];
    [self loadDefinition:template];
  }
  [template release];
}

#pragma mark -
- (NSString *)displayName {
  if (!sd_name) {
    sd_name = [[sd_infos objectForKey:kSdtplDisplayName] retain];
    if (!sd_name) sd_name = [[[sd_path lastPathComponent] stringByDeletingPathExtension] retain];
  }
  return sd_name;
}

- (NSString *)extension {
  id ext = [sd_infos objectForKey:kSdtplRequireFileType];
  if (!ext) {
    ext = [[[sd_tpls objectForKey:SdtplDefinitionDictionaryKey] objectForKey:SdtplDefinitionFileKey] pathExtension];
    [sd_infos setObject:(ext ? : @"") forKey:kSdtplRequireFileType];
  }
  return ext;
}

- (NSString *)menuName {
  return [NSString stringWithFormat:@"%@ (%@)", [self displayName], [self extension]];
}

- (NSDictionary *)formats {
  return [sd_infos objectForKey:kSdtplTemplateStrings];
}

- (NSDictionary *)templates {
  return sd_tpls;
}

- (NSDictionary *)definition {
  return sd_def;
}

#pragma mark -
- (void)notifyChange {
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefTemplateDidChangeNotification object:self];
}

- (NSArray *)styles {
  return sd_styles;
}

- (NSDictionary *)selectedStyle {
  return sd_selectedStyle;
}
- (void)setSelectedStyle:(NSDictionary *)style {
  if (style != sd_selectedStyle) {
    sd_selectedStyle = style;
    [self notifyChange];
  }
}

#pragma mark -
- (BOOL)isHtml {
  return tp_flags.html;
}

- (unsigned)toc {
  return tp_flags.toc;
}

- (BOOL)indexToc {
  return (tp_flags.toc & kSdefTemplateTOCIndex) != 0;
}
- (BOOL)dictionaryToc {
  return (tp_flags.toc & kSdefTemplateTOCDictionary) != 0;
}
- (BOOL)externalToc {
  return (tp_flags.toc & kSdefTemplateTOCExternal) != 0;
}
- (BOOL)requiredToc {
  return (tp_flags.toc & kSdefTemplateTOCRequired) != 0;
}

- (void)setToc:(unsigned)toc {
//  if (toc != tp_flags.toc) {
    tp_flags.toc = toc;
//    [self notifyChange];
//  }
}

- (unsigned)css {
  return tp_flags.css;
}
/* Don't notify css change. */
- (void)setCss:(unsigned)css {
  tp_flags.css = css;
}

@end

#pragma mark -
#pragma mark Private Functions Implementations
static NSArray *SdefTemplatePaths() {
  NSString *appPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Templates"];
  NSString *userPath = [SKFindFolder(kApplicationSupportFolderType, kUserDomain) stringByAppendingPathComponent:kSdefTemplateFolder];
  NSString *locPath = [SKFindFolder(kApplicationSupportFolderType, kLocalDomain) stringByAppendingPathComponent:kSdefTemplateFolder];
  NSString *netPath = [SKFindFolder(kApplicationSupportFolderType, kNetworkDomain) stringByAppendingPathComponent:kSdefTemplateFolder];
  return [NSArray arrayWithObjects:userPath, locPath, netPath, appPath, nil]; // order: User, Library, Network and Built-in
}

static NSDictionary *SdefTemplatesAtPath(NSString *path) {
  NSString *name;
  id templates = [NSMutableDictionary dictionary];
  NSEnumerator *e = [[[NSFileManager defaultManager] directoryContentsAtPath:path] objectEnumerator];
  while (name = [e nextObject]) {
    if ([[name pathExtension] isEqualToString:kSdefTemplateExtension]) {
      id tpl = nil;
      @try {
        tpl = [[SdefTemplate alloc] initWithPath:[path stringByAppendingPathComponent:name]];
        [templates setObject:tpl forKey:[tpl displayName]];
      } @catch (id exception) {
        SKCLogException(exception);
      }
      [tpl release];
    }
  }
  return templates;
}
