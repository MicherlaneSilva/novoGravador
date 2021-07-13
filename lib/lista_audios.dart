import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:new_recorder/list_item.dart';
import 'dart:developer' as developer;
import 'main.dart';
import 'duraction.dart';

void main(List<String> args) {
  runApp(ListaAudios(gravacoes: args));
}

class ListaAudios extends StatefulWidget {
  final List gravacoes;
  const ListaAudios({Key? key, required this.gravacoes}) : super(key: key);

  @override
  State<ListaAudios> createState() => _ListaAudiosState();
}

class _ListaAudiosState extends State<ListaAudios> {
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  String currentTime = "00:00";
  String completeTime = "00:00";
  List list = [];

  @override
  void initState() {
    super.initState();

    audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        currentTime = duration.toString().split(".")[0];
      });
    });

    convertList();

    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        completeTime = duration.toString().split(".")[0];
      });
    });
  }

  void convertList() {
    for (String item in widget.gravacoes) {
      list.add(ListItem<String>(item));
    }
  }

  void desabilitedPlayer(int index) {
    for (int i = 0; i < list.length; i++) {
      if (i != index) {
        list[i].isSelected = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.teal[700],
          scaffoldBackgroundColor: Colors.teal[400]),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "GRAVAÇÕES",
          ),
          actions: [
            IconButton(
              onPressed: () {
                runApp(const Recorder());
              },
              icon: const Icon(Icons.arrow_back),
              iconSize: 50,
            )
          ],
        ),
        body: Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10.0),
                  color: Colors.white60,
                  width: double.infinity,
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DurationText(text: currentTime),
                      DurationText(text: " | " + completeTime),
                    ],
                  ),
                ),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: list.length - 1,
                    itemBuilder: (ctx, index) {
                      final gr = list[index].data;
                      String nomeAudio = gr
                          .toString()
                          .split("/storage/emulated/0/GravacaoApp/")[1];
                      return Card(
                          color: Colors.white60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                nomeAudio.substring(0, 5) +
                                    " " +
                                    index.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              IconButton(
                                onPressed: () {
                                  audioPlayer.play(gr, isLocal: true);
                                  developer.log(gr);
                                  setState(() {
                                    isPlaying = true;
                                    list[index].isSelected = true;
                                    desabilitedPlayer(index);
                                    completeTime;
                                  });
                                },
                                icon: const Icon(Icons.play_arrow),
                              ),
                              IconButton(
                                icon: Icon(isPlaying && list[index].isSelected
                                    ? Icons.pause
                                    : Icons.play_arrow_outlined),
                                onPressed: () {
                                  if (isPlaying) {
                                    audioPlayer.pause();
                                    setState(() {
                                      isPlaying = false;
                                      currentTime;
                                    });
                                  } else {
                                    audioPlayer.resume();
                                    setState(() {
                                      isPlaying = true;
                                      currentTime;
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  audioPlayer.stop();
                                  setState(() {
                                    currentTime = "0:00:00";
                                  });
                                },
                                icon: const Icon(Icons.stop),
                              ),
                            ],
                          ));
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
