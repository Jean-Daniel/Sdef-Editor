/*
 *  SdefDocumentation.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefLeaf.h"

/*
 <!-- DOCUMENTATION ELEMENTS -->
 <!ELEMENT documentation (ANY | html)>
 <!ELEMENT html ANY>
*/
@interface SdefDocumentation : SdefLeaf <NSCopying, NSCoding> {
  id sd_content;
}

- (BOOL)isHtml;
- (void)setHtml:(BOOL)html;

- (NSString *)content;
- (void)setContent:(NSString *)newContent;

@end
