/*
 * Copyright 2020 The Android Open Source Project
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

package androidx.core.widget;

import static androidx.annotation.RestrictTo.Scope.LIBRARY_GROUP_PREFIX;
import static androidx.core.view.ContentInfoCompat.FLAG_CONVERT_TO_PLAIN_TEXT;
import static androidx.core.view.ContentInfoCompat.SOURCE_DRAG_AND_DROP;
import static androidx.core.view.ContentInfoCompat.SOURCE_INPUT_METHOD;

import android.content.ClipData;
import android.content.Context;
import android.os.Build;
import android.text.Editable;
import android.text.Selection;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.annotation.RestrictTo;
import androidx.core.view.ContentInfoCompat;
import androidx.core.view.ContentInfoCompat.Flags;
import androidx.core.view.ContentInfoCompat.Source;
import androidx.core.view.OnReceiveContentListener;

/**
 * Default implementation inserting content into editable {@link TextView} components. This class
 * handles insertion of text (plain text, styled text, HTML, etc) but not images or other content.
 *
 * @hide
 */
@RestrictTo(LIBRARY_GROUP_PREFIX)
public final class TextViewOnReceiveContentListener implements OnReceiveContentListener {
    private static final String LOG_TAG = "ReceiveContent";

    @Nullable
    @Override
    public ContentInfoCompat onReceiveContent(@NonNull View view,
            @NonNull ContentInfoCompat payload) {
        if (Log.isLoggable(LOG_TAG, Log.DEBUG)) {
            Log.d(LOG_TAG, "onReceive: " + payload);
    