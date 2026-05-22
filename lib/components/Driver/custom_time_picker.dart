// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unused_field

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

// Examples can assume:
// BuildContext context;

enum _TimePickerMode { hour, minute }

const BoxConstraints _kMinTappableRegion = BoxConstraints(minWidth: 48, minHeight: 48);

enum _TimePickerHeaderId {
  hour,
  colon,
  minute,
  period, // AM/PM picker
  dot,
  hString, // French Canadian "h" literal
}

/// Provides properties for rendering time picker header fragments.
@immutable
class _TimePickerFragmentContext {
  const _TimePickerFragmentContext({
    required this.headerTextTheme,
    required this.textDirection,
    required this.selectedTime,
    required this.mode,
    required this.activeColor,
    required this.activeStyle,
    required this.inactiveColor,
    required this.inactiveStyle,
    required this.onTimeChange,
    required this.onModeChange,
    required this.targetPlatform,
    required this.use24HourDials,
  });

  final TextTheme headerTextTheme;
  final TextDirection textDirection;
  final TimeOfDay selectedTime;
  final _TimePickerMode mode;
  final Color activeColor;
  final TextStyle activeStyle;
  final Color inactiveColor;
  final TextStyle inactiveStyle;
  final ValueChanged<TimeOfDay> onTimeChange;
  final ValueChanged<_TimePickerMode> onModeChange;
  final TargetPlatform targetPlatform;
  final bool use24HourDials;
}

/// Contains the [widget] and layout properties of an atom of time information,
/// such as am/pm indicator, hour, minute and string literals appearing in the
/// formatted time string.
class _TimePickerHeaderFragment {
  const _TimePickerHeaderFragment({
    required this.layoutId,
    required this.widget,
    this.startMargin = 0.0,
  });

  /// Identifier used by the custom layout to refer to the widget.
  final _TimePickerHeaderId layoutId;

  /// The widget that renders a piece of time information.
  final Widget widget;

  /// Horizontal distance from the fragment appearing at the start of this
  /// fragment.
  ///
  /// This value contributes to the total horizontal width of all fragments
  /// appearing on the same line, unless it is the first fragment on the line,
  /// in which case this value is ignored.
  final double startMargin;
}

/// An unbreakable part of the time picker header.
///
/// When the picker is laid out vertically, [fragments] of the piece are laid
/// out on the same line, with each piece getting its own line.
class _TimePickerHeaderPiece {
  /// Creates a time picker header piece.
  ///
  /// All arguments must be non-null. If the piece does not contain a pivot
  /// fragment, use the value -1 as a convention.
  const _TimePickerHeaderPiece(this.pivotIndex, this.fragments, {this.bottomMargin = 0.0});

  /// Index into the [fragments] list, pointing at the fragment that's centered
  /// horizontally.
  final int pivotIndex;

  /// Fragments this piece is made of.
  final List<_TimePickerHeaderFragment> fragments;

  /// Vertical distance between this piece and the next piece.
  ///
  /// This property applies only when the header is laid out vertically.
  final double bottomMargin;
}

/// Describes how the time picker header must be formatted.
///
/// A [_TimePickerHeaderFormat] is made of multiple [_TimePickerHeaderPiece]s.
/// A piece is made of multiple [_TimePickerHeaderFragment]s. A fragment has a
/// widget used to render some time information and contains some layout
/// properties.
///
/// ## Layout rules
///
/// Pieces are laid out such that all fragments inside the same piece are laid
/// out horizontally. Pieces are laid out horizontally if portrait orientation,
/// and vertically in landscape orientation.
///
/// One of the pieces is identified as a _centerpiece_. It is a piece that is
/// positioned in the center of the header, with all other pieces positioned
/// to the left or right of it.
class _TimePickerHeaderFormat {
  const _TimePickerHeaderFormat(this.centerpieceIndex, this.pieces);

  /// Index into the [pieces] list pointing at the piece that contains the
  /// pivot fragment.
  final int centerpieceIndex;

  /// Pieces that constitute a time picker header.
  final List<_TimePickerHeaderPiece> pieces;
}

/// Displays the hour fragment.
///
/// When tapped changes time picker dial mode to [_TimePickerMode.hour].
class _HourControl extends StatelessWidget {
  const _HourControl({
    required this.fragmentContext,
  });

  final _TimePickerFragmentContext fragmentContext;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final bool alwaysUse24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final TextStyle hourStyle =
        fragmentContext.mode == _TimePickerMode.hour ? fragmentContext.activeStyle : fragmentContext.inactiveStyle;
    final String formattedHour = localizations.formatHour(
      fragmentContext.selectedTime,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );

    TimeOfDay hoursFromSelected(int hoursToAdd) {
      if (fragmentContext.use24HourDials) {
        final int selectedHour = fragmentContext.selectedTime.hour;
        return fragmentContext.selectedTime.replacing(
          hour: (selectedHour + hoursToAdd) % TimeOfDay.hoursPerDay,
        );
      } else {
        // Cycle 1 through 12 without changing day period.
        final int periodOffset = fragmentContext.selectedTime.periodOffset;
        final int hours = fragmentContext.selectedTime.hourOfPeriod;
        return fragmentContext.selectedTime.replacing(
          hour: periodOffset + (hours + hoursToAdd) % TimeOfDay.hoursPerPeriod,
        );
      }
    }

    final TimeOfDay nextHour = hoursFromSelected(1);
    final String formattedNextHour = localizations.formatHour(
      nextHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );
    final TimeOfDay previousHour = hoursFromSelected(-1);
    final String formattedPreviousHour = localizations.formatHour(
      previousHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );

