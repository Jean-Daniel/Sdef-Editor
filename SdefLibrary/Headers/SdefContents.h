//
//  SdefContents.h
//  SDef Editor
//
//  Created by Grayfox on 04/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

@interface SdefContents : SdefTerminologyElement {
  NSString *sd_type;
  unsigned sd_access;
}

- (NSString *)type;
- (void)setType:(NSString *)aType;

- (unsigned)access;
- (void)setAccess:(unsigned)newAccess;

@end
