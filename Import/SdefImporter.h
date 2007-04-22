/*
 *  SdefImporter.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class SdefDictionary;
@class SdefClassManager, SdefObject, SdefEnumeration;
@class SdefVerb, SdefDirectParameter, SdefParameter, SdefResult;
@class SdefClass, SdefContents, SdefElement, SdefProperty, SdefRespondsTo;
@interface SdefImporter : NSObject {
@protected
  NSMutableArray *suites;
  SdefClassManager *manager;
@private
  NSMutableArray *sd_warnings;
}

- (id)initWithContentsOfFile:(NSString *)file;

/*!
    @method     import
    @abstract   Import a script terminology.
    @result     YES if file imported.
*/
- (BOOL)import;
- (NSArray *)warnings;
- (NSUInteger)suiteCount;
- (NSArray *)sdefSuites;
- (SdefDictionary *)sdefDictionary;

#pragma mark -
- (void)addWarning:(NSString *)warning forValue:(NSString *)value node:(SdefObject *)node;

#pragma mark -
- (void)postProcess;
- (BOOL)resolveObjectType:(SdefObject *)obj;

#pragma mark Class
/* two passes post-process (for aete) */
- (void)postProcessClass:(SdefClass *)aClass;
- (void)postProcessClassContent:(SdefClass *)aClass;

- (void)postProcessContents:(SdefContents *)aContents forClass:aClass;
- (void)postProcessElement:(SdefElement *)anElement inClass:(SdefClass *)aClass;
- (void)postProcessProperty:(SdefProperty *)aProperty inClass:(SdefClass *)aClass;
- (void)postProcessRespondsTo:(SdefRespondsTo *)aCmd inClass:(SdefClass *)aClass;

#pragma mark Verb
- (void)postProcessCommand:(SdefVerb *)aCommand;
- (void)postProcessDirectParameter:(SdefDirectParameter *)aParameter inCommand:(SdefVerb *)aCmd;
- (void)postProcessParameter:(SdefParameter *)aParameter inCommand:(SdefVerb *)aCmd;
- (void)postProcessResult:(SdefResult *)aResult inCommand:(SdefVerb *)aCmd;

#pragma mark Enumeration
- (void)postProcessEnumeration:(SdefEnumeration *)anEnumeration;



@end
