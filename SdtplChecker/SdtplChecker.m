//
//  SdtplChecker.m
//  SdefTemplateChecker
//
//  Created by Grayfox on 10/04/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdtplChecker.h"
#import "SKTemplate.h"
#import "SimpleNode.h"
#import "SdefTemplate.h"
#import "ShadowMacros.h"
#import "SdefTemplateCheck.h"

int main(int argc, const char **argv) {
  return NSApplicationMain(argc, argv);
}

static void SdtplAppendChildrenFromStructure(SimpleNode *aNode, NSArray *variables) {
  id var;
  NSEnumerator *vars = [variables objectEnumerator];
  while (var = [vars nextObject]) {
    SimpleNode *node = nil;
    if ([var isKindOfClass:[NSString class]]) {
      node = [[SimpleNode alloc] initWithName:var];
      [node setIcon:[NSImage imageNamed:@"Variable"]];
    } else {
      node = [[SimpleNode alloc] initWithName:[var objectForKey:@"name"]];
      [node setIcon:[NSImage imageNamed:@"Block"]];
      SdtplAppendChildrenFromStructure(node, [var objectForKey:@"content"]);
    }
    [aNode appendChild:node];
    [node release];
  }
}

static SimpleNode *SimpleTemplateTree(SKTemplate *tpl) {
  SimpleNode *root = [SimpleNode nodeWithName:[[tpl name] lastPathComponent]];
  [root setIcon:[NSImage imageNamed:@"Template"]];
  SdtplAppendChildrenFromStructure(root, [[tpl structure] objectForKey:@"content"]);
  return root;
}

@implementation SdtplChecker

+ (void)initialize {
  static BOOL tooLate = NO;
  if (!tooLate) {
    tooLate = YES;
    [NSValueTransformer setValueTransformer:[SdefBooleanTransformer transformer] forName:@"SdefBooleanTransformer"];
  }
}

- (void)dealloc {
  [checker release];
  [templates release];
  [super dealloc];
}

- (void)awakeFromNib {
  templates = [[NSMutableArray alloc] init];
}

- (IBAction)launchTest:(id)sender {
  if (checker) {
    BOOL ok = [checker checkTemplate];
    if (ok) {
      [checker checkTemplateContent];
    }
    [errors removeAllObjects];
    id item;
    id items = [[[checker errors] objectForKey:@"Errors"] objectEnumerator];
    NSImage *icon = [NSImage imageNamed:@"ErrorIcon"];
    while (item = [items nextObject]) {
      [errors addObject:[NSDictionary dictionaryWithObjectsAndKeys:
        item, @"message",
        icon, @"icon",
        nil]];
    }
    items = [[[checker errors] objectForKey:@"Warnings"] objectEnumerator];
    icon = [NSImage imageNamed:@"WarningIcon"];
    while (item = [items nextObject]) {
      [errors addObject:[NSDictionary dictionaryWithObjectsAndKeys:
        item, @"message",
        icon, @"icon",
        nil]];
    }
    if ([errors count] == 0) {
      NSRunAlertPanel(@"No problem detected!", @" Look like \"%@\" is valid.", @"OK", nil, nil, [[checker path] lastPathComponent]);
    } else {
      [warnings makeKeyAndOrderFront:sender];
    }
  }
}

- (void)setChecker:(SdefTemplateCheck *)aChecker {
  if (aChecker != checker) {
    [self willChangeValueForKey:@"template"];
    [checker release];
    checker = [aChecker retain];
    [templates removeAllObjects];
    if (checker) {
      [self launchTest:self];
      unsigned idx;
      id tpls = [[[checker template] templates] allValues];
      for (idx=0; idx<[tpls count]; idx++) {
        [templates addObject:SimpleTemplateTree([tpls objectAtIndex:idx])];
      }
      /* Init Infos */
      /* Styles, Tocs, isHTML, Definition + SingleFiles */
    }
    [self didChangeValueForKey:@"template"];
    [templatesTree reloadData];
  }
}

- (SdefTemplate *)template {
  return [checker template];
}

- (IBAction)open:(id)sender {
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setCanChooseDirectories:NO];
  [panel setAllowsMultipleSelection:NO];
  [panel setTreatsFilePackagesAsDirectories:NO];
  if (NSOKButton == [panel runModalForDirectory:nil file:nil types:[NSArray arrayWithObject:@"sdtpl"]]) {
    if ([[panel filenames] count] == 0) {
      return;
    }
    id file = [[panel filenames] objectAtIndex:0];
    id check = [[SdefTemplateCheck alloc] initWithFile:file];
    [self setChecker:check];
    [check release];
  }
}

#pragma mark -
#pragma mark Application Delegate
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
  BOOL isDir;
  if ([[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDir] && isDir) {
    id check = [[SdefTemplateCheck alloc] initWithFile:filename];
    [self setChecker:check];
    [check release];
    return YES;
  }
  return NO;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
  return YES;
}

#pragma mark OutlineView Delegate
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  if (item == nil) {
    return [templates count] > 0;
  } else {
    return [item hasChildren];
  }
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  if (item == nil) {
    return [templates count];
  } else {
    return [item childCount];
  }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
  if (nil == item) {
    return [templates objectAtIndex:index];
  } else {
    return [item childAtIndex:index];
  }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  if (nil == item) {
    return @"Root";
  } else {
    return [item name];
  }
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  [cell setImage:[item icon]];
}

@end

@implementation SdefBooleanTransformer

+ (id)transformer {
  return [[[self alloc] init] autorelease];
}

// information that can be used to analyze available transformer instances (especially used inside Interface Builder)
// class of the "output" objects, as returned by transformedValue:
+ (Class)transformedValueClass {
  return [NSNumber class];
}

// flag indicating whether transformation is read-only or not
+ (BOOL)allowsReverseTransformation {
  return YES;
}

/* Returns menu idx */
- (id)transformedValue:(id)value {
  return [NSImage imageNamed:[value boolValue] ? @"Enabled" : @"Disable"];
}

/* Returns access value */
- (id)reverseTransformedValue:(id)value {
  return SKBool([[value name] isEqualToString:@"Enabled"]);
}

@end
