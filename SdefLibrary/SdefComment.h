//
//  SdefComment.h
//  Sdef Editor
//
//  Created by Grayfox on 19/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SdefComment : NSObject {
  NSString *sd_value;
}

+ (id)commentWithString:(NSString *)aString;
- (id)initWithString:(NSString *)aString;

- (NSString *)value;
- (void)setValue:(NSString *)value;

@end
