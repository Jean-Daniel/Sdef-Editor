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
#import "SdefDocumentationWindow.h"

static BOOL SDEditorExistsForItem(SdefObject *item) {
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
                                                 name:@"SDTreeNodeDidAppendNodeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveNode:)
                                                 name:@"SDTreeNodeWillRemoveNodeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRemoveNode:)
                                                 name:@"SDTreeNodeDidRemoveNodeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveAllNodes:)
                                                 name:@"SDTreeNodeWillRemoveAllChildrenNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRemoveNode:)
                                                 name:@"SDTreeNodeDidRemoveAllChildrenNotification"
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

- (void)didChangeNodeName:(NSNotification *)aNotification {
  [outline reloadItem:[aNotification object]];
}

- (void)didAppendNode:(NSNotification *)aNotification {
  id item = [aNotification object];
  if ([item findRoot] == (id)[(SdefDocument *)[self document] dictionary] || item == [[self document] imports]) {
    [outline reloadItem:item reloadChildren:[outline isItemExpanded:item]];
    if ([outline isExpandable:item]) {
      [outline expandItem:item];
    }
  }
}

- (void)willRemoveNode:(NSNotification *)aNotification {
  id item = [aNotification object];
  if ([item findRoot] == (id)[(SdefDocument *)[self document] dictionary] || item == [[self document] imports]) {
    if ([item childCount] == 1) {
      [outline collapseItem:item];
    }
  }
}

- (void)didRemoveNode:(NSNotification *)aNotification {
  id item = [aNotification object];
  if ([item findRoot] == (id)[(SdefDocument *)[self document] dictionary] || item == [[self document] imports]) {
    [outline reloadItem:item reloadChildren:[item childCount] != 0];
  }
}

- (void)willRemoveAllNodes:(NSNotification *)aNotification {
  id item = [aNotification object];
  if ([item findRoot] == (id)[(SdefDocument *)[self document] dictionary] || item == [[self document] imports]) {
    [outline collapseItem:item];
  }
}

- (void)windowDidLoad {
  [super windowDidLoad];
  [outline setDataSource:[self document]];
}

#pragma mark -

- (IBAction)viewDocumentation:(id)sender {
  SdefDocumentationWindow *sheet = [[SdefDocumentationWindow alloc] init];
  [sheet setObject:[sender itemAtRow:[sender selectedRow]]];
  [NSApp beginSheet:[sheet window]
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(documentationDidEnd:returnCode:context:)
        contextInfo:nil];
}

- (void)documentationDidEnd:(NSWindow *)sheet returnCode:(int)code context:(id)ctxt {
  [[sheet windowController] autorelease];
}

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
  ShadowTrace();
  id item = [outlineView itemAtRow:[outlineView selectedRow]];
  if (item != [(SdefDocument *)[self document] dictionary] && [item isRemovable]) {
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

@end

#pragma mark -
#pragma mark Missing Method
@implementation NSTabView (Extension)
- (int)indexOfSelectedTabViewItem {
  return [self indexOfTabViewItem:[self selectedTabViewItem]]; 
}
@end
