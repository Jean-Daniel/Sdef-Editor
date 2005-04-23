//
//  SdefTemplateCheck.m
//  SdefTemplateChecker
//
//  Created by Grayfox on 09/04/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefTemplateCheck.h"
#import "SKTemplateParser.h"
#import "SdefTemplate.h"
#import "SKTemplate.h"

@interface _SdtplBlockDefinition : NSObject {
  NSMutableArray *blocks;
  NSMutableArray *variables;
}

- (id)initWithDefinition:(NSArray *)anArray;

- (BOOL)containsBlock:(NSString *)aBlock;
- (NSArray *)variables;
- (void)addVariables:(NSArray *)variables;
- (BOOL)containsVariable:(NSString *)aVariable;

@end

@implementation SdefTemplateCheck

static const id SdefInfosKeys[] = {
  @"Version", @"DisplayName", 
  @"TemplateFormat", @"RequireFileType",
  @"HTMLStyleSheets", @"TemplateStrings", @"Description", nil};
static const unsigned SdefInfosKeysCount = 7;
static const unsigned SdefInfosRequiredKeysCount = 2;

static const id SdefDefinitionKeys[] = {
  @"Dictionary", @"Index", @"Toc",
  @"Suites", @"Classes", @"Commands", @"Events", nil };
static const unsigned SdefDefinitionKeysCount = 7;
static const unsigned SdefDefinitionRequiredKeysCount = 1;

- (id)initWithFile:(NSString *)path {
  if (self = [super init]) {
    [self setPath:path];
    sd_errors = [[NSMutableDictionary alloc] initWithCapacity:2];
    [sd_errors setObject:[NSMutableArray array] forKey:@"Errors"];
    [sd_errors setObject:[NSMutableArray array] forKey:@"Warnings"];
  }
  return self;
}

- (void)dealloc {
  [sd_tpl release];
  [sd_path release];
  [sd_errors release];
  [super dealloc];
}

- (SdefTemplate *)template {
  return sd_tpl;
}

- (NSMutableDictionary *)errors {
  return sd_errors;
}

- (void)addError:(NSString *)format, ... {
  va_list args;
  if (format != nil) {
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    if (str) {
      [[sd_errors objectForKey:@"Errors"] addObject:str];
      [str release];
    }
  }
}

- (void)addWarning:(NSString *)format, ... {
  va_list args;
  if (format != nil) {
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    if (str) {
      [[sd_errors objectForKey:@"Warnings"] addObject:str];
      [str release];
    }
  }
}

- (NSDictionary *)definitions {
  if (!sd_definitions) {
    sd_definitions = [[NSMutableDictionary alloc] init];
    NSBundle *bundle = [NSBundle mainBundle];
    NSArray *defs = [bundle pathsForResourcesOfType:@"plist" inDirectory:@"Definitions"];
    unsigned idx;
    for (idx=0; idx<[defs count]; idx++) {
      NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[defs objectAtIndex:idx]];
      NSString *key;
      NSEnumerator *keys = [dict keyEnumerator];
      while (key = [keys nextObject]) {
        id def = [[_SdtplBlockDefinition alloc] initWithDefinition:[dict objectForKey:key]];
        if ([key isEqualToString:@"Verb"]) {
          [sd_definitions setObject:def forKey:@"Command"];
          [sd_definitions setObject:def forKey:@"Event"];
        } else if ([key isEqualToString:@"Parameter"]) {
          [sd_definitions setObject:def forKey:@"Required-Parameter"];
          [sd_definitions setObject:def forKey:@"Optional-Parameter"];
        } else {
          [sd_definitions setObject:def forKey:key];
        }
        [def release];
      }
      [dict release];
    }
  }
  return sd_definitions;
}

- (NSString *)path {
  return sd_path;
}
- (void)setPath:(NSString *)path {
  if (sd_path != path) {
    [sd_path release];
    sd_path = [path copy];
  }
}

