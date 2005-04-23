//
//  SdtplChecker.h
//  SdefTemplateChecker
//
//  Created by Grayfox on 10/04/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SdefTemplateCheck;
@interface SdtplChecker : NSObject {
  IBOutlet id errors;
  IBOutlet id warnings;
  IBOutlet id templatesTree;
  NSMutableArray *templates;
  SdefTemplateCheck *checker;
}

@end

@interface SdefBooleanTransformer : NSValueTransformer {
}

+ (id)transformer;

@end
