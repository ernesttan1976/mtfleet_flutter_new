// Create a Form widget.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:transport_flutter/components/components.dart';

// ignore: must_be_immutable
class AdditionalDetailScreen extends StatefulWidget with KeepAliveParentDataMixin {
  final Function? onPrev;
  final int? index;
  final Function? onNext;

  AdditionalDetailScreen({
    Key? key,
    this.index,
    this.onPrev,
    this.onNext,
  }) : super(key: key);

  @override
  _AdditionalDetailScreenState createState() => _AdditionalDetailScreenState();

  @override
  void detach() {
    // TODO: implement detach
  }

  @override
  // TODO: implement keptAlive
  bool get keptAlive => true;
}

class _AdditionalDetailScreenState extends State<AdditionalDetailScreen> with AutomaticKeepAliveClientMixin {
  bool additionalCheckBox = false;

  GlobalKey<FormBuilderState> _additionalDetailFormKey = GlobalKey<FormBuilderState>(debugLabel: 'ssas');

  ValueChanged _onChanged = (val) => print(val);

  void _onChangedCheckBox(value) {
    setState(() {
      additionalCheckBox = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? nextAVIDate;
    super.build(context);
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'Additional Details',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            leading: IconButton(
                // alignment: Alignment.topLeft,
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  widget.onPrev!(widget.index! - 1);
                })
            // elevation: 5,
            ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(
                child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        FormBuilder(
                          key: _additionalDetailFormKey,
                          // autovalidate: _autoValidate,
                          child: Column(
                            children: <Widget>[
                              TitleAndWidgetShadow(
                                title: 'Despatch Date',
                                child: FormBuilderDateTimePicker(
                                    enabled: !additionalCheckBox,
                                    name: "despatchDate",
                                    key: Key('ass'),
                                    onChanged: _onChanged,
                                    inputType: InputType.date,
                                    validator: additionalCheckBox
                                        ? FormBuilderValidators.compose([])
                                        : FormBuilderValidators.required(),
                                    decoration: InputDecoration(
                                        hintText: "DD-MMM-YYYY",
                                        suffixIcon: Padding(
                                          padding: const EdgeInsetsDirectional.only(end: 12.0),
                                          child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                                        )),
                                    format: new DateFormat('dd MMMM yyyy')
                                    // readonly: true,
                                    ),
                              ).paddingAll(10),
                              TitleAndWidgetShadow(
                                title: 'Despatch Time',
                                child: FormBuilderDateTimePicker(
                                    name: "despatchTime",
                                    enabled: !additionalCheckBox,
                                    onChanged: _onChanged,
                                    inputType: InputType.time,
                                    validator: additionalCheckBox
                                        ? FormBuilderValidators.compose([])
                                        : FormBuilderValidators.required(),
                                    decoration: InputDecoration(
                                        hintText: "HH-MM",
                                        suffixIcon: Padding(
                                          padding: const EdgeInsetsDirectional.only(end: 12.0),
                                          child: Icon(Icons.access_time), // myIcon is a 48px-wide widget.
                                        )),
                                    format: new DateFormat('HH:mm')
                                    // readonly: true,
                                    ),
                              ).paddingAll(10),
                              TitleAndWidgetShadow(
                                title: 'Release Date',
                                child: FormBuilderDateTimePicker(
                                    name: "releaseDate",
                                    enabled: !additionalCheckBox,
                                    onChanged: _onChanged,
                                    validator: additionalCheckBox
                                        ? FormBuilderValidators.compose([])
                                        : FormBuilderValidators.required(),
                                    inputType: InputType.date,
                                    decoration: InputDecoration(
                                        hintText: "DD-MMM-YYYY",
                                        suffixIcon: Padding(
                                          padding: const EdgeInsetsDirectional.only(end: 12.0),
                                          child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                                        )),
                                    format: new DateFormat('dd MMMM yyyy')
                                    // readonly: true,
                                    ),
                              ).paddingAll(10),
                              TitleAndWidgetShadow(
                                title: 'Release Time',
                                child: FormBuilderDateTimePicker(
                                    name: "releaseTime",
                                    onChanged: _onChanged,
                                    enabled: !additionalCheckBox,
                                    inputType: InputType.time,
                                    validator: additionalCheckBox
                                        ? FormBuilderValidators.compose([])
                                        : FormBuilderValidators.required(),
                                    decoration: InputDecoration(
                                        hintText: "HH-MM",
                                        suffixIcon: Padding(
                                          padding: const EdgeInsetsDirectional.only(end: 12.0),
                                          child: Icon(Icons.access_time), // myIcon is a 48px-wide widget.
                                        )),
                                    format: new DateFormat('HH:mm')
                                    // readonly: true,
                                    ),
                              ).paddingAll(10),

                              ///COMMENT CODE
                              FormBuilderCheckbox(
                                name: 'isAdditionalDetailsApplicable',
                                activeColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onChanged: _onChangedCheckBox,
                                initialValue: additionalCheckBox,
                                title: Text(
                                  "Not Applicable",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                                ),
                              ),
                              TitleAndWidgetShadow(
                                title: 'Vehicle Next AVI Date Due',
                                child: FormBuilderDateTimePicker(
                                        name: "aviDate",
                                        validator: FormBuilderValidators.required(),
                                        inputType: InputType.date,
                                        decoration: InputDecoration(
                                            hintText: "DD-MMM-YYYY",
                                            suffixIcon: Padding(
                                              padding: const EdgeInsetsDirectional.only(end: 12.0),
                                              child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                                            )),
                                        format: new DateFormat('dd MMMM yyyy')
                                        // readonly: true,
                                        ),
                              ).paddingAll(10),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: OutlinedButton(
                                  style: ButtonStyle(
                                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    )),
                                    side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                                  ),
                                  onPressed: () {
                                    if (_additionalDetailFormKey.currentState!.saveAndValidate()) {
                                      widget.onNext!(widget.index! + 1, _additionalDetailFormKey.currentState!.value);
                                    }
                                  },
                                  child: Text(
                                    "Next",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
