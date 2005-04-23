//
//  SimpleNode.h
//  SdtplChecker
//
//  Created by Grayfox on 12/04/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SKTreeNode.h"

@interface SimpleNode : SKTreeNode {
  NSImage *sd_icon;
  NSString *sd_name;
}

+ (id)nodeWithName:(NSString *)aName;
- (id)initWithName:(NSString *)aName;

- (NSImage *)icon;
- (void)setIcon:(NSImage *)anIcon;

- (NSString *)name;
- (void)setName:(NSString *)aName;

@end
