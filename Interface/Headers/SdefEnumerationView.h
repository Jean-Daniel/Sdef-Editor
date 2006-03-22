/*
 *  SdefEnumerationView.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefViewController.h"

@interface SdefEnumerationView : SdefViewController {
  IBOutlet id tab;
  IBOutlet NSArrayController *enumerators;
}

@end

@interface SdefRecordView : SdefViewController {
  IBOutlet id tab;
  IBOutlet NSArrayController *properties;
}

@end
