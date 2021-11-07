/*
 * Copyright (C) 2015 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.android.material.behavior;

import static androidx.annotation.RestrictTo.Scope.LIBRARY_GROUP;

import androidx.core.view.ViewCompat;
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat;
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat.AccessibilityActionCompat;
import androidx.core.view.accessibility.AccessibilityViewCommand;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import androidx.annotation.IntDef;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;
import androidx.annotation.VisibleForTesting;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import androidx.customview.widget.ViewDragHelper;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * An interaction behavior plugin for child views of {@link CoordinatorLayout} to provide support
 * for the 'swipe-to-dismiss' gesture.
 */
public class SwipeDismissBehavior<V extends View> extends CoordinatorLayout.Behavior<V> {

  /** A view is not currently being dragged or animating as a result of a fling/snap. */
  public static final int STATE_IDLE = ViewDragHelper.STATE_IDLE;

  /**
   * A view is currently being dragged. The position is currently changing as a result of user input
   * or simulated user input.
   */
  public static final int STATE_DRAGGING = ViewDragHelper.STATE_DRAGGING;

  /**
   * A view is currently settling into place as a result of a fling or predefined non-interactive
   * motion.
   */
  public static final int STATE_SETTLING = ViewDragHelper.STATE_SETTLING;

  /** @hide */
  @RestrictTo(LIBRARY_GROUP)
  @IntDef({SWIPE_DIRECTION_START_TO_END, SWIPE_DIRECTION_END_TO_START, SWIPE_DIRECTION_ANY})
  @Retention(RetentionPolicy.SOURCE)
  private @interface SwipeDirection {}

  /**
   * Swipe direction that only allows swiping in the direction of start-to-end. That is
   * left-to-right in LTR, or right-to-left in RTL.
   */
  public static final int SWIPE_DIRECTION_START_TO_END = 0;

  /**
   * Swipe direction that only allows swiping in the direction of end-to-start. That is
   * right-to-left in LTR or left-to-right in RTL.
   */
  public static final int SWIPE_DIRECTION_END_TO_START = 1;

  /** Swipe direction which allows swiping in either direction. */
  public static final int SWIPE_DIRECTION_ANY = 2;

  private static final float DEFAULT_DRAG_DISMISS_THRESHOLD = 0.5f;
  private static final float DEFAULT_ALPHA_START_DISTANCE = 0f;
  private static final float DEFAULT_ALPHA_END_DISTANCE = DEFAULT_DRAG_DISMISS_THRESHOLD;

  ViewDragHelper viewDragHelper;
  OnDismissListener listener;
  private boolean interceptingEvents;

  private float sensitivity = 0f;
  private boolean sensitivitySet;

  int swipeDirection = SWIPE_DIRECTION_ANY;
  float dragDismissThreshold = DEFAULT_DRAG_DISMISS_THRESHOLD;
  float alphaStartSwipeDistance = DEFAULT_ALPHA_START_DISTANCE;
  float alphaEndSwipeDistance = DEFAULT_ALPHA_END_DISTANCE;

  /** Callback interface used to notify the application that the view has been dismissed. */
  public interface OnDismissListener {
    /** Called when {@code view} has been dismissed via swiping. */
    public void onDismiss(View view);

    /**
     * Called when the drag state has changed.
     *
     * @param state the new state. One of {@link #STATE_IDLE}, {@link #STATE_DRAGGING} or {@link
     *     #STATE_SETTLING}.
     */
    public void onDragStateChanged(int state);
  }

  /**
   * Set the listener to be used when a dismiss event occurs.
   *
   * @param listener the listener to use.
   */
  public void setListener(@Nullable OnDismissListener listener) {
    this.listener = listener;
  }

  @VisibleForTesting
  @Nullable
  public OnDismissListener getListener() {
    return listener;
  }

  /**
   * Sets the swipe direction for this behavior.
   *
   * @param direction one of the {@link #SWIPE_DIRECTION_START_TO_END}, {@link
   *     #SWIPE_DIRECTION_END_TO_START} or {@link #SWIPE_DIRECTION_ANY}
   */
  public void setSwipeDirection(@SwipeDirection int direction) {
    swipeDirection = direction;
  }

  /**
   * Set the threshold for telling if a view has been dragged enough to be dismissed.
   *
   * @param distance a ratio of a view's width, values are clamped to 0 >= x <= 1f;
   */
  public void setDragDismissDistance(float distance) {
    dragDismissThreshold = clamp(0f, distance, 1f);
  }

  /**
   * The minimum swipe distance before the view's alpha is modified.
   *
   * @param fraction the distance as a fraction of the view's width.
   */
  publi