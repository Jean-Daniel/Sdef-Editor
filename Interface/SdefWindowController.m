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

#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefSuite.h"
#import "SdefObject.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"
#import "SdefEnumeration.h"

#define IsObjectOwner(item)		 		[item findRoot] == (id)[(SdefDocument *)[self document] dictionary]  \
										/* || item == [[self document] imports] */

NSString * const SdefTreePboardType = @"SdefTreeType";
NSString * const SdefInfoPboardType = @"SdefInfoType";

NSString * const SdefDictionarySelectionDidChangeNotification = @"SdefDictionarySelectionDidChange";

static inline BOOL SdefEditorExistsForItem(SdefObject *item) {
  switch ([item objectType]) {
    case kSdefDictionaryType:
    case kSdefSuiteType:
    case kSdefImportsType:
      /* Class */
    case kSdefClassType:
      /* Verbs */
    case kSdefVerbType:
      /* Enumeration */
    case kSdefEnumerationType:  
      /* Misc */
    case kSdefSynonymType:
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
                                                 name:SdefObjectDidAppendChildNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveNode:)
                                                 name:SdefObjectWillRemoveChildNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRemoveNode:)
                                                 name:SdefObjectDidRemoveChildNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveAllNodes:)
                                                 name:SdefObjectWillRemoveAllChildrenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRemoveNode:)
                                                 name:SdefObjectDidRemoveAllChildrenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeNodeName:)
                                                 name:SdefObjectDidChangeNameNotification
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
  id item = [aNotification object];
  if (IsObjectOwner(item)) {
    [outline reloadItem:[aNotification object]];
    if (item == [(SdefDocument *)[self document] dictionary]) {
      [self synchronizeWindowTitleWithDocumentName];
    }
  }
}

