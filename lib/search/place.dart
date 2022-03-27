import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
//import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
import 'search.dart';
import '/map.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_location/user_location.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'package:geocoding/geocoding.dart';
import 'package:polyline/polyline.dart' as directions;
import 'package:flutter_mapbox_navigation/library.dart';
import '../user/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

var output = 'No results found.';

const String token = 'pk.eyJ1Ijoia2ltbW0iLCJhIjoiY2twaWJ1MWg4MDBsdjJvcXI1OHpycmM1ZiJ9.gHQqiF35MLH1fe2zQTYLQw';

final _startPointController = TextEditingController();

class Place extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Place();
}

class _Place extends State<Place> {
  DatabaseService database = DatabaseService();
  final _auth = FirebaseAuth.instance;
  currUser() {
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    return uid.toString();
  }
  Today() {
    DateTime dateToday =new DateTime.now();
    String date = dateToday.toString().substring(0,10);
    final now = new DateTime.now();
    String formatter = DateFormat.Hm().format(now);
    return date + "-" + formatter;
  }

  final _firestore = FirebaseFirestore.instance;

  String currUsername = '';
  List<String> names = [];
  List<LatLng> locs = [];
  List<String> uids = [];

  // 지도
  MapController mapController = MapController();

  late UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  List<Polyline> polylines = [];

