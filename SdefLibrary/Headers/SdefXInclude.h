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
  NSMutableArray *_nodes;
}

@property(nonatomic, copy) NSString *href;
@property(nonatomic, copy) NSString *pointer;

@end

