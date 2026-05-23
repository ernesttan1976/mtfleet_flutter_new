import 'package:flutter/material.dart';
import 'package:transport_flutter/components/components.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/mt_broadcast.dart';

import 'bloc.dart';

class MTBroadCast extends StatefulWidget {
  const MTBroadCast({Key? key}) : super(key: key);

  @override
  State<MTBroadCast> createState() => _MTBroadCastState();
}

class _MTBroadCastState extends State<MTBroadCast> {
  final _bloc = MTBroadCastBloc();

  late ThemeData _themeData;

  @override
  void initState() {
    super.initState();
    _bloc.loadAllBoardCast(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'MT BroadCast',
                style: _themeData.textTheme.headlineMedium?.text244F4E.semiBold,
              ).paddingOnly(left: 24),
              10.verticalSpace,
              Card(
                margin: const EdgeInsets.all(24),
                elevation: 5,
                child: StreamBuilder<List<MtBroadcastModel>>(
                    stream: _bloc.listBroadCast,
                    initialData: const [],
                    builder: (context, snapshot) {
                      return _buildTable(snapshot.data ?? []).paddingAll(20);
                    }),
              )
            ],
          ),
          _buildLoading(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return StreamBuilder<bool>(
        initialData: false,
        stream: _bloc.isLoading,
        builder: (context, snapshot) {
          return snapshot.data!
              ? Center(
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        StreamBuilder<int>(
                            initialData: 0,
                            stream: _bloc.percentDownLoad,
                            builder: (context, snapshot2) {
                              return snapshot2.data == 0
                                  ? const SizedBox()
                                  : Text(
                                      '${snapshot2.data} %',
                                      style: _themeData.textTheme.titleLarge?.semiBold.text244F4E,
                                    ).paddingOnly(top: 20);
                            })
                      ],
                    ).wrapSize(100, 100),
                  ),
                )
              : const Center();
        });
  }

  Widget _buildTable(List<MtBroadcastModel> list) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(flex: 4),
        1: IntrinsicColumnWidth(flex: 1),
      },
      border: TableBorder.all(color: Colors.grey.withValues(alpha: 0.3)),
      children: [
        _buildHeaderTable(),
        ...list
            .map(
              (element) => _dataRowTables(
                model: element,
                onTapDownLoad: () => _bloc.downLoadBroadCats(context, element.path),
              ),
            )
            .toList(),
      ],
    );
  }

  TableRow _buildHeaderTable() {
    return TableRow(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
        children: [
          'Title',
          'Download',
        ]
            .map(
              (e) => _buildItem(value: e, isHeader: true),
            )
            .toList());
  }

  TableRow _dataRowTables({required MtBroadcastModel model, required VoidCallback? onTapDownLoad}) {
    return TableRow(children: [
      _buildItem(value: model.title),
      IconButton(icon: const Icon(Icons.arrow_downward), onPressed: onTapDownLoad)
    ]);
  }

  Widget _buildItem({required String value, bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Text(
        value,
        style: _themeData.textTheme.titleMedium?.weight(isHeader ? FontWeight.w600 : FontWeight.normal),
      ),
    );
  }
}
