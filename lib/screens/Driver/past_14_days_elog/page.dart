import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:transport_flutter/components/Driver/past_14_elog/components.dart';
import 'package:transport_flutter/components/components.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/screens/Driver/past_14_days_elog/bloc.dart';

class Past14DaysELog extends StatefulWidget {
  @override
  _Past14DaysELogState createState() => _Past14DaysELogState();
}

class _Past14DaysELogState extends State<Past14DaysELog> with SingleTickerProviderStateMixin {
  final _bloc = Past14DaysELogBloc();

  late ThemeData _themeData;

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _bloc.vehicleID = ModalRoute.of(context)!.settings.arguments as int;
    await _bloc.fetchDataNormalAdHoc(context);
    await _bloc.fetchDataBAPH(context);
  }

  @override
  void dispose() {
    _bloc.dispose();

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
                'Past 14 days eLogs',
                style: _themeData.textTheme.headlineSmall!.text244F4E.semiBold,
              ).paddingOnly(left: 24),
              10.verticalSpace,
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
          StreamBuilder<bool>(
              initialData: false,
              stream: _bloc.isLoading,
              builder: (context, snapshot1) {
                if (snapshot1.data!)
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                return const Center();
              }),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            20.verticalSpace,
            Row(
              children: <Widget>[
                24.horizontalSpace,
                _buildTabBar(),
                350.horizontalSpace,
                _buildSelectDate(),
              ],
            ),
            20.verticalSpace,
            _getTable().paddingOnly(left: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabController,
        unselectedLabelStyle: _themeData.textTheme.titleMedium!.medium,
        unselectedLabelColor: _themeData.hintColor,
        labelStyle: _themeData.textTheme.titleMedium!.semiBold,
        labelColor: Colors.black,
        indicatorWeight: 0,
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        tabs: ['Normal trips', 'BOS/AOS/AHS/DI'].map((e) {
          return Tab(
            text: e,
          );
        }).toList(),
        indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        isScrollable: true,
        onTap: (val) {
          _bloc.currentIndexTable.add(val);
        },
      ),
    );
  }

  Widget _getTable() {
    final _tables = [
      TableELogOne(
        stream: _bloc.listELogVehicle,
        onTapItem: _bloc.onTapItem,
      ),
      TableELogBAP(
        stream: _bloc.listELogBAPVehicle,
        onTapItem: _bloc.onTapBAPItem,
      ),
    ];
    return StreamBuilder<int>(
        stream: _bloc.currentIndexTable,
        initialData: 0,
        builder: (context, snapshot) {
          return IndexedStack(
            index: snapshot.data,
            children: _tables
                .asMap()
                .keys
                .map(
                  (index) => Visibility(
                    maintainState: true,
                    visible: snapshot.data == index,
                    child: _tables[index],
                  ),
                )
                .toList(),
          );
        });
  }

  Widget _buildSelectDate() {
    return TitleAndWidgetShadow(
      isTitle: false,
      child: FormBuilderDateTimePicker(
        validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
        onChanged: (val) => _bloc.dateSelect = val!,
        inputType: InputType.date,
        decoration: InputDecoration(
            suffixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 12.0),
          child: const Icon(
            Icons.date_range,
            size: 30,
          ), // myIcon is a 48px-wide widget.
        )),
        initialValue: _bloc.dateSelect,
        format: new DateFormat('dd/MM/yyyy'),
        name: '',
        // readonly: true,
      ).wrapWidth(200),
    );
  }
}
