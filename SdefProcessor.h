/*
 *  SdefProcessor.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

enum {
  kSdefUndefinedFormat 			= 0,
  kSdefResourceFormat 			= 1 << 0,
  kSdefScriptSuiteFormat 		= 1 << 1,
  kSdefScriptTerminologyFormat	= 1 << 2,
};
typedef NSInteger SdefProcessorFormat;

@class SdefDocument;
@interface SdefProcessor : NSObject {
  id sd_input;
  NSString *sd_output;
  NSArray *sd_includes;
  NSString *sd_version;
  NSMutableString *sd_msg;
  SdefProcessorFormat sd_format;
}

- (id)initWithFile:(NSString *)aSdefFile;
- (id)initWithSdefDocument:(SdefDocument *)aDocument;

- (NSString *)process;

- (id)input;
- (void)setInput:(id)input;

- (NSString *)output;
- (void)setOutput:(NSString *)output;

- (NSString *)version;
- (void)setVersion:(NSString *)aVersion;

- (NSArray *)includes;
- (void)setIncludes:(NSArray *)includes;

- (SdefProcessorFormat)format;
- (void)setFormat:(SdefProcessorFormat)aFormat;

@end
