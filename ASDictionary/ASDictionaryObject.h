/*
 *  ASDictionaryObject.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

@interface SdefObject (ASDictionary)

- (NSDictionary *)asdictionary;
- (NSDictionary *)asdictionaryString;
- (NSString *)asDictionaryTypeForType:(NSString *)type isList:(BOOL *)list;

@end
