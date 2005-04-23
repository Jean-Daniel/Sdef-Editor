//
//  SdefTemplateCheck.h
//  SdefTemplateChecker
//
//  Created by Grayfox on 09/04/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SdefTemplate;
@interface SdefTemplateCheck : NSObject {
  NSString *sd_path;
  SdefTemplate *sd_tpl;
  NSMutableDictionary *sd_errors;
  NSMutableDictionary *sd_definitions;
}

- (id)initWithFile:(NSString *)path;

- (NSString *)path;
- (void)setPath:(NSString *)path;

- (SdefTemplate *)template;
- (NSMutableDictionary *)errors;

- (BOOL)checkTemplate;
- (BOOL)checkTemplateContent;

@end