    return Semantics(
      hint: localizations.timePickerHourModeAnnouncement,
      value: formattedHour,
      excludeSemantics: true,
      increasedValue: formattedNextHour,
      onIncrease: () {
        fragmentContext.onTimeChange(nextHour);
      },
      decreasedValue: formattedPreviousHour,
      onDecrease: () {
        fragmentContext.onTimeChange(previousHour);
      },
      child: ConstrainedBox(
        constraints: _kMinTappableRegion,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: Feedback.wrapForTap(() => fragmentContext.onModeChange(_TimePickerMode.hour), context),
            child: Text(
              formattedHour,
              style: hourStyle,
              textAlign: TextAlign.end,
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
      ),
    );
  }
}

/// A passive fragment showing a string value.
class _StringFragment extends StatelessWidget {
  const _StringFragment({
    required this.fragmentContext,
    required this.value,
  });

  final _TimePickerFragmentContext fragmentContext;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Text(value, style: fragmentContext.inactiveStyle, textScaler: TextScaler.noScaling),
    );
  }
}

/// Displays the minute fragment.
///
/// When tapped changes time picker dial mode to [_TimePickerMode.minute].
class _MinuteControl extends StatelessWidget {
  const _MinuteControl({
    required this.fragmentContext,
  });

  final _TimePickerFragmentContext fragmentContext;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final TextStyle minuteStyle =
        fragmentContext.mode == _TimePickerMode.minute ? fragmentContext.activeStyle : fragmentContext.inactiveStyle;
    final String formattedMinute = localizations.formatMinute(fragmentContext.selectedTime);

    TimeOfDay minutesFromSelected(int minutesToAdd) {
      final int minutesPerHour = TimeOfDay.minutesPerHour;
      final int hoursPerDay = TimeOfDay.hoursPerDay;
      final int selectedHour = fragmentContext.selectedTime.hour;
      final int selectedMinute = fragmentContext.selectedTime.minute;
      int newHour = selectedHour;
      int newMinute = selectedMinute + minutesToAdd;
      newHour = (newHour + newMinute ~/ minutesPerHour) % hoursPerDay;
      newMinute %= minutesPerHour;
      if (newMinute < 0) {
        newMinute += minutesPerHour;
        newHour = (newHour - 1 + hoursPerDay) % hoursPerDay;
      }
      return fragmentContext.selectedTime.replacing(hour: newHour, minute: newMinute);
    }

    final TimeOfDay nextMinute = minutesFromSelected(1);
    final String formattedNextMinute = localizations.formatMinute(nextMinute);
    final TimeOfDay previousMinute = minutesFromSelected(-1);
    final String formattedPreviousMinute = localizations.formatMinute(previousMinute);

    return Semantics(
      hint: localizations.timePickerMinuteModeAnnouncement,
      value: formattedMinute,
      excludeSemantics: true,
      increasedValue: formattedNextMinute,
      onIncrease: () {
        fragmentContext.onTimeChange(nextMinute);
      },
      decreasedValue: formattedPreviousMinute,
      onDecrease: () {
        fragmentContext.onTimeChange(previousMinute);
      },
      child: ConstrainedBox(
        constraints: _kMinTappableRegion,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: Feedback.wrapForTap(() => fragmentContext.onModeChange(_TimePickerMode.minute), context),
            child: Text(
              formattedMinute,
              style: minuteStyle,
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
      ),
    );
  }
}

/// A custom layout for the time picker header.
class _TimePickerHeaderLayout extends MultiChildLayoutDelegate {
  _TimePickerHeaderLayout(this.format, this.textDirection);

  final _TimePickerHeaderFormat format;
  final TextDirection textDirection;

  @override
  void performLayout(Size size) {
    // Layout all children according to their intrinsic sizes.
    final Map<_TimePickerHeaderId, Size> childSizes = <_TimePickerHeaderId, Size>{};

    void layoutChild(_TimePickerHeaderId id) {
      childSizes[id] = layoutChild(id,
          BoxConstraints.loose(size).deflate(const EdgeInsets.symmetric(horizontal: 24.0)));
    }

    for (final _TimePickerHeaderPiece piece in format.pieces) {
      for (final _TimePickerHeaderFragment fragment in piece.fragments) {
        layoutChild(fragment.layoutId);
      }
    }

    // Compute the horizontal positions of each child.
    double startX = 0.0;
    final double y = size.height / 2.0;

    for (final _TimePickerHeaderPiece piece in format.pieces) {
      double pieceWidth = 0.0;
      for (final _TimePickerHeaderFragment fragment in piece.fragments) {
        final Size childSize = childSizes[fragment.layoutId]!;
        pieceWidth += childSize.width;
        if (fragment != piece.fragments.first) {
          pieceWidth += fragment.startMargin;
        }
      }

      final double pivotX = piece.fragments
          .take(piece.pivotIndex + 1)
          .fold<double>(0.0, (double sum, _TimePickerHeaderFragment fragment) {
        final Size childSize = childSizes[fragment.layoutId]!;
        if (fragment == piece.fragments.last) {
          return sum + childSize.width / 2.0;
        }
        return sum + childSize.width + fragment.startMargin;
      });

      final double pieceStartX = size.width / 2.0 - pivotX;

      for (final _TimePickerHeaderFragment fragment in piece.fragments) {
        final Size childSize = childSizes[fragment.layoutId]!;
        final double childX = startX + pieceStartX;
        final double childY = y - childSize.height / 2.0;
        positionChild(fragment.layoutId, Offset(childX, childY));
        startX += childSize.width + fragment.startMargin;
      }
    }
  }

  @override
  bool shouldRelayout(covariant _TimePickerHeaderLayout oldDelegate) {
    return oldDelegate.format != format || oldDelegate.textDirection != textDirection;
  }
}

// ... file continues unchanged ...
