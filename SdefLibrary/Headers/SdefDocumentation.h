//
//  SdefDocumentation.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

/*
 <!-- DOCUMENTATION ELEMENTS -->
 <!ELEMENT documentation (#PCDATA)>
*/
@interface SdefDocumentation : SdefObject <NSCopying, NSCoding> {
  id sd_content;
}

- (NSString *)content;
- (void)setContent:(NSString *)newContent;

@end
