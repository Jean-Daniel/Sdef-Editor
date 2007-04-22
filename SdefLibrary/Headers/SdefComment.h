/*
 *  SdefComment.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"

@interface SdefComment : SdefLeaf <NSCopying, NSCoding> {
  NSString *sd_value;
}

+ (id)commentWithString:(NSString *)aString;
- (id)initWithString:(NSString *)aString;

- (NSString *)value;
- (void)setValue:(NSString *)value;

@end
