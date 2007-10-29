/*
 *  SdefXMLNode.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <ShadowKit/SKTreeNode.h>

@interface SdefXMLNode : SKTreeNode {
  BOOL sd_list;
  BOOL sd_empty;
  BOOL sd_cddata;
  NSString *sd_name;
  NSMutableArray *sd_attrKeys, *sd_attrValues;
  
  NSString * sd_content;
  NSMutableArray *sd_comments;
  NSMutableDictionary *sd_metas;
  NSMutableDictionary *sd_postmetas;
}

+ (id)nodeWithElementName:(NSString *)aName;
- (id)initWithElementName:(NSString *)name;

- (BOOL)isList;
- (void)setList:(BOOL)flag;

- (BOOL)isEmpty;
- (void)setEmpty:(BOOL)flag;

- (BOOL)isCDData;
- (void)setCDData:(BOOL)flag;

- (NSString *)elementName;
- (void)setElementName:(NSString *)aName;

- (NSUInteger)attributeCount;

- (NSArray *)attrKeys;
- (NSArray *)attrValues;

- (NSString *)attributForKey:(NSString *)key;
- (void)setAttribute:(NSString *)value forKey:(NSString *)key;
- (void)addAttributesFromDictionary:(NSDictionary *)dict;
- (void)removeAttributeForKey:(NSString *)key;
- (void)removeAllAttributes;

- (NSString *)content;
- (void)setContent:(NSString *)aContent;

- (NSArray *)comments;
- (void)setComments:(NSArray *)comments;
- (void)addComment:(NSString *)comment;
- (void)removeCommentAtIndex:(NSUInteger)index;

/* set nil value to remove a meta */
- (NSDictionary *)metas;
- (NSDictionary *)postmetas;
- (void)setMeta:(NSString *)value forKey:(NSString *)key;
- (void)setPostMeta:(NSString *)value forKey:(NSString *)key;

@end
