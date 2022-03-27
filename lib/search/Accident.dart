import 'package:flutter/material.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'searchRoute.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_location/user_location.dart';
import 'package:http/http.dart' as http;
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
import 'package:geocoding/geocoding.dart';

late double search_lat, search_lng;
String search_place = 'null';
String prev_search = 'null';

late double curr_lat, curr_lng; // 현재 좌표값


class Accident extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _Accident();
}

class _Accident extends State<Accident> with TickerProviderStateMixin {
  MapController mapController = MapController();
  late UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  List<String> _test = [];
  String Addr = 'null';
  int Occr = 0;
  List<String> _Address = [];
  List<int> _Occr = [];

  int i = 0;
  int j = 0;
  int k = 0;

  List<dynamic> areaPoints = [];
  List<LatLng> _areaPoints = <LatLng>[];
  List<List<LatLng>> areaList = [];
  late LatLng latlng;
  dynamic temp;
  List<Polygon> polygon = <Polygon>[];
  //List<TaggedPolyline> _polygon = <TaggedPolyline>[];
  late double _la, _lo;
  List<LatLng> centerPoints = <LatLng>[];

  String path = 'Assets/data/AccidentData.json';
  loadJsonData() async {
    final String response = await rootBundle.loadString(path);
    Map<String, dynamic> acd = jsonDecode(response);
    String jsonData;
    String jsonData_la, jsonData_lo;
    String jsonData_add;
    int jsonData_cnt;
    int num = acd['totalCount'];
    for (i = 0; i < 30; i++) {
      jsonData_la = acd['items']['item'][i]['la_crd'];
      jsonData_lo = acd['items']['item'][i]['lo_crd'];
      _la = double.parse(jsonData_la);
      _lo = double.parse(jsonData_lo);
      centerPoints.add(LatLng(_la, _lo)); // 중심값

      jsonData_add = acd['items']['item'][i]['spot_nm'];
      _Address.add(jsonData_add); // 주소값

      jsonData_cnt = acd['items']['item'][i]['occrrnc_cnt'];
      _Occr.add(jsonData_cnt); // 발생건수

      jsonData = acd['items']['item'][i]['geom_json'];
      temp = jsonDecode(jsonData)['coordinates'][0];
      areaPoints.add(temp);
      for (j = 0; j < temp.length; j++) {
        latlng = LatLng(areaPoints[i][j][1], areaPoints[i][j][0]);
        _areaPoints.add(latlng);
      }
      areaList.add(_areaPoints.toList());
      _areaPoints.clear();
    }
    polygon = [Polygon(points: areaList[0], color: Colors.redAccent.withOpacity(0.7))];
    for(k=1; k<30; k++){
      polygon.add(
        Polygon(points: areaList[k],
            color: Colors.redAccent.withOpacity(0.7)),
      );
    }
  }


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
    loadJsonData();

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
                // onTap: popupAc,
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
              ],
              layers: [
                new PolygonLayerOptions(
                  polygons: polygon,
                  polygonCulling: true,
                ),
                new MarkerLayerOptions(
                  markers: _markers,
                ),
                new MarkerLayerOptions(
                  markers: markers,
                ),
                userLocationOptions,

              ],
              mapController: mapController,

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
                    child: Icon(
                      Icons.location_searching, color: Colors.white,),
                    mini: true,
                  ),
                )
            ),
            Positioned(
              top: 15.0,
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
                    }
                    );
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
                      mapController.move(LatLng(search_lat, search_lng),
                          15.0); // 검색한 좌표로 지도 이동
                    },
                    child: Text('')) //투명 버튼
            ),
          ],

        ),
      ),
    );
  }

  void _showModalBottomSheet(LatLng latlng){
    for (var p=0; p<30; p++){
      if(latlng == centerPoints[p]){
        Addr = _Address[p];
        Occr = _Occr[p];
      }
    }
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            width: double.infinity,
            color: Colors.white,
            height: 200.0,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  color: Colors.red,
                  child: Row(
                    children: [
                      Spacer(),
                      InkWell(
                        child: Icon(Icons.report_problem_rounded, color: Colors.white,),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.center,
                        child: Text(
                          '자전거 사고 다발 지역',
                          style: TextStyle(fontSize: 20.0, color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Spacer(),
                    ],
                  )
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: ListTile(
                          leading: Icon(Icons.location_city_rounded,
                            color: Colors.grey[850],
                          ),
                          title: Text(Addr,
                            style: TextStyle(fontSize: 17.0,
                                fontWeight: FontWeight.w700),),
                          onTap: (){
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Container(
                        child: ListTile(
                          leading: Icon(Icons.info,
                            color: Colors.redAccent,
                          ),
                          title:
                          Text('최근 1년간 사고 발생 ' + Occr.toString() + '건',
                              style: TextStyle(fontSize: 17.0, color: Colors.redAccent,
                                  fontWeight: FontWeight.w700)),
                          onTap: (){
                            Navigator.pop(context);
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }
    );
  }

  List<Marker> get _markers => centerPoints
      .map(
          (markerPosition) => Marker(
          width: 40.0,
          height: 40.0,
          point: markerPosition,
          builder: (ctx) =>
          new Container(
              child: IconButton(
                icon: Icon(Icons.brightness_1_outlined),
                color: Colors.transparent,
                iconSize: 0.0,
                onPressed: () {
                  _showModalBottomSheet(markerPosition);
                },
              )
          )
      )
  ).toList();
}