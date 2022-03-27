import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_210521/search/Road/roadData.dart';
import 'package:user_location/user_location.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../bicycleRoad.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'package:polyline/polyline.dart' as directions;
// import 'roadData.dart';


const String token = 'pk.eyJ1Ijoia2ltbW0iLCJhIjoiY2twaWJ1MWg4MDBsdjJvcXI1OHpycmM1ZiJ9.gHQqiF35MLH1fe2zQTYLQw';
late double curr_lat, curr_lng; // 현재 좌표값

class Road2 extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Road2();
}

class _Road2 extends State<Road2> {

  MapController mapController = MapController();
  late UserLocationOptions userLocationOptions;
  List<Marker> markers = [];

  List<LatLng> path = [];
  List<List<LatLng>> _path = [];
  late TaggedPolyline tagpolyline;
  List<TaggedPolyline> tagpolylines = [];
  List<List<List<double>>> points = [
    [
      [37.57194333901629, 127.04112402679019],
      [37.5561451814551, 127.05126534255436]
    ],
    [
      [37.58763104838888, 126.93563995786636],
      [37.56781543114469, 126.91648342338715]
    ],
    [
      [37.59881040240862, 126.79958536259103],
      [37.52483027168649, 127.10243133586648],
      [37.56213369187951, 127.12819667163534],
      [37.56800785620553, 127.1526071686583],
      [37.5829667245429, 127.19582768274562],
      [37.553787420381944, 127.22148904660556],
      [37.542377513054426, 127.23831767806406]
    ],
    [
      [37.428785293781544, 126.99356409669875],
      [37.45917094095935, 127.02632487461509],
      [37.45926168828694, 127.02673282355559],
      [37.49784785181783, 127.07399382746092],
      [37.49927757952147, 127.0735606846643],
      [37.50025010956584, 127.07386546758325]
    ],
    [
      [37.45917094095935, 127.02632487461509],
      [37.48099854686479, 127.04497422755686],
      [37.48552355207492, 127.05251904604305],
      [37.48772811061392, 127.05626881921413],
      [37.49021552995956, 127.06516232434518],
      [37.49110247496957, 127.06823464288287],
      [37.49343502270588, 127.07126898976476],
      [37.49727631909022, 127.0735024013892],
      [37.50038875619295, 127.0722589279402]
    ],
    [
      [37.59530243179597, 127.04073737176292],
      [37.57247192880805, 127.03600704308097]
    ],
    [
      [37.59563813086858, 126.83343842042534],
      [37.55907446356908, 126.89205065739125],
      [37.558624429362574, 126.89261389849888],
      [37.55645683548135, 126.89332970262494],
      [37.542226253749945, 127.02786182262669],
      [37.54146445924285, 127.02812685975124],
      [37.54115798799267, 127.03092079277268],
      [37.56705705589257, 127.12110005275909],
      [37.571340077530124, 127.12675357412513],
      [37.57067223470215, 127.12743758414533],
      [37.546730455869515, 127.2413026235226],
    ]
  ];
  List<String> Addr = [
    "청계천자전거길", "홍제천서자전거길", "한강자전거길", "양재천자전거길", "양재천자전거길",
        "정릉천자전거길", "한강자전거길"
  ];
  List<String> ListAddrN = [
    "마장동먹자골목 ~ 살곶이체육공원", "서대문구", "전호대교 ~ 팔당대교", "대치교 ~ 과천중앙공원", "대치교 ~ 과천중앙공원"
    , "월곱역입구교차로 ~ 정릉천교", "전호대교 ~ 팔당대교"
  ];
  List<int> Ldistance = [
    2, 3, 103, 19, 19, 3, 103
  ];
  List<int> Ltime = [
    8, 9, 412, 76, 76, 12, 412
  ];
  String AddrN = '';
  String distance ='';
  String time ='';

  @override
  void initState() {
    super.initState();
    loadPolylines();
  }

  MapboxApi mapbox = MapboxApi(
    accessToken: token,
  );

