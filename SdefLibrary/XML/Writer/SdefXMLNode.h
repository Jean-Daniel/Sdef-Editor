/*
 *  SdefXMLNode.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <WonderBox/WBTreeNode.h>

@interface SdefXMLNode : WBTreeNode {
  BOOL _list;
  BOOL _empty;
  BOOL _cddata;
  NSString *_name;
  NSMutableArray *sd_attrKeys, *sd_attrValues;
  
  NSString *_content;
  NSMutableArray *sd_comments;
  NSMutableDictionary *sd_metas;
  NSMutableDictionary *sd_postmetas;
}

+ (id)nodeWithElementName:(NSString *)aName;
- (id)initWithElementName:(NSString *)name;

@property(nonatomic, copy) NSString *elementName;
@property(nonatomic, copy) NSString *content;

@property(nonatomic, getter = isList) BOOL list;
@property(nonatomic, getter = isEmpty) BOOL empty;
@property(nonatomic, getter = isCDData) BOOL CDData;

- (NSUInteger)attributeCount;

- (NSArray *)attrKeys;
- (NSArray *)attrValues;

- (NSString *)attributForKey:(NSString *)key;
- (void)setAttribute:(NSString *)value forKey:(NSString *)key;
- (void)addAttributesFromDictionary:(NSDictionary *)dict;
- (void)removeAttributeForKey:(NSString *)key;
- (void)removeAllAttributes;

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
