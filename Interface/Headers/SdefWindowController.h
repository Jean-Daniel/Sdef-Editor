//
//  SdefWindowController.h
//  SDef Editor
//
//  Created by Grayfox on 04/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const SdefTreePboardType;
extern NSString * const SdefInfoPboardType;

extern NSString * const SdefDictionarySelectionDidChangeNotification;

@class SdefObject;
@interface SdefWindowController : NSWindowController {
  IBOutlet NSOutlineView *outline;
  IBOutlet NSTabView *inspector;
  
  NSMutableDictionary *_viewControllers;
}

- (id)initWithOwner:(id)owner;

- (void)displayObject:(SdefObject *)anObject;

- (SdefObject *)selection;
- (void)setSelection:(SdefObject *)anObject;

@end

@interface NSTabView (Extension)
- (int)indexOfSelectedTabViewItem;
@end
