/*
 *  ASDictionaryObject.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefBase.h"

@interface SdefObject (ASDictionary)

#if !__LP64__

- (NSDictionary *)asdictionary;
- (NSDictionary *)asdictionaryString;

#endif /* LP64 */

- (NSString *)asDictionaryTypeForType:(NSString *)type isList:(BOOL *)list;

@end