  loadPolylines() async {
    for (int pos=0; pos<=6; pos++){
      DirectionsApiResponse response = await mapbox.directions.request(
        profile: NavigationProfile.CYCLING,
        steps: true,
        language: 'ko',
        coordinates: points[pos],
      );

      //if (response.routes!.isNotEmpty) {
        final route = response.routes![0];
        final polyline = directions.Polyline.Decode(
          encodedString: route.geometry as String,
          precision: 5,
        );
        final coordinates = polyline.decodedCoords;
        for (var i = 0; i < coordinates.length; i++) {
          path.add(
            LatLng(
              coordinates[i][0],
              coordinates[i][1],
            ),
          );
        }
        _path.add(path.toList());
      print(_path[pos]);
      path.clear();
    }
    tagpolylines = [TaggedPolyline(
        points: _path[0],
        tag: Addr[0],
        borderStrokeWidth: 8.0,
        color: Colors.redAccent,
        borderColor: Colors.redAccent
    )];

    for(int k=1; k<=6; k++){
      tagpolylines.add(TaggedPolyline(
          points: _path[k],
          tag: Addr[k],
          borderStrokeWidth: 8.0,
          color: Colors.redAccent,
          borderColor: Colors.redAccent
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            Container(
              height: 50.0,
            ),
            Divider(
              height: 0,
            ),
            Expanded(
                flex: 1,
                child: Stack(
                  children: <Widget>[
                    new FlutterMap(
                      options: new MapOptions(
                        center: new LatLng(37.517235, 127.047325),
                        minZoom: 0,
                        maxZoom: 20,
                        zoom: 10,
                        plugins: [UserLocationPlugin(),
                          TappablePolylineMapPlugin(),],
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
                        // new PolylineLayerOptions(
                        //     polylineCulling: false,
                        //     polylines: [
                        //       new Polyline(
                        //         points: path,
                        //         strokeWidth: 5.0,
                        //         color: Colors.blueAccent,
                        //       )
                        //     ]
                        // ),
                        new TappablePolylineLayerOptions(
                            polylineCulling: false,
                            polylines: tagpolylines,
                            onTap: (polylines, tapPosition) => {
                              _showModalBottomSheet(polylines.map((e) => e.tag).toString())
                            }
                        )
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
                            child: Icon(Icons.location_searching, color: Colors.white,),
                            mini: true,
                          ),
                        )
                    ),
                  ],

                ),)
          ],
        )
      );
  }

  void _showModalBottomSheet(String tag){
    String _tag = tag.substring(1, tag.lastIndexOf(')'));
    for (int j=0; j<=6; j++){
        if (_tag == Addr[j]){
          AddrN = ListAddrN[j];
          distance = Ldistance[j].toString();
          if (Ltime[j] >= 60){
            int temp=0;
            temp = (Ltime[j] / 60).toInt();
            time = temp.toString() + '시간 ' + (Ltime[j] - temp*60).toString();
          }
          else {
            time = Ltime[j].toString();
          }
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
                    color: Colors.black87,
                    child: Row(
                      children: [
                        Spacer(),
                        InkWell(
                          child: Icon(Icons.pedal_bike_outlined, color: Colors.white,),
                        ),
                        Container(
                          padding: EdgeInsets.all(10.0),
                          alignment: Alignment.center,
                          child: Text(
                            _tag,
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
                          leading: Icon(Icons.add_road_outlined,
                            color: Colors.grey[850],
                          ),
                          title: Text(AddrN,
                            style: TextStyle(fontSize: 17.0,
                                fontWeight: FontWeight.w600),),
                          onTap: (){
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Container(
                        child: ListTile(
                          leading: Icon(Icons.info,
                            color: Colors.black87,
                          ),
                          title:
                          Text('총 거리 ' + distance + 'km | 소요시간 약 ' + time + '분',
                              style: TextStyle(fontSize: 17.0, color: Colors.black87,
                                  fontWeight: FontWeight.w400)),
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


}