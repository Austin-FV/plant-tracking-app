// ignore: file_names
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plant_tracker/plant_db.dart';
import 'package:intl/intl.dart';
import '../services/notification.dart';
import 'My_Plants_Page.dart';
import 'add_note_page.dart';

// ignore: must_be_immutable
class PlantInfoPage extends StatelessWidget {
  Plant displayPlant;
  int index;
  plant_db db = plant_db();
  PlantInfoPage({super.key, required this.displayPlant, required this.index, required this.refreshPlantList});
  final VoidCallback refreshPlantList;

  Future<bool> _onSaveNote() async {
    //TODO: Refresh the state of this widget
    List<Plant> templist = await db.getPlants();
    displayPlant = templist[index-1];
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Details"),
        elevation: 0,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              color: const Color.fromRGBO(255, 255, 255, 0),
              width: double.infinity,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Hero(
                      tag: displayPlant.plant_name,
                        child: Image.memory(
                        base64Decode(displayPlant.imageUrl),
                        fit: BoxFit.fitWidth,
                        height: 400.0,
                        width: double.infinity,
                        alignment: Alignment.center,
                      ),
                    ),
                    Card(
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      margin: const EdgeInsets.all(0.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: StatefulBuilder(builder: (context, setState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    displayPlant.plant_name,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 40,
                                    ),
                                  ),
                                  IconButton(onPressed: () {
                                    db.setWatering(displayPlant).then((value) => setState((){refreshPlantList(); }) );
                                  }, icon: const Icon(Icons.water_drop_outlined))
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(
                                    5.0), // add a height to the container
                                child: Container(
                                  margin: const EdgeInsets.only(top: 15.0),
                                  width: 300,
                                  height: 10,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: LinearProgressIndicator(
                                      value: getWateringBar(
                                          displayPlant), // This should be a value between 0.0 and 1.0
                                      backgroundColor: Colors.grey,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Color.fromARGB(
                                                  255, 76, 222, 241)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                displayPlant.description,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text.rich(
                                textAlign: TextAlign.left,
                                TextSpan(
                                  text: "Last Watered: ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: DateFormat.yMMMd()
                                            .format(displayPlant.last_watered),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal)),
                                  ],
                                ),
                              ),
                              Text.rich(
                                textAlign: TextAlign.left,
                                TextSpan(
                                  text: "Room: ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: theRoom(displayPlant),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal)),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Card(
                                    shadowColor: Colors.black,
                                    color:
                                        const Color.fromARGB(255, 76, 222, 241),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            height: 75,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              image: const DecorationImage(
                                                image: NetworkImage(
                                                    'https://cdn.shopify.com/s/files/1/1061/1924/products/Sweat_Water_Emoji_1024x1024.png?v=1571606064'),
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                          ),
                                        ),
                                        Text(
                                          displayPlant.water_volume == 0 ? "Water amount" : "${displayPlant.water_volume} ml",
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Card(
                                    shadowColor: Colors.black,
                                    color: Colors.yellow,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            height: 75,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              image: const DecorationImage(
                                                image: NetworkImage(
                                                    'https://em-content.zobj.net/thumbs/160/apple/81/electric-light-bulb_1f4a1.png'),
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                          ),
                                        ),
                                        Text(
                                          displayPlant.light_type.displayValue,
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                  Card(
                                    shadowColor: Colors.black,
                                    color: Colors.grey,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            height: 75,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              image: const DecorationImage(
                                                image: NetworkImage(
                                                    'https://images.emojiterra.com/twitter/v13.1/512px/1f506.png'),
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                          ),
                                        ),
                                        Text(
                                          displayPlant.light_level.displayValue,
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add this line to spread the children horizontally
                                  children: [
                                    const Text(
                                      "Notes",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        decoration: TextDecoration.underline,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    Container( // Wrap IconButton inside a Container widget
                                      decoration: const BoxDecoration( // Add BoxDecoration to give the container a circular shape
                                        shape: BoxShape.circle,
                                        color: greenColour, // Set the color of the container
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white, // Set the color of the icon
                                        ),
                                        onPressed: () async {
                                            await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: ((context) => AddNotePage(onSaveNote: _onSaveNote, database: db, plant: displayPlant,))),
                                          ).then((value) => setState((){refreshPlantList(); }));
                                          await _onSaveNote();
                                          //setState((){refreshPlantList(); });
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              getNotesAsListView(displayPlant),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getNotesAsListView(Plant displayPlant) {
    List<Note> notes = displayPlant.note;
    
    if (notes.isEmpty){
      return Container();
    }

    return ListView.builder(
    shrinkWrap: true,
    itemCount: notes.length,
    itemBuilder: (context, index) {
      final note = notes[index];
      return ListTile(
        title: Text(note.note),
        subtitle: Text(note.dateAdded.toString()),
      );
    },
    );
  }

  void saveNewNode(String noteText) {
    
  }



  double getWateringBar(Plant plant) {
    DateTime lastWatered = plant.last_watered;
    DateTime now = DateTime.now();

    int hoursSinceLastWatered = now.difference(lastWatered).inHours;
    int wateringIntervalInHours = plant.water_days * 24;

    // If the plant has not been watered for longer than its watering interval, return 0
    NotificationService x = NotificationService();

    if (hoursSinceLastWatered >= wateringIntervalInHours) {
      return 0.0;
    }

    // Calculate the watering level as a fraction between 0 and 1
    double wateringLevel =
        1.0 - (hoursSinceLastWatered / wateringIntervalInHours);
    wateringLevel.clamp(0, 1);
    return wateringLevel;
  }

  String theRoom(Plant plant) {
    if (plant.room == "") {
      return "No room";
    } else {
      return plant.room;
    }
  }
  
  int noteLength(Plant plant) {
    final notes = plant.note;
    return notes.length;
  }


}
