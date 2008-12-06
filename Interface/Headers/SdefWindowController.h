/*
 *  SdefWindowController.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

extern NSString * const SdefTreePboardType;
extern NSString * const SdefInfoPboardType;

extern NSString * const SdefDictionarySelectionDidChangeNotification;

@class WBSplitView;
@class SdefObject;
@class SdefDictionary, WBOutlineViewController;
@interface SdefWindowController : NSWindowController {
  IBOutlet NSOutlineView *outline;
  IBOutlet NSTabView *inspector;
  IBOutlet WBSplitView *uiSplitview;
  
  @private
    BOOL sd_remove;
  WBOutlineViewController *sd_tree;
  NSMutableDictionary *sd_viewControllers;
}

- (id)init;
- (void)setDictionary:(SdefDictionary *)dictionary;

- (void)displayObject:(SdefObject *)anObject;

- (SdefObject *)selection;
- (void)setSelection:(SdefObject *)anObject;

@end
