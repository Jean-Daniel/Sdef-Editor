/*
 *  SdefLeopardParser.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefLeopardParser.h"
#import "SdefBase.h"
#import "SdefObjects.h"
#import "SdefXMLBase.h"

@implementation SdefLeopardParser

- (SdefParserVersion)parserVersion {
  return kSdefParserLeopardVersion;
}

- (SdefParserVersion)supportedVersions {
  return kSdefParserLeopardVersion;
}

- (void)parser:(CFXMLParserRef)parser didStartXref:(NSDictionary *)attributes {
  if (sd_node) {
    if (![sd_node hasXrefs]) {
      NSString *msg = [NSString stringWithFormat:@"Unexpected xref element in %@ element", [sd_node xmlElementName]];
      CFXMLParserAbort(parser, kCFXMLErrorMalformedDocument, (CFStringRef)msg);
    } else {
      SdefXRef *xref = [[SdefXRef allocWithZone:[self zone]] init];
      [xref setAttributes:attributes];
      [sd_node addXrefs:xref];
      [xref release];
    }
  }
}

- (void)parser:(CFXMLParserRef)parser didEndElement:(NSString *)element {
  if (![element isEqualToString:@"xref"]) {
    [super parser:parser didEndElement:element];
  }
}

- (void)parser:(CFXMLParserRef)parser didStartElement:(NSString *)element withAttributes:(NSDictionary *)attributes {
  if ([element isEqualToString:@"xref"]) {
    [self parser:parser didStartXref:attributes];
  } else {
    [super parser:parser didStartElement:element withAttributes:attributes];
  }
}

@end
