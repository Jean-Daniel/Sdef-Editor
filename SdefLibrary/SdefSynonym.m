//
//  SdefSynonym.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefSynonym.h"

@implementation SdefSynonym

+ (SDObjectType)objectType {
  return kSDSynonymType;
}

+ (NSString *)defaultName {
  return @"synonym";
}

+ (NSString *)defaultIconName {
  return @"Misc";
}

- (void)dealloc {
  [super dealloc];
}

- (NSString *)desc {
  return nil;
}

- (void)setDesc:(NSString *)description {
}

#pragma mark -
#pragma mark XML Generation

- (NSString *)xmlElementName {
  return @"synonym";
}

#pragma mark -
#pragma mark Parsing




@end
