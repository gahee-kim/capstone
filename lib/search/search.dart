import 'package:flutter/material.dart';
// import 'package:flutter_mapbox_navigation/library.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:user_location/user_location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'place.dart';
import '/map.dart';
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
import 'package:polyline/polyline.dart' as directions;


// 맵박스 토큰
const String token = 'pk.eyJ1Ijoia2ltbW0iLCJhIjoiY2twaWJ1MWg4MDBsdjJvcXI1OHpycmM1ZiJ9.gHQqiF35MLH1fe2zQTYLQw';

final _startPointController = TextEditingController();
late String curr_addr; // 현재 주소, 이름
late String select_destination, select_origin; // 선택 목적지 선택 출발지 주소
late String destination_name, origin_name;// 목적지 출발지 이름
String search_place = 'null';
String prev_search = 'null';
late double search_lat, search_lng; // 검색 좌표값
List <LatLng> path = []; // 폴리라인
late String displayname=''; // 예상소요시간
late double destination_lat, destination_lng; // 목적지 좌표값
late String distance_, duration_;
late double origin_lat, origin_lng;

String hint_text = 'null';


class Search extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Search();
}

class _Search extends State<Search> {
  //지도
  MapController mapController = MapController();

  late UserLocationOptions userLocationOptions;
  List<Marker> markers = [];

  //마커추가
  void addPin(LatLng latlng) {
    setState(() {
      // 길게 누른 부분 목적지로 설정
      if (origin_search == false){
        destination_lat = latlng.latitude;
        destination_lng = latlng.longitude;
      }
      else if (origin_search == true){
        origin_lat = latlng.latitude;
        origin_lng = latlng.longitude;
      }

      markers.add(Marker(
        width: 50.0,
        height: 100.0,
        point: latlng,
        builder: (ctx) => Container(
          padding: EdgeInsets.only(bottom: 40),
          child: Icon(Icons.location_on, size: 50, color: Colors.redAccent),
        ),
      ));
    });
  }

  // 마커 클리어
  void subPin(LatLng latlng){
    setState(() {
      markers.clear();
    });
  }

  // 길찾기
  MapboxApi mapbox = MapboxApi(
    accessToken: token,
  );

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

