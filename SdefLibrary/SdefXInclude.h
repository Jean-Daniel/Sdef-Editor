/*
 *  SdefXInclude.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"

@interface SdefXInclude : SdefLeaf <NSCopying, NSCoding> {
  @private
  NSString *sd_href;
  NSString *sd_pointer;
  
  NSMutableArray *sd_nodes;
}

- (NSString *)href;
- (void)setHref:(NSString *)aRef;

- (NSString *)pointer;
- (void)setPointer:(NSString *)aPointer;

@end

