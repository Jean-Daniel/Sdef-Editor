//
//  CocoaObject.h
//  Sdef Editor
//
//  Created by Grayfox on 03/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

@interface SdefObject (CocoaTerminology)
- (id)initWithName:(NSString *)name suite:(NSDictionary *)suite andTerminology:(NSDictionary *)terminology;
@end
