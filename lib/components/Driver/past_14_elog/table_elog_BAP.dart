import 'package:flutter/material.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';

class TableELogBAP extends StatelessWidget {
  final Stream<List<ELogBapVehicleModel>> stream;
  final Function(ELogBapVehicleModel) onTapItem;

  const TableELogBAP({Key? key, required this.onTapItem, required this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return StreamBuilder<List<ELogBapVehicleModel>>(
        initialData: const [],
        stream: stream,
        builder: (context, snapshot) {
          return Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(color: Colors.grey),
            children: [
              _buildHeaderTable(themeData),
              ...?snapshot.data
                  ?.map((element) => _dataRowTables(model: element, onTap: () => onTapItem(element), themeData: themeData))
                  .toList(),
            ],
          );
        });
  }

  TableRow _buildHeaderTable(ThemeData themeData) {
    return TableRow(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
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
              (e) => _buildItem(value: e, isHeader: true, onTap: () {}, themeData: themeData),
            )
            .toList());
  }

  TableRow _dataRowTables({required VoidCallback onTap, required ELogBapVehicleModel model, required ThemeData themeData}) {
    return TableRow(children: [
      _buildItem(value: model.tripDate != null ? model.tripDate!.toLocal().formatDateTime('dd, MMMM') : '', onTap: onTap, themeData: themeData),
      _buildItem(
          value: model.startTime != null ? model.startTime!.toLocal().formatDateTime('HH:mm a') : '', onTap: onTap, themeData: themeData),
      _buildItem(value: model.endTime != null ? model.endTime!.toLocal().formatDateTime('HH:mm a') : '', onTap: onTap, themeData: themeData),
      _buildItem(value: '${model.meterReading}KM', onTap: onTap, themeData: themeData),
      _buildItem(value: model.requisitionerPurpose, onTap: onTap, themeData: themeData),
      _buildItem(value: model.driverName, onTap: onTap, themeData: themeData),
    ]);
  }

  Widget _buildItem({required VoidCallback onTap, required String value, bool isHeader = false, required ThemeData themeData}) {
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
