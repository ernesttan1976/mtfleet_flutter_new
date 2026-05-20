class MtBroadcastModel {
  MtBroadcastModel({
    required this.id,
    required this.title,
    required this.path,
  });

  int id;
  String title;
  String path;

  factory MtBroadcastModel.fromJson(Map<String, dynamic> json) => MtBroadcastModel(
        id: json["id"],
        title: json["title"],
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "path": path,
      };
}
