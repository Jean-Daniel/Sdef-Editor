/*
 *  SdefVerb.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

/*
<!-- VERBS (COMMANDS OR EVENTS) -->
<!ELEMENT command ((%implementation;)?, synonym*, direct-parameter?, parameter*, result?, documentation*, xref*)>
<!ATTLIST command
name       %Verbname;      #REQUIRED
id         ID              #IMPLIED
code       %EventCode;     #REQUIRED 
description  %Text;        #IMPLIED
hidden     %yorn;          #IMPLIED 
>

<!ELEMENT event ((%implementation;)?, synonym*, documentation*, direct-parameter?, (documentation | parameter)*, result?, documentation*, xref*)>
<!ATTLIST event
name       %Verbname;      #REQUIRED
id         ID              #IMPLIED
code       %EventCode;     #REQUIRED 
description  %Text;        #IMPLIED
hidden     %yorn;          #IMPLIED 
>

<!ELEMENT direct-parameter (type*)>
<!ATTLIST direct-parameter
type       %Typename;      #IMPLIED 
optional   %yorn;          #IMPLIED 
description  %Text;        #IMPLIED 
>

<!ELEMENT result (type*)>
<!ATTLIST result
type       %Typename;      #IMPLIED 
description  %Text;        #IMPLIED 
>

<!ELEMENT parameter ((%implementation;)?, (type*))>
<!ATTLIST parameter
name       %Term;          #REQUIRED
code       %OSType;        #REQUIRED 
hidden     %yorn;          #IMPLIED 
type       %Typename;      #IMPLIED 
optional   %yorn;          #IMPLIED 
description  %Text;        #IMPLIED 
>
 */

@class SdefDocumentation, SdefDirectParameter, SdefResult;
@interface SdefVerb : SdefTerminologyObject <NSCopying, NSCoding> {
  @private
  SdefResult *sd_result;
  SdefDirectParameter *sd_direct;
  // Code into verb are split into class & ID that are two concat four char codes (i.e. eavtquit).
}

- (BOOL)isCommand;
/* Just an hint. isCommand can returns something different */
- (void)setCommand:(BOOL)flag;

- (BOOL)hasResult;
- (SdefResult *)result;
- (void)setResult:(SdefResult *)aResult;

- (BOOL)hasDirectParameter;
- (SdefDirectParameter *)directParameter;
- (void)setDirectParameter:(SdefDirectParameter *)aParameter;

@end