#pragma mark -
#pragma mark Checking
- (BOOL)checkInfos:(id)plist {
  BOOL result = YES;
  if (![plist isKindOfClass:[NSDictionary class]]) {
    [self addError:@"Info.plist must be a Dictionary!"];
    return NO;
  }
  NSArray *stdKeys = [[NSArray alloc] initWithObjects:(id *)SdefInfosKeys count:SdefInfosKeysCount];
  /* Check unused keys */
  NSEnumerator *keys = [plist keyEnumerator];
  NSString *key;
  while (key = [keys nextObject]) {
    if (![stdKeys containsObject:key]) {
      [self addWarning:@"Info.plist: Unknown key \"%@\"", key];
    }
  }
  [stdKeys release];
  stdKeys = nil;
  /* Check Required keys */
  unsigned idx;
  for (idx=0; idx < SdefInfosRequiredKeysCount; idx++) {
    NSString *required = SdefInfosKeys[idx];
    if (![plist objectForKey:required]) {
      [self addError:@"Info.plist: Missing required Key \"%@\"", required];
      result = NO;
    }
  }
  /* Check values types */
  id value = [plist objectForKey:@"TemplateStrings"];
  if (value && ![value isKindOfClass:[NSDictionary class]]) {
    [self addError:@"TemplateStrings must be a Dictionary"];
    result = NO;
  } else {
    /* Check composed Keys & number of %@ in predefined formats */
    
  }
  
  value = [plist objectForKey:@"HTMLStyleSheets"];
  if (value && ![value isKindOfClass:[NSDictionary class]]) {
    [self addError:@"HTMLStyleSheets must be a Dictionary"];
    result = NO;
  }
  /* Check Template Format */
  value = [plist objectForKey:@"TemplateFormat"];
  if (value && ([value caseInsensitiveCompare:@"html"] != NSOrderedSame)) {
    [self addWarning:@"Unknown Template Format (%@): Should be HTML", value];
    if ([plist objectForKey:@"HTMLStyleSheets"]) {
      [self addWarning:@"HTMLStyleSheets defined but format isn't HTML."];
    }
  }
  /* Check Version */
  int version = [[plist objectForKey:@"Version"] intValue];
  if (version != 1) {
    [self addError:@"Info.plist: %i is an invalid Version (Must be 1)", version];
    result = NO;
  }
  
  return result;
}

- (BOOL)checkTemplatesFiles:(NSDictionary *)plist {
  BOOL result = YES;
  SKTemplateParser *parser = [[SKTemplateParser alloc] init];
  [parser setDelegate:self];
  NSEnumerator *enume = [plist keyEnumerator];
  NSString *key;
  while (key = [enume nextObject]) {
    id item = [plist objectForKey:key];
    NSString *file = [item objectForKey:@"File"];
    file = [sd_path stringByAppendingPathComponent:file];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
      [self addError:@"%@ Template File \"%@\" not found", key, [item objectForKey:@"File"]];
      result = NO;
    } else {
      [parser setFile:file];
      @try {
        [parser parse];
      } @catch (NSException *exception) {
        [self addError:@"Exception occured when parsing file %@: %@", [item objectForKey:@"File"], exception];
      }
    }
  }
  [parser release];
  return result;
}

- (BOOL)checkDefinition:(id)plist {
  BOOL result = YES;
  if (![plist isKindOfClass:[NSDictionary class]]) {
    [self addError:@"Definition.plist must be a Dictionary!"];
    return NO;
  }
  /* Check undefined keys */
  NSArray *stdKeys = [[NSArray alloc] initWithObjects:(id *)SdefDefinitionKeys count:SdefDefinitionKeysCount];
  NSEnumerator *keys = [plist keyEnumerator];
  NSString *key;
  while (key = [keys nextObject]) {
    if (![stdKeys containsObject:key]) {
      [self addWarning:@"Definition.plist: Unknown key \"%@\"", key];
    }
  }
  [stdKeys release];
  stdKeys = nil;
  /* Check Required keys */
  unsigned idx;
  for (idx=0; idx < SdefDefinitionRequiredKeysCount; idx++) {
    NSString *required = SdefDefinitionKeys[idx];
    if (![plist objectForKey:required]) {
      [self addError:@"Definition.plist: Missing required key \"%@\"", required];
      result = NO;
    }
  }
  /* Check value type and contents */
  keys = [plist keyEnumerator];
  while (key = [keys nextObject]) {
    id item = [plist objectForKey:key];
    if ([item isKindOfClass:[NSDictionary class]]) {
      if (![(NSString *)[item objectForKey:@"File"] length]) {
        [self addError:@"Definition.plist: Required key \"File\" missing in %@", key];
        result = NO;
      }
    } else {
      [self addError:@"Definition.plist: \"%@\" key must be a Dictionary", key];
      result = NO;
    }
  }
  
  if (result) {
    /* Check Single File in Dictionary */
    id value = [plist objectForKey:@"Dictionary"];
    if ([[value objectForKey:@"SingleFile"] boolValue]) {
      [self addWarning:@"SingleFile defined in \"Dictionary\" but has no effect"];
    }
    value = [plist objectForKey:@"Index"];
    if (value && [[value objectForKey:@"SingleFile"] boolValue]) {
      [self addWarning:@"SingleFile defined in \"Index\" but has no effect"];
    }
  }
  
  if (result) {
    result = [self checkTemplatesFiles:plist];
  }
  
  return result;
}

