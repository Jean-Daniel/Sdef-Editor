//
//  SdefXMLNode.h
//  SDef Editor
//
//  Created by Grayfox on 08/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SKTreeNode.h"

@interface SdefXMLNode : SKTreeNode {
  BOOL empty;
  NSString *sd_name;
  NSMutableArray *sd_attrKeys, *sd_attrValues;
  
  NSMutableArray *sd_comments;
  NSString * sd_content;
}

+ (id)nodeWithElementName:(NSString *)aName;
- (id)initWithElementName:(NSString *)name;

- (BOOL)isEmpty;
- (void)setEmpty:(BOOL)flag;

- (NSString *)elementName;
- (void)setElementName:(NSString *)aName;

- (unsigned)attributeCount;

- (NSArray *)attrKeys;
- (NSArray *)attrValues;

- (id)attributForKey:(NSString *)key;
- (void)setAttribute:(NSString *)value forKey:(NSString *)key;
- (void)removeAttributeForKey:(NSString *)key;

- (NSString *)content;
- (void)setContent:(NSString *)aContent;

- (NSArray *)comments;
- (void)setComments:(NSArray *)comments;
- (void)addComment:(NSString *)comment;
- (void)removeCommentAtIndex:(unsigned)index;

@end
