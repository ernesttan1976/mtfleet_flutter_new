import 'package:flutter/material.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';

class TableELogOne extends StatelessWidget {
  final Stream<List<ELogVehicleModel>> stream;
  final Function(ELogVehicleModel) onTapItem;

  TableELogOne({required this.onTapItem, required this.stream});

  late ThemeData _themeData;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return StreamBuilder<List<ELogVehicleModel>>(
        initialData: [],
        stream: stream,
        builder: (context, snapshot) {
          return Table(
            defaultColumnWidth: IntrinsicColumnWidth(),
            border: TableBorder.all(color: Colors.grey),
            children: [
              _buildHeaderTable(),
              ...?snapshot.data
                  ?.map((element) => _dataRowTables(
                      model: element,
                      onTap: () {
                        onTapItem.call(element);
                      }))
                  .toList(),
            ],
          );
        });
  }

  TableRow _buildHeaderTable() {
    return TableRow(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
        ),
        children: [
          'Vehicle Number',
          'Trip Date',
          // 'To Destination',
          'Requisition Purpose',
          'Trip Status',
          'Start Time',
          'End Time',
          // 'Start Meter',
          'End Meter',
          'Total Distance',
          'Driver',
          'Approving Officer',
        ]
            .map(
              (e) => _buildItem(value: e, isHeader: true, onTap: () {}),
            )
            .toList());
  }

  TableRow _dataRowTables({required VoidCallback onTap, required ELogVehicleModel model}) {
    return TableRow(children: [
      _buildItem(value: model.vehicleNumber, onTap: onTap),
      _buildItem(value: model.tripDate != null ? model.tripDate!.toLocal().formatDateddMMyyyy : '', onTap: onTap),
      // _buildItem(value: 'ABC', onTap: onTap),
      _buildItem(value: model.requisitionerPurpose, onTap: onTap),
      _buildItem(value: model.tripStatus, onTap: onTap),
      _buildItem(
          value: model.startTime != null ? model.startTime!.toLocal().formatDateTime('HH:mm a') : '', onTap: onTap),
      _buildItem(value: model.endTime != null ? model.endTime!.toLocal().formatDateTime('HH:mm a') : '', onTap: onTap),
      _buildItem(value: '${model.meterReading}KM', onTap: onTap),
      // _buildItem(value: '123KM', onTap: onTap),
      _buildItem(value: '${model.totalDistance}KM', onTap: onTap),
      _buildItem(value: model.driverName, onTap: onTap),
      _buildItem(value: model.approvingOfficer != null ? model.approvingOfficer! : "N/A", onTap: onTap),
    ]);
  }

  Widget _buildItem({required VoidCallback onTap, required String value, bool isHeader = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        height: 35,
        child: Text(
          value,
          style: _themeData.textTheme.subtitle1?.weight(isHeader ? FontWeight.w600 : FontWeight.normal),
        ),
      ),
    );
  }
}
