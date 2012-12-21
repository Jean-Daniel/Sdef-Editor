/*
 *  WBDisclosurePanel.m
 *  WonderBox
 *
 *  Created by Jean-Daniel Dupas.
 *  Copyright (c) 2004 - 2009 Jean-Daniel Dupas. All rights reserved.
 *
 *  This file is distributed under the MIT License. See LICENSE.TXT for details.
 */

#import "WBDisclosurePanel.h"

#pragma mark -
@interface _WBSeparatorBox : NSBox {
}
+ (id)separatorWithWidth:(CGFloat)width;
- (CGFloat)minWidth;
@end

#pragma mark -
@implementation WBDisclosurePanel

- (id)init {
  if (self = [self initWithContentRect:NSMakeRect(0, 0, 180, 50)
                             styleMask:NSTitledWindowMask | NSClosableWindowMask | NSUtilityWindowMask
                               backing:NSBackingStoreBuffered
                                 defer:NO]) {
  }
  return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag {
  if (self = [super initWithContentRect:contentRect styleMask:styleMask | NSUtilityWindowMask backing:backingType defer:flag]) {
    wb_views =[[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [wb_views makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [wb_views release];
  [super dealloc];
}

- (void)setContentView:(NSView *)aView {
  [aView setAutoresizesSubviews:YES];
  [super setContentView:aView];
}

#pragma mark -
- (NSTimeInterval)animationResizeTime:(NSRect)newFrame {
  CGFloat deltaWidth = ABS(NSWidth(newFrame) - NSWidth([self frame]));
  CGFloat deltaHeight = ABS(NSHeight(newFrame) - NSHeight([self frame]));
  CGFloat delta = MAX(deltaWidth, deltaHeight);
  return delta / 1200;
}

- (CGFloat)minWidth {
  CGFloat width = 0;
  NSUInteger i;
  for (i=0; i<[wb_views count]; i++) {
    width = MAX(width, [[wb_views objectAtIndex:i] minWidth]);
  }
  width = MAX(width, [self minSize].width);
  return width;
}

- (void)setTopPadding:(CGFloat)padding {
  wb_padding.top = padding;
}

- (void)setBottomPadding:(CGFloat)padding {
  wb_padding.bottom = padding;
}

#pragma mark Views Manipulation

- (NSUInteger)indexOfDisclosureViewWithView:(NSView *)aView {
  for (NSUInteger i=0; i<[wb_views count]; i++) {
    id view = [wb_views objectAtIndex:i];
    if ([view detailView] == aView)
      return i;
  }
  return NSNotFound;
}

- (void)toggleView:(NSView *)aView {
  NSUInteger idx = [self indexOfDisclosureViewWithView:aView];
  if (idx != NSNotFound)
    [self toggleViewAtIndex:idx];
}

- (void)toggleViewAtIndex:(NSUInteger)idx {
  id view = [wb_views objectAtIndex:idx];
  [view setVisible:![view isVisible]];
}

- (WBDisclosureView *)viewAtIndex:(NSUInteger)idx {
  return [wb_views objectAtIndex:idx];
}

- (NSArray *)disclosureViews {
  return [[wb_views copy] autorelease];
}

- (NSArray *)disclosureViewsAndSeparators {
  id views = [NSMutableArray array];
  id view;
  id subviews = [[[self contentView] subviews] objectEnumerator];
  while (view = [subviews nextObject]) {
    if ([view isKindOfClass:[WBDisclosureView class]] ||
        [view isKindOfClass:[_WBSeparatorBox class]])
      [views addObject:view];
  }
  return views;
}

- (void)setLabel:(NSString *)label atIndex:(NSUInteger)idx {
  [[wb_views objectAtIndex:idx] setLabel:label];
}

- (void)addViewWithLabel:(NSString *)label {
  NSRect frame = [[self contentView] frame];
  frame.size.height = 150;
  
  id view = [[NSView alloc] initWithFrame:frame];
  [self addView:view withLabel:label];
  [view release];
}

- (void)addView:(NSView *)newView withLabel:(NSString *)label {
  /* Create new Disclosure View */
  id view = [[WBDisclosureView alloc] initWithDetailView:newView];
  [view setLabel:label];
  
  NSRect frame = [[self contentView] frame];

  if ([wb_views count]) {
    /* if panel contains view, add a separator */
    NSBox *separator = [_WBSeparatorBox separatorWithWidth:NSWidth(frame)];
    [separator setFrameOrigin:NSMakePoint(0, wb_padding.bottom)];
    [[self contentView] addSubview:separator];
  } else {
    /* if contains 0 view, set content height to 0 */
    CGFloat padding = wb_padding.top + wb_padding.bottom;
    [self setContentSize:NSMakeSize(MAX([self minWidth], NSWidth([view frame])), padding)];
  }
  
  /* Calcul new frame */
  frame.size.width = MAX(NSWidth([self frame]), NSWidth([view frame]));
  frame.size.height = NSHeight([[self contentView] frame]) + NSHeight([view frame]);
  frame.origin = NSZeroPoint;
  
  /* Set resizing mask so 
     NSViewMinYMargin -> we can change height without moving existing view
   */
  NSArray *subviews = [self disclosureViewsAndSeparators];
  WBSetViewsAutoresizingMask(subviews, NSMakeRange(0, [subviews count]), NSViewMinYMargin);
  [self setContentSize:frame.size];
  
  [view setFrameOrigin:NSMakePoint(0, wb_padding.bottom)];
  /* Add the new view */
  if ([newView autoresizingMask] & NSViewWidthSizable) {
    [view setFrameSize:NSMakeSize(NSWidth(frame), NSHeight([view frame]))];
  }
  [[self contentView] addSubview:view];
  
  /* Adding view */
  [wb_views addObject:view];
  [view release];
}

- (void)insertView:(NSView *)view withLabel:(NSString *)label atIndex:(NSUInteger)idx {
}

- (void)removeViewAtIndex:(NSUInteger)idx {
  
}

- (void)removeView:(NSView *)view {
  [self removeViewAtIndex:[wb_views indexOfObject:view]];
}

@end

#pragma mark -
@implementation _WBSeparatorBox 

+ (id)separatorWithWidth:(CGFloat)width {
  id separator  = [[self alloc] initWithFrame:NSMakeRect(0, 0, width, 1)];
  [separator setBoxType:NSBoxSeparator];
  return [separator autorelease];
}

- (CGFloat)minWidth {
  return 0;
}

- (void)setAutoresizingMask:(NSUInteger)mask {
  [super setAutoresizingMask:mask | NSViewWidthSizable];
}

@end

#pragma mark -
#pragma mark Private Functions Implementation
void WBSetViewsAutoresizingMask(NSArray *views, NSRange range, NSUInteger mask) {
  NSUInteger idx;
  NSUInteger end = range.location + range.length;
  for (idx=range.location; idx<end; idx++) {
    [[views objectAtIndex:idx] setAutoresizingMask:mask];
  }
}
