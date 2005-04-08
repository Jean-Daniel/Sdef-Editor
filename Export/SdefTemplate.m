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
static NSString * const kSdtplDisplayName = @"DisplayName"; /* NSString */
static NSString * const kSdtplTemplateFormat = @"TemplateFormat"; /* NSString */
static NSString * const kSdtplRequireFileType = @"RequireFileType"; /* NSString */
static NSString * const kSdtplRemoveBlockLine = @"RemoveBlockLines"; /* Boolean */
static NSString * const kSdtplTemplateStrings = @"TemplateStrings"; /* NSArray */

static NSString * const kSdtplStyleSheets = @"HTMLStyleSheets"; /* NSDictionary */

static NSString * const kSdtplTocDefinition = @"Toc";
static NSString * const kSdtplDictionaryDefinition = @"Dictionary";

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
    [NSException raise:NSInvalidArgumentException format:@"%@ isn not a valid template file.", sd_path];
    return;
  }
  [sd_infos retain];
  
  /* Set format */
  if ([sd_infos objectForKey:kSdtplTemplateFormat]) {
    tp_flags.html = [[sd_infos objectForKey:kSdtplTemplateFormat] caseInsensitiveCompare:@"html"] == 0;
  }
  
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
  
  if (!sd_def || ![sd_def objectForKey:kSdtplDictionaryDefinition]) {
    [NSException raise:@"SdefInvalidTemplateException" format:@"%@ does not contains a \"DictionaryTemplate\" file.", [sd_path lastPathComponent]];
    return;
  } else {
    [sd_def retain];
    Class tplClass = tp_flags.html ? [SKXMLTemplate class] : [SKTemplate class];
    sd_tpls = [[NSMutableDictionary alloc] initWithCapacity:[sd_def count]];
    id keys = [sd_def keyEnumerator];
    NSString *key;
    while (key = [keys nextObject]) {
      NSDictionary *tplDef = [sd_def objectForKey:key];
      SKTemplate *tpl = [[tplClass alloc] initWithContentsOfFile:
        [sd_path stringByAppendingPathComponent:[tplDef objectForKey:@"File"]]];
      [tpl setRemoveBlockLine:[[tplDef objectForKey:kSdtplRemoveBlockLine] boolValue]];
      [sd_tpls setObject:tpl forKey:key];
      [tpl release];
//      SKTimeUnit start, end;
//      SKTimeStart(&start);
//      [tpl load];
//      SKTimeEnd(&end);
//      DLog(@"%@ loaded in %u ms", key, SKTimeDeltaMillis(&start, &end));
    }
  }
  
  id toc = [sd_tpls objectForKey:kSdtplTocDefinition];
  tp_flags.toc = (toc != nil) ? kSdefTemplateTOCExternal : kSdefTemplateTOCNone;
  if ([[sd_tpls objectForKey:kSdtplDictionaryDefinition] blockWithName:@"Table_Of_Content"]) {
    tp_flags.toc |= kSdefTemplateTOCInline;  
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
    ext = [[[sd_tpls objectForKey:kSdtplDictionaryDefinition] objectForKey:@"File"] pathExtension];
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
- (BOOL)isHtml {
  return tp_flags.html;
}

- (unsigned)toc {
  return tp_flags.toc;
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
