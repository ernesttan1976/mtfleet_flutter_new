import 'package:flutter/material.dart';
import 'package:transport_flutter/extensions/extensions.dart';

import 'components.dart';

class TitleAndWidgetShadow extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool isShadow;
  final bool isTitle;

  TitleAndWidgetShadow({this.title, required this.child, this.isShadow = true, this.isTitle = true});

  late ThemeData _themeData;
  static final InputBorder _inputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.circular(12),
  );

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return Theme(
      data: _themeData.copyWith(
        inputDecorationTheme: InputDecorationTheme(
          errorMaxLines: 2,
          helperMaxLines: 2,
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(fontSize: 16, color: Colors.black45),
          focusedBorder: _inputBorder,
          border: _inputBorder,
          enabledBorder: _inputBorder,
          errorBorder: _inputBorder.copyWith(
              borderSide: BorderSide(
            color: Colors.red,
          )),
          focusedErrorBorder: _inputBorder.copyWith(
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          isDense: true,
          disabledBorder: _inputBorder,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isTitle) Text(title ?? '', style: _themeData.textTheme.subtitle2?.semiBold).paddingFromLTRB(0, 0, 0, 10),
          if (isShadow) child.shadow() else child
        ],
      ),
    );
  }

  Widget? _buildInputTitle({required String title, required Widget child, bool isShadow = true}) {
    return null;
  }
}
