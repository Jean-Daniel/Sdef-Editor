//
//  ASDictionaryStream.m
//  Sdef Editor
//
//  Created by Grayfox on 28/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ASDictionaryStream.h"
#import "ShadowMacros.h"

#pragma mark Private Functions Declaration
static NSFont *FontForASDictionaryStyle(ASDictionaryStyle *style);
static void ASDictionaryStyleForFont(NSFont *aFont, ASDictionaryStyle *style);
static void ASGetStyleForASPreferences(CFStringRef str, ASDictionaryStyle *style);

static __inline__ SInt16 ASFontFamilyIDForFamilyName(CFStringRef name);
static __inline__ BOOL ASDictionaryStyleEqualsStyle(ASDictionaryStyle *style1, ASDictionaryStyle *style2);

#pragma mark -
@implementation ASDictionaryStream

static ASDictionaryStyle stdStyles[4];

+ (void)loadStandardsAppleScriptStyles {
  @synchronized (self) {
    memset(stdStyles, 0, 4 * sizeof(ASDictionaryStyle));
    CFPreferencesAppSynchronize(CFSTR("com.apple.applescript"));
    CFArrayRef asFonts = CFPreferencesCopyValue(CFSTR("AppleScriptTextStyles"),
                                                CFSTR("com.apple.applescript"),
                                                kCFPreferencesCurrentUser,
                                                kCFPreferencesAnyHost);
    if (asFonts && CFArrayGetCount(asFonts) >= 3) { /* index max = 4 */
      CFStringRef styleStr;
      styleStr = CFArrayGetValueAtIndex(asFonts, 2);
      ASGetStyleForASPreferences(styleStr, &stdStyles[kASStyleLanguageKeyword]);
      
      styleStr = CFArrayGetValueAtIndex(asFonts, 3);
      ASGetStyleForASPreferences(styleStr, &stdStyles[kASStyleApplicationKeyword]);
      stdStyles[kASStyleApplicationKeyword].fontStyle |= bold;
      
      styleStr = CFArrayGetValueAtIndex(asFonts, 4);
      ASGetStyleForASPreferences(styleStr, &stdStyles[kASStyleComment]);
    } else {
      ASDictionaryStyle *style;
      style = &stdStyles[kASStyleLanguageKeyword];
      style->fontFamily = ASFontFamilyIDForFamilyName(CFSTR("Verdana"));
      style->fontStyle = normal;
      style->fontSize = 12;
      style->green = 0;
      style->blue = 65535;
      style->red = 0;
    
      style = &stdStyles[kASStyleApplicationKeyword];
      style->fontFamily = ASFontFamilyIDForFamilyName(CFSTR("Verdana"));
      style->fontStyle = bold;
      style->fontSize = 12;
      style->green = 0;
      style->blue = 65535;
      style->red = 0;
      
      style = &stdStyles[kASStyleComment];
      style->fontFamily = ASFontFamilyIDForFamilyName(CFSTR("Verdana"));
      style->fontStyle = italic;
      style->fontSize = 12;
      style->green = 19660;
      style->blue = 19660;
      style->red = 19660;
    }
    ASGetStyleForASPreferences(NULL, &stdStyles[kASStyleStandard]);
    if (asFonts) CFRelease(asFonts);
  }
}

+ (void)getStyle:(ASDictionaryStyle *)style forApplescriptStyle:(ASDictionaryStyleType)aStyle {
  @synchronized (self) {
    ASDictionaryStyle *stdStyle = &stdStyles[aStyle];
    if (stdStyle->fontFamily == 0) stdStyle = &stdStyles[kASStyleStandard];
    style->fontFamily = stdStyle->fontFamily;
    style->fontStyle = stdStyle->fontStyle;
    style->fontSize = stdStyle->fontSize;
    style->green = stdStyle->green;
    style->blue = stdStyle->blue;
    style->red = stdStyle->red;
  }
}

#pragma mark -
- (id)init {
  if (self = [super init]) {
    as_string = [[NSMutableString alloc] init];
    UInt16 count = 0;
    as_styles = [[NSMutableData alloc] initWithBytes:&count length:sizeof(UInt16)];
  }
  return self;
}

