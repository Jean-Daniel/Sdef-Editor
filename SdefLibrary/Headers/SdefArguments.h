//
//  SdefArguments.h
//  SDef Editor
//
//  Created by Grayfox on 05/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

@interface SdefParameter : SdefTerminologyElement <NSCopying, NSCoding> {
  BOOL sd_optional;
  NSString *sd_type; 
}

- (BOOL)isOptional;
- (void)setOptional:(BOOL)flag;

- (NSString *)type;
- (void)setType:(NSString *)aType;

@end

#pragma mark -
@interface SdefDirectParameter : SdefOrphanObject <NSCopying, NSCoding> {
  BOOL sd_optional;
  NSString *sd_type; 
  NSString *sd_desc;
}

- (BOOL)isOptional;
- (void)setOptional:(BOOL)flag;

- (NSString *)type;
- (void)setType:(NSString *)aType;

- (NSString *)desc;
- (void)setDesc:(NSString *)aDesc;

@end

#pragma mark -
@interface SdefResult : SdefOrphanObject <NSCopying, NSCoding> {
  NSString *sd_type; 
  NSString *sd_desc;
}

- (NSString *)type;
- (void)setType:(NSString *)aType;

- (NSString *)desc;
- (void)setDesc:(NSString *)aDesc;

@end
