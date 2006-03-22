/*
 *  SdefXMLEnumeration.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefTypedef.h"

#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

@implementation SdefEnumeration (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"enumeration";
}

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)aVersion {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:aVersion]) {
    if ([self inlineValue] != kSdefInlineAll)
      [node setAttribute:[NSString stringWithFormat:@"%i", [self inlineValue]] forKey:@"inline"];
  }
  return node;
}


#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  NSString *value = [attrs objectForKey:@"inline"];
  if (value) {
    [self setInlineValue:[value intValue]];
  } else {
    [self setInlineValue:kSdefInlineAll];
  }
}

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

@end

#pragma mark -
@implementation SdefEnumerator (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"enumerator";
}

#pragma mark Parsing
- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

@end

#pragma mark -
@implementation SdefValue (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  return (kSdefTigerVersion == version) ? [super xmlNodeForVersion:version] : nil;
}

- (NSString *)xmlElementName {
  return @"value-type";
}

#pragma mark Parsing
- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

@end

#pragma mark -
@implementation SdefRecord (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  return (kSdefTigerVersion == version) ? [super xmlNodeForVersion:version] : nil;
}

- (NSString *)xmlElementName {
  return @"record-type";
}

#pragma mark Parsing
- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

@end
