//
//  SdefClassView.h
//  SDef Editor
//
//  Created by Grayfox on 12/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefViewController.h"

@interface SdefClassView : SdefViewController {
  IBOutlet NSTabView *tab;
  IBOutlet NSArrayController *properties;
  IBOutlet NSArrayController *elements;
  IBOutlet NSArrayController *commands;
  IBOutlet NSArrayController *events;
}

@end
