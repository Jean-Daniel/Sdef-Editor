/*
 *  WBDisclosurePanel.h
 *  WonderBox
 *
 *  Created by Jean-Daniel Dupas.
 *  Copyright (c) 2004 - 2009 Jean-Daniel Dupas. All rights reserved.
 *
 *  This file is distributed under the MIT License. See LICENSE.TXT for details.
 */

#import <WonderBox/WBBase.h>

WB_EXPORT
void WBSetViewsAutoresizingMask(NSArray *views, NSRange range, NSUInteger mask);

@class WBDisclosureView;
WB_OBJC_EXPORT
@interface WBDisclosurePanel : NSPanel {
@private
  struct wb_padding {
    CGFloat top;
    CGFloat bottom;
  } wb_padding;
  NSMutableArray *wb_views;
}

- (NSArray *)disclosureViews;
- (NSArray *)disclosureViewsAndSeparators;
- (WBDisclosureView *)viewAtIndex:(NSUInteger)index;

- (void)addView:(NSView *)view withLabel:(NSString *)label;
- (void)setLabel:(NSString *)label atIndex:(NSUInteger)index;

- (void)toggleView:(NSView *)aView;
- (void)toggleViewAtIndex:(NSUInteger)index;

- (void)setTopPadding:(CGFloat)padding;
- (void)setBottomPadding:(CGFloat)padding;

- (CGFloat)minWidth;

- (NSTimeInterval)animationResizeTime:(NSRect)newFrame;

/* Not Implemented */
- (void)insertView:(NSView *)view withLabel:(NSString *)label atIndex:(NSUInteger)index;
- (void)removeViewAtIndex:(NSUInteger)index;
- (void)removeView:(NSView *)view;

@end

#pragma mark -
@interface WBDisclosureView : NSView {
  @private
  CGFloat wb_width;
  struct _wb_dvFlags {
    unsigned int visible:1;
    unsigned int:7;
  } wb_dvFlags;
  NSView *wb_detailView;
  NSButton *wb_button;
  NSTextField *wb_label;
  NSUInteger wb_resizing;
}

- (id)initWithDetailView:(NSView *)newView;

- (NSView *)detailView;
- (void)setDetailView:(NSView *)newView;

- (CGFloat)calculWidth;
- (IBAction)toggleDetailVisible:(id)sender;

- (BOOL)isVisible;
- (void)setVisible:(BOOL)newIsVisible;

- (NSString *)label;
- (void)setLabel:(NSString *)newLabel;

@end