- (id)initWithString:(NSString *)aString {
  if (self = [super init]) {
    as_string = [[NSMutableString alloc] initWithString:aString];
    UInt16 count = 0;
    as_styles = [[NSMutableData alloc] initWithBytes:&count length:sizeof(UInt16)];
  }
  return self;
}

- (id)initWithAttributedString:(NSAttributedString *)aString {
  if (self = [super init]) {
    NSDictionary *dict = ASDictionaryStringForAttributedString(aString);
    as_string = [[NSMutableString alloc] initWithString:[aString string]];
    as_styles = [[NSMutableData alloc] initWithData:[dict objectForKey:@"style"]];
  }
  return self;
}

- (id)initWithASDictionaryString:(NSDictionary *)aDictionary {
  if (self = [super init]) {
    as_string = [[NSMutableString alloc] initWithData:[aDictionary objectForKey:@"text"] encoding:[NSString defaultCStringEncoding]];
    as_styles = [[NSMutableData alloc] initWithData:[aDictionary objectForKey:@"style"]];
  }
  return self;
}

- (void)dealloc {
  [as_string release];
  [as_styles release];
  [super dealloc];
}

#pragma mark -
- (NSString *)string {
  return as_string;
}

- (NSDictionary *)asDictionaryString {
  return [NSDictionary dictionaryWithObjectsAndKeys:
    [as_string dataUsingEncoding:[NSString defaultCStringEncoding]], @"text",
    as_styles, @"style", nil];
}

- (NSAttributedString *)attributedString {
  return AttributedStringForASDictionaryString([self asDictionaryString]);
}

- (void)appendString:(NSString *)aString {
  [as_string appendString:aString];
}

- (void)appendFormat:(NSString *)format, ... {
  va_list argList;
  va_start(argList, format);
  id str = [[NSString alloc] initWithFormat:format arguments:argList];
  va_end(argList);
  
  [self appendString:str];
  [str release];
}

- (void)setASDictionaryStyle:(ASDictionaryStyleType)aStyle {
  [self setStyle:normal];
  [[self class] getStyle:&as_style forApplescriptStyle:aStyle];
}

- (void)setFont:(NSFont *)aFont {
  NSParameterAssert(nil != aFont);
  ASDictionaryStyleForFont(aFont, &as_style);
}

- (void)setSize:(FMFontSize)aSize {
  as_style.fontSize = aSize;
}

- (void)setStyle:(FMFontStyle)aStyle {
  as_style.fontStyle = aStyle;
}

- (void)setFontFamily:(NSString *)aFamily {
  as_style.fontFamily = ASFontFamilyIDForFamilyName((CFStringRef)aFamily);
}

- (void)setFontFamily:(NSString *)fontName style:(FMFontStyle)aStyle size:(FMFontSize)aSize {
  [self setSize:aSize];
  [self setStyle:aStyle];
  [self setFontFamily:fontName];
}

- (void)setBold:(BOOL)flag {
  as_style.fontStyle |= bold;
}
- (void)setItalic:(BOOL)flag {
  as_style.fontStyle |= italic;
}
- (void)setUnderline:(BOOL)flag {
  as_style.fontStyle |= underline;
}

