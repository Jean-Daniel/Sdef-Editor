/*
 *  SdefToolbar.m
 *  Sdef Editor
 *
 *  Created by Grayfox on 22/04/07.
 *  Copyright 2007 Shadow Lab. All rights reserved.
 */

#import "SdefWindowController.h"

@implementation SdefWindowController (SdefToolbarDelegate)

NSString *SdefSaveDocToolbarItemIdentifier = @"org.shadowlab.sdef.toolbar.save";
NSString *SdefOpenReferenceToolbarItemIdentifier = @"org.shadowlab.sdef.toolbar.reference";

- (NSArray *)toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
  return @[SdefSaveDocToolbarItemIdentifier,
    SdefOpenReferenceToolbarItemIdentifier,
    //NSToolbarPrintItemIdentifier,
    //NSToolbarShowColorsItemIdentifier,
    //NSToolbarShowFontsItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarSpaceItemIdentifier,
    NSToolbarSeparatorItemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
  return @[SdefSaveDocToolbarItemIdentifier,
    NSToolbarSeparatorItemIdentifier,
    SdefOpenReferenceToolbarItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarSpaceItemIdentifier];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag {
  NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
  
  if ([itemIdentifier isEqual:SdefSaveDocToolbarItemIdentifier]) {
    // Set the text label to be displayed in the 
    // toolbar and customization palette 
    [toolbarItem setLabel:@"Save"];
    [toolbarItem setPaletteLabel:@"Save"];
    
    // Set up a reasonable tooltip, and image
    // you will likely want to localize many of the item's properties 
    [toolbarItem setToolTip:@"Save Your Document"];
    [toolbarItem setImage:[NSImage imageNamed:@"SaveDocumentItemImage"]];
    
    // Tell the item what message to send when it is clicked 
    //[toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(saveDocument:)];
  } else if ([itemIdentifier isEqualToString:SdefOpenReferenceToolbarItemIdentifier]) {
    [toolbarItem setLabel:@"Sdef Reference"];
    [toolbarItem setPaletteLabel:@"Sdef Reference"];
    
    [toolbarItem setToolTip:@"Open Sdef format Reference"];
    [toolbarItem setImage:[NSImage imageNamed:@"SdefReference"]];
    
    [toolbarItem setAction:@selector(openSdefReference:)];
  } else {
    // itemIdentifier referred to a toolbar item that is not
    // provided or supported by us or Cocoa 
    // Returning nil will inform the toolbar
    // that this kind of item is not supported 
    toolbarItem = nil;
  }
  return toolbarItem;
}

@end
