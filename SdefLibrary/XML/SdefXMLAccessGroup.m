//
//  SdefXMLAccessGroup.m
//  Sdef Editor
//
//  Created by Jean-Daniel Dupas on 18/07/13.
//
//

#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

#import "SdefAccessGroup.h"

@implementation SdefAccessGroup (SdefXMLManager)

#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"access-group";
}
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  if (version >= kSdefMountainLionVersion) {
    SdefXMLNode *node = [SdefXMLNode nodeWithElementName:[self xmlElementName]];
    if (node) {
      if (_access)
        [node setAttribute:SdefXMLAccessStringFromFlag(_access) forKey:@"access"];
      
      if (self.identifier)
        [node setAttribute:self.identifier forKey:@"identifier"];
    }
    [node setEmpty:YES];
    return node;
  } else {
    // TODO: write meta required to restore this accesss group if needed
    
    return nil;
  }
}

#pragma mark Parsing
- (void)addXMLChild:(id<SdefObject>)node {
  [NSException raise:NSInvalidArgumentException format:@"%@ does not support children", self];
}
- (void)addXMLComment:(NSString *)comment {
  SPXTrace();
}

- (void)setXMLMetas:(NSDictionary *)metas {
  //DLog(@"Metas: %@, %@", self, metas);
}
- (void)setXMLAttributes:(NSDictionary *)attrs {
  self.identifier = [attrs objectForKey:@"identifier"];
  _access = SdefXMLAccessFlagFromString([attrs objectForKey:@"access"]);
}

@end
