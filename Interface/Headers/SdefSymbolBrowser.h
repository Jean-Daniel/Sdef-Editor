/*
 *  SdefSymbolBrowser.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

typedef enum {
  kSdefSearchAll,
  kSdefSearchCode,
	kSdefSearchType,
  kSdefSearchSuite,
  kSdefSearchSymbol,
  kSdefSearchSymbolType
} SdefSearchField;

@class SdefSuite;
@class WBTableDataSource;
@interface SdefSymbolBrowser : NSWindowController {
  SdefSearchField sd_filter;
  NSSearchField *searchField;
  IBOutlet id symbolTable;
  IBOutlet NSDrawer *editDrawer;
  IBOutlet WBTableDataSource *symbols;
}

- (void)createToolbar;
- (IBAction)limitSearch:(id)sender;

- (void)loadSymbols;
- (void)addSuite:(SdefSuite *)aSuite;
- (void)removeSuite:(SdefSuite *)aSuite;

@end
