/*
*   SdefTemplate.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

enum {
  kSdefTemplateTOCNone			= 0,
  kSdefTemplateTOCIndex			= 1 << 0,
  kSdefTemplateTOCDictionary	= 1 << 1,
  kSdefTemplateTOCExternal		= 1 << 2,
  kSdefTemplateTOCRequired		= 1 << 3
};

enum {
  kSdefTemplateCSSNone		= 0,
  kSdefTemplateCSSInline	= 1 << 0,
  kSdefTemplateCSSExternal	= 1 << 1
};

/* Definition */
extern NSString * const SdtplDefinitionTocKey;
extern NSString * const SdtplDefinitionIndexKey;
extern NSString * const SdtplDefinitionDictionaryKey;
extern NSString * const SdtplDefinitionSuitesKey;
extern NSString * const SdtplDefinitionClassesKey;
extern NSString * const SdtplDefinitionCommandsKey;
extern NSString * const SdtplDefinitionEventsKey;

/* Definition Options */
extern NSString * const SdtplDefinitionFileKey;
extern NSString * const SdtplDefinitionSingleFileKey;
extern NSString * const SdtplDefinitionRemoveBlockLine;

/* Variables */
extern NSString * const StdplVariableLinks;
extern NSString * const StdplVariableStyleLink;
extern NSString * const StdplVariableAnchorFormat;

/* Misc */
extern NSString * const SdefInvalidTemplateException;
extern NSString * const SdefTemplateDidChangeNotification;

@class SKTemplate;
@interface SdefTemplate : NSObject {
  NSString *sd_path;
  NSString *sd_name;
  struct _sd_tpFlags {
    unsigned int css:4;
    unsigned int toc:4;
    unsigned int html:1;
    unsigned int :7;
  } sd_tpFlags;
  NSArray *sd_styles;
  NSString *sd_information;
  NSDictionary *sd_selectedStyle; /* Weak */
  NSMutableDictionary *sd_infos, *sd_tpls, *sd_def;
}

+ (NSDictionary *)findAllTemplates;

- (NSString *)path;
- (void)setPath:(NSString *)path;

- (NSString *)information;
- (NSString *)displayName;
- (NSString *)extension;
- (NSString *)menuName;

- (NSDictionary *)formats;
- (NSDictionary *)templates;
- (NSDictionary *)definition;

- (NSArray *)styles;
- (NSDictionary *)selectedStyle;
- (void)setSelectedStyle:(NSDictionary *)style;

- (BOOL)isHtml;

- (BOOL)indexToc;
- (BOOL)dictionaryToc;
- (BOOL)externalToc;
- (BOOL)requiredToc;

- (unsigned)toc;
- (void)setToc:(unsigned)toc;

- (unsigned)css;
- (void)setCss:(unsigned)css;

@end
