import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'MapStorage.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;


class Popup extends StatefulWidget {
  final Marker marker;

  Popup(this.marker, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PopupState(this.marker);
}

class _PopupState extends State<Popup> {
  String Addr = '';
  String LCDQR = '';
  String AddrF = '';
  List<List<dynamic>> csvdata = [];

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  late String path;
  _loadCSV() async {
    if (rental == true){
      path = 'Assets/data/rentalSeoul.csv';
    }
    else if (rental == false){
      path = 'Assets/data/park_seodaemun.csv';
    }
    final Data = await rootBundle.loadString(path);
    List<List<dynamic>> csvData = CsvToListConverter().convert(Data);
    setState(() {
      csvdata = csvData;
      if (rental == true){
        for (var i=0; i<2170; i++){
          if (_marker.point.latitude == csvdata[i][4] && _marker.point.longitude == csvdata[i][5]){
            Addr = csvdata[i][1];
            if (csvdata[i][9] == 'LCD'){
              LCDQR = "LCD " + csvdata[i][7].toString() + "대";
            }
            else {
              LCDQR = "QR " + csvdata[i][8].toString() + "대";
            }
            AddrF = csvdata[i][3];
          }
        }
      }
      else if (rental == false){
        for(var i=1; i<51; i++){
          if (_marker.point.latitude == csvdata[i][3] && _marker.point.longitude == csvdata[i][4]){
            Addr = csvdata[i][0];
            LCDQR = csvdata[i][5].toString() + "대";
            AddrF = csvdata[i][1];
          }
        }
      }
    });

  }

  final Marker _marker;

  final List<IconData> _icons = [
    Icons.star_border,
    Icons.star_half,
    Icons.star
  ];
  int _currentIcon = 0;

  _PopupState(this._marker);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
//            Padding(
//              padding: EdgeInsets.only(left: 10, right: 10),
//              child: Icon(_icons[_currentIcon]),
//            ),
            _cardDescription(context),
          ],
        ),
        onTap: () =>
            setState(() {
              _currentIcon = (_currentIcon + 1) % _icons.length;
            }),
      ),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: BoxConstraints(minWidth: 100, maxWidth: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              Addr,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Text(
              AddrF,
              style: const TextStyle(fontSize: 14.0),
            ),
            Text(
              LCDQR,
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}