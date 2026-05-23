import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:transport_flutter/util/checkListArray.dart';

class DriverCheckList extends StatefulWidget {
  final void Function(int index) onPrev;
  final void Function(int index, Map<String, dynamic> value) onNext;
  final int index;
  final String overAllRisk;
  final bool isVehicleCommander;
  final void Function(Map<String, dynamic> value) onSubmit;

  const DriverCheckList({
    super.key,
    required this.index,
    required this.onPrev,
    required this.onNext,
    required this.overAllRisk,
    required this.isVehicleCommander,
    required this.onSubmit,
  });

  @override
  State<DriverCheckList> createState() => _DriverCheckListState();
}

class _DriverCheckListState extends State<DriverCheckList> with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormBuilderState> _driverFormKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  void submissionFormAlert(Map<String, dynamic> value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Text(
            "Are you sure to submit this trip form ?",
            textAlign: TextAlign.center,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          widget.onSubmit(value);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "No",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildChildrenVehicle() {
    Color? myColor;
    if (widget.overAllRisk == "HIGH") {
      myColor = Colors.red[500];
    } else if (widget.overAllRisk == "LOW") {
      myColor = Colors.green;
    } else {
      myColor = Colors.orange[500];
    }
    var listofWidgets = <Widget>[
      FormBuilder(
        key: _driverFormKey,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                    child: Text('Overall Risk:',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                    child: Text(
                  widget.overAllRisk,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: myColor),
                )),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Flexible(
                    child: Text('Checklist:',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold))),
              ],
            ),
            FormBuilderCheckboxGroup(
              name: "driver_checklist",
              activeColor: Theme.of(context).primaryColor,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              options: [
                FormBuilderFieldOption(
                  value: "${driverCheckList[0]['title']}",
                ),
                FormBuilderFieldOption(value: "${driverCheckList[1]['title']}"),
                FormBuilderFieldOption(value: "${driverCheckList[2]['title']}"),
                FormBuilderFieldOption(value: "${driverCheckList[3]['title']}"),
                FormBuilderFieldOption(value: "${driverCheckList[4]['title']}"),
                FormBuilderFieldOption(value: "${driverCheckList[5]['title']}"),
                FormBuilderFieldOption(value: "${driverCheckList[6]['title']}"),
              ],
            ),
          ],
        ),
      ),
    ];

    if (widget.isVehicleCommander) {
      listofWidgets.add(Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: !isLoading
              ? OutlinedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    )),
                    side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                  ),
                  onPressed: () {
                    if (_driverFormKey.currentState!.saveAndValidate()) {
                      widget.onNext(widget.index + 1, _driverFormKey.currentState!.value);
                    }
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ));
    } else {
      listofWidgets.add(Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: !isLoading
              ? OutlinedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    )),
                    side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                  ),
                  onPressed: () {
                    if (_driverFormKey.currentState!.saveAndValidate()) {
                      submissionFormAlert(_driverFormKey.currentState!.value);
                    }
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ));
    }

    return listofWidgets;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        appBar: AppBar(
            title: Text(
              'For Driver',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  widget.onPrev(widget.index - 1);
                })),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: _buildChildrenVehicle(),
                ),
              ),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
