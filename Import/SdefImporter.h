//
//  SdefImporter.h
//  Sdef Editor
//
//  Created by Grayfox on 30/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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
- (unsigned)suiteCount;
- (NSArray *)sdefSuites;

#pragma mark -
- (void)addWarning:(NSString *)warning forValue:(NSString *)value;

#pragma mark -
- (void)postProcess;
- (BOOL)resolveObjectType:(SdefObject *)obj;

#pragma mark Class
- (void)postProcessClass:(SdefClass *)aClass;
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
