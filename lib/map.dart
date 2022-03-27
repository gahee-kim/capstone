import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'search/searchRoute.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_location/user_location.dart';
import 'user/friends.dart';
import '../user/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart' as loc;


late double curr_lat, curr_lng; // 현재 좌표값
bool origin_search = false;
bool first_search = true;


class Map extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Map();
}

class _Map extends State<Map> {

  MapController mapController = MapController();
  late UserLocationOptions userLocationOptions;
  List<Marker> markers = [];

  final _firestore = FirebaseFirestore.instance;

  String currUsername = '';
  List<String> names = [];
  List<LatLng> locs = [];
  List<String> uids = [];
  DatabaseService database = DatabaseService();
  final _auth = FirebaseAuth.instance;
  currUser() {
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    return uid.toString();
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    final String token = 'pk.eyJ1Ijoia2ltbW0iLCJhIjoiY2twaWJ1MWg4MDBsdjJvcXI1OHpycmM1ZiJ9.gHQqiF35MLH1fe2zQTYLQw';
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      zoomToCurrentLocationOnLoad: true,
      onLocationUpdate: (LatLng pos, double? speed) =>
          setState(() { curr_lat = pos.latitude; curr_lng = pos.longitude; }),
      updateMapLocationOnPositionChange: false,
      showMoveToCurrentLocationFloatingActionButton: false,
      //moveToCurrentLocationFloatingActionButton: _currentButton,
      defaultZoom: 15.0,
      markers: markers,
    );


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            new FlutterMap(
                options: new MapOptions(
                  center: new LatLng(37.517235, 127.047325),
                  minZoom: 0,
                  maxZoom: 18,
                  zoom: 10,
                  plugins: [
                    UserLocationPlugin(),
                  ],
                ),
                layers: [
                  new TileLayerOptions(
                    urlTemplate: "https://api.mapbox.com/styles/v1/kimmm/ckpia5oj215g018o5fxl9lve2/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia2ltbW0iLCJhIjoiY2twaWJ1MWg4MDBsdjJvcXI1OHpycmM1ZiJ9.gHQqiF35MLH1fe2zQTYLQw",
                    additionalOptions: {
                      'accessToken' : token,
                      'id' : 'mapbox.mapbox-streets-v8',
                    },

                  ),
                  new MarkerLayerOptions(
                    markers: markers,
                  ),
                  userLocationOptions,
                ],
              mapController: mapController,

            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 60.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    //borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey, blurRadius: 0.0)
                    ],
                  ),
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    Container(
                      child: TextButton.icon(
                        onPressed: () {
                          first_search = true;
                          origin_search = false;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchRoute(),
                            ),
                          );
                        },
                        icon: Icon(Icons.map_outlined, size: 30),
                        label: Text('길 찾기', style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700
                        ),),
                        style: TextButton.styleFrom(
                            primary: Color.fromRGBO(45, 78, 115, 1),
                            textStyle: TextStyle(fontSize: 20)
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      child: TextButton.icon(
                        onPressed: () {
                          first_search = true;
                          origin_search = false;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Friend(),
                            ),
                          );
                        },
                        icon: Icon(Icons.pedal_bike_outlined, size: 30),
                        label: Text('친구 찾기', style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700
                        ),),
                        style: TextButton.styleFrom(
                            primary: Color.fromRGBO(45, 78, 115, 1),
                            textStyle: TextStyle(fontSize: 20)
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),

            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: FloatingActionButton(
                    backgroundColor: Colors.black54,
                    onPressed: () {
                      mapController.move(LatLng(curr_lat, curr_lng), 15.0);
                      origin_search = false;
                    },
                    child: Icon(Icons.location_searching, color: Colors.white,),
                    mini: true,
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
