//
//  SdefVerb.h
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefObject.h"

/*
<!-- VERB (COMMAND OR EVENT) DEFINITION -->
<!ELEMENT command (documentation?, %implementation;?, synonyms?, direct-parameter?, result?, parameter*)>
<!ATTLIST command
name       %Verbname;      #REQUIRED
code       %EventCode;     #IMPLIED 
description  %Text;        #IMPLIED
hidden     (hidden)        #IMPLIED 
>

<!ELEMENT event (documentation?, %implementation;?, synonyms?, direct-parameter?, result?, parameter*)>
<!ATTLIST event
name       %Verbname;      #REQUIRED
code       %EventCode;     #IMPLIED 
description  %Text;        #IMPLIED
hidden     (hidden)        #IMPLIED 
>

<!ELEMENT direct-parameter EMPTY>
<!ATTLIST direct-parameter
type       %Typename;      #REQUIRED 
optional   (optional)      #IMPLIED 
description  %Text;        #IMPLIED 
>

<!ELEMENT result EMPTY>
<!ATTLIST result
type       %Typename;      #REQUIRED 
description  %Text;        #IMPLIED 
>

<!ELEMENT parameter (%implementation;?)>
<!ATTLIST parameter
name       %Term;          #REQUIRED
code       %OSType;        #IMPLIED 
hidden     (hidden)        #IMPLIED 
type       %Typename;      #REQUIRED 
optional   (optional)      #IMPLIED 
description  %Text;        #IMPLIED 
>
*/

@class SdefDocumentation, SdefDirectParameter, SdefResult;
@interface SdefVerb : SdefTerminologyElement <NSCopying, NSCoding> {
  SdefResult *sd_result;
  SdefDirectParameter *sd_direct;
  // Code into verb are split into class & ID that are two concat four char codes (i.e. eavtquit).
}

- (BOOL)isCommand;

- (SdefResult *)result;
- (void)setResult:(SdefResult *)aResult;

- (SdefDirectParameter *)directParameter;
- (void)setDirectParameter:(SdefDirectParameter *)aParameter;

@end
