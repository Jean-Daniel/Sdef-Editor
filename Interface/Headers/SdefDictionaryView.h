//
//  SdefDictionaryView.h
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefViewController.h"

@interface SdefDictionaryView : SdefViewController {
  IBOutlet id suitesTable;
}

- (IBAction)addSuite:(id)sender;

@end
