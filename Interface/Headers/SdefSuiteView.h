//
//  SdefSuiteView.h
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefViewController.h"

@interface SdefSuiteView : SdefViewController {
  IBOutlet NSTabView *tab;
  IBOutlet id typeTable;
  IBOutlet id classTable;
  IBOutlet id commandTable;
  IBOutlet id eventTable;
}

@end
