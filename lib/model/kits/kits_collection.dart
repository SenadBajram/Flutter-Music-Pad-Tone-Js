import 'package:music_box/model/kits/sounds.dart';

import 'kit.dart';

class KitCollection {
  List<Kits>? kits;
  List<Sounds>? sounds;

  KitCollection({this.kits, this.sounds});

  KitCollection.fromJson(Map<String, dynamic> json) {
    if (json['kits'] != null) {
      kits = <Kits>[];
      json['kits'].forEach((v) {
        kits!.add(new Kits.fromJson(v));
      });
    }
    if (json['sounds'] != null) {
      sounds = <Sounds>[];
      json['sounds'].forEach((v) {
        sounds!.add(new Sounds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.kits != null) {
      data['kits'] = this.kits!.map((v) => v.toJson()).toList();
    }
    if (this.sounds != null) {
      data['sounds'] = this.sounds!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}