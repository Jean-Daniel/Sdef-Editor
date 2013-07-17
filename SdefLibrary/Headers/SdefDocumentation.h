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
  NSString *_content;
}

@property(nonatomic, copy) NSString *content;

@property(nonatomic, getter=isHtml) BOOL html;

@end
