/*
 *  SdefEnumeration.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefObjects.h"

/*
<!-- SIMPLE TYPES -->

<!-- values -->
<!ELEMENT value-type ((%implementation;)?, synonym*, documentation*, xref*)>
<!ATTLIST value-type
name       %Term;          #REQUIRED
code       %OSType;        #REQUIRED 
hidden     %yorn;          #IMPLIED 
plural     %Term;          #IMPLIED 
description  %Text;        #IMPLIED 
>

<!-- records -->
<!ELEMENT record-type ((%implementation;)?, synonym*, (documentation | property | xref)+)>
<!-- should be at least one property. -->
<!ATTLIST record-type
name       %Term;          #REQUIRED
code       %OSType;        #REQUIRED 
hidden     %yorn;          #IMPLIED 
description  %Text;        #IMPLIED 
>

<!-- enumerations -->
<!ELEMENT enumeration ((%implementation;)?, (documentation | enumerator | xref)+)>
<!-- should be at least one enumerator. -->
<!ATTLIST enumeration
name       %Term;          #REQUIRED
code       %OSType;        #REQUIRED
hidden     %yorn;          #IMPLIED
description  %Text;        #IMPLIED
inline     CDATA           #IMPLIED
>

<!ELEMENT enumerator ((%implementation;)?, synonym*, documentation*)>
<!ATTLIST enumerator
name       %Term;          #REQUIRED
code       %OSType;        #REQUIRED 
hidden     %yorn;          #IMPLIED 
description  %Text;        #IMPLIED 
>
 
*/

enum {
  kSdefInlineAll = -1
};

@interface SdefEnumeration : SdefTerminologyObject <NSCopying, NSCoding> {
  int sd_inline;
}

- (int)inlineValue;
- (void)setInlineValue:(int)value;

@end

@interface SdefEnumerator : SdefTerminologyObject <NSCopying, NSCoding> {
}

@end

@interface SdefValue  : SdefTerminologyObject <NSCopying, NSCoding> {
}

@end

@interface SdefRecord : SdefTerminologyObject <NSCopying, NSCoding> {  
}

@end

