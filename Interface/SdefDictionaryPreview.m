/*
 *  SdefDictionaryPreview.m
 *  Sdef Editor
 *
 *  Created by Grayfox on 25/04/07.
 *  Copyright 2007 Shadow Lab. All rights reserved.
 */

#import "SdefDictionaryPreview.h"

#import "SdefEditor.h"

#import "OSADictionary.h"
#import "OSADictionaryView.h"
#import "OSADictionaryController.h"

@implementation SdefDictionaryPreview

- (id)init {
  if (self = [super init]) {
  }
  return self;
}

- (void)dealloc {
  [sd_dict release];
  [super dealloc];
}

- (void)awakeFromNib {
  [ibDictionary setDictionary:sd_dict];
  /*
   0: search result
   1: inheritance browser
   2: container browser
   3: suite browser
   4: crash
   */
  [[ibDictionary dictionaryView] setViewMode:2];
}

- (void)setDocument:(NSDocument *)document {
  if (document) {
    NSData *data = [document dataOfType:ScriptingDefinitionFileType error:nil];
    if (data) {
      id error;
      if (sd_dict) [sd_dict release];
      
      sd_dict = [[OSADictionary alloc] initWithData:data error:&error];
      if (error)
        DLog(@"Error: %@", error);
    }
  }
  [super setDocument:document];
}

@end
