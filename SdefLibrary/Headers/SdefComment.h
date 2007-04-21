/*
 *  SdefComment.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@interface SdefComment : NSObject <NSCopying, NSCoding> {
  NSString *sd_value;
}

+ (id)commentWithString:(NSString *)aString;
- (id)initWithString:(NSString *)aString;

- (NSString *)value;
- (void)setValue:(NSString *)value;

@end
