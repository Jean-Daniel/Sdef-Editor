/*
 *  ASDictionary.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#if !__LP64__
@class SdefDictionary;
WB_PRIVATE
NSDictionary *AppleScriptDictionaryFromSdefDictionary(SdefDictionary *sdef);
#endif
