//
//  SdefVerbView.m
//  SDef Editor
//
//  Created by Grayfox on 19/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefVerbView.h"
#import "SdefVerb.h"
#import "SdefArguments.h"

@implementation SdefVerbView

+ (void)initialize {
  [super initialize];
  [self setKeys:[NSArray arrayWithObject:@"object"] triggerChangeNotificationsForDependentKey:@"verbLabel"];
}

- (NSString *)verbLabel {
  if (![self object])
    return @"Verb";
  return [[self object] isKindOfClass:[SdefCommand class]] ? @"Command" : @"Event";
}

- (void)selectObject:(SdefObject*)anObject {
  int idx = -1;
  SdefVerb *content = [self object];
  if (anObject == content) idx = 0;
  else if ([anObject parent] == content)  {
    idx = 1;
    [parameters setSelectedObjects:[NSArray arrayWithObject:anObject]];
  }
  if (idx >= 0)
    [tab selectTabViewItemAtIndex:idx];
}

@end
