//
//  SdefImporter.h
//  Sdef Editor
//
//  Created by Grayfox on 30/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SdefClassManager, SdefObject, SdefClass, SdefVerb, SdefEnumeration;
@interface SdefImporter : NSObject {
@protected
  NSMutableArray *suites;
  SdefClassManager *manager;
@private
  NSMutableArray *sd_warnings;
}

- (id)init;
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
- (void)postProcessClass:(SdefClass *)aClass;
- (void)postProcessCommand:(SdefVerb *)aCommand;
- (void)postProcessEnumeration:(SdefEnumeration *)anEnumeration;

- (BOOL)resolveObjectType:(SdefObject *)obj;

@end
