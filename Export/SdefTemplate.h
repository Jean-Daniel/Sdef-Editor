//
//  SdefTemplate.h
//  Sdef Editor
//
//  Created by Grayfox on 28/03/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
  kSdefTemplateTOCNone		= 0,
  kSdefTemplateTOCInline	= 1,
  kSdefTemplateTOCExternal	= 2
};

enum {
  kSdefTemplateCSSInline	= 0,
  kSdefTemplateCSSNone		= 1
};

extern NSString * const kSdefTemplateDidChangeNotification;

@class SKTemplate;
@interface SdefTemplate : NSObject {
  NSString *sd_path;
  NSString *sd_name;
  struct _tp_flags {
    unsigned int css:4;
    unsigned int toc:4;
    unsigned int sort:1;
    unsigned int html:1;
    unsigned int links:1;
    unsigned int removeBlockLine:1;
    unsigned int :2;
  } tp_flags;
  NSArray *sd_styles;
  NSMutableDictionary *sd_infos;
  SKTemplate *sd_layout, *sd_toc;
  NSDictionary *sd_selectedStyle;
}

+ (NSDictionary *)findAllTemplates;

- (NSString *)path;
- (void)setPath:(NSString *)path;

- (SKTemplate *)tocTemplate;
- (SKTemplate *)layoutTemplate;

- (NSString *)displayName;
- (NSString *)extension;
- (NSString *)menuName;

- (NSDictionary *)formats;

- (NSArray *)styles;
- (NSDictionary *)selectedStyle;
- (void)setSelectedStyle:(NSDictionary *)style;

- (BOOL)html;

- (unsigned)toc;
- (void)setToc:(unsigned)toc;
- (unsigned)css;
- (void)setCss:(unsigned)css;

- (BOOL)sort;
- (void)setSort:(BOOL)flag;
- (BOOL)links;
- (void)setLinks:(BOOL)flag;

@end
