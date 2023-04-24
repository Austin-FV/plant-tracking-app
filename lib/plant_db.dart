// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

enum LightLevel { dark, medium, bright }

extension LightLevelExtension on LightLevel {
  String get displayValue {
    switch (this) {
      case LightLevel.dark:
        return "Dark";
      case LightLevel.medium:
        return "Medium";
      case LightLevel.bright:
        return "Bright";
      default:
        return "Dark";
    }
  }
}

enum LightType { direct, indirect }

extension LightTypeExtension on LightType {
  String get displayValue {
    switch (this) {
      case LightType.direct:
        return "Direct";
      case LightType.indirect:
        return "Indirect";
      default:
        return "No Light";
    }
  }
}

class Plant {
  String plant_name, description, imageUrl;
  // ignore: prefer_typing_uninitialized_variables
  int water_days, water_volume, plant_id;
  DateTime date_added, last_watered;
  bool isFavourite, hasShownNotification;
  List<Note> note;

  LightLevel light_level;
  LightType light_type;

  String room;

  Plant({
    required this.plant_id,
    required this.plant_name,
    required this.date_added,
    required this.water_days,
    required this.last_watered,
    required this.water_volume,
    required this.light_level,
    required this.light_type,
    required this.imageUrl,
    required this.description,
    required this.isFavourite,
    required this.room,
    required this.hasShownNotification,
    required this.note,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    List<dynamic> noteJsonList = json['note'] ?? [];
    List<Note> noteList = noteJsonList.map((noteJson) {
      DateTime dateAdded = DateTime.parse(noteJson['dateAdded']);
      String note = noteJson['note'];
      return Note(dateAdded: dateAdded, note: note);
    }).toList();

    return Plant(
      plant_id: json['plant_id'],
      plant_name: json['plant_name'],
      date_added: DateTime.parse(json['date_added']),
      water_days: json['water_days'],
      last_watered: DateTime.parse(json['last_watered']),
      water_volume: json['water_volume'],
      light_level: _parseLightLevel(json['light_level']),
      light_type: _parseLightType(json['light_type']),
      imageUrl: json['imageUrl'],
      description: json['description'],
      isFavourite: json['isFavourite'],
      room: json['room'],
      hasShownNotification: json['hasShownNotification'],
      note: noteList,
    );
  }

  static LightLevel _parseLightLevel(String displayValue) {
    switch (displayValue) {
      case 'Dark':
        return LightLevel.dark;
      case 'Medium':
        return LightLevel.medium;
      case 'Bright':
        return LightLevel.bright;
      default:
        return LightLevel.dark;
    }
  }

  static LightType _parseLightType(String displayValue) {
    switch (displayValue) {
      case 'Direct':
        return LightType.direct;
      case 'Indirect':
        return LightType.indirect;
      default:
        return LightType.direct;
    }
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> noteJsonList = [];
    noteJsonList = note
      .map((note) => {
        'dateAdded': note.dateAdded.toIso8601String(),
        'note': note.note,
      })
      .toList();

    return {
      'plant_id': plant_id,
      'plant_name': plant_name,
      'date_added': date_added.toIso8601String(),
      'water_days': water_days,
      'last_watered': last_watered.toIso8601String(),
      'water_volume': water_volume,
      'light_level': light_level.displayValue,
      'light_type': light_type.displayValue,
      'imageUrl': imageUrl,
      'description': description,
      'isFavourite': isFavourite,
      'note': noteJsonList,
      'room': room,
      'hasShownNotification' : hasShownNotification
    };
  }


}

class Note {
  DateTime dateAdded;
  String note;

  Note({required this.dateAdded, required this.note});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      dateAdded: DateTime.parse(json['dateAdded']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateAdded': dateAdded.toIso8601String(),
      'note': note,
    };
  }
}


class plant_db {
  List<Plant> plant_list = [];

  List<Plant> getList() {
    return plant_list;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/plant_list.json');
  }

  Future<void> addNote(String plantName, String text) async {
    List<Plant> plants = await getPlants();
    Note newNote = Note(dateAdded: DateTime.now(), note: text); //create a new note 
    log("New note: $text");

    int plantIndex =
        plants.indexWhere((plant) => plant.plant_name == plantName);

    if (plantIndex != -1) {
      plants[plantIndex].note.add(newNote);
      await writePlants(plants);
    }
    log("Added note");
  }


  Future<bool> addPlant(Plant newPlant) async {
    // Get the current list of plants
    List<Plant> plants = await getPlants();
    List<Note> noteList = [];
    // Add the new plant to the plant_list

    //set default plant image
    if (newPlant.imageUrl == "") {
      http.Response response = await http.get(Uri.parse(
          "https://creazilla-store.fra1.digitaloceanspaces.com/cliparts/63919/potted-plant-clipart-md.png"));
      String base64Image = base64Encode(response.bodyBytes);
      newPlant.imageUrl = base64Image;
    }

    newPlant.plant_id = plants.length + 1;
    newPlant.note = noteList;

    plants.add(newPlant);
    plant_list = plants;

    // Write the updated plant_list to a file
    log("Added plant");
    return writePlants(plants);
  }

  Future<void> removePlant(int plantIndex) async {
    // Get the current list of plants
    List<Plant> plants = await getPlants();

    // Remove the plant at the specified index from plant_list
    plants.removeAt(plantIndex);
    plant_list = plants;

    // Write the updated plant_list to a file
    log("Removed plant");
    await writePlants(plants);
  }

  Future<void> removeAllPlants() async {
    plant_list = [];
    await writePlants([]);
  }

    Future<bool> setWatering(Plant plant) async {
    // Water the plant and update the last_watered date
    // ignore: avoid_print
    plant.last_watered = DateTime.now();

    // Write the updated plant to the file
    List<Plant> plants = await getPlants();
    int index = plants.indexWhere((p) => p.plant_name == plant.plant_name);
    if (index != -1) {
      plants[index] = plant;
      return await writePlants(plants);
    }
    // ignore: avoid_print
    log("watered plant ${plant.plant_name}");
    return false;
  }

  Future<bool> writePlants(List<Plant> plants) async {
    // Convert each Plant object to a JSON-encodable Map
    List<Map<String, dynamic>> plantJsonList =
        plants.map((plant) => plant.toJson()).toList();

    // Write the updated plantJsonList to the file
    final file = await _localFile;
    await file.writeAsString(jsonEncode(plantJsonList));
    log("Wrote plants to DB");
    return true;
  }

  Future<List<Plant>> getPlants() async {
    log("Getting plants");
    try {
      final file = await _localFile;
      final contents = await file.readAsString();

      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