- (void)setColor:(NSColor *)aColor {
  id rgb = [aColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
  float r, g, b;
  [rgb getRed:&r green:&g blue:&b alpha:nil];
  [self setRed:lround(r * 65535) green:lround(g * 65535) blue:lround(b * 65535)];
}

- (void)setRed:(UInt16)red green:(UInt16)green blue:(UInt16)blue {
  as_style.red = red;
  as_style.green = green;
  as_style.blue = blue;
}

- (void)closeStyle {
  FontInfo info;
  if (as_style.position != [as_string length]) {
    OSStatus err = FetchFontInfo(as_style.fontFamily, as_style.fontSize, normal /*as_style.fontStyle*/, &info);
    if (noErr == err) {
      as_style.fontWidth = info.widMax;
      as_style.fontAscent = info.ascent;
    }
    ASDictionaryStyle *previous = nil;
    if ([as_styles length] > sizeof(ASDictionaryStyle)) {
      previous = ([as_styles mutableBytes] + [as_styles length] - sizeof(ASDictionaryStyle));
    }
    if (!previous || !ASDictionaryStyleEqualsStyle(&as_style, previous)) {
      [as_styles appendBytes:&as_style length:sizeof(ASDictionaryStyle)];
      UInt16 *data = [as_styles mutableBytes];
      *data = ([as_styles length] - 2) / sizeof(ASDictionaryStyle);
    }
    as_style.position = [as_string length];
  }
}

@end

#pragma mark -
#pragma mark Private Functions Implementation
static void ASGetStyleForASPreferences(CFStringRef str, ASDictionaryStyle *style) {
  CFArrayRef values = str ? CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault, str, CFSTR(";")) : NULL;
  if (values && CFArrayGetCount(values) < 4) {
    CFRelease(values);
    values = NULL;
  }
  
  /* Get font family and style */
  if (values && CFStringFind(CFArrayGetValueAtIndex(values, 1), CFSTR("i"), kCFCompareCaseInsensitive).location != kCFNotFound)
    style->fontStyle = italic;
  else
    style->fontStyle = normal;
  
  style->fontFamily = values ? ASFontFamilyIDForFamilyName(CFArrayGetValueAtIndex(values, 0)) : kFontIDTimes;
  
  UInt16 size = values ? CFStringGetIntValue(CFArrayGetValueAtIndex(values, 2)) : 0;
  style->fontSize = (size > 0) ? size : 12;
  
  CFArrayRef colors = values ? CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault, CFArrayGetValueAtIndex(values, 3), CFSTR(" ")) : NULL;
  if (colors && CFArrayGetCount(colors) == 3) {
    style->red = CFStringGetIntValue(CFArrayGetValueAtIndex(colors, 0));
    style->green = CFStringGetIntValue(CFArrayGetValueAtIndex(colors, 1));
    style->blue = CFStringGetIntValue(CFArrayGetValueAtIndex(colors, 2));
  } else {
    style->red = 0;
    style->green = 0;
    style->blue = 0;
  }
  if (colors) CFRelease(colors);
  if (values) CFRelease(values);
}

static __inline__ SInt16 ASFontFamilyIDForFamilyName(CFStringRef name) {
  Str255 fName;
  FMFontFamily family = -1;
  if (CFStringGetPascalString (name, fName, 255, CFStringGetSystemEncoding()))
    family = FMGetFontFamilyFromName(fName);
  return (family > 0) ? family : kFontIDTimes;
}

static __inline__ BOOL ASDictionaryStyleEqualsStyle(ASDictionaryStyle *style1, ASDictionaryStyle *style2) {
  return style1->fontFamily == style2->fontFamily &&
  style1->fontStyle == style2->fontStyle &&
  style1->fontSize == style2->fontSize &&
  style1->red == style2->red &&
  style1->green == style2->green &&
  style1->blue == style2->blue;
}

NSFont *FontForASDictionaryStyle(ASDictionaryStyle *style) {
  NSFont *font = nil;
  FMFont oFont;
  FMFontStyle oIntrinsicStyle;
  OSStatus err = FMGetFontFromFontFamilyInstance (style->fontFamily, style->fontStyle, &oFont, &oIntrinsicStyle);
  require_noerr(err, bail);
  /*
   FontInfo info;
   FetchFontInfo(style->fontFamily, style->fontSize, style->fontStyle, &info);
   */
  CFStringRef name = nil;
  err = ATSFontGetName(oFont, kATSOptionFlagsDefault, &name);
  require_noerr(err, bail);
  
  font = [NSFont fontWithName:(NSString *)name size:style->fontSize];
  CFRelease(name);
  
bail:
    if (!font) font = [NSFont systemFontOfSize:style->fontSize];
  return font;
}

