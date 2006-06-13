/*
 *  SdefSymbolBrowser.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefSymbolBrowser.h"
#import <ShadowKit/SKExtensions.h>
#import <ShadowKit/SKTableDataSource.h>
#import <ShadowKit/SKAppKitExtensions.h>

#import "SdefWindowController.h"
#import "SdefDictionary.h"
#import "SdefDocument.h"
#import "SdefObjects.h"
#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefVerb.h"

static BOOL SdefSearchFilter(NSString *search, SdefObject *object, void *ctxt);

@interface SearchFieldToolbarItem : NSToolbarItem {
}
@end

#pragma mark -
@implementation SdefSymbolBrowser

- (id)init {
  if (self = [super initWithWindowNibName:@"SdefSymbolBrowser"]) {
    /* WARNING: do not handle multiple nodes notifications */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAppendChild:)
                                                 name:SKUITreeNodeDidInsertChildNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveChild:)
                                                 name:SKUITreeNodeWillRemoveChildNotification
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  ShadowTrace();
  [searchField setTarget:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
  return [displayName stringByAppendingString:@" - Symbol Browser"];
}

- (void)setDocumentEdited:(BOOL)flag {
  /* Do nothing */
}

- (void)awakeFromNib {
  [self createToolbar];
  [self loadSymbols];
  id menu = [[NSMenu alloc] initWithTitle:@"Search Menu"];
  
  /* Search Menu Categories */
  id item = [[NSMenuItem alloc] initWithTitle:@"All Fields"
                                       action:@selector(limitSearch:)
                                keyEquivalent:@""];
  [item setRepresentedObject:SKUInt(kSdefSearchAll)];
  [menu addItem:item];
  [item release];
  item = [[NSMenuItem alloc] initWithTitle:@"Symbol"
                                    action:@selector(limitSearch:)
                             keyEquivalent:@""];
  [item setRepresentedObject:SKUInt(kSdefSearchSymbol)];
  [menu addItem:item];
  [item release];
  item = [[NSMenuItem alloc] initWithTitle:@"Symbol Type"
                                    action:@selector(limitSearch:)
                             keyEquivalent:@""];
  [item setRepresentedObject:SKUInt(kSdefSearchSymbolType)];
  [menu addItem:item];
  [item release];
  item = [[NSMenuItem alloc] initWithTitle:@"Code"
                                    action:@selector(limitSearch:)
                             keyEquivalent:@""];
  [item setRepresentedObject:SKUInt(kSdefSearchCode)];
  [menu addItem:item];
  [item release];
  item = [[NSMenuItem alloc] initWithTitle:@"Suite"
                                    action:@selector(limitSearch:)
                             keyEquivalent:@""];
  [item setRepresentedObject:SKUInt(kSdefSearchSuite)];
  [menu addItem:item];
  [item release];
  
  /* Search Menu Template */
  [menu addItem:[NSMenuItem separatorItem]];
  item = [[NSMenuItem alloc] initWithTitle:@"Recent Searches"
                                    action:NULL
                             keyEquivalent:@""];
  [item setTag:NSSearchFieldRecentsTitleMenuItemTag];
  [menu addItem:item];
  [item release];
  item = [[NSMenuItem alloc] initWithTitle:@"Recents"
                                     action:NULL
                              keyEquivalent:@""];
  [item setTag:NSSearchFieldRecentsMenuItemTag];
  [menu addItem:item];
  [item release];
  [menu addItem:[NSMenuItem separatorItem]];
  item = [[NSMenuItem alloc] initWithTitle:@"Clear"
                                     action:NULL
                              keyEquivalent:@""];
  [item setTag:NSSearchFieldClearRecentsMenuItemTag];
  [menu addItem:item];
  [item release];
  
  [[searchField cell] setSearchMenuTemplate:menu];
  [self limitSearch:[menu itemAtIndex:0]];
  [menu release];
  [symbols setFilterFunction:SdefSearchFilter context:&sd_filter];
  id search = [[[[self window] toolbar] items] objectAtIndex:2];
  [search setTarget:symbols];
  [search setAction:@selector(search:)];
  
  [symbolTable setTarget:self];
  [symbolTable setDoubleAction:@selector(openSymbol:)];
}

- (IBAction)openSymbol:(id)sender {
  unsigned row = [sender clickedRow];
  if (row != NSNotFound) {
    id symbol = [symbols objectAtIndex:row];
    id ctrl = [[self document] documentWindow];
    [ctrl setSelection:symbol];
    [ctrl showWindow:sender];
  }
}

