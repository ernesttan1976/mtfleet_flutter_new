import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

export 'package:flutter_typeahead/flutter_typeahead.dart';

// Compatibility aliases for flutter_typeahead 6.x API changes
// These allow older code that referenced the previous API names to continue
// working while we migrate callers incrementally.
// Legacy alias kept for backwards compatibility was removed because it conflicted with the
// new SuggestionsBoxDecoration type in flutter_typeahead 6.x. Use the upstream type directly.
typedef SuggestionsBoxController = SuggestionsController;
typedef ErrorBuilder = SuggestionsErrorBuilder;

class TextFieldConfiguration {
  final TextStyle? style;
  final bool autofocus;
  TextFieldConfiguration({this.style, this.autofocus = false});
}


typedef SelectionToTextTransformer<T> = String Function(T suggestion);

/// Text field that auto-completes user input from a list of items
class FormBuilderTypeAhead<T> extends FormBuilderField<T> {
  /// Called with the search pattern to get the search suggestions.
  ///
  /// This callback must not be null. It is be called by the TypeAhead widget
  /// and provided with the search pattern. It should return a [List](https://api.dartlang.org/stable/2.0.0/dart-core/List-class.html)
  /// of suggestions either synchronously, or asynchronously (as the result of a
  /// [Future](https://api.dartlang.org/stable/dart-async/Future-class.html)).
  /// Typically, the list of suggestions should not contain more than 4 or 5
  /// entries. These entries will then be provided to [itemBuilder] to display
  /// the suggestions.
  ///
  /// Example:
  /// ```dart
  /// suggestionsCallback: (pattern) async {
  ///   return await _getSuggestions(pattern);
  /// }
  /// ```
  final SuggestionsCallback<T> suggestionsCallback;

  /// Called when a suggestion is tapped.
  ///
  /// This callback must not be null. It is called by the TypeAhead widget and
  /// provided with the value of the tapped suggestion.
  ///
  /// For example, you might want to navigate to a specific view when the user
  /// tabs a suggestion:
  /// ```dart
  /// onSuggestionSelected: (suggestion) {
  ///   Navigator.of(context).push(MaterialPageRoute(
  ///     builder: (context) => SearchResult(
  ///       searchItem: suggestion
  ///     )
  ///   ));
  /// }
  /// ```
  ///
  /// Or to set the value of the text field:
  /// ```dart
  /// onSuggestionSelected: (suggestion) {
  ///   _controller.text = suggestion['name'];
  /// }
  /// ```
  final SuggestionSelectionCallback<T>? onSuggestionSelected;

  /// Called for each suggestion returned by [suggestionsCallback] to build the
  /// corresponding widget.
  ///
  /// This callback must not be null. It is called by the TypeAhead widget for
  /// each suggestion, and expected to build a widget to display this
  /// suggestion's info. For example:
  ///
  /// ```dart
  /// itemBuilder: (context, suggestion) {
  ///   return ListTile(
  ///     title: Text(suggestion['name']),
  ///     subtitle: Text('USD' + suggestion['price'].toString())
  ///   );
  /// }
  /// ```
  final Widget Function(BuildContext, T) itemBuilder;

  /// The decoration of the material sheet that contains the suggestions.
  ///
  /// If null, default decoration with an elevation of 4.0 is used
  /// Used to control the `_SuggestionsBox`. Allows manual control to
  /// open, close, toggle, or resize the `_SuggestionsBox`.
  final SuggestionsBoxController? suggestionsBoxController;

  /// The duration to wait after the user stops typing before calling
  /// [suggestionsCallback]
  ///
  /// This is useful, because, if not set, a request for suggestions will be
  /// sent for every character that the user types.
  ///
  /// This duration is set by default to 300 milliseconds
  final Duration debounceDuration;

  /// Called when waiting for [suggestionsCallback] to return.
  ///
  /// It is expected to return a widget to display while waiting.
  /// For example:
  /// ```dart
  /// (BuildContext context) {
  ///   return Text('Loading...');
  /// }
  /// ```
  ///
  /// If not specified, a [CircularProgressIndicator](https://docs.flutter.io/flutter/material/CircularProgressIndicator-class.html) is shown
  final WidgetBuilder? loadingBuilder;

  /// Called when [suggestionsCallback] returns an empty array.
  ///
  /// It is expected to return a widget to display when no suggestions are
  /// available.
  /// For example:
  /// ```dart
  /// (BuildContext context) {
  ///   return Text('No Items Found!');
  /// }
  /// ```
  ///
  /// If not specified, a simple text is shown
  final WidgetBuilder? noItemsFoundBuilder;

