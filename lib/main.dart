import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:core';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: MapSample (),
            ),
          ],
        ),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-33.86677454358747, 151.2084462493658),
    zoom: 14.4746,
  );

  final Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
        },
        tileOverlays: <TileOverlay>{
          TileOverlay(
            tileOverlayId: TileOverlayId('pollen'),
            tileProvider: new PollenTileProvider(),
            transparency: 0.6,
          ),
        },
        markers: markers,
        onTap: (LatLng pos) async {
          var uri = Uri.https('pollen.googleapis.com', '/v1/forecast:lookup', {
            'key': 'AIzaSyAJvYO51ZXJ37odx-UHhBvkdDrhYEjeYGY',
            'location.longitude': pos.longitude.toString(),
            'location.latitude': pos.latitude.toString(),
            'days': 1.toString(),
          });
          var data = await http.read(uri, headers: {'Referer': 'https://storage.googleapis.com/'});
          var info = json.decode(data)["dailyInfo"][0]["pollenTypeInfo"][0];
          setState(() {
            markers.add(Marker(
              markerId: MarkerId('src'),
              position: pos,
              infoWindow: InfoWindow(
                title: info["indexInfo"]["category"],
                snippet: info["indexInfo"]["indexDescription"],
              ),
            ));

          });
          (await _controller.future).showMarkerInfoWindow(MarkerId('src'));
        },
      ),
    );
  }
}

class PollenTileProvider implements TileProvider {
  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    // key is grabbed from https://storage.googleapis.com/gmp-maps-demos/pollen/index.html
    var uri = Uri.https('pollen.googleapis.com', '/v1/mapTypes/TREE_UPI/heatmapTiles/$zoom/$x/$y', {'key': 'AIzaSyAJvYO51ZXJ37odx-UHhBvkdDrhYEjeYGY'});
    var data = await http.readBytes(uri, headers: {'Referer': 'https://storage.googleapis.com/'});
    return Tile(256, 256, data);
  }
}
