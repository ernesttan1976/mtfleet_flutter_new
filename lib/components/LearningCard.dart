import 'package:flutter/material.dart';
import 'package:transport_flutter/screens/video.dart';

class LearningCard extends StatelessWidget {
  final String title;
  final String description;
  final String cover;
  final String videoUrl;

  const LearningCard({
    Key? key,
    required this.title,
    required this.cover,
    required this.videoUrl,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        // Navigator.pushNamed(context, "/slide"),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(
                title: description,
                url: videoUrl,
              ),
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Image.network(
                  "$cover",
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
                Expanded(
                    child: ListTile(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  title: Text(
                    '$title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("$description"),
                )),
                // Padding(
                //     padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                //     child: Text("5 mins")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
