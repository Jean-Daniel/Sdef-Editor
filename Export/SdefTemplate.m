//
//  SdefTemplate.m
//  Sdef Editor
//
//  Created by Grayfox on 28/03/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefTemplate.h"
#import "SKFSFunctions.h"
#import "SKTemplate.h"
#import "SKXMLTemplate.h"

NSString * const kSdefTemplateDidChangeNotification = @"SdefTemplateDidChange";

static NSString * const kSdefTemplateExtension = @"sdtpl";
static NSString * const kSdefTemplateFolder = @"Sdef Editor/Templates/";

static NSArray *SdefTemplatePaths();
static NSDictionary *SdefTemplatesAtPath(NSString *path);

static NSString * const kSdtplVersion = @"Version"; /* Number */
static NSString * const kSdtplPreviewFile = @"PreviewFile"; /* NSString */
static NSString * const kSdtplDisplayName = @"DisplayName"; /* NSString */
static NSString * const kSdtplTemplateFormat = @"TemplateFormat"; /* NSString */
static NSString * const kSdtplRequireFileType = @"RequireFileType"; /* NSString */
static NSString * const kSdtplRemoveBlockLine = @"RemoveBlockLine"; /* Boolean */
static NSString * const kSdtplTemplateStrings = @"TemplateStrings"; /* NSArray */

static NSString * const kSdtplTocTemplate = @"TocTemplate"; /* NSString */
static NSString * const kSdtplDictionaryTemplate = @"DictionaryTemplate"; /* NSString */

static NSString * const kSdtplInlineToc = @"InlineToc"; /* Boolean */
static NSString * const kSdtplSortEntries = @"SortEntries"; /* Boolean */
static NSString * const kSdtplStyleSheets = @"HTMLStyleSheets"; /* NSDictionary */
static NSString * const kSdtplCreateLinks = @"HTMLCreateLinks"; /* Boolean */
static NSString * const kSdtplInlineStyleSheet = @"HTMLInlineStyle"; /* Boolean */

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
  [sd_toc release];
  [sd_path release];
  [sd_name release];
  [sd_infos release];
  [sd_layout release];
  [sd_styles release];
  [super dealloc];
}

#pragma mark -
- (void)reset {
  [sd_toc release];
  sd_toc = nil;
  [sd_path release];
  sd_path = nil;
  [sd_name release];
  sd_name = nil;
  [sd_infos release];
  sd_infos = nil;
  [sd_styles release];
  sd_styles = nil;
  [sd_layout release];
  sd_layout = nil;
  sd_selectedStyle = nil;
  bzero(&tp_flags, sizeof(tp_flags));
}

- (NSString *)path {
  return sd_path;
}

- (void)setPath:(NSString *)path {
  [self reset];
  NSFileWrapper *template = [[NSFileWrapper alloc] initWithPath:path];
  if (template && [template isDirectory]) {
    NSData *fileData = [[[template fileWrappers] objectForKey:@"Info.plist"] regularFileContents];
    if (fileData) {
      sd_infos = [NSPropertyListSerialization propertyListFromData:fileData
                                                  mutabilityOption:NSPropertyListMutableContainers
                                                            format:nil
                                                  errorDescription:nil];
    }
  }
  [template release];
  if (!sd_infos) {
    [NSException raise:NSInvalidArgumentException format:@"%@ isn not a valid template file.", path];
    return;
  }
  if (![sd_infos objectForKey:kSdtplDictionaryTemplate]) {
    sd_infos = nil;
    [NSException raise:@"SdefInvalidTemplateException" format:@"%@ does not contains a \"DictionaryTemplate\" file.", [path lastPathComponent]];
    return;
  }
  [sd_infos retain];
  sd_path = [path copy];
  
  
  if ([sd_infos objectForKey:kSdtplTemplateFormat]) {
    tp_flags.html = [[sd_infos objectForKey:kSdtplTemplateFormat] caseInsensitiveCompare:@"html"] == 0;
  }
  tp_flags.sort = [[sd_infos objectForKey:kSdtplSortEntries] boolValue] ? 1 : 0;
  tp_flags.links = [[sd_infos objectForKey:kSdtplCreateLinks] boolValue] ? 1 : 0;
  tp_flags.removeBlockLine = [[sd_infos objectForKey:kSdtplRemoveBlockLine] boolValue] ? 1 : 0;
  
  if ([(NSString *)[sd_infos objectForKey:kSdtplTocTemplate] length]) {
    tp_flags.toc = [[sd_infos objectForKey:kSdtplInlineToc] boolValue] ? kSdefTemplateTOCInline : kSdefTemplateTOCExternal;
  }
  if (tp_flags.html && [[sd_infos objectForKey:kSdtplStyleSheets] count]) {
    tp_flags.css = [[sd_infos objectForKey:kSdtplInlineStyleSheet] boolValue] ? kSdefTemplateCSSInline : kSdefTemplateCSSNone;
    
    NSDictionary *styles = [sd_infos objectForKey:kSdtplStyleSheets];
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
  }
}

#pragma mark -
- (SKTemplate *)tocTemplate {
  id toc = [sd_infos objectForKey:kSdtplTocTemplate];
  if (!sd_toc && toc) {
    id tplClass = tp_flags.html ? [SKXMLTemplate class] : [SKTemplate class];
    sd_toc = [[tplClass alloc] initWithContentsOfFile:[sd_path stringByAppendingPathComponent:toc]];
    if (!sd_toc)
      [NSException raise:@"SdefInvalidTemplateException" format:@"Invalid TOC Template File"];
    [sd_toc setRemoveBlockLine:tp_flags.removeBlockLine];
  }
  return sd_toc;  
}
- (SKTemplate *)layoutTemplate {
  if (!sd_layout) {
    id tplClass = tp_flags.html ? [SKXMLTemplate class] : [SKTemplate class];
    sd_layout = [[tplClass alloc] initWithContentsOfFile:[sd_path stringByAppendingPathComponent:[sd_infos objectForKey:kSdtplDictionaryTemplate]]];
    if (!sd_layout)
      [NSException raise:@"SdefInvalidTemplateException" format:@"Invalid Layout Template File"];
    [sd_layout setRemoveBlockLine:tp_flags.removeBlockLine];
  }
  return sd_layout;
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
    ext = [[sd_infos objectForKey:kSdtplDictionaryTemplate] pathExtension];
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

#pragma mark -
- (void)notifyChange {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SdefTemplateDidChange" object:self];
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
- (BOOL)html {
  return tp_flags.html;
}

- (unsigned)toc {
  return tp_flags.toc;
}
- (void)setToc:(unsigned)toc {
  if (toc != tp_flags.toc) {
    tp_flags.toc = toc;
    [self notifyChange];
  }
}

- (unsigned)css {
  return tp_flags.css;
}
/* Don't notify css change. */
- (void)setCss:(unsigned)css {
  tp_flags.css = css;
}

- (BOOL)sort {
  return tp_flags.sort;
}
- (void)setSort:(BOOL)flag {
  flag = flag ? 1 : 0;
  if (tp_flags.sort != flag) {
    tp_flags.sort = flag;
    [self notifyChange];
  }
}

- (BOOL)links {
  return tp_flags.links;
}
- (void)setLinks:(BOOL)flag {
  flag = flag ? 1 : 0;
  if (tp_flags.links != flag) {
    tp_flags.links = flag;
    [self notifyChange];
  }
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
        [templates setObject:tpl forKey:name];
      } @catch (id exception) {
        SKCLogException(exception);
      }
      [tpl release];
    }
  }
  return templates;
}
