//
//  CocoaSuiteImporter.h
//  Sdef Editor
//
//  Created by Grayfox on 25/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefImporter.h"

@class SdefSuite ;
@interface CocoaSuiteImporter : SdefImporter {
  NSDictionary *sd_suite;
  NSDictionary *sd_terminology;

  NSMutableArray *sd_suites;
}

- (id)initWithContentsOfFile:(NSString *)file;
- (id)initWithSuiteFile:(NSString *)suite andTerminologyFile:(NSString *)aTerm;

- (SdefSuite *)sdefSuite;

- (NSDictionary *)suite;
- (void)setSuite:(NSDictionary *)aSuite;

- (NSDictionary *)terminology;
- (void)setTerminology:(NSDictionary *)aTerminology;

@end

