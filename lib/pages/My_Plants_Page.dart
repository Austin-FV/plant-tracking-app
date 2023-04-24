// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plant_tracker/pages/add_plant_page.dart';
import '../services/Navigation_Drawer.dart';
import '../services/notification.dart';
import 'package:plant_tracker/plant_db.dart';
import 'Plant_Info_Page.dart';

const greenColour = Color.fromARGB(255, 140, 182, 131);

enum SortOption {
  nextToWater,
  name,
  dateAdded,
  room,
}

SortOption _sortOption = SortOption.nextToWater;

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.refreshPlantList}) : super(key: key);
  final VoidCallback refreshPlantList;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  plant_db db = plant_db();
  List<Plant> _plantList = [];

  late final AnimationController controller;
  late final Animation<double> aniimation;

  void refreshPlantList() async {
    controller.stop(canceled: false);
    _plantList = await db.getPlants();
    setState(() {});
    controller.forward();
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    aniimation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    for (var plant in _plantList) {
      precacheImage(MemoryImage(base64Decode(plant.imageUrl)), context);
    }

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: const Text("Bloom Buddy"),
          backgroundColor: Colors.green,
          actions: [
            IconButton(onPressed: refreshPlantList, icon: const Icon(Icons.sync)),
            IconButton(
              onPressed: () {
                setState(() {
                  controller.reset();
                  controller.forward();
                  switch (_sortOption) {
                    case SortOption.nextToWater:
                      _sortOption = SortOption.name;
                      break;
                    case SortOption.name:
                      _sortOption = SortOption.dateAdded;
                      break;
                    case SortOption.dateAdded:
                      _sortOption = SortOption.room;
                      break;
                    case SortOption.room:
                      _sortOption = SortOption.nextToWater;
                      break;
                  }
                });
              },
              icon: Icon(_sortOption == SortOption.nextToWater
                  ? Icons.water_drop_outlined
                  : _sortOption == SortOption.name
                      ? Icons.sort_by_alpha_outlined
                      : _sortOption == SortOption.dateAdded
                          ? Icons.date_range_outlined
                          : Icons.house_outlined),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: getPlantTiles(_plantList, context),
      drawer: NavDrawer(
        refreshPlantList: refreshPlantList,
      ),
      floatingActionButton:
          getAddPlantButton(context, _plantList, db, refreshPlantList),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  FloatingActionButton getAddPlantButton(BuildContext context,
      List<Plant> plantList, plant_db db, VoidCallback callback) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddPlantPage(db: plant_db(), key: UniqueKey())));
        plantList = await db.getPlants();
        callback();
      },
      backgroundColor: greenColour,
      child: const Icon(Icons.add),
    );
  }

  FutureBuilder<List<Plant>> getPlantTiles(
      List<Plant> plantList, BuildContext context) {
    switch (_sortOption) {
      case SortOption.nextToWater:
        plantList
            .sort((a, b) => getWateringBar(a).compareTo(getWateringBar(b)));
        break;
      case SortOption.name:
        plantList.sort((a, b) => a.plant_name.compareTo(b.plant_name));
        break;
      case SortOption.dateAdded:
        plantList.sort((a, b) => a.date_added.compareTo(b.date_added));
        break;
      case SortOption.room:
        plantList.sort((a, b) => a.room.compareTo(b.room));
        break;
    }

    return FutureBuilder<List<Plant>>(
      future: db.getPlants(),
      builder: (BuildContext context, AsyncSnapshot<List<Plant>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(0.0)),
          );
        } else {
          return AnimatedList(
            itemBuilder: (context, index, animation) {
              return FadeTransition(
                opacity: aniimation,
                child: _buildPlantTile(context, snapshot.data![index]),
              );
            },
            initialItemCount: snapshot.data!.length,
          );
        }
      },
    );
  }

  Widget _buildPlantTile(BuildContext context, Plant plant) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlantInfoPage(
                  displayPlant: plant, index: plant.plant_id, refreshPlantList: refreshPlantList),
            ),
          );
        },
        child: Card(
          shadowColor: const Color.fromARGB(255, 131, 131, 131),
          color: greenColour,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                height: 100,
                child: _buildImage(plant),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildInfoContainer(plant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildInfoContainer(Plant plant) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPlantDetails(plant),
        ],
      ),
    );
  }


Widget _buildImage(Plant plant) {
  return FutureBuilder(
    future: Future.value(MemoryImage(base64Decode(plant.imageUrl))),
    builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // return a placeholder or loading indicator widget here
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // handle the error state here
        return const Icon(Icons.error);
      } else {
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: greenColour,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image(
                image: snapshot.data!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }
    },
  );
}


  Widget _buildPlantDetails(Plant plant) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      plant.plant_name,
                      style: const TextStyle(
                        fontSize: 24.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        db
                            .setWatering(plant)
                            .then((value) => refreshPlantList());
                      },
                      icon: const Icon(Icons.water_drop_outlined))
                ],
              )),
          Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                margin: const EdgeInsets.only(top: 15.0),
                width: 300,
                height: 10,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    value: getWateringBar(plant),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 0, 174, 255)),
                    backgroundColor: const Color(0xffD6D6D6),
                  ),
                ),
              ))
        ],
      ),
    );
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
}