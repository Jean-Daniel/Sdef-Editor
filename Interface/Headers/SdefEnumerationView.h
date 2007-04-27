/*
 *  SdefEnumerationView.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefViewController.h"

@interface SdefEnumerationView : SdefViewController {
  IBOutlet NSTabView *uiTab;
  IBOutlet NSArrayController *ibEnumerators;
}

@end

@interface SdefRecordView : SdefViewController {
  IBOutlet NSTabView *uiTab;
  IBOutlet NSArrayController *ibProperties;
}

@end
