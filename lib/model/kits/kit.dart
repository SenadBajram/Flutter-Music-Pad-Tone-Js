import 'package:music_box/model/kits/sounds.dart';

class Kits {
  int? kitId;
  String? name;
  int? bpm;
  String? folder;
  String? sampleDuration;

  Kits({this.kitId, this.name, this.bpm, this.folder, this.sampleDuration});

  Kits.fromJson(Map<String, dynamic> json) {
    kitId = json['kitId'];
    name = json['name'];
    bpm = json['bpm'];
    folder = json['folder'];
    sampleDuration = json['sampleDuration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kitId'] = this.kitId;
    data['name'] = this.name;
    data['bpm'] = this.bpm;
    data['folder'] = this.folder;
    data['sampleDuration'] = this.sampleDuration;
    return data;
  }
}