import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:user_location/user_location.dart';
import 'DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friends.dart';


late double curr_lat, curr_lng; // 현재 좌표값
bool origin_search = false;
bool first_search = true;

class userMap extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _userMap();
}

class _userMap extends State<userMap> {

  MapController mapController = MapController();
  late UserLocationOptions userLocationOptions;
  List<Marker> markers = [];

  DatabaseService database = DatabaseService();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String name = 'null';

  currUser() {
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    return uid.toString();
  }

  @override
  void initState() {
    super.initState();
  }

  List<String> friends = [];
  List<LatLng> locations = [];
  List<String> id = [];

  @override
  Widget build(BuildContext context) {
    final String token = 'pk.eyJ1Ijoia2ltbW0iLCJhIjoiY2twaWJ1MWg4MDBsdjJvcXI1OHpycmM1ZiJ9.gHQqiF35MLH1fe2zQTYLQw';
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      zoomToCurrentLocationOnLoad: true,
      onLocationUpdate: (LatLng pos, double? speed) =>
          setState(() {
            curr_lat = pos.latitude;
            curr_lng = pos.longitude;
          }),
      updateMapLocationOnPositionChange: false,
      showMoveToCurrentLocationFloatingActionButton: false,
      //moveToCurrentLocationFloatingActionButton: _currentButton,
      defaultZoom: 15.0,
      markers: markers,
    );
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(currUser()).collection('friends').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          friends.clear();
          locations.clear();
          id.clear();

          final users = snapshot.data!.docs;
          for (var user in users) {
            String uid = user['uid'];
            friends.add(uid);
          }


          for(int i=0; i<uids.length; i++){
            for(int j=0; j<friends.length; j++){
              if(uids[i] == friends[j]) {
                locations.add(locs[i]);
                id.add(names[i]);
              }
            }
          }

          // return StreamBuilder<QuerySnapshot>(
          //     stream: _firestore.collection('users').doc(currUser()).collection('friends').snapshots(),
          //     builder: (context, snapshot) {
          //       if (!snapshot.hasData) {
          //         return Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       }
          //       locs.clear();
          //       final users = snapshot.data!.docs;
          //       names.clear();
          //       for (var user in users) {
          //         String username = user['name'];
          //         GeoPoint geoPoint = user['location'];
          //         locs.add(LatLng(geoPoint.latitude, geoPoint.longitude));
          //         names.add(username.toString());
          //       }
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: DefaultTabController(
                  length: 4,
                  child: Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: Colors.black,
                        icon: Icon(Icons.arrow_back),
                      ),
                      backgroundColor: Colors.white,
                      centerTitle: true,
                      elevation: 0.0,
                      title: Text('친구찾기',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
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
                                'accessToken': token,
                                'id': 'mapbox.mapbox-streets-v8',
                              },

                            ),
                            new MarkerLayerOptions(
                              markers: markers,
                            ),
                            new MarkerLayerOptions(
                              markers: _markers,
                            ),
                            userLocationOptions,
                          ],
                          mapController: mapController,

                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: FloatingActionButton(
                                backgroundColor: Colors.black54,
                                onPressed: () {
                                  mapController.move(
                                      LatLng(curr_lat, curr_lng), 15.0);
                                  origin_search = false;
                                },
                                child: Icon(Icons.location_searching,
                                  color: Colors.white,),
                                mini: true,
                              ),
                            )
                        ),
                      ],
                    ),
                  )
              )
          );
        }
    );
  }


  List<Marker> get _markers => locations
      .map(
        (markerPosition) => Marker(
      point: markerPosition,
      width: 150,
      height: 60,
          anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (_) => Container(
        height:60,
        child: Column(
          children: <Widget>[
            Container(
              height: 20,
              color: Colors.transparent,
              child: Center(
                child: Builder(
                  builder: (BuildContext context) {
                    String name='';
                    for(int i=0; i<locations.length; i++){
                      if(locations[i].latitude == markerPosition.latitude){
                        name = id[i];
                      }
                    }
                    return Text(name, style: TextStyle(color: Colors.white, backgroundColor: Colors.black87, fontWeight: FontWeight.w600),);
                  },
                ),
              )
            ),
            Container(
              child: Icon(Icons.location_on, size: 40, color: Colors.red),
              height: 40
            ),
          ],
        ),
      ),
    ),
  ).toList();
}