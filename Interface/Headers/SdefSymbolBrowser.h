/*
 *  SdefSymbolBrowser.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

typedef enum {
  kSdefSearchAll,
  kSdefSearchCode,
  kSdefSearchSuite,
  kSdefSearchSymbol,
  kSdefSearchSymbolType
} SdefSearchField;

@class SdefSuite;
@class SKTableDataSource;
@interface SdefSymbolBrowser : NSWindowController {
  SdefSearchField sd_filter;
  NSSearchField *searchField;
  IBOutlet id symbolTable;
  IBOutlet NSDrawer *editDrawer;
  IBOutlet SKTableDataSource *symbols;
}

- (void)createToolbar;
- (IBAction)limitSearch:(id)sender;

- (void)loadSymbols;
- (void)addSuite:(SdefSuite *)aSuite;
- (void)removeSuite:(SdefSuite *)aSuite;

@end
