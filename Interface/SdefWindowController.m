//
//  SdefWindowController.m
//  SDef Editor
//
//  Created by Grayfox on 04/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefWindowController.h"
#import "SdefViewController.h"

#import "ShadowMacros.h"
#import "SKFunctions.h"

#import "SdefObject.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"
#import "SdefDocumentationWindow.h"

#define IsObjectOwner(item)		 		[item findRoot] == (id)[(SdefDocument *)[self document] dictionary]  \
										/* || item == [[self document] imports] */

NSString * const SdefDictionarySelectionDidChangeNotification = @"SdefDictionarySelectionDidChange";

static inline BOOL SDEditorExistsForItem(SdefObject *item) {
  switch ([item objectType]) {
    case kSDDictionaryType:
    case kSDSuiteType:
    case kSDImportsType:
      /* Class */
    case kSDClassType:
      /* Verbs */
    case kSDVerbType:
      /* Enumeration */
    case kSDEnumerationType:  
      /* Misc */
    case kSDSynonymType:
      return YES;
    default:
      return NO;
  }
}

@implementation SdefWindowController

- (id)initWithOwner:(id)owner {
  if (self = [super initWithWindowNibName:@"SdefDocument" owner:(owner) ? : self]) {
    _viewControllers = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAppendNode:)
                                                 name:@"SdefObjectDidAppendChild"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveNode:)
                                                 name:@"SdefObjectWillRemoveChild"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRemoveNode:)
                                                 name:@"SdefObjectDidRemoveChild"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveAllNodes:)
                                                 name:@"SdefObjectWillRemoveAllChildren"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRemoveNode:)
                                                 name:@"SdefObjectDidRemoveAllChildren"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeNodeName:)
                                                 name:@"SDTreeNodeDidChangeNameNotification"
                                               object:nil];    
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_viewControllers release];
  [super dealloc];
}

#pragma mark -
- (SdefObject *)selection {
  return [outline itemAtRow:[outline selectedRow]];
}

- (void)didChangeNodeName:(NSNotification *)aNotification {
  [outline reloadItem:[aNotification object]];
}

#pragma mark -
- (void)didAppendNode:(NSNotification *)aNotification {
  id item = [aNotification object];
  if (IsObjectOwner(item)) {
    [outline reloadItem:item reloadChildren:[outline isItemExpanded:item]];
    if ([outline isExpandable:item]) {
      [outline expandItem:item];
    }
  }
}

- (void)willRemoveNode:(NSNotification *)aNotification {
  id item = [aNotification object];
  if (IsObjectOwner(item)) {
    if ([item childCount] == 1) {
      [outline collapseItem:item];
    }
  }
}

- (void)didRemoveNode:(NSNotification *)aNotification {
  id item = [aNotification object];
  if (IsObjectOwner(item)) {
    [outline reloadItem:item reloadChildren:[item childCount] != 0];
  }
}

- (void)willRemoveAllNodes:(NSNotification *)aNotification {
  id item = [aNotification object];
  if (IsObjectOwner(item)) {
    [outline collapseItem:item];
  }
}

