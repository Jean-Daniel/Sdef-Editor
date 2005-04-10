//
//  SdtplGenerator.h
//  Sdef Editor
//
//  Created by Grayfox on 04/04/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
  kSdtplInline		= 0,
  kSdtplSingleFile	= 1,
  kSdtplMultiFiles	= 2,
};

enum {
  kSdefTemplateDefaultFormat,
  kSdefTemplateXMLFormat,
};

@class SdefObject, SdefDictionary;
@class SdefTemplate, SdefClassManager;
@interface SdtplGenerator : NSObject {
  struct sd_gnflags {
    unsigned int toc:4; /* OK */
    unsigned int css:4; /* OK */
    unsigned int index:1;
    unsigned int suites:2;
    unsigned int classes:2;
    unsigned int events:2;
    unsigned int commands:2;
    /* User preferences */
    unsigned int sortSuites:1; /* OK */
    unsigned int sortOthers:1; /* OK */
    unsigned int subclasses:1; /* OK */
    unsigned int groupEvents:1; /* OK */
    unsigned int ignoreEvents:1; /* OK */
    unsigned int ignoreRespondsTo:1; /* OK */
    /* HTML Preferences */
    unsigned int links:1; /* OK */
    unsigned int format:2; /* OK */
    unsigned int:6;
  } gnflags;
  NSString *sd_path;
  NSString *sd_base;
  /* Template Bundle */
  SdefTemplate *sd_tpl;
  /* Caches */
  NSString *sd_link; /* Weak */
  NSString *sd_tocFile;
  NSString *sd_cssFile;
  SdefClassManager *sd_manager; /* Weak */
  NSMutableDictionary *sd_formats;
  CFMutableDictionaryRef sd_links, sd_files, sd_anchors;
}

#pragma mark Accessors

- (BOOL)indexToc;
- (BOOL)externalToc;
- (BOOL)dictionaryToc;

- (unsigned)toc;
- (void)setToc:(unsigned)toc;

- (BOOL)externalCss;
- (unsigned)css;
- (void)setCss:(unsigned)css;

- (BOOL)sortSuites;
- (void)setSortSuites:(BOOL)sort;

- (BOOL)sortOthers;
- (void)setSortOthers:(BOOL)sort;

- (BOOL)subclasses;
- (void)setSubclasses:(BOOL)flag;

- (BOOL)ignoreEvents;
- (void)setIgnoreEvents:(BOOL)flag;

- (BOOL)groupEventsAndCommands;
- (void)setGroupEventsAndCommands:(BOOL)flag;

- (BOOL)ignoreRespondsTo;
- (void)setIgnoreRespondsTo:(BOOL)flag;

#pragma mark HTML
- (BOOL)links;
- (void)setLinks:(BOOL)links;

- (SdefTemplate *)template;
- (void)setTemplate:(SdefTemplate *)aTemplate;

#pragma mark Generate Files
- (BOOL)writeDictionary:(SdefDictionary *)aDico toFile:(NSString *)aFile;

@end
