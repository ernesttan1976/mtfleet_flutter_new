// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// Examples can assume:
// BuildContext context;

const Duration _kDialAnimateDuration = Duration(milliseconds: 200);
const double _kTwoPi = 2 * math.pi;
const Duration _kVibrateCommitDelay = Duration(milliseconds: 100);

enum _TimePickerMode { hour, minute }

const double _kTimePickerHeaderPortraitHeight = 96.0;
const double _kTimePickerHeaderLandscapeWidth = 168.0;

const double _kTimePickerWidthPortrait = 328.0;
const double _kTimePickerWidthLandscape = 512.0;

const double _kTimePickerHeightPortrait = 496.0;
const double _kTimePickerHeightLandscape = 316.0;

const double _kTimePickerHeightPortraitCollapsed = 484.0;
const double _kTimePickerHeightLandscapeCollapsed = 304.0;

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
  });

  /// Identifier used by the custom layout to refer to the widget.
  final _TimePickerHeaderId layoutId;

  /// The widget that renders a piece of time information.
  final Widget widget;
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

/// Displays the am/pm fragment and provides controls for switching between am
/// and pm.
class _DayPeriodControl extends StatelessWidget {
  const _DayPeriodControl({
    required this.fragmentContext,
    required this.orientation,
  });

  final _TimePickerFragmentContext fragmentContext;
  final Orientation orientation;

  void _togglePeriod() {
    final int newHour = (fragmentContext.selectedTime.hour + TimeOfDay.hoursPerPeriod) % TimeOfDay.hoursPerDay;
    final TimeOfDay newTime = fragmentContext.selectedTime.replacing(hour: newHour);
    fragmentContext.onTimeChange(newTime);
  }

  void _setAm(BuildContext context) {
    if (fragmentContext.selectedTime.period == DayPeriod.am) {
      return;
    }
    switch (fragmentContext.targetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _announceToAccessibility(context, MaterialLocalizations.of(context).anteMeridiemAbbreviation);
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod();
  }

  void _setPm(BuildContext context) {
    if (fragmentContext.selectedTime.period == DayPeriod.pm) {
      return;
    }
    switch (fragmentContext.targetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _announceToAccessibility(context, MaterialLocalizations.of(context).postMeridiemAbbreviation);
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod();
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations materialLocalizations = MaterialLocalizations.of(context);
    final TextTheme headerTextTheme = fragmentContext.headerTextTheme;
    final TimeOfDay selectedTime = fragmentContext.selectedTime;
    final Color activeColor = fragmentContext.activeColor;
    final Color inactiveColor = fragmentContext.inactiveColor;
    final bool amSelected = selectedTime.period == DayPeriod.am;
    final TextStyle amStyle = headerTextTheme.titleMedium!.copyWith(color: amSelected ? activeColor : inactiveColor);
    final TextStyle pmStyle = headerTextTheme.titleMedium!.copyWith(color: !amSelected ? activeColor : inactiveColor);
    final bool layoutPortrait = orientation == Orientation.portrait;

    final double buttonTextScaleFactor = (MediaQuery.of(context).textScaler.clamp(TextScaler.noScaling, const TextScaler.linear(2.0))).scale(1.0);

    final Widget amButton = ConstrainedBox(
      constraints: _kMinTappableRegion,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: Feedback.wrapForTap(() => _setAm(context), context),
          child: Padding(
            padding: layoutPortrait ? const EdgeInsets.only(bottom: 2.0) : const EdgeInsets.only(right: 4.0),
            child: Align(
              alignment: layoutPortrait ? Alignment.bottomCenter : Alignment.centerRight,
              widthFactor: 1,
              heightFactor: 1,
              child: Semantics(
                selected: amSelected,
                child: Text(
                  materialLocalizations.anteMeridiemAbbreviation,
                  style: amStyle,
                  textScaler: TextScaler.linear(buttonTextScaleFactor),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final Widget pmButton = ConstrainedBox(
      constraints: _kMinTappableRegion,
      child: Material(
        type: MaterialType.transparency,
        textStyle: pmStyle,
        child: InkWell(
          onTap: Feedback.wrapForTap(() => _setPm(context), context),
          child: Padding(
            padding: layoutPortrait ? const EdgeInsets.only(top: 2.0) : const EdgeInsets.only(left: 4.0),
            child: Align(
              alignment: orientation == Orientation.portrait ? Alignment.topCenter : Alignment.centerLeft,
              widthFactor: 1,
              heightFactor: 1,
              child: Semantics(
                selected: !amSelected,
                child: Text(
                  materialLocalizations.postMeridiemAbbreviation,
                  style: pmStyle,
                  textScaler: TextScaler.linear(buttonTextScaleFactor),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    switch (orientation) {
      case Orientation.portrait:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            amButton,
            pmButton,
          ],
        );

      case Orientation.landscape:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            amButton,
            pmButton,
          ],
        );
    }
  }
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
              textScaler: MediaQuery.of(context).textScaler,
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
      child: Text(
        value,
        style: fragmentContext.inactiveStyle,
        textScaler: MediaQuery.of(context).textScaler,
      ),
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

    final TimeOfDay selectedTime = fragmentContext.selectedTime;
    final TimeOfDay nextTime = selectedTime.replacing(minute: (selectedTime.minute + 1) % 60);
    final String formattedNextMinute = localizations.formatMinute(nextTime);
    final TimeOfDay previousTime = selectedTime.replacing(minute: (selectedTime.minute - 1) % 60);
    final String formattedPreviousMinute = localizations.formatMinute(previousTime);

    return Semantics(
      hint: localizations.timePickerMinuteModeAnnouncement,
      value: formattedMinute,
      excludeSemantics: true,
      increasedValue: formattedNextMinute,
      onIncrease: () {
        fragmentContext.onTimeChange(nextTime);
      },
      decreasedValue: formattedPreviousMinute,
      onDecrease: () {
        fragmentContext.onTimeChange(previousTime);
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
              textAlign: TextAlign.start,
              textScaler: MediaQuery.of(context).textScaler,
            ),
          ),
        ),
      ),
    );
  }
}

// ... more code ...

/// See also:
///
///  * [showDatePicker], which shows a dialog that contains a material design
///    date picker.
Future<TimeOfDay?> showTimePickerCustom({
  required BuildContext context,
  required TimeOfDay initialTime,
  TransitionBuilder? builder,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) async {
  assert(debugCheckHasMaterialLocalizations(context));

  final Widget dialog = _TimePickerDialogCustom(initialTime: initialTime);
  return await showDialog<TimeOfDay>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      if (builder == null) {
        return dialog;
      }
      final child = builder(context, dialog);
      return child ?? dialog;
    },
    routeSettings: routeSettings,
  );
}

void _announceToAccessibility(BuildContext context, String message) {
  SemanticsService.announce(
    message,
    Directionality.of(context),
  );
}
