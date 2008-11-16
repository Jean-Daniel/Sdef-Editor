/*
 *  SdefTemplate.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefTemplate.h"

#import WBHEADER(WBFSFunctions.h)

#import WBHEADER(WBTemplate.h)
#import WBHEADER(WBXMLTemplate.h)

extern NSString *const SdtplBlockTableOfContent;

/* Specials Keys */
NSString * const StdplVariableLinks = @"Links";
NSString * const StdplVariableStyleLink = @"Style-Link";
NSString * const StdplVariableAnchorFormat = @"AnchorFormat";

/* Misc */
NSString * const SdefInvalidTemplateException = @"SdefInvalidTemplate";

static NSString * const kSdefTemplateExtension = @"sdtpl";
static NSString * const kSdefTemplateFolder = @"Sdef Editor/Templates/";

static NSArray *SdefTemplatePaths(void);
static NSDictionary *SdefTemplatesAtPath(NSString *path);

static NSString * const kSdtplVersion = @"Version"; /* Number */
static NSString * const kSdtplDisplayName = @"DisplayName"; /* NSString */
static NSString * const kSdtplDescriptionFile = @"Description";
static NSString * const kSdtplStyleSheets = @"HTMLStyleSheets"; /* NSDictionary */
static NSString * const kSdtplTemplateFormat = @"TemplateFormat"; /* NSString */
static NSString * const kSdtplRequireFileType = @"RequireFileType"; /* NSString */
static NSString * const kSdtplTemplateStrings = @"TemplateStrings"; /* NSArray */

/* Definition Keys */
NSString * const SdtplDefinitionFileKey = @"File";
NSString * const SdtplDefinitionFileEncoding = @"Encoding"; /* NSString */
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
  NSArray *paths = SdefTemplatePaths();
  NSUInteger idx = [paths count];
  /* Add entries will replace existing entries, so use a reverse enumerator */
  NSMutableDictionary *templates = [[NSMutableDictionary alloc] init];
  while (idx-- > 0) {
    NSString *path = [paths objectAtIndex:idx];
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
  [sd_information release];
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
  [sd_information release];
  sd_information = nil;
  sd_selectedStyle = nil;
  bzero(&sd_tpFlags, sizeof(sd_tpFlags));
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
    sd_tpFlags.html = [[sd_infos objectForKey:kSdtplTemplateFormat] caseInsensitiveCompare:@"html"] == 0;
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
  if (sd_tpFlags.html && [styles count]) {
    sd_tpFlags.css = kSdefTemplateCSSInline | kSdefTemplateCSSExternal;
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
    sd_tpFlags.css = kSdefTemplateCSSNone;
  }
}

