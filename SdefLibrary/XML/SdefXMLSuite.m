/*
 *  SdefXMLSuite.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefSuite.h"
#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

@implementation SdefSuite (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"suite";
}

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:version]) {
    
  }
  return node;
}

#pragma mark Parsing
- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[element methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");
  
    /* element that contains id */
  if (isEqual(element, cmd, @"class") || 
      isEqual(element, cmd, @"command") || 
      isEqual(element, cmd, @"event")) {
    /* If id => Leopard, else Tiger or Leopard */
    return [attrs objectForKey:@"id"] ? kSdefParserLeopardVersion : kSdefParserTigerVersion | kSdefParserLeopardVersion;
  } else if (isEqual(element, cmd, @"enumeration") || 
             isEqual(element, cmd, @"value-type") || 
             isEqual(element, cmd, @"record-type")) {
    return kSdefParserTigerVersion | kSdefParserLeopardVersion;
  } else if (isEqual(element, cmd, @"class-extension")) {
    return kSdefParserLeopardVersion;
  } else /* If a collection => Panther */
  if (isEqual(element, cmd, @"types") || 
      isEqual(element, cmd, @"classes") || 
      isEqual(element, cmd, @"commands") || 
      isEqual(element, cmd, @"events")) {
    return kSdefParserPantherVersion;
  }
  return kSdefParserAllVersions;
}

@end
