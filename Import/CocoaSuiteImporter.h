//
//  CocoaSuiteImporter.h
//  Sdef Editor
//
//  Created by Grayfox on 25/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SdefSuite ;
@interface CocoaSuiteImporter : NSObject {
  SdefSuite *sd_sdefSuite;
  NSDictionary *sd_suite;
  NSDictionary *sd_terminology;

  NSMutableArray *sd_suites;
  NSMutableArray *sd_warnings;
}

- (id)initWithFile:(NSString *)file;
- (id)initWithSuiteFile:(NSString *)suite andTerminologyFile:(NSString *)aTerm;

- (BOOL)import;
- (SdefSuite *)sdefSuite;

- (NSDictionary *)suite;
- (void)setSuite:(NSDictionary *)aSuite;

- (NSDictionary *)terminology;
- (void)setTerminology:(NSDictionary *)aTerminology;

- (NSArray *)warnings;

@end