    return Scaffold(
        body: Container(
            child: Stack(
              children: <Widget>[
                new FlutterMap( // 지도
                  options: new MapOptions(
                    center: new LatLng(curr_lat, curr_lng),
                    minZoom: 0.0,
                    maxZoom: 18.0,
                    onTap: subPin,
                    onLongPress: addPin, // 길게 클릭 시 마커 추가
                    plugins: [
                      UserLocationPlugin(),
                    ],
                    enableMultiFingerGestureRace: true,
                    controller: mapController,
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
                            addPin(LatLng(search_lat, search_lng)); // 검색한 좌표에 마커 추가
                            mapController.move(LatLng(search_lat, search_lng), 15.0); // 검색한 좌표로 지도 이동
                            // 목적지 좌표값에 검색한 좌표값 넣기
                            if (origin_search == false){
                              destination_lat = search_lat;
                              destination_lng = search_lng;
                            }
                            else if (origin_search == true){
                              origin_lat = search_lat;
                              origin_lng = search_lng;
                            }
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
                      margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 20.0),
                        child: FloatingActionButton.extended( // 선택하기 버튼
                          onPressed:  () async {

                            List<Placemark> placemarkers = [];

                            // 목적지 좌표로 목적지 이름, 주소 얻기
                            placemarkers = await placemarkFromCoordinates(destination_lat, destination_lng);
                            if (placemarkers[0].subThoroughfare == ''){
                              select_destination = placemarkers[0].name.toString();
                            }
                            else if (placemarkers[0].subThoroughfare == placemarkers[0].name){
                              select_destination = placemarkers[0].street.toString().substring(5, placemarkers[0].street.toString().length);
                            }

                            if (first_search == true){ // 처음 길 찾기
                              placemarkers = await placemarkFromCoordinates(curr_lat, curr_lng);
                              origin_lat = curr_lat; // 출발지 좌표에 현재 좌표 넣기
                              origin_lng = curr_lng;
                              if (placemarkers[0].subThoroughfare == ''){
                                select_origin = placemarkers[0].name.toString();
                              }
                              else if (placemarkers[0].subThoroughfare == placemarkers[0].name){
                                select_origin = placemarkers[0].street.toString().substring(5, placemarkers[0].street.toString().length);
                              }
                            }
                            else if (first_search == false){ // 장소 수정하는 경우
                              if (origin_search == true) { // 출발지 검색
                                // 출발지 좌표값으로 이름 주소, 얻기
                                placemarkers = await placemarkFromCoordinates(origin_lat, origin_lng);
                                if (placemarkers[0].subThoroughfare == ''){
                                  select_origin = placemarkers[0].name.toString();
                                }
                                else if (placemarkers[0].subThoroughfare == placemarkers[0].name){
                                  select_origin = placemarkers[0].street.toString().substring(5, placemarkers[0].street.toString().length);
                                }
                              }
                              else if(origin_search == false) {
                                if (origin_lat == curr_lat && origin_lng == curr_lng){
                                  // 현재 위치 좌표값으로 이름, 주소 얻기
                                  placemarkers = await placemarkFromCoordinates(curr_lat, curr_lng);
                                  origin_lat = curr_lat;
                                  origin_lng = curr_lng;
                                  if (placemarkers[0].subThoroughfare == ''){
                                    select_origin = placemarkers[0].name.toString();
                                  }
                                  else if (placemarkers[0].subThoroughfare == placemarkers[0].name){
                                    select_origin = placemarkers[0].street.toString().substring(5, placemarkers[0].street.toString().length);
                                  }
                                }
                                else if(origin_lat != curr_lat || origin_lng != curr_lng){
                                  placemarkers = await placemarkFromCoordinates(origin_lat, origin_lng);
                                  if (placemarkers[0].subThoroughfare == ''){
                                    select_origin = placemarkers[0].name.toString();
                                  }
                                  else if (placemarkers[0].subThoroughfare == placemarkers[0].name){
                                    select_origin = placemarkers[0].street.toString().substring(5, placemarkers[0].street.toString().length);
                                  }
                                }
                              }
                            }

                            // 정상 출력 테스트
                            print("here");
                            print(origin_search);
                            print(select_origin);

                            // 길찾기
                            DirectionsApiResponse response = await mapbox.directions.request(
                              profile: NavigationProfile.CYCLING,
                              steps: true,
                              language: 'ko',
                              coordinates: <List<double>>[
                                <double>[origin_lat, origin_lng],
                                <double>[destination_lat, destination_lng],
                              ],
                            );


                            if (response.error != null) {
                              if (response.error is NavigationNoRouteError) {}
                              else if (response.error is NavigationNoSegmentError) {}
                              return;
                            }

                            if (response.routes!.isNotEmpty) {
                              final route = response.routes![0];
                              final polyline = directions.Polyline.Decode(
                                encodedString: route.geometry as String,
                                precision: 5,
                              );
                              final coordinates = polyline.decodedCoords;

                              setState(() {
                                path.clear();
                                for (var i = 0; i < coordinates.length; i++) {
                                  path.add(
                                    LatLng(
                                      coordinates[i][0],
                                      coordinates[i][1],
                                    ),
                                  );
                                }
                              });

                              //예상 소요 시간 + 출력용 다듬기
                              final eta = Duration(
                                seconds: route.duration!.toInt(),
                              );
                              duration_ = eta.toString();
                              int temp = duration_.indexOf('.000000');
                              duration_ = duration_.substring(0, temp);

                              final List<String> values = duration_.split(':');
                              int duration_hour = int.parse(values[0]);
                              int duration_min = int.parse(values[1]);
                              int duration_sec = int.parse(values[2]);

                              if (duration_hour == 0) {
                                if (duration_sec > 30){
                                  duration_min = duration_min + 1;
                                  duration_ = duration_min.toString() + '분 ';
                                }
                                else {
                                  duration_ = duration_min.toString() + '분 ';
                                }
                              }
                              else if (duration_hour != 0){
                                if (duration_sec > 30){
                                  duration_min = duration_min + 1;
                                  duration_ = duration_hour.toString() + '시간 ' + duration_min.toString() + '분 ';
                                }
                                else {
                                  duration_ = duration_hour.toString() + '시간 ' + duration_min.toString() + '분 ';
                                }
                              }

                              //예상 거리 계산 - 폴리라인
                              final distance_polyline = directions.Polyline.Distance(
                                  encodedString: route.geometry as String,
                                  unit: 'miles');

                              // 킬로미터 계산 + 출력용 다듬기
                              double distance = distance_polyline.distance.toDouble();
                              double result = distance / 100 * 1.609344;
                              if (result < 1.0){
                                distance_ = (result * 1000).toString().substring(0, 3) + "m";
                              }
                              else if (result >=1.0 && result < 10){
                                distance_ = result.toString().substring(0, 4) + 'km';
                              }
                              else if (result >=10){
                                distance_ = result.toString().substring(0, 5) + 'km';
                              }


                              //출력 테스트
                              print('here');
                              print(eta.toString());
                              print(distance);
                              print("km");
                            }

                            origin_search = false;
                            first_search = false;

                            Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => Place(),
                                )
                            );

                          },
                          icon: Icon(Icons.add_circle),
                          label: Text('장소 선택'),
                          backgroundColor:Color.fromRGBO(45, 78, 115, 1),
                        ),
                      ),
                      ),
              ],
            )
        )
    );
  }
}