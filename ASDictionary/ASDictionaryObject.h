//
//  ASDictionaryObject.h
//  Sdef Editor
//
//  Created by Grayfox on 27/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"
#import "ShadowMacros.h"

@interface SdefObject (ASDictionary)

- (NSDictionary *)asdictionary;
- (NSDictionary *)asdictionaryString;
- (NSString *)sdefTypeToASDictionaryType:(NSString *)type;

@end
