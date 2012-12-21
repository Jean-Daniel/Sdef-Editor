/*
 *  WBDisclosureView.m
 *  WonderBox
 *
 *  Created by Jean-Daniel Dupas.
 *  Copyright (c) 2004 - 2009 Jean-Daniel Dupas. All rights reserved.
 *
 *  This file is distributed under the MIT License. See LICENSE.TXT for details.
 */

#import "WBDisclosurePanel.h"

#pragma mark Private Functions
WB_INLINE
NSRect WindowFrameAdjustedBySize(NSRect frame, NSSize size) {
  frame.size.width += size.width;
  frame.size.height += size.height;
  frame.origin.y -= size.height;
  return frame;
}

static 
NSComparisonResult VerticalOriginCompare(NSView *v1, NSView *v2, void *context) {
  CGFloat w1 = NSMinY([v1 frame]);
  CGFloat w2 = NSMinY([v2 frame]);
  if (fequal(w1, w2)) {
    return (NSHeight([v1 frame]) > NSHeight([v2 frame])) ? NSOrderedAscending : NSOrderedDescending;
  }
  else {
    return (w1 > w2) ? NSOrderedAscending : NSOrderedDescending;
  }
}

@implementation WBDisclosureView

- (void)dealloc {
  [super dealloc];
}

