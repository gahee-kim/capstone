import 'package:flutter/material.dart';
import 'searchRoute.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_location/user_location.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'popup.dart';
//import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
import 'package:geocoding/geocoding.dart';

bool rental = true;
late double search_lat, search_lng;
String search_place = 'null';
String prev_search = 'null';

late double curr_lat, curr_lng; // 현재 좌표값

class MapStorage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MapStorage();
}

class _MapStorage extends State<MapStorage> {
  List<LatLng> _markerPositions = [];
  List<String> _markerAddress = [];
  List<List<dynamic>> csvdata = [];

  MapController mapController = MapController();
  late UserLocationOptions userLocationOptions;
  List<Marker> markers = [];

  /// Used to trigger showing/hiding of popups.
  final PopupController _popupLayerController = PopupController();

  loadCSV_rental() async {
    final Data = await rootBundle.loadString('Assets/data/rentalSeoul.csv');
    List<List<dynamic>> csvData = CsvToListConverter().convert(Data);
    setState(() {
      csvdata = csvData;
      for (int i=0; i<2170; i++){
        if (csvdata[i][2] == '종로구'){
          double la = csvdata[i][4];
          double lo = csvdata[i][5];
          _markerPositions.add(LatLng(la, lo));
          _markerAddress.add(csvdata[i][1]);
        }
      }
      rental = true;
    });
  }

  loadCSV_park() async {
    final Data = await rootBundle.loadString('Assets/data/park_seodaemun.csv');
    List<List<dynamic>> csvData = CsvToListConverter().convert(Data);
    setState(() {
      csvdata = csvData;
      for (int i=1; i<51; i++){
          if(csvdata[i][4] != ''){
            double la = csvdata[i][3];
            double lo = csvdata[i][4];
            _markerPositions.add(LatLng(la, lo));
            _markerAddress.add(csvdata[i][1]);
          }
      }
      rental = false;
      print(csvdata[5][5]);
    });
  }

  @override
  void initState() {
    super.initState();
//    loadCSV();
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
      defaultZoom: 16.0,
      markers: markers,
    );

    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            new FlutterMap(
              options: MapOptions(
                zoom: 12.0,
                center: LatLng(37.517235, 127.047325),
                plugins: [UserLocationPlugin(),
                  //MarkerClusterPlugin(),
                ],
                onTap: (_) => _popupLayerController.hideAllPopups(), // Hide popup when the map is tapped.
              ),
              children: [
                TileLayerWidget(
                  options: TileLayerOptions(
                    urlTemplate: "https://api.mapbox.com/styles/v1/kimmm/ckpia5oj215g018o5fxl9lve2/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia2ltbW0iLCJhIjoiY2twaWJ1MWg4MDBsdjJvcXI1OHpycmM1ZiJ9.gHQqiF35MLH1fe2zQTYLQw",
                    additionalOptions: {
                      'accessToken' : token,
                      'id' : 'mapbox.mapbox-streets-v8',
                    },),
                ),
                PopupMarkerLayerWidget(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupLayerController,
                    markers: _markers,
                    popupAnimation: PopupAnimation.fade(duration: Duration(milliseconds: 700)),
                    markerRotateAlignment:
                    PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.top),
                    popupBuilder: (BuildContext context, Marker marker) =>
                        Popup(marker),
                  ),
                ),
              ],
              layers: [
                  new MarkerLayerOptions(
                  markers: markers,
                ),
                userLocationOptions,
              ],
              mapController: mapController,
            ),
            Positioned(
              top:15.0,
              left: 15.0,
              right: 15.0,
              child: Container(
                child: MapBoxPlaceSearchWidget( // 장소 검색 자동 완성 위젯
                  popOnSelect: false,
                  apiKey: token,
                  searchHint: '장소 검색',
                  onSelected: (place) {
                    //_startPointController.text = place.placeName;
                    search_place = place.placeName; // 목적지에 검색한 위치 이름 저장
                    prev_search = search_place;
                    locationFromAddress(search_place) // 위치 이름 좌표로 변환
                        .then((locations) {
                      if (locations.isNotEmpty) {
                        search_lat = locations[0].latitude; // 검색 좌표값에 저장
                        search_lng = locations[0].longitude;
                      }
                    });
                  },
                  context: context,
                ),
              ),
            ),
            Positioned(
                top: 20.0,
                right: 20.0,
                width: 45,
                height: 65,
                child: TextButton( // 장소 검색 위젯 옆 버튼 기능
                    onPressed: () {
                      mapController.move(LatLng(search_lat, search_lng), 15.0); // 검색한 좌표로 지도 이동
                    },
                    child: Text('')) //투명 버튼
            ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: FloatingActionButton(
                    backgroundColor: Colors.black54,
                    onPressed: () {
                      mapController.move(LatLng(curr_lat, curr_lng), 15.0);
                    },
                    child: Icon(Icons.location_searching, color: Colors.white,),
                    mini: true,
                  ),
                )
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                child: Column(
                  children: <Widget>[
                    Container(
                      height:50,
                      child: Row(
                        children: <Widget>[
                          Spacer(),
                          Container(
                            child: ElevatedButton(
                              onPressed: () async {
                                _popupLayerController.hideAllPopups();
                                setState(() {
                                  _markerPositions.clear();
                                });
                                await loadCSV_rental();
                                print(rental);
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                              ),
                              child: Text("대여소"),
                            ),
                          ),
                          Spacer(),
                          Container(
                            child: ElevatedButton(
                              onPressed: () async {
                                _popupLayerController.hideAllPopups();
                                setState(() {
                                  _markerPositions.clear();
                                });
                                await loadCSV_park();
                                print(rental);
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                              ),
                              child: Text("보관소"),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    Container(
                      height:20,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }

  List<Marker> get _markers => _markerPositions
      .map(
        (markerPosition) => Marker(
      point: markerPosition,
      width: 40,
      height: 40,
      builder: (_) => Icon(Icons.location_on, size: 40, color:
      (rental == true ? Colors.redAccent : Colors.blueAccent),),
      anchorPos: AnchorPos.align(AnchorAlign.top),
    ),
  ).toList();
}