NSAttributedString *AttributedStringForASDictionaryString(NSDictionary *content) {
  id str = [[NSString alloc] initWithData:[content objectForKey:@"text"] encoding:[NSString defaultCStringEncoding]];
  NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str];
  [str release];
  id attributes = [[NSMutableDictionary alloc] initWithCapacity:5];
  Byte *data = (Byte *)[[content objectForKey:@"style"] bytes];
  ASDictionaryStyle *styles = (ASDictionaryStyle *)(data + 2);
  UInt16 count = *(UInt16 *)data;
  int idx;
  for (idx=0; idx<count; idx++) {
    ASDictionaryStyle style = styles[idx];
    unsigned end = (idx != count -1) ? styles[idx+1].position : [string length];
    NSRange range = NSMakeRange(style.position, end - style.position);
    [attributes removeAllObjects];
    [attributes setObject:FontForASDictionaryStyle(&style) forKey:NSFontAttributeName];
    [attributes setObject:[NSColor colorWithDeviceRed:style.red / 65535.0
                                                green:style.green / 65535.0
                                                 blue:style.blue / 65535.0
                                                alpha:1] forKey:NSForegroundColorAttributeName];
    if (style.fontStyle & underline) {
      [attributes setObject:SKInt(NSUnderlineStyleSingle | NSUnderlinePatternSolid) forKey:NSUnderlineStyleAttributeName];
    }
    if (style.fontStyle & outline) {
      [attributes setObject:SKFloat(3.0) forKey:NSStrokeWidthAttributeName];
    }
    [string setAttributes:attributes range:range];
  }
  [attributes release];
  return [string autorelease];
}

void ASDictionaryStyleForFont(NSFont *aFont, ASDictionaryStyle *style) {
  NSCParameterAssert(nil != style);
  require(aFont != nil, bail);
  
  style->fontAscent = lround([aFont ascender]);
  style->fontSize  = lround([aFont pointSize]);
  style->fontWidth = lround([aFont maximumAdvancement].width);
  
  NSString *name = [aFont fontName];
  ATSUFontID fontId;
  OSStatus err = ATSUFindFontFromName([name cString],
                                      [name cStringLength],
                                      kFontPostscriptName,
                                      kFontNoPlatformCode,
                                      kFontNoScriptCode,
                                      kFontNoLanguageCode,
                                      &fontId);
  require_noerr(err, bail);
  
  SInt16 fStyle;
  err = FMGetFontFamilyInstanceFromFont(fontId, 
                                        &style->fontFamily, 
                                        &fStyle);
  require_noerr(err, bail);
  style->fontStyle = fStyle;
  return;
  
bail:
    style->fontFamily = kFontIDTimes;
  style->fontStyle = 0;
  if (!style->fontSize) style->fontSize = 12;
}

NSDictionary *ASDictionaryStringForAttributedString(NSAttributedString *aString) {
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
  [dict setObject:[[aString string] dataUsingEncoding:[NSString defaultCStringEncoding]] forKey:@"text"];
  
  UInt16 styleCount = 0;
  NSMutableData *data = [[NSMutableData alloc] initWithBytes:&styleCount length:sizeof(UInt16)];
  
  NSRange limitRange;
  NSRange effectiveRange;
  id attributes;
  
  limitRange = NSMakeRange(0, [aString length]);
  ASDictionaryStyle style;
  while (limitRange.length > 0) {
    memset(&style, 0, sizeof(ASDictionaryStyle));
    attributes = [aString attributesAtIndex:limitRange.location
                      longestEffectiveRange:&effectiveRange
                                    inRange:limitRange];
    style.position = limitRange.location;
    
    /* Extracting Style */
    ASDictionaryStyleForFont([attributes objectForKey:NSFontAttributeName], &style);
    NSColor *color = [attributes objectForKey:NSForegroundColorAttributeName];
    if (color) {
      color = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
      float r, g, b;
      [color getRed:&r green:&g blue:&b alpha:nil];
      style.red = lround(65535 * r);
      style.green = lround(65535 * g);
      style.blue = lround(65535 * b);
    }
    if ([[attributes objectForKey:NSUnderlineStyleAttributeName] intValue] > 0) {
      style.fontStyle |= underline;
    }
    
    /* Append style */
    [data appendBytes:&style length:sizeof(ASDictionaryStyle)];
    styleCount++;
    
    limitRange = NSMakeRange(NSMaxRange(effectiveRange), 
                             NSMaxRange(limitRange) - NSMaxRange(effectiveRange));
  }
  UInt16 *count = [data mutableBytes];
  *count = styleCount;
  [dict setObject:data forKey:@"style"];
  [data release];
  return dict;
}

