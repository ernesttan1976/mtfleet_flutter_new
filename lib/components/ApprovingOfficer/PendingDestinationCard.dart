import 'package:flutter/material.dart';
import 'package:transport_flutter/components/extension/extension.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';

class PendingDestinationCard extends StatelessWidget {
  final AdHocDestinationModel tripData;

  const PendingDestinationCard({Key? key, required this.tripData}) : super(key: key);

  List<Widget> _buildChildren(var context) {
    var myList = [
      Text(
        "Date:",
        style: Theme.of(context).textTheme.bodyText1,
      ),
      5.verticalSpace,
      Text(
        tripData.createdAt == null ? '--' : tripData.createdAt.formatDateTime('dd MMM yyyy'),
        style: Theme.of(context).textTheme.bodyText2,
      ),
      5.verticalSpace,
      Text(
        "To:",
        style: Theme.of(context).textTheme.bodyText1,
      ),
      5.verticalSpace,
      Text(
        tripData.to,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      5.verticalSpace,
      Text(
        "Requisitioner Purpose:",
        style: Theme.of(context).textTheme.bodyText1,
      ),
      5.verticalSpace,
      Text(
        tripData.requisitionerPurpose,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    ];

    return myList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _buildChildren(context),
    ).paddingAll(15);
  }
}
