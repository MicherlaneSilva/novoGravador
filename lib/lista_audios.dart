import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as developer;
import 'main.dart';

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

  @override
  void initState() {
    super.initState();

    audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        currentTime = duration.toString().split(".")[0];
      });
    });

    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        completeTime = duration.toString().split(".")[0];
      });
    });
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
          height: 300,
          child: ListView.builder(
              itemCount: widget.gravacoes.length,
              itemBuilder: (ctx, index) {
                final gr = widget.gravacoes[index];
                String nomeAudio =
                    gr.toString().split("/storage/emulated/0/GravacaoApp/")[1];
                developer.log(widget.gravacoes.toString());
                return Card(
                    color: Colors.white60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          nomeAudio.substring(0, 5) +
                              " " +
                              index.toString() +
                              " " +
                              completeTime,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        IconButton(
                          onPressed: () {
                            audioPlayer.play(gr, isLocal: true);
                            developer.log(nomeAudio);
                            setState(() {
                              isPlaying = true;
                            });
                          },
                          icon: const Icon(Icons.play_arrow),
                        ),
                        IconButton(
                          icon: Icon(isPlaying
                              ? Icons.pause
                              : Icons.play_arrow_outlined),
                          onPressed: () {
                            if (isPlaying) {
                              audioPlayer.pause();
                              setState(() {
                                isPlaying = false;
                              });
                            } else {
                              audioPlayer.resume();
                              setState(() {
                                isPlaying = true;
                              });
                            }
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            audioPlayer.stop();
                          },
                          icon: const Icon(Icons.stop),
                        ),
                      ],
                    ));
              }),
        ),
      ),
    );
  }
}
