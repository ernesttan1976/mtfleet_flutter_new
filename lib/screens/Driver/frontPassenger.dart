import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FrontPassengerScreen extends StatefulWidget {
  final Function? onPrev;
  final int? index;
  final String? overAllRisk;
  final Function? onSubmit;

  FrontPassengerScreen({Key? key, this.index, this.onPrev, this.overAllRisk, this.onSubmit}) : super(key: key);

  @override
  _FrontPassengerScreenState createState() => _FrontPassengerScreenState();
}

class _FrontPassengerScreenState extends State<FrontPassengerScreen> with AutomaticKeepAliveClientMixin {
  var data;
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  final GlobalKey<FormBuilderState> _frontPassengerFormKey = GlobalKey<FormBuilderState>();

  List<Widget> _buildChildren() {
    Color? myColor;
    if (widget.overAllRisk == "MEDIUM") {
      myColor = Colors.orange[500];
    } else if (widget.overAllRisk == "LOW") {
      myColor = Colors.green;
    } else {
      myColor = Colors.red[500];
    }
    var listofWidgets = [
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('Overall Risk:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              child: Flexible(
                  child: Text(
            '${widget.overAllRisk}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: myColor),
          ))),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('Checklist:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      FormBuilder(
        key: _frontPassengerFormKey,
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: FormBuilderCheckboxGroup(
                  name: "passenger_checklist",
                  activeColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  options: [
                    FormBuilderFieldOption(
                        value:
                            "Driver is licensed to eperate the vehicle and has displayed Miltary driving permit on dashboard"),
                    FormBuilderFieldOption(value: "Ensure the driver does not exceed the vehicle or road speed limit."),
                    FormBuilderFieldOption(value: "Assist/warn driver of obstruction, hazard or danger"),
                    FormBuilderFieldOption(
                        value: "if involved in an accident, to contact parent unit, Transport Node and Police"),
                  ],
                )),
          ],
        ),
      ),
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
            if (_frontPassengerFormKey.currentState!.saveAndValidate()) {
              _frontPassengerFormKey.currentState!.save();
              widget.onSubmit!(widget.index! + 1, _frontPassengerFormKey.currentState!.value);
            }
          },
          child: Text(
            "Next",
            style: TextStyle(color: Colors.black),
          ),
        ),
      )
    ];

    return listofWidgets;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        appBar: AppBar(
            title: Text(
              'For Front Passenger',
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
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: _buildChildren(),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
