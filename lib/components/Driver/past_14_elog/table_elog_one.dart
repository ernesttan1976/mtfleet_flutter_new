import 'package:flutter/material.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';

class TableELogOne extends StatelessWidget {
  final Stream<List<ELogVehicleModel>> stream;
  final Function(ELogVehicleModel) onTapItem;

  const TableELogOne({Key? key, required this.onTapItem, required this.stream}) : super(key: key);

  static const List<String> _headers = [
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
  ];

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return StreamBuilder<List<ELogVehicleModel>>(
        initialData: const [],
        stream: stream,
        builder: (context, snapshot) {
          return Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(color: Colors.grey),
            children: [
              _buildHeaderTable(themeData),
              ...?snapshot.data
                  ?.map((element) => _dataRowTables(
                      model: element,
                      onTap: () {
                        onTapItem.call(element);
                      },
                      themeData: themeData))
                  .toList(),
            ],
          );
        });
  }

  TableRow _buildHeaderTable(ThemeData themeData) {
    return TableRow(
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha((0.3 * 255).round()),
        ),
        children: _headers
            .map(
              (e) => _buildItem(value: e, isHeader: true, onTap: () {}, themeData: themeData),
            )
            .toList());
  }

  TableRow _dataRowTables({
    required VoidCallback onTap,
    required ELogVehicleModel model,
    required ThemeData themeData,
  }) {
    return TableRow(children: [
      _buildItem(value: model.vehicleNumber, onTap: onTap, themeData: themeData),
      _buildItem(
          value: model.tripDate != null ? model.tripDate!.toLocal().formatDateddMMyyyy : '',
          onTap: onTap,
          themeData: themeData),
      // _buildItem(value: 'ABC', onTap: onTap),
      _buildItem(value: model.requisitionerPurpose, onTap: onTap, themeData: themeData),
      _buildItem(value: model.tripStatus, onTap: onTap, themeData: themeData),
      _buildItem(
          value: model.startTime != null ? model.startTime!.toLocal().formatDateTime('HH:mm a') : '',
          onTap: onTap,
          themeData: themeData),
      _buildItem(
          value: model.endTime != null ? model.endTime!.toLocal().formatDateTime('HH:mm a') : '',
          onTap: onTap,
          themeData: themeData),
      _buildItem(value: '${model.meterReading}KM', onTap: onTap, themeData: themeData),
      // _buildItem(value: '123KM', onTap: onTap),
      _buildItem(value: '${model.totalDistance}KM', onTap: onTap, themeData: themeData),
      _buildItem(value: model.driverName, onTap: onTap, themeData: themeData),
      _buildItem(
          value: model.approvingOfficer != null ? model.approvingOfficer! : "N/A",
          onTap: onTap,
          themeData: themeData),
    ]);
  }

  Widget _buildItem({
    required VoidCallback onTap,
    required String value,
    bool isHeader = false,
    required ThemeData themeData,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        height: 35,
        child: Text(
          value,
          style: themeData.textTheme.titleMedium?.weight(isHeader ? FontWeight.w600 : FontWeight.normal),
        ),
      ),
    );
  }
}
