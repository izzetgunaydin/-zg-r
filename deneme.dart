import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'buttombar.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';




class DetayScreen extends StatefulWidget {
  final String category_id;
  final String category_name;
  const DetayScreen(
      {Key? key, required this.category_id, required this.category_name})
      : super(key: key);

  @override
  _DetayScreenState createState() => _DetayScreenState();
}

class _DetayScreenState extends State<DetayScreen> {
  @override
  Future getWorkplaces(id) async {
    var categoryId = id;
    var url = Uri.parse(
        'http://192.168.23.96:80/anycep/viewWorkplaces.php?id=$categoryId');

    var response = await http.get(url);
    return jsonDecode(response.body);
  }

  Future _setFavorite(favorites) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites);
    print(favorites);
  }

  bool _isFavorited = true;
  void _toggleFavorite() {
    setState(() {
      if (_isFavorited) {
        _isFavorited = false;
      } else {
        _isFavorited = true;
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: background_color,
          title: Text(
            widget.category_name,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        bottomNavigationBar: const Buttombar(),
        body: FutureBuilder(
          future: getWorkplaces(widget.category_id),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data.length,

                    itemBuilder: (context, index) {
                      List list = snapshot.data;
                      return  Card(
                        margin: const EdgeInsets.only(
                            top: 20, left: 20, bottom: 5, right: 20),
                        elevation:20,
                        color: background_color,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: ListTile(
                          onTap: (){

                          },
                          textColor: foreground_color,
                          title: Text(list[index]['workplace_name'],
                            style: const TextStyle(
                            fontSize: 20,
                            color: foreground_color,
                            fontFamily: 'RobotoCondonsed',
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                          trailing: FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  iconSize: 40,
                                  icon: Image.asset(
                                      'assets/icons/icons8-website-100.png'),
                                  onPressed: () {
                                    launch(list[index]['tel']);
                                  },
                                ),
                                IconButton(
                                  iconSize: 30,
                                  icon: Image.asset(
                                      'assets/icons/phone-ringing-14.png'),
                                  onPressed: () {
                                    launch(list[index]['tel']);
                                  },
                                ),
                                IconButton(
                                  iconSize: 30,
                                  color: foreground_color,
                                  icon:   (_isFavorited ? Icon(Icons.favorite_border) : Icon(Icons.favorite)),
                                  onPressed: _toggleFavorite,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ));
  }
}
