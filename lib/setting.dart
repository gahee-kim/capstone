import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 50.0,
          width: double.infinity,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '설정',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
    ),
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Column(
    children: <Widget>[
      Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text(
    '공지사항',
    style: TextStyle(
    fontSize: 18.0,
    ),
    ),
    Chip(
    label: Text('0'),
    backgroundColor: Colors.grey[300],
    ),
    ],
    ),
    Divider(color: Colors.black45),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '버전정보',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          Chip(
            label: Text('0'),
            backgroundColor: Colors.grey[300],
          ),
        ],
      ),
      Divider(color: Colors.black45),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '알림',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          Chip(
            label: Text('0'),
            backgroundColor: Colors.grey[300],
          ),
        ],
      ),
      Divider(color: Colors.black45),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '친구',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          Chip(
            label: Text('0'),
            backgroundColor: Colors.grey[300],
          ),
        ],
      ),
      Divider(color: Colors.black45),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '기타설정',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          Chip(
            label: Text('0'),
            backgroundColor: Colors.grey[300],
          ),
        ],
      ),
      Divider(color: Colors.black45),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '도움말',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          Chip(
            label: Text('0'),
            backgroundColor: Colors.grey[300],
          ),
        ],
      ),
    ],
    ),
    ),
        Divider(color: Colors.black45),
      ],
    );
  }
}