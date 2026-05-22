import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/screens/MAC/Maintenance.dart';

class MaintenanceCard extends StatefulWidget {
  final List<VehicleServicingModel> vehicleServicings;
  final refetch;

  const MaintenanceCard({Key? key, required this.vehicleServicings, this.refetch}) : super(key: key);

  @override
  _MaintenanceCardState createState() => new _MaintenanceCardState();
}

class _MaintenanceCardState extends State<MaintenanceCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: widget.vehicleServicings.isNotEmpty
          ? Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: <Widget>[
                    for (var item in widget.vehicleServicings)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "MID ${item.vehicle != null ? item.vehicle?.vehicleNumber : ''}",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(letterSpacing: 1.5),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () async {
                              await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MaintenanceScreen(service: item),
                              ));
                              widget.refetch();
                            },
                            child: Text(
                              "View",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(letterSpacing: 1.5, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            )
          : const Center(
              child: Text("No Vehicles are Checked-In for Maintenance!"),
            ),
    );
  }
}
