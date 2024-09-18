import 'dart:convert';

import 'package:favorite_plaes/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelecLocation});

  final void Function(PlaceLocation location) onSelecLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  // String get locationImage {
  //   String lat = _pickedLocation.latitude;
  //   String lng = _pickedLocation.longitude;
  //   return 'google maps static image api MODIFIED';
  // }

  void _getCurrentLocation() async {
    Location location = new Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    // final url = Uri.parse( *PUT THE HTTP LINK OF MAPS API HERE* );
    // final response = await http.get(url);
    // final resData = json.decode(response.body);
    // final address = resData['results'][0]['formatted_address'];

    final double? lat = locationData.latitude;
    final double? lng = locationData.longitude;

    if(lat == null || lng == null) {
      return;
    }
    
    setState(() {
      _pickedLocation = PlaceLocation(latitude: lat, longitude: lng);
      _isGettingLocation = false;
    });

    widget.onSelecLocation(_pickedLocation!);
  }

  @override
  Widget build(BuildContext context) {

    Widget previewContent = Text(
            'No Location Chosen',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          );
      
    if(_isGettingLocation == true){
      previewContent = const CircularProgressIndicator();
    }

    // if(_pickedLocation != null) {
    //   previewContent = Image.network(locationImage, fit: BoxFit.cover, width: double.infinity, height: double.infinity,);
    // }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          height: 170,
          width: double.infinity,
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              onPressed: _getCurrentLocation,
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              onPressed: () {},
              label: const Text('Pick a Location'),
            )
          ],
        ),
      ],
    );
  }
}
