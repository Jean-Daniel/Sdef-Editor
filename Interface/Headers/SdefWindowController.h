//
//  SdefWindowController.h
//  SDef Editor
//
//  Created by Grayfox on 04/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const SdefDictionarySelectionDidChangeNotification;

@class SdefObject, SdefDocumentationWindow;
@interface SdefWindowController : NSWindowController {
  IBOutlet NSOutlineView *outline;
  IBOutlet NSTabView *inspector;
  
  NSMutableDictionary *_viewControllers;
}

- (id)initWithOwner:(id)owner;
- (SdefObject *)selection;

@end

@interface NSTabView (Extension)
- (int)indexOfSelectedTabViewItem;
@end

extern NSString * const SdefTreePboardType;

/*
@interface SdefEditorPasteManager : NSObject {
  SdefObject *sd_content;
}

+ (id)sharedManager;
- (id)content;
- (void)setContent:(SdefObject *)content;

@end
*/
