import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sociopost/_model/unsplash.dart';
import 'package:sociopost/_utils/unsplashAPI.dart';

import '_editor.dart';

class CloudAssets extends StatefulWidget {
  @override
  _CloudAssetsState createState() => _CloudAssetsState();
}

class _CloudAssetsState extends State<CloudAssets> {
  var rng = new Random();
  var qkwrd = [
    "sunset",
    "sunrise",
    "road dark",
    "dark bridge",
    "evening cloud",
    "evening road",
    "rainy night",
    "sea sunset"
  ];
  String searchQuery;
  List<Unsplash> _searchAssets = new List<Unsplash>();
  bool working = false;


  @override
  void initState() {
    searchQuery = qkwrd[rng.nextInt(qkwrd.length)];
    _getSearchResults();
  }

  _getSearchResults() async {
    if(_searchAssets.isNotEmpty){
      _searchAssets.clear();
    }
    setState(() {
      working = true;
    });
    var _fetch = await http
        .get(UnsplashAPI().SearchPhotos(Uri.encodeQueryComponent(searchQuery)));
    if (_fetch.statusCode == 200) {
      var deData = json.decode(_fetch.body);
      setState(() {
        for (Map i in deData['results']) {
          _searchAssets.add(Unsplash.fromJson(i));
        }
      });
    }
    setState(() {
      working = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Cloud Assets"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0,right:10.0),
            child: DropdownButton<String>(
              underline: Center(),
              value: searchQuery,
              icon: Icon(Icons.search,color: Colors.white),
              dropdownColor: Theme.of(context).primaryColor,
              items: qkwrd.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value,style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (q) {
                setState(() {
                  searchQuery = q;
                });
                _getSearchResults();
              },
            ),
          )
        ],
      ),
      body: (_searchAssets.length >= 1)
          ? Padding(
        padding: const EdgeInsets.all(5.0),
        child: GridView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemCount: _searchAssets.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () => _showModal(_searchAssets[index].smallUrl),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: CachedNetworkImage(
                  imageUrl: _searchAssets[index].thumb,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            );
          },
        ),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }


  // -- Helper Function
  Future<File> _fileFromImageUrl(url) async {
    imageCache.clear();
    final response = await http.get(url);
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = new File(documentDirectory.path+'/imagetest.png');
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  // todo --Push to editor
  _pushToEditor(url) async {
    File _xyx = await _fileFromImageUrl(url);
    setState(() {
      working = false;
    });
    // -- Push Editor
    if (_xyx != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Editor(
                file_image: _xyx,
              )
          )
      );
    }
  }

  // -- TODO --- Show Modal
  _showModal(peer_url){
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder){
          return StatefulBuilder(
            builder: (BuildContext context,setState){
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.6),
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: peer_url,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlatButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("Go Back",style: TextStyle(color: Colors.white)),
                        ),
                        (!working) ? FlatButton(
                          onPressed: (){
                            setState(() {
                              working = true;
                            });
                            _pushToEditor(peer_url);
                          },
                          child: Text("Make Post",style: TextStyle(color: Colors.white)),
                          color: Colors.white.withOpacity(0.3),
                        ) : CircularProgressIndicator(),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        }
    );
  }
}
