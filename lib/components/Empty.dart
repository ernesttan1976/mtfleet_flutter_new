import 'package:flutter/material.dart';

class EmptyPlaceholder extends StatelessWidget {
  final String description;
  final String imagePath;
  final double? width;

  const EmptyPlaceholder({
    Key? key,
    required this.description,
    required this.imagePath,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          children: <Widget>[
            Image(
              image: AssetImage(imagePath),
              width: width ?? MediaQuery.of(context).size.width,
            ),
            Text(
              "$description",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