  //내비
  dynamic _instruction = '';
  late MapBoxNavigation _directions;
  late MapBoxOptions _options;
  late double _distanceRemaining, _durationRemaining;
  late MapBoxNavigationViewController _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  bool _isMultipleStop = false;
  dynamic _arrived = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }



  Future<void> initialize() async {
    if (!mounted) return;

    _directions = MapBoxNavigation(onRouteEvent: _onRouteEvent);
    _options = MapBoxOptions(
      //initialLatitude: 37.517235,
      //initialLongitude: 127.047325,
        zoom: 15.0,
        tilt: 0.0,
        bearing: 0.0,
        //mapStyleUrlDay:
        enableRefresh: true,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: false,
        mode: MapBoxNavigationMode.cycling,
        units: VoiceUnits.metric,
        simulateRoute: false,
        animateBuildRoute: true,
        isOptimized: true,
        longPressDestinationEnabled: true,
        enableFreeDriveMode: true,
        language: "ko");
  }

  Future<void> _onRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
  }

  var bounds = LatLngBounds(LatLng(origin_lat, origin_lng), LatLng(destination_lat, destination_lng));

  Future<bool> _onBackPressed() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text("취소하시겠습니까?"),
        actions: <Widget>[
          new FlatButton(
              onPressed: () => {
                origin_search = false,
                origin_lat = curr_lat,
                origin_lng = curr_lng,
                Navigator.of(context).pop(true)
              },
              child: Text("YES")
          ),
          new FlatButton(
            child: Text("NO"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    )) ??
    false;
  }

  @override
  Widget build(BuildContext context) {

    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      zoomToCurrentLocationOnLoad: false,
      onLocationUpdate: (LatLng pos, double? speed) =>
          setState(() { curr_lat = pos.latitude; curr_lng = pos.longitude; }),
      updateMapLocationOnPositionChange: false,
      showMoveToCurrentLocationFloatingActionButton: false,
      defaultZoom: 15.0,
      markers: markers,
    );


    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      names.clear();
      locs.clear();
      uids.clear();
      final users = snapshot.data!.docs;
      for (var user in users) {
        var username = user['name'];
        var uid = user['uid'];
        GeoPoint geoPoint = user['location'];
        locs.add(LatLng(geoPoint.latitude, geoPoint.longitude));
        names.add(username.toString());
        uids.add(uid.toString());
      }
      for (int pos = 0; pos < names.length; pos++) {
        if (uids[pos] == currUser())
          currUsername = names[pos];
      }

      return WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
            appBar: AppBar(
              title: Text('길 찾기',
                style: TextStyle(color: Colors.white
                ),
              ),
              centerTitle: true,
              flexibleSpace: new Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(45, 78, 115, 1)
                ),
              ),
            ),
            body: Column(
              children: <Widget>[
                Container(
                  height: 50.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,

                  ),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 1,
                    //controller: _startPointController,
                    decoration: InputDecoration(
                      hintText: select_origin,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15.0),
                      suffixIcon: IconButton(
                          onPressed: () {
                            mapController.move(
                                LatLng(curr_lat, curr_lng), 15.0);
                          }, icon: Icon(Icons.search)),
                    ),
                    onTap: () {
                      origin_search = true;
                      Navigator.pop(context);
                    },
                    readOnly: true,
                  ),
                ),
                Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: TextField(
                    readOnly: true,
                    decoration: new InputDecoration(
                      hintText: select_destination,
                      contentPadding: EdgeInsets.only(
                          left: 15, top: 15, bottom: 15, right: 0),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: Colors.black
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            //mapController.move(LatLng(destination_lat, destination_lng), 15.0);
                            Navigator.pop(context);
                          }, icon: Icon(Icons.search)),
                    ),
                  ),
                ),
                Container(
                  height: 1.0,
                  color: Colors.black26,
                ),
                Expanded(
                  flex: 1,
                  child: Stack(
                      children: <Widget>[
                        new FlutterMap(
                          options: new MapOptions(
                            center: new LatLng(
                                destination_lat, destination_lng),
                            zoom: 12.0,
                            minZoom: 0,
                            maxZoom: 18.0,
                            plugins: [
                              UserLocationPlugin(),
                            ],
                            enableMultiFingerGestureRace: true,
                            bounds: bounds,
                            boundsOptions: FitBoundsOptions(
                                padding: EdgeInsets.only(
                                    top: 100, right: 70, left: 70, bottom: 150)
                            ),
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
                                markers: [
                                  new Marker(
                                    point: LatLng(
                                        destination_lat, destination_lng),
                                    width: 50.0,
                                    height: 100.0,
                                    builder: (ctx) =>
                                        Container(
                                          padding: EdgeInsets.only(bottom: 40),
                                          child: Icon(
                                              Icons.location_on, size: 50,
                                              color: Colors.redAccent),
                                        ),
                                  )
                                ]
                            ),
                            new PolylineLayerOptions(
                                polylineCulling: false,
                                polylines: [
                                  new Polyline(
                                    points: path,
                                    strokeWidth: 5.0,
                                    color: Colors.blueAccent,
                                  )
                                ]
                            ),
                            userLocationOptions,
                          ],
                          mapController: mapController,
                        ),
                        Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: FloatingActionButton(
                                backgroundColor: Colors.black54,
                                onPressed: () {
                                  mapController.move(
                                      LatLng(curr_lat, curr_lng), 15.0);
                                },
                                child: Icon(Icons.location_searching,
                                  color: Colors.white,),
                                mini: true,
                              ),
                            )
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              padding: EdgeInsets.all(20),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3.0),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey, blurRadius: 1.0)
                                    ]
                                ),
                                height: 70,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                              flex: 6,
                                              child: Text(duration_,
                                                style: TextStyle(
                                                    fontSize: 22.0,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.blueAccent
                                                ),)
                                          ),
                                          Expanded(
                                              flex: 4,
                                              child: Text(distance_,
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54
                                                ),
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius: BorderRadius.circular(
                                              3.0),

                                        ),
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            var wayPoints = <WayPoint>[];
                                            wayPoints.add(
                                                WayPoint(
                                                    name: "Origin",
                                                    latitude: origin_lat,
                                                    longitude: origin_lng)
                                            );
                                            wayPoints.add(
                                                WayPoint(
                                                    name: "Destination",
                                                    latitude: destination_lat,
                                                    longitude: destination_lng)
                                            );


                                            await database.Collection.doc(
                                                currUser()).collection(
                                                'records').doc(Today()).set({
                                              'Origin': GeoPoint(
                                                  origin_lat, origin_lng),
                                              'Destination': GeoPoint(
                                                  destination_lat,
                                                  destination_lng),
                                              'Origin_addr': select_origin,
                                              'Destination_addr': select_destination,
                                              'date': Today(),

                                            });
                                            await database.Collection.doc(
                                                currUser()).collection(
                                                'friends')
                                                .doc(currUser())
                                                .delete();


                                            await _directions.startNavigation(
                                                wayPoints: wayPoints,
                                                options: _options);
                                          },
                                          icon: Icon(
                                              Icons.bike_scooter, size: 30),
                                          label: Text("주행 시작"),
                                          style: TextButton.styleFrom(
                                              primary: Colors.white,
                                              textStyle: TextStyle(fontSize: 22)
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ),
                        ),

                      ]
                  ),
                )
              ],
            ),
          ));
    });
        }
}