- (BOOL)checkTemplate {
  BOOL result = YES;
  [sd_tpl release];
  sd_tpl = nil;
  
  NSAssert(sd_path, @"Template path is nil!");
  NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithPath:sd_path];
  if (![wrapper isDirectory]) {
    [self addError:@"%@ isn't a directory", [sd_path lastPathComponent]];
    [wrapper release];
    return NO;
  }
  
  id plist = nil;
  NSString *error = nil;
  if (![[wrapper fileWrappers] objectForKey:@"Info.plist"]) {
    [self addError:@"Info.plist not found in Template"];
    result = NO;
  } else {
    /* Parse Info.plist */
    NSData *fileData = [[[wrapper fileWrappers] objectForKey:@"Info.plist"] regularFileContents];
    if (fileData) {
      plist = [NSPropertyListSerialization propertyListFromData:fileData
                                               mutabilityOption:NSPropertyListMutableContainers
                                                         format:nil
                                               errorDescription:&error];
    }
    if (!plist || error) {
      [self addError:@"Invalid Info.plist file: %@", error ? : @"Undefined error"];
      [error release];
      error = nil;
      result = NO;
    } else {
      result = [self checkInfos:plist] && result;
    }
  }
  
  if (![[wrapper fileWrappers] objectForKey:@"Definition.plist"]) {
    [self addError:@"Definition.plist not found in Template"];
    result = NO;
  } else {
    /* Parse Definition.plist */
    NSData *fileData = [[[wrapper fileWrappers] objectForKey:@"Definition.plist"] regularFileContents];
    if (fileData) {
      plist = [NSPropertyListSerialization propertyListFromData:fileData
                                               mutabilityOption:NSPropertyListMutableContainers
                                                         format:nil
                                               errorDescription:&error];
    }
    if (!plist || error) {
      [self addError:@"Invalid Definition.plist file: %@", error ? : @"Undefined error"];
      [error release];
      error = nil;
      result = NO;
    } else {
      result = [self checkDefinition:plist] && result;
    }
  }
  
  if (result) {
    sd_tpl = [[SdefTemplate alloc] initWithPath:sd_path];
  }
  return result;
}

- (void)checkTemplateBlock:(SKTemplate *)block withName:(NSString *)name {
  if (!block)
    return;
  
  NSString *file = [[[block findRoot] name] lastPathComponent];
  id blockDef = [[self definitions] objectForKey:name];
  if (!blockDef) {
    [self addError:@"%@: Undefined Block \"%@\"", file, name];
    return;
  }
  unsigned idx;
  NSArray *vars = [block allKeys];
  for (idx=0; idx<[vars count]; idx++) {
    NSString *var = [vars objectAtIndex:idx];
    if (![blockDef containsVariable:var]) {
      /* If is not Root */
      if ([block parent] || ![[[self definitions] objectForKey:@"Root"] containsVariable:var]) {
        [self addError:@"%@: Undefined Variable \"%@\" in Block \"%@\"", file, var, name];
      }
    }
  }
  NSArray *blocks = [block allBlocks];
  for (idx=0; idx<[blocks count]; idx++) {
    SKTemplate *childBlock = [blocks objectAtIndex:idx];
    if (![blockDef containsBlock:[childBlock name]] &&
        ([block parent] || ![[[self definitions] objectForKey:@"Root"] containsBlock:[childBlock name]])) {
      [self addError:@"%@: Undefined Block \"%@\" in Block \"%@\"", file, [childBlock name], name];
    } else {
      [self checkTemplateBlock:childBlock withName:[childBlock name]];
    }
  }
}