#pragma mark -
- (void)didAppendNode:(NSNotification *)aNotification {
  SdefObject *item = [aNotification object];
  if (IsObjectOwner(item)) {
    SdefObject *parent = item;
    id path = [NSMutableArray array];
    do {
      [path addObject:parent];
      parent = [parent parent];
    } while (parent);
    [outline reloadItem:item reloadChildren:YES];
    id parents = [path reverseObjectEnumerator];
    while (parent = [parents nextObject]) {
      [outline expandItem:parent];
    }
    id child = [[aNotification userInfo] objectForKey:SdefNewTreeNode];
    int row = [outline rowForItem:child];
    if (row > 0)
      [outline selectRow:[outline rowForItem:child] byExtendingSelection:NO];
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
  [outline registerForDraggedTypes:[NSArray arrayWithObject:SdefObjectDragType]];
  [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification {
  [[_viewControllers allValues] makeObjectsPerformSelector:@selector(setObject:) withObject:nil];
  [[_viewControllers allValues] makeObjectsPerformSelector:@selector(documentWillClose:) withObject:[self document]];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
  return [NSString stringWithFormat:@"%@ : %@", displayName, [[(SdefDocument *)[self document] dictionary] name]];
}

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
  while (item && !SdefEditorExistsForItem(item)) {
    item = [item parent];
  }
  if ([item objectType] != kSdefUndefinedType) {
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
    unsigned idx = [parent indexOfChild:item];
    [item remove];
    [outlineView selectRow:[outline rowForItem:(idx > 0) ? [parent childAtIndex:idx-1] : parent]
      byExtendingSelection:NO];
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
      case kSdefDictionaryType:
        class = @"SdefDictionaryView";
        nibName = @"SdefDictionary";
        break;
      case kSdefImportsType:
        class = @"SdefImportsView";
        nibName = @"SdefImports";
        break;
      case kSdefClassType:
        class = @"SdefClassView";
        nibName = @"SdefClass";
        break;
      case kSdefSuiteType:
        class = @"SdefSuiteView";
        nibName = @"SdefSuite";
        break;
      case kSdefEnumerationType:
        class = @"SdefEnumerationView";
        nibName = @"SdefEnumeration";
        break;
      case kSdefVerbType:
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
- (BOOL)validateMenuItem:(NSMenuItem *)anItem {
  SEL action = [anItem action];
  id selection = [self selection];
  if (action == @selector(copy:) || action == @selector(cut:)) {
    switch ([selection objectType]) {
      case kSdefUndefinedType:
      case kSdefDictionaryType:
        return NO;
      case kSdefCollectionType:
        if ([selection childCount] == 0)
          return NO;
      default:
        break;
    }
  }
  if (action == @selector(delete:) || action == @selector(cut:)) {
    if (![selection isRemovable] || [(SdefDocument *)[self document] dictionary] == selection)
      return NO;
  }
  if (action == @selector(paste:)) {
    if (![selection isEditable] || ![[[NSPasteboard generalPasteboard] types] containsObject:SdefTreePboardType])
      return NO;
  }
  return YES;
}

- (IBAction)copy:(id)sender {
  id selection = [self selection];
  NSPasteboard *pboard = [NSPasteboard generalPasteboard];
  switch ([selection objectType]) {
    case kSdefUndefinedType:
    case kSdefDictionaryType:
      NSBeep();
      break;
    default:
      [pboard declareTypes:[NSArray arrayWithObjects:SdefTreePboardType, SdefInfoPboardType, NSStringPboardType, nil] owner:nil];
      if ([selection objectType] == kSdefRespondsToType) {
        id str = nil;
        SdefClass *class = [selection firstParentOfType:kSdefClassType];
        if ([selection parent] == [class commands] || selection == [class commands]) {
          str = @"commands";
        } else if ([selection parent] == [class events] || selection == [class events]) {
          str = @"events";
        }
        [pboard setString:str forType:SdefInfoPboardType];
      } else if ([selection objectType] == kSdefVerbType) {
        id str = nil;
        SdefSuite *suite = [selection firstParentOfType:kSdefSuiteType];
        if ([selection parent] == [suite commands] || selection == [suite commands]) {
          str = @"commands";
        } else if ([selection parent] == [suite events] || selection == [suite events]) {
          str = @"events";
        }
        [pboard setString:str forType:SdefInfoPboardType];
      } else {
        [pboard setString:@"" forType:SdefInfoPboardType];
      }
      [pboard setString:[selection name] forType:NSStringPboardType];
      [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:selection] forType:SdefTreePboardType];
  }
}

- (IBAction)delete:(id)sender {
  [self deleteSelectionInOutlineView:outline];
}

- (IBAction)cut:(id)sender {
  [self copy:sender];
  [self delete:sender];
}

- (IBAction)paste:(id)sender {
  NSPasteboard *pboard = [NSPasteboard generalPasteboard];
  if (![[pboard types] containsObject:SdefTreePboardType]) return;
  
  id selection = [self selection];
  id data = [pboard dataForType:SdefTreePboardType];
  SdefObject *tree = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  if (!tree) return;
  
  id destination = nil;
  switch ([tree objectType]) {
    case kSdefUndefinedType:
    case kSdefDictionaryType:
      NSBeep();
      break;
    case kSdefSuiteType:
      destination = [selection firstParentOfType:kSdefDictionaryType];
      break;
      /* 4 main types */
    case kSdefEnumerationType:
      destination = [(SdefSuite *)[selection firstParentOfType:kSdefSuiteType] types];
      break;
    case kSdefClassType:
      destination = [(SdefSuite *)[selection firstParentOfType:kSdefSuiteType] classes];
      break;
    case kSdefVerbType:
    {
      id str = [pboard stringForType:SdefInfoPboardType];
      @try {
        destination = [(SdefSuite *)[selection firstParentOfType:kSdefSuiteType] valueForKey:str];
      } @catch (id exception) {
        SKLogException(exception);
        destination = nil;
      }
    }
      break;
      /* 4 Class content type */
    case kSdefElementType:
      destination = [[selection firstParentOfType:kSdefClassType] elements];
      break;
    case kSdefPropertyType:
      destination = [(SdefClass *)[selection firstParentOfType:kSdefClassType] properties];
      break;
    case kSdefRespondsToType:
    {
      id str = [pboard stringForType:SdefInfoPboardType];
      @try {
        destination = [(SdefClass *)[selection firstParentOfType:kSdefClassType] valueForKey:str];
      } @catch (id exception) {
        SKLogException(exception);
        destination = nil;
      }
    }
      break;
      /* Misc */
    case kSdefEnumeratorType:
      destination = [selection firstParentOfType:kSdefEnumerationType];
      break;
    case kSdefParameterType:
      destination = [selection firstParentOfType:kSdefVerbType];
      break;
    case kSdefCollectionType:
    {
      id type = [(SdefCollection *)tree contentType];
      SdefSuite *suite = [selection firstParentOfType:kSdefSuiteType];
      SdefClass *class = [selection firstParentOfType:kSdefClassType];
      if (type == [SdefEnumeration class]) destination = [suite types];
      else if (type == [SdefClass class]) destination = [suite classes];
      else if (type == [SdefVerb class]) {
        id str = [pboard stringForType:SdefInfoPboardType];
        @try {
          destination = [suite valueForKey:str];
        } @catch (id exception) {
          SKLogException(exception);
          destination = nil;
        }
      }
      else if (type == [SdefElement class]) destination = [class elements];
      else if (type == [SdefProperty class]) destination = [class properties];
      else if (type == [SdefRespondsTo class]) {
        id str = [pboard stringForType:SdefInfoPboardType];
        @try {
          destination = [class valueForKey:str];
        } @catch (id exception) {
          SKLogException(exception);
          destination = nil;
        }
      }
    }
      break;
    default:
      break;
  }
  if (destination) {
    if ([tree objectType] == kSdefCollectionType) {
      id children = [tree childEnumerator];
      id child;
      while (child = [children nextObject]) {
        [child retain];
        [child remove];
        [destination appendChild:child];
        [child release];
      }
    } else {
      [destination appendChild:tree];
    }
  }
  else
    NSBeep();
}

@end

#pragma mark -
#pragma mark Missing Method
@implementation NSTabView (Extension)
- (int)indexOfSelectedTabViewItem {
  return [self indexOfTabViewItem:[self selectedTabViewItem]]; 
}
@end
