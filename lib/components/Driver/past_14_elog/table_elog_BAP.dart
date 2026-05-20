import 'package:flutter/material.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';

class TableELogBAP extends StatelessWidget {
  final Stream<List<ELogBapVehicleModel>> stream;
  final Function(ELogBapVehicleModel) onTapItem;
  late ThemeData _themeData;

  TableELogBAP({required this.onTapItem, required this.stream});

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return StreamBuilder<List<ELogBapVehicleModel>>(
        initialData: [],
        stream: stream,
        builder: (context, snapshot) {
          return Table(
            defaultColumnWidth: IntrinsicColumnWidth(),
            border: TableBorder.all(color: Colors.grey),
            children: [
              _buildHeaderTable(),
              ...?snapshot.data
                  ?.map((element) => _dataRowTables(model: element, onTap: () => onTapItem(element)))
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
          'Date',
          'Start Time',
          'End Time',
          'Meter',
          'Requisitioner Purpose',
          'Driver Name',
        ]
            .map(
              (e) => _buildItem(value: e, isHeader: true, onTap: () {}),
            )
            .toList());
  }

  TableRow _dataRowTables({required VoidCallback onTap, required ELogBapVehicleModel model}) {
    return TableRow(children: [
      _buildItem(value: model.tripDate != null ? model.tripDate!.toLocal().formatDateTime('dd, MMMM') : '', onTap: onTap),
      _buildItem(
          value: model.startTime != null ? model.startTime!.toLocal().formatDateTime('HH:mm a') : '', onTap: onTap),
      _buildItem(value: model.endTime != null ? model.endTime!.toLocal().formatDateTime('HH:mm a') : '', onTap: onTap),
      _buildItem(value: '${model.meterReading}KM', onTap: onTap),
      _buildItem(value: model.requisitionerPurpose, onTap: onTap),
      _buildItem(value: model.driverName, onTap: onTap),
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