- (BOOL)checkTemplateContent {
  NSAssert(sd_tpl, @"Template is nil!");
  BOOL result = YES;
  id defs = [sd_tpl definition];
  id templates = [sd_tpl templates];
  
  /* Dictionary blocks */
  NSString *tplFile = [[defs objectForKey:@"Dictionary"] objectForKey:@"File"];
  SKTemplate *dict = [templates objectForKey:@"Dictionary"];
  if (![dict blockWithName:@"Suite"]) {
    [self addError:@"\"Dictionary\" Template file \"%@\" must declare a \"Suite\" block.", tplFile];
    result = NO;
  }
  [self checkTemplateBlock:dict withName:@"Dictionary"];
  
  /* Suite Single File */
  NSDictionary *item;
  if (item = [defs objectForKey:@"Suites"]) {
    SKTemplate *tpl = [templates objectForKey:@"Suites"];
    if ([[item objectForKey:@"SingleFile"] boolValue]) {
      if (![tpl blockWithName:@"Suite"]) {
        [self addError:@"\"SingleFile\" declared in \"Suites\" Definition but no block \"Suite\" found in %@", [item objectForKey:@"File"]];
        result = NO;
      } else {
        [self checkTemplateBlock:tpl withName:@"Suites"];
      }
    } else {
      [self checkTemplateBlock:tpl withName:@"Suite"];
    }
  }
  
  /* Class Single File */
  if (item = [defs objectForKey:@"Classes"]) {
    SKTemplate *tpl = [templates objectForKey:@"Classes"];
    if ([[item objectForKey:@"SingleFile"] boolValue]) {
      if (![tpl blockWithName:@"Class"]) {
        [self addError:@"\"SingleFile\" declared in \"Classes\" Definition but no block \"Class\" found in %@", [item objectForKey:@"File"]];
        result = NO;
      } else {
        [self checkTemplateBlock:tpl withName:@"Classes"];
      }
    } else {
      [self checkTemplateBlock:tpl withName:@"Class"];
    }
  }
  
  /* Command Single File */
  if (item = [defs objectForKey:@"Commands"]) {
    SKTemplate *tpl = [templates objectForKey:@"Commands"];
    if ([[item objectForKey:@"SingleFile"] boolValue]) {
      if (![tpl blockWithName:@"Command"]) {
        [self addError:@"\"SingleFile\" declared in \"Commands\" Definition but no block \"Command\" found in %@", [item objectForKey:@"File"]];
        result = NO;
      } else {
        [self checkTemplateBlock:tpl withName:@"Commands"];
      }
    } else {
      [self checkTemplateBlock:tpl withName:@"Command"];
    }
  }
  
  /* Event Single File */
  if (item = [defs objectForKey:@"Events"]) {
    SKTemplate *tpl = [templates objectForKey:@"Events"];
    if ([[item objectForKey:@"SingleFile"] boolValue]) {
      if (![tpl blockWithName:@"Event"]) {
        [self addError:@"\"SingleFile\" declared in \"Events\" Definition but no block \"Event\" found in %@", [item objectForKey:@"File"]];
        result = NO;
      } else {
        [self checkTemplateBlock:tpl withName:@"Events"];
      }
    } else {
      [self checkTemplateBlock:tpl withName:@"Event"];
    }
  }
  
  /* Check Toc and Index */
  if (item = [defs objectForKey:@"Toc"]) {
    SKTemplate *tpl = [templates objectForKey:@"Toc"];
    [self checkTemplateBlock:tpl withName:@"Toc"];
  }
  if (item = [defs objectForKey:@"Index"]) {
    SKTemplate *tpl = [templates objectForKey:@"Index"];
    [self checkTemplateBlock:tpl withName:@"Index"];
  }
  
  return result;
}

#pragma mark -
#pragma mark Template Parser Delegate

- (void)templateParser:(SKTemplateParser *)parser warningOccured:(NSString *)warning {
  id file = [[parser file] lastPathComponent];
  [self addWarning:@"Warning occured when parsing file %@: %@", file, warning];
}

/* Check templates contents */

@end

@implementation _SdtplBlockDefinition

- (id)initWithDefinition:(NSArray *)anArray {
  if (self = [super init]) {
    blocks = [[NSMutableArray alloc] init];
    variables = [[NSMutableArray alloc] init];
    if ([anArray count]) {
      id last = [anArray lastObject];
      unsigned idx;
      unsigned lastIdx = [anArray count];
      /* Blocks */
      if ([last isKindOfClass:[NSArray class]]) {
        for (idx=0; idx<[last count]; idx++) {
          [blocks addObject:[last objectAtIndex:idx]];
        }
        lastIdx--;
      }
      /* Variables */
      for (idx=0; idx<lastIdx; idx++) {
        [variables addObject:[anArray objectAtIndex:idx]];
      }
    }
  }
  return self;
}

- (void)dealloc {
  [blocks release];
  [variables release];
  [super dealloc];
}

- (BOOL)containsBlock:(NSString *)aBlock {
  return [blocks containsObject:aBlock];
}

- (NSArray *)variables {
  return variables;
}

- (void)addVariables:(NSArray *)someVariables {
  [variables addObjectsFromArray:someVariables];
}

- (BOOL)containsVariable:(NSString *)aVariable {
  return [variables containsObject:aVariable];
}

@end