  /// Called when [suggestionsCallback] throws an exception.
  ///
  /// It is called with the error object, and expected to return a widget to
  /// display when an exception is thrown
  /// For example:
  /// ```dart
  /// (BuildContext context, error) {
  ///   return Text('$error');
  /// }
  /// ```
  ///
  /// If not specified, the error is shown in [ThemeData.errorColor](https://docs.flutter.io/flutter/material/ThemeData/errorColor.html)
  final ErrorBuilder? errorBuilder;

  /// Called to display animations when [suggestionsCallback] returns suggestions
  ///
  /// It is provided with the suggestions box instance and the animation
  /// controller, and expected to return some animation that uses the controller
  /// to display the suggestion box.
  ///
  /// For example:
  /// ```dart
  /// transitionBuilder: (context, suggestionsBox, animationController) {
  ///   return FadeTransition(
  ///     child: suggestionsBox,
  ///     opacity: CurvedAnimation(
  ///       parent: animationController,
  ///       curve: Curves.fastOutSlowIn
  ///     ),
  ///   );
  /// }
  /// ```
  /// This argument is best used with [animationDuration] and [animationStart]
  /// to fully control the animation.
  ///
  /// To fully remove the animation, just return `suggestionsBox`
  ///
  /// If not specified, a [SizeTransition](https://docs.flutter.io/flutter/widgets/SizeTransition-class.html) is shown.
  final SuggestionsAnimationBuilder? transitionBuilder;

  /// The duration that [transitionBuilder] animation takes.
  ///
  /// This argument is best used with [transitionBuilder] and [animationStart]
  /// to fully control the animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration animationDuration;

  /// Determine the [SuggestionBox]'s vertical direction.
  ///
  /// If [VerticalDirection.down], the [SuggestionBox] will be below the [TextField]
  /// and the [_SuggestionsList] will grow **down**.
  ///
  /// If [VerticalDirection.up], the [SuggestionBox] will be above the [TextField]
  /// and the [_SuggestionsList] will grow **up**.
  ///
  /// Only [VerticalDirection.up] and [VerticalDirection.down] are allowed.
  final VerticalDirection direction;

  /// The value at which the [transitionBuilder] animation starts.
  ///
  /// This argument is best used with [transitionBuilder] and [animationDuration]
  /// to fully control the animation.
  ///
  /// Defaults to 0.25.
  final double animationStart;

  /// The configuration of the [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
  /// that the TypeAhead widget displays
  final TextFieldConfiguration textFieldConfiguration;

  /// The decoration for the TextField shown by the widget
  final InputDecoration decoration;

  /// How far below the text field should the suggestions box be
  ///
  /// Defaults to 5.0
  final double suggestionsBoxVerticalOffset;

  /// If set to true, suggestions will be fetched immediately when the field is
  /// added to the view.
  ///
  /// But the suggestions box will only be shown when the field receives focus.
  /// To make the field receive focus immediately, you can set the `autofocus`
  /// property in the [textFieldConfiguration] to true
  ///
  /// Defaults to false
  final bool getImmediateSuggestions;

  /// If set to true, no loading box will be shown while suggestions are
  /// being fetched. [loadingBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnLoading;

  /// If set to true, nothing will be shown if there are no results.
  /// [noItemsFoundBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnEmpty;

  /// If set to true, nothing will be shown if there is an error.
  /// [errorBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnError;

  /// If set to false, the suggestions box will stay opened after
  /// the keyboard is closed.
  ///
  /// Defaults to true.
  final bool hideSuggestionsOnKeyboardHide;

  /// If set to false, the suggestions box will show a circular
  /// progress indicator when retrieving suggestions.
  ///
  /// Defaults to true.
  final bool keepSuggestionsOnLoading;

  /// If set to true, the suggestions box will remain opened even after
  /// selecting a suggestion.
  ///
  /// Note that if this is enabled, the only way
  /// to close the suggestions box is either manually via the
  /// `SuggestionsBoxController` or when the user closes the software
  /// keyboard if `hideSuggestionsOnKeyboardHide` is set to true. Users
  /// with a physical keyboard will be unable to close the
  /// box without a manual way via `SuggestionsBoxController`.
  ///
  /// Defaults to false.
  final bool keepSuggestionsOnSuggestionSelected;

  /// If set to true, in the case where the suggestions box has less than
  /// _SuggestionsBoxController.minOverlaySpace to grow in the desired [direction], the direction axis
  /// will be temporarily flipped if there's more room available in the opposite
  /// direction.
  ///
  /// Defaults to false
  final bool autoFlipDirection;

