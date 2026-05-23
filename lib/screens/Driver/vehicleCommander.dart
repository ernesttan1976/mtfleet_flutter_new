import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class VehicleCommanderScreen extends StatefulWidget {
  final Function? onPrev;
  final int? index;
  final String? overAllRisk;
  final Function? onSubmit;

  const VehicleCommanderScreen({Key? key, this.index, this.onPrev, this.onSubmit, this.overAllRisk}) : super(key: key);

  @override
  VehicleCommanderScreenState createState() => VehicleCommanderScreenState();
}

class VehicleCommanderScreenState extends State<VehicleCommanderScreen> with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormBuilderState> _vehicleCommanderFormKey = GlobalKey<FormBuilderState>();

  List<Widget> _buildChildren() {
    Color? myColor;
    if (widget.overAllRisk == "HIGH") {
      myColor = Colors.red[500];
    } else if (widget.overAllRisk == "LOW") {
      myColor = Colors.green;
    } else {
      myColor = Colors.orange[500];
    }
    var listofWidgets = [
      Row(
        children: <Widget>[
          Flexible(
              child: Text('Overall Risk:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
      const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
              child: Text(
            '${widget.overAllRisk}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: myColor),
          )),
        ],
      ),
      const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text('Checklist:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
      FormBuilder(
        key: _vehicleCommanderFormKey,
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(10),
                child: FormBuilderCheckboxGroup(
                  name: "vehicleCommanderChecklist",
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  activeColor: Theme.of(context).primaryColor,
                  options: const [
                    FormBuilderFieldOption(
                        value:
                            "Driver is Licensed to operate the vehicle and has displayed Miltray Driving permit on dashboard"),
                    FormBuilderFieldOption(value: "Ensure the driver does not exceed the vehicle or road speed limit."),
                    FormBuilderFieldOption(value: "Assist/warn driver of obstruction, hazard or danger."),
                    FormBuilderFieldOption(
                        value: "Warn driver during reversing or movement towards congested or narrow space."),
                    FormBuilderFieldOption(value: "Ensure no admin movement during no-move timings."),
                    FormBuilderFieldOption(
                        value: "Brief and ensure troops secure their seat belts before movement of vehicle."),
                    FormBuilderFieldOption(
                        value: "Check and ensure safety straps in place and taildboard of vehicle is closed."),
                    FormBuilderFieldOption(value: "Secure load before movement of vehicle."),
                    FormBuilderFieldOption(
                        value: "if involved in an accident, to contact parent unit, Transport Node and Police."),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.all(10),
              child: FormBuilderTextField(
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(errorText: "Please Enter Your Correct Email."),
                ]),
                name: "vehicleCommanderEmail",
                decoration: const InputDecoration(
                    labelText: "Vehicle Commander Email",
                    hintText: "TypeHere",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: OutlinedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
          ),
          onPressed: () {
            if (_vehicleCommanderFormKey.currentState!.saveAndValidate()) {
              widget.onSubmit!(_vehicleCommanderFormKey.currentState!.value);
            }
          },
          child: const Text(
            "Submit",
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
              'For Vehicle Commander',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: IconButton(
                // alignment: Alignment.topLeft,
                icon: const Icon(Icons.arrow_back),
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(children: _buildChildren()),
                ),
              ),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