#define NSStringContains(str, substr)		([str rangeOfString:substr \
                                                        options:NSCaseInsensitiveSearch | NSLiteralSearch].location != NSNotFound)

#pragma mark Search Support
BOOL SdefSearchFilter(NSString *search, SdefObject *object, void *ctxt) {
  if (!search) return YES;
  NSString *str = nil;
  SdefSearchField field = *(SdefSearchField *)ctxt;
  switch (field) {
    case kSdefSearchAll:
      return NSStringContains([object name], search) ||
      NSStringContains([(SdefTerminologyObject *)object code], search) ||
      NSStringContains([object objectTypeName], search) ||
      NSStringContains([object location], search);
    case kSdefSearchSymbol:
      str = [object name];
      break;
    case kSdefSearchSymbolType:
      str = [object objectTypeName];
      break;
    case kSdefSearchCode:
      str = [(SdefTerminologyObject *)object code];
      break;
    case kSdefSearchSuite:
      str = [object location];
      break;
    default:
      break;
  }
  return str ? NSStringContains(str, search) : NO;
}

- (void)limitSearch:(id)sender {
  SdefSearchField filter = [[sender representedObject] unsignedIntValue];
  if (filter != sd_filter) {
    sd_filter = filter;
    [[searchField cell] setPlaceholderString:[sender title]];
    id search = [[[[self window] toolbar] items] objectAtIndex:2];
    NSString *label;
    if (sd_filter) {
      label = [NSString stringWithFormat:@"%@ %@", 
        NSLocalizedString(@"SEARCH_FIELD", @"Inspector Toolbar item label"), [sender title]];
    } else {
      label = NSLocalizedString(@"SEARCH_FIELD", @"Inspector Toolbar item label");
    }
    [search setLabel:label];
    [symbols rearrangeObjects];
  }
}

#pragma mark -
#pragma mark Loading and synchronize
- (void)loadSymbols {
  [symbols removeAllObjects];
  id suites = [[(SdefDocument *)[self document] dictionary] childEnumerator];
  id suite;
  while (suite = [suites nextObject]) {
    [self addSuite:suite];
  }
}

- (void)addSuite:(SdefSuite *)aSuite {
  //[symbols addObject:aSuite];
  /* Enumeration/Enumerators */
  id items = [[aSuite types] childEnumerator];
  SdefObject *item;
  while (item = [items nextObject]) {
    if (kSdefValueType == [item objectType] ||
        kSdefRecordType == [item objectType]) {
      [symbols addObject:item];
    } else {
      [symbols addObjects:[item children]];
    }
  }
  /* Classes/Property */
  items = [[aSuite classes] childEnumerator];
  SdefClass *class;
  while (class = [items nextObject]) {
    [symbols addObject:class];
    [symbols addObjects:[[class properties] children]];
  }
  /* Events/Commands/Parameters */
  items = [[aSuite commands] childEnumerator];
  SdefVerb *verb;
  while (verb = [items nextObject]) {
    [symbols addObject:verb];
    [symbols addObjects:[verb children]];
  }
  items = [[aSuite events] childEnumerator];
  while (verb = [items nextObject]) {
    [symbols addObject:verb];
    [symbols addObjects:[verb children]];
  }
  [symbols rearrangeObjects];
}

- (void)removeSuite:(SdefSuite *)aSuite {
//   [symbols removeObject:aSuite];
  /* Enumeration/Enumerators */
  id items = [[aSuite types] childEnumerator];
  SdefObject *item;
  while (item = [items nextObject]) {
    if (kSdefValueType == [item objectType] ||
        kSdefRecordType == [item objectType]) {
      [symbols removeObject:item];
    } else {
      [symbols removeObjects:[item children]];
    }
  }
  /* Classes/Property */
  items = [[aSuite classes] childEnumerator];
  SdefClass *class;
  while (class = [items nextObject]) {
    [symbols removeObject:class];
    [symbols removeObjects:[[class properties] children]];
  }
  /* Events/Commands/Parameters */
  items = [[aSuite commands] childEnumerator];
  SdefVerb *verb;
  while (verb = [items nextObject]) {
    [symbols removeObject:verb];
    [symbols removeObjects:[verb children]];
  }
  items = [[aSuite events] childEnumerator];
  while (verb = [items nextObject]) {
    [symbols removeObject:verb];
    [symbols removeObjects:[verb children]];
  }
}

