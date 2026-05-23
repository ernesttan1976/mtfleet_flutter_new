import 'package:flutter/material.dart';
import 'package:transport_flutter/components/LearningCard.dart';
import 'package:transport_flutter/constants.dart' as constants;

class LearningVideoScreen extends StatefulWidget {
  const LearningVideoScreen({Key? key}) : super(key: key);

  @override
  LearningVideoScreenState createState() => LearningVideoScreenState();
}

class LearningVideoScreenState extends State<LearningVideoScreen> {
  String query = """
  query {
    learningVideos{
      video {
        url
        mime
      }
      title
      description
      cover {
        url
      }
    }
  }
  """;

  // ignore: unused_element
  List _buildList(learningVideos) {
    List<Widget> listItems = [];

    for (var item in learningVideos) {
      if (item['video'] != null && item['video']['mime'].contains("video")) {
        listItems.add(Padding(
            padding: const EdgeInsets.all(10.0),
            child: LearningCard(
              title: item['title'],
              description: item['description'],
              cover: constants.SERVER_URI_API + item['cover']['url'],
              videoUrl: constants.SERVER_URI_API + item['video']['url'],
            )));
      }
    }

    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    // final ValueNotifier<GraphQLClient> client = GQLClient.instance.client;
    //
    // return GraphQLProvider(
    //   client: client,
    //   child: Query(
    //     options: QueryOptions(documentNode: gql(query), pollInterval: 10),
    //     builder: (result, {fetchMore, refetch}) {
    //       if (result.hasException) {
    //         return Scaffold(
    //           appBar: AppBar(
    //             title: Text(
    //               "Learning Videos",
    //               style: TextStyle(
    //                   color: Theme.of(context).primaryColor,
    //                   fontWeight: FontWeight.bold),
    //             ),
    //             backgroundColor: Colors.white,
    //             iconTheme: IconThemeData(color: Colors.black),
    //             // elevation: 5,
    //           ),
    //           body: Container(
    //             padding: EdgeInsets.all(10),
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: <Widget>[
    //                 Text(
    //                   "There were some internal server errors while fetching the data. Please try again.",
    //                   textAlign: TextAlign.center,
    //                 ),
    //                 RaisedButton(
    //                   onPressed: () => refetch(),
    //                   child: const Text('Refetch',
    //                       style: TextStyle(
    //                         fontSize: 14,
    //                       )),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         );
    //       }
    //
    //       if (result.loading) {
    //         return Scaffold(
    //             appBar: AppBar(
    //               title: Text(
    //                 "Learning Videos",
    //                 style: TextStyle(
    //                     color: Theme.of(context).primaryColor,
    //                     fontWeight: FontWeight.bold),
    //               ),
    //               backgroundColor: Colors.white,
    //               iconTheme: IconThemeData(color: Colors.black),
    //               // elevation: 5,
    //             ),
    //             body: Center(
    //               child: CircularProgressIndicator(),
    //             ));
    //       }
    //
    //       var learningVideos = result.data['learningVideos'];
    //
    //       if (learningVideos.length == 0) {
    //         return Scaffold(
    //             appBar: AppBar(
    //               title: Text(
    //                 "Learning Videos",
    //                 style: TextStyle(
    //                     color: Theme.of(context).primaryColor,
    //                     fontWeight: FontWeight.bold),
    //               ),
    //               backgroundColor: Colors.white,
    //               iconTheme: IconThemeData(color: Colors.black),
    //               // elevation: 5,
    //             ),
    //             body: Container(
    //               height: MediaQuery.of(context).size.height,
    //               color: Colors.white,
    //               child: Center(
    //                 child: EmptyPlaceholder(
    //                     description:
    //                         "No Learning Videos Found. Please check back later!",
    //                     imagePath: "assets/images/blank_canvas.png"),
    //               ),
    //             ));
    //       }
    //
    //       return Scaffold(
    //           body: CustomScrollView(
    //         slivers: <Widget>[
    //           SliverAppBar(
    //             pinned: true,
    //             title: Text(
    //               "Learning Videos",
    //               style: TextStyle(
    //                   color: Theme.of(context).primaryColor,
    //                   fontWeight: FontWeight.bold),
    //             ),
    //             backgroundColor: Colors.white,
    //             iconTheme: IconThemeData(color: Colors.black),
    //             // elevation: 5,
    //           ),
    //           SliverList(
    //               delegate:
    //                   new SliverChildListDelegate(_buildList(learningVideos))),
    //         ],
    //       ));
    //     },
    //   ),
    // );

    return const SizedBox();
  }
}
