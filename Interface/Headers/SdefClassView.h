/*
 *  SdefClassView.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefViewController.h"

@interface SdefClassView : SdefViewController {
  IBOutlet NSTabView *tab;
  IBOutlet NSArrayController *properties;
  IBOutlet NSArrayController *elements;
  IBOutlet NSArrayController *commands;
  IBOutlet NSArrayController *events;
  
  IBOutlet id commandTable;
  IBOutlet id eventTable;
  @private
    int sd_idx;
}

@end
