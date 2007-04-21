/*
 *  SdefXRef.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"

/* 
<!ELEMENT xref EMPTY>
<!ATTLIST xref
target     CDATA           #REQUIRED
hidden     %yorn;          #IMPLIED 
>
*/

@interface SdefXRef : SdefLeaf <NSCopying, NSCoding> {
  @private
  NSString *sd_target;
}

- (NSString *)target;
- (void)setTarget:(NSString *)target;

@end
