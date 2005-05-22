//
//  SdefVerb.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefVerb.h"
#import "SdefArguments.h"

@implementation SdefVerb
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefVerb *copy = [super copyWithZone:aZone];
  copy->sd_result = [sd_result copyWithZone:aZone];
  [copy->sd_result setOwner:copy];
  copy->sd_direct = [sd_direct copyWithZone:aZone];
  [copy->sd_direct setOwner:copy];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_result forKey:@"SVResult"];
  [aCoder encodeObject:sd_direct forKey:@"SVDirectParameter"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_result = [[aCoder decodeObjectForKey:@"SVResult"] retain];
    sd_direct = [[aCoder decodeObjectForKey:@"SVDirectParameter"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefVerbType;
}

- (NSString *)objectTypeName {
  return [self isCommand] ? NSLocalizedStringFromTable(@"Command", @"SdefLibrary", @"Object Type Name.")
  : NSLocalizedStringFromTable(@"Event", @"SdefLibrary", @"Object Type Name.");
}

+ (NSString *)defaultIconName {
  return @"Function";
}

#pragma mark -
+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"method", @"SdefLibrary", @"Verb & Responds To default name.");
}

- (void)dealloc {
  [sd_result setOwner:nil];
  [sd_result release];
  [sd_direct setOwner:nil];
  [sd_direct release];
  [super dealloc];
}
#pragma mark -

- (BOOL)isCommand {
  id suite = [self suite];
  return [self parent] == [suite commands];
}
  
- (void)sdefInit {
  [super sdefInit];

  SdefResult *result = [[SdefResult allocWithZone:[self zone]] init];
  [self setResult:result];
  [result release];
  
  SdefDirectParameter *param = [[SdefDirectParameter allocWithZone:[self zone]] init];
  [self setDirectParameter:param];
  [param release];
}

- (SdefResult *)result {
  return sd_result;
}
- (void)setResult:(SdefResult *)aResult {
  if (sd_result != aResult) {
    [sd_result setOwner:nil];
    [sd_result release];
    sd_result = [aResult retain];
    [sd_result setOwner:self];
  }
}

- (SdefDirectParameter *)directParameter {
  return sd_direct;
}
- (void)setDirectParameter:(SdefDirectParameter *)aParameter {
  if (sd_direct != aParameter) {
    [sd_direct setOwner:nil];
    [sd_direct release];
    sd_direct = [aParameter retain];
    [sd_direct setOwner:self];
  }
}

@end