#pragma mark -
#pragma mark Notification Handling
- (void)didAppendChild:(NSNotification *)aNotification {
  id node = [aNotification object];
  if ([self document] && ([node document] == [self document])) {
    id child = [[aNotification userInfo] objectForKey:SKInsertedChild];
    switch ([child objectType]) {
      case kSdefSuiteType:
        [self addSuite:child];
        break;
      case kSdefClassType:
        [symbols addObject:child];
        [symbols addObjects:[[(SdefClass *)child properties] children]];
        [symbols rearrangeObjects];
        break;
      case kSdefVerbType:
        [symbols addObject:child];
      case kSdefEnumerationType:
        [symbols addObjects:[child children]];
        [symbols rearrangeObjects];
        break;
        /* Leaves */
      case kSdefEnumeratorType:
      case kSdefPropertyType:
      case kSdefParameterType:
        [symbols addObject:child];
        [symbols rearrangeObjects];
        break;
      default:
        break;
    }
  }
}

- (void)willRemoveChild:(NSNotification *)aNotification {
  id node = [aNotification object];
  if ([self document] && ([node document] == [self document])) {
    id child = [[aNotification userInfo] objectForKey:SKRemovedChild];
    switch ([child objectType]) {
      case kSdefSuiteType:
        [self removeSuite:child];
        break;
      case kSdefClassType:
        [symbols removeObjects:[[(SdefClass *)child properties] children]];
        [symbols removeObject:child];
        break;
      case kSdefVerbType:
        [symbols removeObject:child];
      case kSdefEnumerationType:
        [symbols removeObjects:[child children]];
        break;
        /* Leaves */
      case kSdefEnumeratorType:
      case kSdefPropertyType:
      case kSdefParameterType:
        [symbols removeObject:child];
        break;
      default:
        break;
    }
  }
}

- (void)createToolbar {
  NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"SdefSymbolBrowserToolbar"];
  [toolbar setDelegate:self];
  [toolbar setAutosavesConfiguration:NO];
  [toolbar setAllowsUserCustomization:NO];
  [toolbar setSizeMode:NSToolbarSizeModeSmall];
  [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
  [[self window] setToolbar:toolbar];
  
  searchField = (id)[[[toolbar items] objectAtIndex:2] view];
  [toolbar release];
}

- (void)windowWillClose:(NSNotification *)aNotification {
  [symbols removeAllObjects];
}

#pragma mark -
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  id item = nil;
  if ([itemIdentifier isEqualToString:@"SdefToggleEditSymbolDrawer"]) {
    item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [item setTag:0];
    [item setLabel:NSLocalizedString(@"TB_LABEL_TOGGLE_EDITOR", @"Inspector Toolbar item label")];
    [item setToolTip:NSLocalizedString(@"TB_TOOLTIP_TOGGLE_EDITOR", @"Inspector Toolbar item tooltip")];
    [item setImage:[NSImage imageNamed:@"EditSymbol"]];
    [item setTarget:editDrawer];
    [item setAction:@selector(toggle:)];
  } else if ([itemIdentifier isEqualToString:@"SdefSearchFieldToolbarItem"]) {
    item = [[SearchFieldToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [item setLabel:NSLocalizedString(@"SEARCH_FIELD", @"Inspector Toolbar item label")];
    [item setToolTip:NSLocalizedString(@"SEARCH_FIELD_TOOLTIP", @"Search Field")];
  }
  return [item autorelease];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
  return [NSArray arrayWithObjects:@"SdefToggleEditSymbolDrawer", NSToolbarFlexibleSpaceItemIdentifier, @"SdefSearchFieldToolbarItem", nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
  return [self toolbarDefaultItemIdentifiers:toolbar];
}

@end

@implementation SearchFieldToolbarItem

- (id)initWithItemIdentifier:(NSString *)itemIdentifier {
  if (self = [super initWithItemIdentifier:itemIdentifier]) {
    id searchField = [[NSSearchField alloc] initWithFrame:NSMakeRect(0, 0, 120, 19)];
    [[searchField cell] setControlSize:NSSmallControlSize];
    [self setView:searchField];
    [self setMinSize:[searchField frame].size];
    [self setMaxSize:[searchField frame].size];
    [searchField release];
  }
  return self;
}

@end
