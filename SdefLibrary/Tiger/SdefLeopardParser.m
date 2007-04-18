/*
 *  SdefLeopardParser.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefLeopardParser.h"

@implementation SdefLeopardParser

- (SdefParserVersion)parserVersion {
  return kSdefParserLeopardVersion;
}

- (SdefParserVersion)supportedVersions {
  return kSdefParserLeopardVersion;
}

- (void)parser:(CFXMLParserRef)parser didStartElement:(NSString *)element withAttributes:(NSDictionary *)attributes {
  if ([element isEqualToString:@"xref"]) {
    DLog(@"xref found");
  } else {
    [super parser:parser didStartElement:element withAttributes:attributes];
  }
}

@end
