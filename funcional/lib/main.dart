import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int maxduration = 100;
  int currentpos = 0;
  String currentpostlabel = "00:00";
  String audioasset = "assets/cancion.mp3";
  bool isplaying = false;
  bool audioplayed = false;
  late Uint8List audiobytes;

  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      ByteData bytes =
          await rootBundle.load(audioasset); //load audio from assets
      audiobytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      //convert ByteData to Uint8List

      player.onDurationChanged.listen((Duration d) {
        //get the duration of audio
        maxduration = d.inMilliseconds;
        setState(() {});
      });

      player.onAudioPositionChanged.listen((Duration p) {
        currentpos =
            p.inMilliseconds; //get the current position of playing audio

        //generating the duration label
        int shours = Duration(milliseconds: currentpos).inHours;
        int sminutes = Duration(milliseconds: currentpos).inMinutes;
        int sseconds = Duration(milliseconds: currentpos).inSeconds;

        int rhours = shours;
        int rminutes = sminutes - (shours * 60);
        int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

        currentpostlabel = "$rhours:$rminutes:$rseconds";

        setState(() {
          //refresh the UI
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            title: Text("Bad Gyal de bolsillo"),
            backgroundColor: Color.fromARGB(255, 223, 8, 112)),
        body: Container(
            margin: EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Container(
                  width: 300.0,
                  height: 300.0,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('badgyal.jpg'), fit: BoxFit.fill),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Text(
                    currentpostlabel,
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                Container(
                    child: Slider(
                  thumbColor: Color.fromARGB(255, 20, 241, 174),
                  value: double.parse(currentpos.toString()),
                  min: 0,
                  max: double.parse(maxduration.toString()),
                  divisions: maxduration,
                  label: currentpostlabel,
                  onChanged: (double value) async {
                    int seekval = value.round();
                    int result =
                        await player.seek(Duration(milliseconds: seekval));
                    if (result == 1) {
                      //seek successful
                      currentpos = seekval;
                    } else {
                      print("buscando.");
                    }
                  },
                )),
                Container(
                  child: Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(
                                255, 211, 33, 157), // Background color
                          ),
                          onPressed: () async {
                            if (!isplaying && !audioplayed) {
                              int result = await player.playBytes(audiobytes);
                              if (result == 1) {
                                setState(() {
                                  isplaying = true;
                                  audioplayed = true;
                                });
                              } else {
                                print("Error while playing audio.");
                              }
                            } else if (audioplayed && !isplaying) {
                              int result = await player.resume();
                              if (result == 1) {
                                //resume success
                                setState(() {
                                  isplaying = true;
                                  audioplayed = true;
                                });
                              } else {
                                print("no se ha podido reanudar el audio.");
                              }
                            } else {
                              int result = await player.pause();
                              if (result == 1) {
                                //pause success
                                setState(() {
                                  isplaying = false;
                                });
                              } else {
                                print("Error al pasar el  audio.");
                              }
                            }
                          },
                          icon:
                              Icon(isplaying ? Icons.pause : Icons.play_arrow),
                          label: Text(isplaying ? "Pausar" : "Reproducir")),
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(
                                255, 255, 11, 141), // Background color
                          ),
                          onPressed: () async {
                            int result = await player.stop();
                            if (result == 1) {
                              //stop success
                              setState(() {
                                isplaying = false;
                                audioplayed = false;
                                currentpos = 0;
                              });
                            } else {
                              print("Error on stop audio.");
                            }
                          },
                          icon: Icon(Icons.stop),
                          label: Text("Parar")),
                    ],
                  ),
                )
              ],
            )));
  }
}