#pragma mark -
- (void)initViews {
  wb_label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 0, 14)];
  [wb_label setSelectable:NO];
  [wb_label setDrawsBackground:NO];
  [wb_label setBezeled:NO];
  [wb_label setFont:[NSFont systemFontOfSize:11]];
  [wb_label setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
  [self addSubview:wb_label];
  [wb_label release];
  
  wb_button = [[NSButton alloc] init];
  [wb_button setTitle:nil];
  [wb_button setBezelStyle:NSDisclosureBezelStyle];
  [wb_button setButtonType:NSOnOffButton];
  [wb_button sizeToFit];
  [wb_button setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
  [wb_button setState:NSOnState];
  [wb_button setTarget:self];
  [wb_button setAction:@selector(toggleDetailVisible:)];
  [self addSubview:wb_button];
  [wb_button release];
  
  CGFloat labelHeight = NSHeight([wb_label frame]);
  CGFloat viewHeight = NSHeight([self frame]);
  NSPoint origin = NSMakePoint(12 + NSWidth([wb_button frame]), viewHeight - labelHeight - 2);
  [wb_label setFrameOrigin:origin];
  NSSize size = NSMakeSize(0, labelHeight);
  [wb_label setFrameSize:size];
  
  CGFloat deltaHeight = (NSHeight([wb_label frame]) - NSHeight([wb_button frame])) / 2;
  origin.y += deltaHeight;
  origin.x = 8;
  [wb_button setFrameOrigin:origin];
  
  size.height = NSMinY([wb_label frame]) - 3;
  size.width = NSWidth([self frame]);
  NSRect rect;
  rect.origin = NSZeroPoint;
  rect.size = size;
  
  wb_detailView = [[NSView alloc] initWithFrame:rect];
  [wb_detailView setAutoresizingMask:NSViewMinYMargin];
  [self addSubview:wb_detailView];
  [wb_detailView release];
}

- (id)initWithFrame:(NSRect)rect {
  if (self = [super initWithFrame:rect]) {
    wb_dvFlags.visible = YES;
    [self initViews];
  }
  return self;
}

- (id)initWithDetailView:(NSView *)newView {
  NSRect frame;
  if (newView) {
    frame = [newView frame];
  } else {
    return [self init];
  }
  if (self = [self initWithFrame:frame]) {
    [self setDetailView:newView];
  }
  return self;
}

#pragma mark -
- (BOOL)isVisible {
  return wb_dvFlags.visible;
}
- (void)setVisible:(BOOL)visible {
  BOOL flag = wb_dvFlags.visible;
  if (spx_xor(visible, flag)) { /* visible != wb_dvFlags.visible (Boolean compare) */
    [self toggleDetailVisible:nil];
    [wb_button setState:wb_dvFlags.visible ? NSOnState : NSOffState];
  }
}

- (NSString *)label {
  return [wb_label stringValue];
}

- (void)setLabel:(NSString *)newLabel {
  [wb_label setStringValue:(newLabel) ? : @""];
  if (newLabel) {
    [wb_label sizeToFit];
    [wb_label setFrameSize:NSMakeSize(NSWidth([wb_label frame]) + 8, NSHeight([wb_label frame]))];
  }
}

- (IBAction)toggleDetailVisible:(id)sender {
  NSSize detailSize = [wb_detailView frame].size;
  NSRect newWindowFrame = [[self window] frame];
  BOOL makeVisible = !wb_dvFlags.visible;
  wb_dvFlags.visible = wb_dvFlags.visible ? 0 : 1;
  CGFloat deltaHeight = (makeVisible ? detailSize.height : -detailSize.height);
  CGFloat deltaWidth = 0;
  
  CGFloat width = [self calculWidth];
  deltaWidth = width - newWindowFrame.size.width;
  
  // Make sure the detailView is visible while it animates.
  if (makeVisible) [wb_detailView setHidden:NO];
  
  newWindowFrame = WindowFrameAdjustedBySize(newWindowFrame, NSMakeSize(deltaWidth, deltaHeight));
  
  //Order all DisclosureViews by their Y coordinate.
  NSArray *verticallyOrderedDisclosureViews = [(WBDisclosurePanel *)[self window] disclosureViewsAndSeparators];
  verticallyOrderedDisclosureViews = [verticallyOrderedDisclosureViews sortedArrayUsingFunction:VerticalOriginCompare context:nil];
  
  NSUInteger ourViewIndex = [verticallyOrderedDisclosureViews indexOfObjectIdenticalTo:self];
  
  NSRange aboveRange = NSMakeRange(0, ourViewIndex);
  NSRange belowRange = NSMakeRange(ourViewIndex + 1, [verticallyOrderedDisclosureViews count] - ourViewIndex - 1);
  
  WBSetViewsAutoresizingMask(verticallyOrderedDisclosureViews, aboveRange, NSViewMinYMargin);
  WBSetViewsAutoresizingMask(verticallyOrderedDisclosureViews, belowRange, NSViewMaxYMargin);
  
  [self setAutoresizingMask:NSViewHeightSizable];
  
  [[self window] setFrame:newWindowFrame display:YES animate:YES];
  
  if (!makeVisible) [wb_detailView setHidden:YES];
}

- (CGFloat)calculWidth {
  return [(WBDisclosurePanel *)[self window] minWidth];
}

- (void)setAutoresizingMask:(NSUInteger)mask {
  [super setAutoresizingMask:mask | wb_resizing];
}

#pragma mark -
- (NSView *)detailView {
  return wb_detailView;
}

- (void)setDetailView:(NSView *)newView {
  CGFloat oldHeight = 0;
  if (wb_detailView != nil) {
    oldHeight = NSHeight([wb_detailView frame]);
    [wb_detailView removeFromSuperviewWithoutNeedingDisplay];
  }
  wb_detailView = newView;
  if (wb_detailView) {
    /* Backup width resizing mask */
    wb_width = NSWidth([wb_detailView frame]);
    wb_resizing = [newView autoresizingMask] & (NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin);
    CGFloat newHeight = NSHeight([wb_detailView frame]);
    
    NSRect rect = [self frame];
    rect.size.height += (newHeight - oldHeight);
    [self setFrame:rect];
    
//    rect.size.height = newHeight;
//    rect.origin = NSZeroPoint;
    [wb_detailView setFrameOrigin:NSZeroPoint];
    [wb_detailView setAutoresizingMask:NSViewMinYMargin | wb_resizing];
    [self addSubview:wb_detailView];
    /* See -setAutoresizingMask: */ 
    [self setAutoresizingMask:[self autoresizingMask]];
  }
}

- (CGFloat)minWidth {
  return wb_dvFlags.visible ? wb_width : NSWidth([wb_label frame]) + NSMinX([wb_label frame]) + 12;
}

@end