- (void)windowDidLoad {
  [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification {
  [[_viewControllers allValues] makeObjectsPerformSelector:@selector(setObject:) withObject:nil];
  [[_viewControllers allValues] makeObjectsPerformSelector:@selector(documentWillClose:) withObject:[self document]];
}

//- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
//  return [NSString stringWithFormat:@"%@ : %@", displayName, [[(SdefDocument *)[self document] dictionary] name]];
//}

- (void)awakeFromNib {
  [outline setDataSource:[self document]];
  [outline setDoubleAction:@selector(openInspector:)];
  [outline setTarget:[NSApp delegate]];
}

#pragma mark -
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
  NSOutlineView *view = [notification object];
  SdefObject *selection = [view itemAtRow:[view selectedRow]];
  SdefObject *item = selection;
  while (item && !SDEditorExistsForItem(item)) {
    item = [item parent];
  }
  if ([item objectType] != kSDUndefinedType) {
    id str = SKFileTypeForHFSTypeCode([item objectType]);
    unsigned idx = [inspector indexOfTabViewItemWithIdentifier:str];
    NSAssert1(idx != NSNotFound, @"Unable to find tab item for identifier \"%@\"", str);
    [inspector selectTabViewItemAtIndex:idx];
    SdefViewController *ctrl = [_viewControllers objectForKey:str];
    [ctrl setObject:item];
    [ctrl selectObject:selection];
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefDictionarySelectionDidChangeNotification object:[self document]];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  if ([[tableColumn identifier] isEqualToString:@"documentation"]) {
    [cell setTransparent:[item documentation] == nil];
    [cell setEnabled:[item documentation] != nil];
  } else if ([[tableColumn identifier] isEqualToString:@"_item"]) {
    if ([outlineView rowForItem:item] == [outlineView selectedRow]) {
      [cell setTextColor:([[self window] firstResponder] == self) ? [NSColor whiteColor] : [NSColor blackColor]];
    } else {
      [cell setTextColor:([item isEditable]) ? [NSColor textColor] : [NSColor disabledControlTextColor]];
    }
  }
}

- (void)deleteSelectionInOutlineView:(NSOutlineView *)outlineView {
  id item = [outlineView itemAtRow:[outlineView selectedRow]];
  if (item != [(SdefDocument *)[self document] dictionary] && [item isEditable] && [item isRemovable]) {
    id parent = [item parent];
    [item remove];
    if ([outlineView selectedRow] <= 0) {
      [outlineView selectRow:[outlineView rowForItem:parent] byExtendingSelection:NO];
    }
  } else {
    NSBeep();
  }
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem {
  id key = [tabViewItem identifier];
  if (![_viewControllers objectForKey:key]) {
    id ctrl;
    id class = nil;
    id nibName = nil;
    switch (SKHFSTypeCodeFromFileType(key)) {
      case kSDDictionaryType:
        class = @"SdefDictionaryView";
        nibName = @"SdefDictionary";
        break;
      case kSDImportsType:
        class = @"SdefImportsView";
        nibName = @"SdefImports";
        break;
      case kSDClassType:
        class = @"SdefClassView";
        nibName = @"SdefClass";
        break;
      case kSDSuiteType:
        class = @"SdefSuiteView";
        nibName = @"SdefSuite";
        break;
      case kSDEnumerationType:
        class = @"SdefEnumerationView";
        nibName = @"SdefEnumeration";
        break;
      case kSDVerbType:
        class = @"SdefVerbView";
        nibName = @"SdefVerb";
        break;
    }
    if (class && nibName) {
      ctrl = [[NSClassFromString(class) alloc] initWithNibName:nibName];
      NSAssert1(ctrl != nil, @"Unable to instanciate controller: %@", class);
      if (ctrl) {
        [_viewControllers setObject:ctrl forKey:key];
        [ctrl release];
        [tabViewItem setView:[ctrl sdefView]];
      }
    }
  }
}

#pragma mark -
#pragma mark Copy/Paste
/*
- (IBAction)copy:(id)sender {
  id selection = [self selection];
  id pboard = [NSPasteboard generalPasteboard];
  [pboard declareTypes:[NSArray arrayWithObjects:SdefTreePboardType, NSStringPboardType, nil] owner:nil];
  [pboard setString:[selection name] forType:NSStringPboardType];
  [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:selection] forType:SdefTreePboardType];
}

- (IBAction)paste:(id)sender {
  id pboard = [NSPasteboard generalPasteboard];
  if (![[pboard types] containsObject:SdefTreePboardType]) return;
  
  id selection = [self selection];
  id data = [pboard dataForType:SdefTreePboardType];
  SdefObject *tree = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  switch ([tree objectType]) {
    
  }
}
*/
@end

#pragma mark -
#pragma mark Missing Method
@implementation NSTabView (Extension)
- (int)indexOfSelectedTabViewItem {
  return [self indexOfTabViewItem:[self selectedTabViewItem]]; 
}
@end

NSString * const SdefTreePboardType = @"SdefTreeType";

/*
#pragma mark -
@implementation SdefEditorPasteManager

+ (id)sharedManager {
  static id shared = nil;
  if (!shared) {
    shared = [[self alloc] init];
  }
  return shared;
}

- (void)dealloc {
  [sd_content release];
  [super dealloc];
}

- (id)content {
  return sd_content;
}

- (void)setContent:(SdefObject *)content {
  if (sd_content != content) {
    [sd_content release];
    sd_content = [content retain];
  }
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type {
  if ([type isEqualToString:SdefTreePboardType] && sd_content) {
    [sender setData:[NSKeyedArchiver archivedDataWithRootObject:sd_content] forType:type];
  }
  [sender setString:@"<Empty>" forType:type];
}

- (void)pasteboardChangedOwner:(NSPasteboard *)sender {
  [self setContent:nil];
}

@end
*/
