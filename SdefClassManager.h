//
//  SdefClassManager.h
//  SDef Editor
//
//  Created by Grayfox on 17/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTreeNode.h"

@class SdefClass, SdefDocument, SdefDictionary;
@interface SdefClassManager : NSObject {
@private
  SdefDocument *sd_document;
  NSMutableArray *sd_classes, *sd_commands, *sd_events, *sd_types;
}

- (id)initWithDocument:(SdefDocument *)aDocument;

- (void)addDictionary:(SdefDictionary *)aDico;
- (void)removeDictionary:(SdefDictionary *)aDico;

- (NSArray *)types;
- (NSArray *)classes;

- (NSArray *)commands;
- (NSArray *)events;

- (SdefClass *)classWithName:(NSString *)name;
- (SdefClass *)superClassOfClass:(SdefClass *)aClass;

@end
