/*
 *  SdtplGenerator.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

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

SK_PRIVATE
NSString * const SdtplBlockTableOfContent;

@class SdefObject, SdefDictionary;
@class SdefTemplate, SdefClassManager;
@interface SdtplGenerator : NSObject {
  struct _sd_gnFlags {
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
    /* Internal use */
    unsigned int cancel:1;
    unsigned int existingFile:2;
    unsigned int useBlockFormat:1;
    unsigned int:2;
  } sd_gnFlags;
  NSString *sd_path;
  NSString *sd_base;
  /* Template Bundle */
  SdefTemplate *sd_tpl;
  /* Caches */
  NSString *sd_link; /* Weak */
  NSString *sd_tocFile;
  NSString *sd_cssFile;
  NSMutableSet *sd_cancel;
  SdefClassManager *sd_manager; /* Weak */
  NSMapTable *sd_formats;
  NSMapTable *sd_links, *sd_files, *sd_anchors;
}

#pragma mark Accessors

- (BOOL)indexToc;
- (BOOL)externalToc;
- (BOOL)dictionaryToc;

- (NSUInteger)toc;
- (void)setToc:(NSUInteger)toc;

- (BOOL)externalCss;
- (NSUInteger)css;
- (void)setCss:(NSUInteger)css;

- (NSString *)tocFile;
- (void)setTocFile:(NSString *)aFile;

- (NSString *)cssFile;
- (void)setCssFile:(NSString *)aFile;

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
