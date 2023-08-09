class Sounds {
  int? type;
  String? file;

  Sounds({this.type, this.file});

  Sounds.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['file'] = this.file;
    return data;
  }
}