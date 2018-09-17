/*
 *  SdefWindowController.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefWindowController.h"
#import "SdefViewController.h"

#import <WonderBox/WBFunctions.h>
#import <WonderBox/WBSplitView.h>
#import <WonderBox/WBOutlineViewController.h>

#import "SdefVerb.h"
#import "SdefClass.h"
#import "SdefSuite.h"
#import "SdefObjects.h"
#import "SdefTypedef.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"

#import "SdefEditor.h"
#import "SdefTypesEditor.h"

#define IsObjectOwner(item)		 		[item findRoot] == [sd_tree root]

static
NSString * const SdefObjectDragType = @"SdefObjectDragType";

@interface SdefDictionaryTree : WBOutlineViewController {
}

@end

NSString * const SdefTreePboardType = @"SdefTreeType";
NSString * const SdefInfoPboardType = @"SdefInfoType";

NSString * const SdefDictionarySelectionDidChangeNotification = @"SdefDictionarySelectionDidChange";

static inline BOOL SdefEditorExistsForItem(SdefObject *item) {
  switch ([item objectType]) {
    case kSdefType_Dictionary:
    case kSdefType_Suite:
      /* Class */
    case kSdefType_Class:
      /* Verbs */
    case kSdefType_Command:
      /* Enumeration */
    case kSdefType_RecordType:
    case kSdefType_Enumeration:
      return YES;
    default:
      return NO;
  }
}

@implementation SdefWindowController

- (id)init {
  if (self = [super initWithWindowNibName:@"SdefDocument"]) {
    sd_viewControllers = [[NSMutableDictionary alloc] initWithCapacity:16];
  }
  return self;
}

- (void)dealloc {
  [self setDocument:nil];
  [sd_tree unbind:@"autoSelect"];
}

#pragma mark -
- (SdefObject *)selection {
  return [outline itemAtRow:[outline selectedRow]];
}

- (void)displayObject:(SdefObject *)anObject {
  if (IsObjectOwner(anObject)) {
    [sd_tree displayNode:anObject];
  }
}

- (void)setSelection:(SdefObject *)anObject display:(BOOL)display {
  if (IsObjectOwner(anObject)) {
    [sd_tree setSelectedNode:anObject display:display];
    if (SdefEditorExistsForItem(anObject))
      [[self window] makeFirstResponder:outline];
  }
}

- (void)setSelection:(SdefObject *)anObject {
  [self setSelection:anObject display:YES];
}

- (SdefViewController *)currentController {
  SdefObject *selection = [outline itemAtRow:[outline selectedRow]];
  SdefObject *item = selection;
  while (item && !SdefEditorExistsForItem(item)) {
    item = [item parent];
  }
  if (item && ([item objectType] != kSdefType_Undefined)) {
    return [sd_viewControllers objectForKey:WBStringForOSType([item objectType])];
  }
  return nil;
}

- (void)didChangeNodeName:(NSNotification *)aNotification {
  id item = [aNotification object];
  if (item == [(SdefDocument *)[self document] dictionary]) {
    [self synchronizeWindowTitleWithDocumentName];
  }
}

//- (void)didRemoveNode:(NSNotification *)aNotification {
//  id item = [aNotification object];
//  if (!sd_remove && IsObjectOwner(item)) {
//    /* was first child */
//    if ([outline selectedRow] == ([outline rowForItem:item] +1)) {
//      DLog(@"Should hack");
//      if ([item hasChildren]) {
//        [self setSelection:[item firstChild]];
//      } else {
//        [self setSelection:item];
//      }
//    }
//  }
//}

#pragma mark -

