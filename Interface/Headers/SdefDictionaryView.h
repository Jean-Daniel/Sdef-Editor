/*
 *  SdefDictionaryView.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefViewController.h"

@interface SdefDictionaryView : SdefViewController {
  IBOutlet id suitesTable;
}

- (IBAction)addSuite:(id)sender;

@end
