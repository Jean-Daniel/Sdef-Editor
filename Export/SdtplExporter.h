//
//  SdtplExporter.h
//  Sdef Editor
//
//  Created by Grayfox on 06/03/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
  kSdefTemplateDefaultFormat,
  kSdefTemplateXMLFormat,
} SdefTemplateFormat;

@class SdefTemplate, SdefDictionary;
@interface SdtplExporter : NSObject {
  SdefDictionary *sd_dictionary;
  struct _xd_flags {
    unsigned int sort:1;
    unsigned int links:1;
    unsigned int:6;
  } xd_flags;
  SdefTemplate *sd_tpl;
  SdefTemplateFormat sd_format;
  NSMutableDictionary *sd_formats;
  NSMutableDictionary *sd_anchors;
}

- (SdefTemplate *)template;
- (void)setTemplate:(SdefTemplate *)tpl;

- (SdefDictionary *)dictionary;
- (void)setDictionary:(SdefDictionary *)theDictionary;

- (BOOL)writeToFile:(NSString *)file atomically:(BOOL)flag;

@end