- (void)loadDefinition:(NSFileWrapper *)aFileWrapper {
  NSData *fileData = [[[aFileWrapper fileWrappers] objectForKey:@"Definition.plist"] regularFileContents];
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
    Class tplClass = sd_tpFlags.html ? [WBXMLTemplate class] : [WBTemplate class];
    sd_tpls = [[NSMutableDictionary alloc] initWithCapacity:[sd_def count]];
    NSString *key;
    id keys = [sd_def keyEnumerator];
    while (key = [keys nextObject]) {
      NSDictionary *tplDef = [sd_def objectForKey:key];
      /* Get encoding */
      NSString *encoding = [tplDef objectForKey:SdtplDefinitionFileEncoding];
      CFStringEncoding cfe = encoding ? CFStringConvertIANACharSetNameToEncoding((CFStringRef)encoding) : kCFStringEncodingInvalidId;
      /* If undefined or invalid, use utf-8 for html templates and system encoding for other templates */
      NSStringEncoding ste = (cfe != kCFStringEncodingInvalidId) ? CFStringConvertEncodingToNSStringEncoding(cfe) :
        (sd_tpFlags.html ? NSUTF8StringEncoding : [NSString defaultCStringEncoding]);
      
      WBTemplate *tpl = [[tplClass alloc] initWithContentsOfFile:
        [sd_path stringByAppendingPathComponent:[tplDef objectForKey:SdtplDefinitionFileKey]] encoding:ste];
      [tpl setRemoveBlockLine:[[tplDef objectForKey:SdtplDefinitionRemoveBlockLine] boolValue]];
      [sd_tpls setObject:tpl forKey:key];
      [tpl release];
    }
  }
  
  sd_tpFlags.toc = kSdefTemplateTOCNone;
  NSDictionary *toc = [sd_def objectForKey:SdtplDefinitionTocKey];
  if (toc) {
    sd_tpFlags.toc |= kSdefTemplateTOCExternal;
    if ([[toc objectForKey:@"Required"] boolValue])
      sd_tpFlags.toc |= kSdefTemplateTOCRequired;
  }
  if ([[sd_tpls objectForKey:SdtplDefinitionDictionaryKey] blockWithName:SdtplBlockTableOfContent]) {
    sd_tpFlags.toc |= kSdefTemplateTOCDictionary;  
  }
  if ([[sd_tpls objectForKey:SdtplDefinitionIndexKey] blockWithName:SdtplBlockTableOfContent]) {
    sd_tpFlags.toc |= kSdefTemplateTOCIndex;  
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
- (NSString *)information {
  if (!sd_information) {
    NSString *file = [sd_infos objectForKey:kSdtplDescriptionFile];
    sd_information = file ? [[sd_path stringByAppendingPathComponent:file] copy]: nil;
  }
  return sd_information;
}

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
- (NSArray *)styles {
  return sd_styles;
}

- (NSDictionary *)selectedStyle {
  return sd_selectedStyle;
}
- (void)setSelectedStyle:(NSDictionary *)style {
  sd_selectedStyle = style;
}

#pragma mark -
- (BOOL)isHtml {
  return sd_tpFlags.html;
}

- (unsigned)toc {
  return sd_tpFlags.toc;
}

- (BOOL)indexToc {
  return (sd_tpFlags.toc & kSdefTemplateTOCIndex) != 0;
}
- (BOOL)dictionaryToc {
  return (sd_tpFlags.toc & kSdefTemplateTOCDictionary) != 0;
}
- (BOOL)externalToc {
  return (sd_tpFlags.toc & kSdefTemplateTOCExternal) != 0;
}
- (BOOL)requiredToc {
  return (sd_tpFlags.toc & kSdefTemplateTOCRequired) != 0;
}

- (void)setToc:(unsigned)toc {
  sd_tpFlags.toc = toc;
}

- (unsigned)css {
  return sd_tpFlags.css;
}
/* Don't notify css change. */
- (void)setCss:(unsigned)css {
  sd_tpFlags.css = css;
}

@end

#pragma mark -
#pragma mark Private Functions Implementations
static NSArray *SdefTemplatePaths(void) {
	NSMutableArray *paths = [NSMutableArray array];
  NSString *path = [WBFSFindFolder(kApplicationSupportFolderType, kUserDomain, NO) stringByAppendingPathComponent:kSdefTemplateFolder];
	if (path) [paths addObject:path];
	
	path = [WBFSFindFolder(kApplicationSupportFolderType, kLocalDomain, NO) stringByAppendingPathComponent:kSdefTemplateFolder];
	if (path) [paths addObject:path];
	
	path = [WBFSFindFolder(kApplicationSupportFolderType, kNetworkDomain, NO) stringByAppendingPathComponent:kSdefTemplateFolder];
	if (path) [paths addObject:path];
	
	path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Templates"];
	if (path) [paths addObject:path];
	
  return paths; // order: User, Library, Network and Built-in
}

static
NSDictionary *SdefTemplatesAtPath(NSString *path) {
  NSMutableDictionary *templates = [NSMutableDictionary dictionary];
  NSArray *names = [[NSFileManager defaultManager] directoryContentsAtPath:path];
  NSUInteger idx = [names count];
  while (idx-- > 0) {
    NSString *name = [names objectAtIndex:idx];
    if ([[name pathExtension] isEqualToString:kSdefTemplateExtension]) {
      SdefTemplate *tpl = nil;
      @try {
        tpl = [[SdefTemplate alloc] initWithPath:[path stringByAppendingPathComponent:name]];
        [templates setObject:tpl forKey:[tpl menuName]];
      } @catch (id exception) {
        WBCLogException(exception);
      }
      [tpl release];
    }
  }
  return templates;
}