  final SelectionToTextTransformer<T>? selectionToTextTransformer;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Creates text field that auto-completes user input from a list of items
  FormBuilderTypeAhead({
    Key? key,
    //From Super
    required String name,
    required FormFieldValidator<T> validator,
    T? initialValue,
    this.decoration = const InputDecoration(),
    ValueChanged<T?>? onChanged,
    ValueTransformer<T?>? valueTransformer,
    bool enabled = true,
    FormFieldSetter<T?>? onSaved,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required this.itemBuilder,
    required this.suggestionsCallback,
    this.getImmediateSuggestions = false,
    this.selectionToTextTransformer,
    this.errorBuilder,
    this.noItemsFoundBuilder,
    this.loadingBuilder,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.suggestionsBoxVerticalOffset = 5.0,
    required this.textFieldConfiguration,
    this.transitionBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationStart = 0.25,
    this.direction = VerticalDirection.down,
    this.hideOnLoading = false,
    this.hideOnEmpty = false,
    this.hideOnError = false,
    this.hideSuggestionsOnKeyboardHide = true,
    this.keepSuggestionsOnLoading = true,
    this.autoFlipDirection = false,
    this.suggestionsBoxController,
    this.keepSuggestionsOnSuggestionSelected = false,
    this.onSuggestionSelected,
    this.controller,
  })  : assert(T == String || selectionToTextTransformer != null),
        super(
          key: key,
          initialValue: initialValue,
          name: name,
          validator: validator,
          valueTransformer: valueTransformer,
          onChanged: onChanged,
          autovalidateMode: autovalidateMode,
          onSaved: onSaved,
          enabled: enabled,
          onReset: onReset,
          focusNode: focusNode,
          builder: (FormFieldState<T> field) {
            final state = field as _FormBuilderTypeAheadState<T>;
            final theme = Theme.of(state.context);

            return TypeAheadField<T>(
              controller: state._typeAheadController,
              suggestionsCallback: suggestionsCallback,
              itemBuilder: itemBuilder,
              builder: (context, textEditingController, focusNode) {
                final effectiveController = state._typeAheadController;
                return TextField(
                  controller: effectiveController,
                  focusNode: state.effectiveFocusNode,
                  enabled: state.enabled,
                  decoration: state.widget.decoration.copyWith(
                        errorText: field.errorText,
                      ),
                  style: state.enabled
                      ? textFieldConfiguration.style
                      : theme.textTheme.titleMedium?.copyWith(
                          color: theme.disabledColor,
                        ),
                );
              },
              onSelected: (T suggestion) {
                if (selectionToTextTransformer != null) {
                  state._typeAheadController.text = selectionToTextTransformer(suggestion);
                } else {
                  state._typeAheadController.text = suggestion.toString();
                }
                onSuggestionSelected?.call(suggestion);
              },
              hideOnEmpty: hideOnEmpty,
              hideOnError: hideOnError,
              hideOnLoading: hideOnLoading,
              debounceDuration: debounceDuration,
              // suggestionsBoxDecoration is no longer supported in flutter_typeahead 6.x
              // suggestionsBoxVerticalOffset is not a parameter on TypeAheadField in 6.x, handled internally.
              // getImmediateSuggestions is no longer a supported parameter in flutter_typeahead 6.x
              transitionBuilder: transitionBuilder,
              animationDuration: animationDuration,
              direction: direction,
              // hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide,
              // keepSuggestionsOnLoading: keepSuggestionsOnLoading,
              autoFlipDirection: autoFlipDirection,
              // suggestionsBoxController: suggestionsBoxController,
              // keepSuggestionsOnSuggestionSelected: keepSuggestionsOnSuggestionSelected,
              // noItemsFoundBuilder: noItemsFoundBuilder,
              loadingBuilder: loadingBuilder,
              errorBuilder: errorBuilder,
            );
          },
        );

  @override
  _FormBuilderTypeAheadState<T> createState() => _FormBuilderTypeAheadState<T>();
}

class _FormBuilderTypeAheadState<T> extends FormBuilderFieldState<FormBuilderTypeAhead<T>, T> {
  late TextEditingController _typeAheadController;

  @override
  void initState() {
    super.initState();
    _typeAheadController = widget.controller ?? TextEditingController(text: widget.initialValue?.toString());
    _typeAheadController.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_typeAheadController.text != value) {
      didChange(_typeAheadController.text as T);
    }
  }

  @override
  void didChange(T? value) {
    super.didChange(value);

    if (_typeAheadController.text != value) {
      _typeAheadController.text = value.toString();
    }
  }

  @override
  void dispose() {
    _typeAheadController.removeListener(_handleControllerChanged);
    if (null == widget.controller) {
      _typeAheadController.dispose();
    }
    super.dispose();
  }
}