// set autoselect: [[NSUserDefaults standardUserDefaults] boolForKey:@"SdefAutoSelectItem"]
- (void)windowDidLoad {
  [outline registerForDraggedTypes:[NSArray arrayWithObject:SdefObjectDragType]];
  
  [[self window] center];
//  NSToolbar *tb = [[NSToolbar alloc] initWithIdentifier:@"SdefWindowToolbar"];
//  [tb setDelegate:self];
//  [[self window] setToolbar:tb];
//  [tb setVisible:NO];
//  [tb release];
  [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification {
  [[sd_viewControllers allValues] makeObjectsPerformSelector:@selector(setObject:) withObject:nil];
  [[sd_viewControllers allValues] makeObjectsPerformSelector:@selector(documentWillClose:) withObject:[self document]];
}

- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect {
  id ctrl = [sheet windowController];
  if (ctrl && [ctrl respondsToSelector:@selector(field)]) {
    NSView *type = [ctrl performSelector:@selector(field)];
    if ([type superview]) {
      NSRect typeRect = [[type superview] convertRect:[type frame] toView:nil];
      rect.origin.x = NSMinX(typeRect);
      rect.origin.y = NSMaxY(typeRect) - 2;
      rect.size.width = NSWidth(typeRect);
      rect.size.height = 0;
    }
  }
  return rect;
}

- (void)setDocument:(NSDocument *)aDocument {
  if ([super document]) {
    [[[super document] notificationCenter] removeObserver:self];
  }
  [super setDocument:aDocument];
  if ([super document]) {
    /* WARNING: do not handle multiple nodes notifications */
    [[[super document] notificationCenter] addObserver:self
                                              selector:@selector(didChangeNodeName:)
                                                  name:WBUITreeNodeDidChangeNameNotification
                                                object:nil];
    //    [[[super document] notificationCenter] addObserver:self
    //                                             selector:@selector(didRemoveNode:)
    //                                                 name:WBUITreeNodeDidRemoveChildNotification
    //                                               object:nil];
  }
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
  return [NSString stringWithFormat:@"%@ : %@", displayName, [[(SdefDocument *)[self document] dictionary] name]];
}

#pragma mark -
- (void)awakeFromNib {
  [uiSplitview setGray:YES];
  [uiSplitview setBorders:kWBBorderRight];
  [uiSplitview setDividerThickness:6];
  
  if (!sd_tree && outline) {
    sd_tree = [[SdefDictionaryTree alloc] initWithOutlineView:outline];
    [sd_tree setDisplayRoot:YES];
    [sd_tree setRoot:[(SdefDocument *)[self document] dictionary]];
    [sd_tree bind:@"autoSelect"    
         toObject:[NSUserDefaultsController sharedUserDefaultsController]
      withKeyPath:@"values.SdefAutoSelectItem"
          options:nil];
  }
  [outline setTarget:[NSApp delegate]];
  [outline setDoubleAction:@selector(openInspector:)];
}

- (void)setDictionary:(SdefDictionary *)dictionary {
  [sd_tree setRoot:dictionary];
}

- (IBAction)sortByName:(id)sender {
  if ([outline selectedRow] != -1) {
    SdefObject *item = [outline itemAtRow:[outline selectedRow]];
    /* If contains user objects */
    if ([[item firstChild] isRemovable]) {
      [item sortByName];
    }
  }
}

#pragma mark -
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
  NSOutlineView *view = [notification object];
  SdefObject *selection = [view itemAtRow:[view selectedRow]];
  SdefObject *item = selection;
  while (item && !SdefEditorExistsForItem(item)) {
    item = [item parent];
  }
  if (item && ([item objectType] != kSdefType_Undefined)) {
    NSString *str = WBStringForOSType([item objectType]);
    NSUInteger idx = [inspector indexOfTabViewItemWithIdentifier:str];
    NSAssert1(idx != NSNotFound, @"Unable to find tab item for identifier \"%@\"", str);
    /* Sould select else ctrl would not be created */
    if ([inspector tabViewItemAtIndex:idx] != [inspector selectedTabViewItem]) {
      [inspector selectTabViewItemAtIndex:idx];
    }
    SdefViewController *ctrl = [sd_viewControllers objectForKey:str];    
    if ([ctrl object] != item) {
      [ctrl setObject:item];
    }
    [ctrl selectObject:selection];

  }
  [[NSNotificationCenter defaultCenter] postNotificationName:SdefDictionarySelectionDidChangeNotification object:[self document]];
}


 - (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id<SdefObject>)item {
   if ([[tableColumn identifier] isEqualToString:@"_item"]) {
     if (item.editable) {
       [cell setTextColor:[NSColor controlTextColor]];
     } else if ([outlineView rowForItem:item] == [outlineView selectedRow]) {
       [cell setTextColor:([[self window] firstResponder] == outlineView) ? [NSColor selectedControlTextColor] : [NSColor blackColor]];
     } else {
       [cell setTextColor:[NSColor disabledControlTextColor]];
     }
//     if ([outlineView rowForItem:item] == [outlineView selectedRow]) {
//       [cell setTextColor:([[self window] firstResponder] == self) ? [NSColor whiteColor] : [NSColor blackColor]];
//     } else {
//     [cell setTextColor:([item isEditable]) ? [NSColor textColor] : [NSColor disabledControlTextColor]];
//     }
   }
 }

- (void)deleteSelectionInOutlineView:(NSOutlineView *)outlineView {
  sd_remove = YES;
  SdefObject *item = [outlineView itemAtRow:[outlineView selectedRow]];
  if (item != [(SdefDocument *)[self document] dictionary] && [item isRemovable]) {
    SdefObject *parent = [item parent];
    NSUInteger idx = [parent indexOfChild:item];
    [item remove];
    if (idx > 0) {
      [self setSelection:[parent childAtIndex:idx-1]];
    } else if ([parent hasChildren]) {
      [self setSelection:[parent firstChild]];
    } else {
      [self setSelection:parent];
    }
  } else {
    NSBeep();
  }
  sd_remove = NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id<SdefObject>)item {
  return item.editable && [item objectType] != kSdefType_Collection;
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem {
  id key = [tabViewItem identifier];
  if (![sd_viewControllers objectForKey:key]) {
    id ctrl;
    id class = nil;
    id nibName = nil;
    switch (WBOSTypeFromString(key)) {
      case kSdefType_Dictionary:
        class = @"SdefDictionaryView";
        nibName = @"SdefDictionary";
        break;
      case kSdefType_Class:
        class = @"SdefClassView";
        nibName = @"SdefClass";
        break;
      case kSdefType_Suite:
        class = @"SdefSuiteView";
        nibName = @"SdefSuite";
        break;
      case kSdefType_RecordType:
        class = @"SdefRecordView";
        nibName = @"SdefRecord";
        break;
      case kSdefType_Enumeration:
        class = @"SdefEnumerationView";
        nibName = @"SdefEnumeration";
        break;
      case kSdefType_Command:
        class = @"SdefVerbView";
        nibName = @"SdefVerb";
        break;
    }
    if (class && nibName) {
      ctrl = [[NSClassFromString(class) alloc] initWithNibName:nibName];
      NSAssert1(ctrl != nil, @"Unable to instanciate controller: %@", class);
      if (ctrl) {
        [sd_viewControllers setObject:ctrl forKey:key];
        [tabViewItem setView:[ctrl sdefView]];
      }
    }
  }
}

#pragma mark -
#pragma mark Copy/Paste
- (BOOL)validateMenuItem:(NSMenuItem *)anItem {
  SEL action = [anItem action];
  SdefObject *selection = [self selection];
  if (action == @selector(copy:) || action == @selector(cut:)) {
    switch ([selection objectType]) {
      case kSdefType_Undefined:
      case kSdefType_Dictionary:
        return NO;
      case kSdefType_Collection:
        if ([selection count] == 0)
          return NO;
      default:
        break;
    }
  }
  if (action == @selector(delete:) || action == @selector(cut:)) {
    if (!selection.removable || [(SdefDocument *)[self document] dictionary] == selection)
      return NO;
  }
  if (action == @selector(paste:)) {
    if (!selection.editable || ![[[NSPasteboard generalPasteboard] types] containsObject:SdefTreePboardType])
      return NO;
  }
  return YES;
}

- (IBAction)copy:(id)sender {
  SdefObject *selection = [self selection];
  NSPasteboard *pboard = [NSPasteboard generalPasteboard];
  switch ([selection objectType]) {
    case kSdefType_Undefined:
    case kSdefType_Dictionary:
      NSBeep();
      break;
    default:
      [pboard declareTypes:@[SdefTreePboardType, SdefInfoPboardType, NSStringPboardType] owner:nil];
      if ([selection objectType] == kSdefType_RespondsTo ||
          ([selection objectType] == kSdefType_Collection && [(SdefCollection *)selection acceptsObjectType:kSdefType_RespondsTo])) {
        id str = nil;
        SdefClass *class = (SdefClass *)[selection firstParentOfType:kSdefType_Class];
        if ([selection parent] == [class commands] || selection == [class commands]) {
          str = @"commands";
        } else if ([selection parent] == [class events] || selection == [class events]) {
          str = @"events";
        }
        [pboard setString:str forType:SdefInfoPboardType];
      } else if ([selection objectType] == kSdefType_Command ||
                 ([selection objectType] == kSdefType_Collection && [(SdefCollection *)selection acceptsObjectType:kSdefType_Command])) {
        id str = nil;
        SdefSuite *suite = (SdefSuite *)[selection firstParentOfType:kSdefType_Suite];
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
    case kSdefType_Undefined:
    case kSdefType_Dictionary:
      NSBeep();
      break;
    case kSdefType_Suite:
      destination = [selection firstParentOfType:kSdefType_Dictionary];
      break;
      /* 4 main types */
    case kSdefType_ValueType:
    case kSdefType_RecordType:
    case kSdefType_Enumeration:
      destination = [(SdefSuite *)[selection firstParentOfType:kSdefType_Suite] types];
      break;
    case kSdefType_Class:
      destination = [(SdefSuite *)[selection firstParentOfType:kSdefType_Suite] classes];
      break;
    case kSdefType_Command:
    {
      id str = [pboard stringForType:SdefInfoPboardType];
      @try {
        destination = [(SdefSuite *)[selection firstParentOfType:kSdefType_Suite] valueForKey:str];
      } @catch (id exception) {
        SPXLogException(exception);
        destination = nil;
      }
    }
      break;
      /* 4 Class content type */
    case kSdefType_Element:
      destination = [(SdefClass *)[selection firstParentOfType:kSdefType_Class] elements];
      break;
    case kSdefType_Property:
      destination = [(SdefClass *)[selection firstParentOfType:kSdefType_Class] properties];
      if (!destination) {
        destination = [selection firstParentOfType:kSdefType_RecordType];
      }
      break;
    case kSdefType_RespondsTo:
    {
      id str = [pboard stringForType:SdefInfoPboardType];
      @try {
        destination = [(SdefClass *)[selection firstParentOfType:kSdefType_Class] valueForKey:str];
      } @catch (id exception) {
        SPXLogException(exception);
        destination = nil;
      }
    }
      break;
      /* Misc */
    case kSdefType_Enumerator:
      destination = [selection firstParentOfType:kSdefType_Enumeration];
      break;
    case kSdefType_Parameter:
      destination = [selection firstParentOfType:kSdefType_Command];
      break;
    case kSdefType_Collection:
    {
      SdefSuite *suite = (SdefSuite *)[selection firstParentOfType:kSdefType_Suite];
      SdefClass *class = (SdefClass *)[selection firstParentOfType:kSdefType_Class];
      SdefObjectType type = [[(SdefCollection *)tree contentType] objectType];
      if ([[suite types] acceptsObjectType:type]) destination = [suite types];
      else if ([[suite classes] acceptsObjectType:type]) destination = [suite classes];
      else if ([[suite commands] acceptsObjectType:type] ||
               [[suite events] acceptsObjectType:type]) {
        id str = [pboard stringForType:SdefInfoPboardType];
        @try {
          destination = [suite valueForKey:str];
        } @catch (id exception) {
          SPXLogException(exception);
          destination = nil;
        }
      }
      else if ([[class elements] acceptsObjectType:type]) destination = [class elements];
      else if ([[class properties] acceptsObjectType:type]) destination = [class properties];
      else if ([[class commands] acceptsObjectType:type] || 
               [[class events] acceptsObjectType:type]) {
        id str = [pboard stringForType:SdefInfoPboardType];
        @try {
          destination = [class valueForKey:str];
        } @catch (id exception) {
          SPXLogException(exception);
          destination = nil;
        }
      }
    }
      break;
    default:
      break;
  }
  if (destination) {
    if ([tree objectType] == kSdefType_Collection) {
      id child;
      id children = [tree childEnumerator];
      while (child = [children nextObject]) {
        // TODO: child.remove may release child. Make sure ARC keep it alive
        [child remove];
        [destination appendChild:child];
      }
    } else {
      [destination appendChild:tree];
    }
  }
  else
    NSBeep();
}

@end

@implementation SdefDictionaryTree 

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  return item;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(SdefObject *)item {
  if (![[item name] isEqualToString:object]) {
    [item setName:object];
  }
}

#pragma mark -
#pragma mark Drag & Drop
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
  SdefObject *selection = [items objectAtIndex:0];
  if (selection != [self root] && [selection objectType] != kSdefType_Collection && selection.editable) {
    [pboard declareTypes:[NSArray arrayWithObject:SdefObjectDragType] owner:self];
    id value = [NSData dataWithBytes:&selection length:sizeof(id)];
    [pboard setData:value forType:SdefObjectDragType];
    return YES;
  } else {
    return NO;
  }
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info
                  proposedItem:(id)item proposedChildIndex:(int)anIndex {
  NSPasteboard *pboard = [info draggingPasteboard];
  
  if (item == nil && anIndex < 0)
    return NSDragOperationNone;
  
  if (![[pboard types] containsObject:SdefObjectDragType]) {
    return NSDragOperationNone;
  }
  id value = [pboard dataForType:SdefObjectDragType];
  SdefObject *object = nil;
  [value getBytes:&object length:sizeof(id)];
  
  SdefObjectType srcType = [[object parent] objectType];  
  
  if ([object objectType] == kSdefType_Property) {
    /* refuse if not record and not a collection that accept it */
    if ([item objectType] != kSdefType_RecordType &&
        ([item objectType] != kSdefType_Collection || ![item acceptsObjectType:kSdefType_Property]))
      return NSDragOperationNone;
  } else {    
    if (srcType != [item objectType]) {
      return NSDragOperationNone;
    }
    if (srcType == kSdefType_Collection && ![item acceptsObjectType:[object objectType]]) {
      return NSDragOperationNone;
    }
  }
  
  if ([object findRoot] != [self root] || NSDragOperationCopy == [info draggingSourceOperationMask])
    return NSDragOperationCopy;
  
  return NSDragOperationGeneric;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(SdefObject *)item childIndex:(int)anIndex {
  NSPasteboard *pboard = [info draggingPasteboard];
  if (![[pboard types] containsObject:SdefObjectDragType]) {
    return NO;
  }
  id value = [pboard dataForType:SdefObjectDragType];
  SdefObject *object = nil;
  [value getBytes:&object length:sizeof(id)];
  
  if (object) {
    return [self dropObject:object item:item childIndex:anIndex operation:[info draggingSourceOperationMask]];
  }
  
  return NO;
}

@end
