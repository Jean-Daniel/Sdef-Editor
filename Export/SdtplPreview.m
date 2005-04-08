//
//  SdtplPreview.m
//  Sdef Editor
//
//  Created by Grayfox on 02/04/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdtplPreview.h"
#import <WebKit/WebKit.h>

#import "SKFSFunctions.h"
#import "SdefTemplate.h"
#import "SdtplExporter.h"
#import "SdefDocument.h"
#import "SdefDictionary.h"

@implementation SdtplPreview

- (void)dealloc {
  /* Release sd_tpl and delete sd_tmp */
  [self setTemplate:nil];
  [sd_exporter release];
  [super dealloc];
}

- (void)awakeFromNib {
  [self refresh];
}

- (NSString *)temporaryFile {
  if (!sd_tmp) {
    sd_tmp = (id)SKTemporaryFileCopy(kUserDomain, nil, (CFStringRef)[sd_tpl extension], kCFURLPOSIXPathStyle);
    prflags.pathChanged = 1;
  }
  return sd_tmp;
}

- (SdtplExporter *)exporter {
  if (!sd_exporter) {
    sd_exporter = [[SdtplExporter alloc] init];
    id sample = SdefLoadDictionary([[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"sdef" inDirectory:@"Templates"]);
    [sd_exporter setDictionary:sample];
  }
  return sd_exporter;
}

- (void)refresh {
  if (sd_tpl && view) {
    unsigned css = [sd_tpl css];
    unsigned toc = [sd_tpl toc];
    [sd_tpl setCss:kSdefTemplateCSSInline];
    if (kSdefTemplateTOCExternal == toc) {
      [sd_tpl setToc:kSdefTemplateTOCNone];
    }
    
    id exporter = [self exporter];
    [exporter setTemplate:sd_tpl];
    @try {
      [exporter writeToFile:[self temporaryFile] atomically:NO];
    } @catch (id exception) {
      SKLogException(exception);
    }
    [sd_tpl setCss:css];
    [sd_tpl setToc:toc];
    
    if (prflags.pathChanged) {
      [view takeStringURLFrom:self];
      prflags.pathChanged = 0;
    }
    else {
      [view reload:nil];
    }
  }
}

- (SdefTemplate *)template {
  return sd_tpl;
}

- (void)setTemplate:(SdefTemplate *)tpl {
  if (sd_tpl != tpl) {
    [sd_tpl release];
    sd_tpl = [tpl retain];
    /* Reset temporary file */
    if (sd_tmp) {
      [[NSFileManager defaultManager] removeFileAtPath:sd_tmp handler:nil];
      [sd_tmp release];
      sd_tmp = nil;
    }
  }
}

#pragma mark -
#pragma mark WebView CallBack
- (NSString *)stringValue {
  id url = [[NSURL fileURLWithPath:[self temporaryFile]] absoluteString];
  return url;
}

@end
