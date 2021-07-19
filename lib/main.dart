import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'dart:developer' as developer;
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const Recorder());

class Recorder extends StatefulWidget {
  const Recorder({Key? key}) : super(key: key);

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      theme: ThemeData(
        primaryColor: Colors.teal[700],
        scaffoldBackgroundColor: Colors.teal[400],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  // ignore: use_key_in_widget_constructors
  const MyHomePage({localFileSystem})
      : localFileSystem = localFileSystem ?? const LocalFileSystem();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> gravacoes = [];
  FlutterAudioRecorder2? recorder;
  Recording? current;
  bool estaGravando = false;
  String caminhoArquivo = '';
  String status = "";
  bool isPlaying = false;
  String currentTime = "";
  String completedTime = "";
  bool terminouGravacao = false;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RECORDER'),
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 400,
              height: 200,
              child: Image.asset("assets/images/img.png"),
            ),
            Container(
              width: 400,
              height: 50,
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Text(status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            Container(
              width: 400,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Container(
                margin: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    !terminouGravacao
                        ? Container(
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: IconButton(
                              onPressed: () {
                                if (estaGravando) {
                                  stop();
                                } else {
                                  start();
                                }
                              },
                              icon: Icon(estaGravando
                                  ? Icons.stop
                                  : Icons.mic_outlined),
                              color: Colors.white,
                              iconSize: 100,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "$currentTime | $completedTime",
                                style: TextStyle(fontSize: 35.0),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      ouvirAudio();
                                    },
                                    iconSize: 35.0,
                                    icon: const Icon(Icons.play_arrow),
                                  ),
                                  IconButton(
                                    icon: Icon(isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow_outlined),
                                    iconSize: 35.0,
                                    onPressed: () {
                                      if (isPlaying) {
                                        audioPlayer.pause();
                                        setState(() {
                                          isPlaying = false;
                                          status = "áudio pausado";
                                        });
                                      } else {
                                        audioPlayer.resume();
                                        setState(() {
                                          isPlaying = true;
                                          status = "Playing áudio";
                                        });
                                      }
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showAlertDialog(context);
                                    },
                                    iconSize: 45.0,
                                    icon: const Icon(Icons.save),
                                  ),
                                ],
                              ),
                            ],
                          )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<io.Directory> criarDiretorio(String nomeDiretorio) async {
    io.Directory diretorioBase;

    if (io.Platform.isIOS) {
      diretorioBase = await getApplicationDocumentsDirectory();
    } else {
      diretorioBase = (await getExternalStorageDirectory())!;
    }

    var caminhoCompleto = diretorioBase.path + nomeDiretorio;

    var diretorioDoApp = io.Directory(caminhoCompleto);
    bool existDiretorio = await diretorioDoApp.exists();

    if (!existDiretorio) {
      diretorioDoApp.create();
    }

    return diretorioDoApp;
  }

  Future<String> getNomeDoArquivo() async {
    var diretorio = await criarDiretorio('/GravacaoApp');
    var caminhoArquivo =
        diretorio.path + '/audio_' + DateTime.now().second.toString();

    return caminhoArquivo;
  }

  init() async {
    try {
      bool temPermissao = await FlutterAudioRecorder2.hasPermissions ?? false;
      caminhoArquivo = await getNomeDoArquivo();

      if (temPermissao) {
        recorder = FlutterAudioRecorder2(caminhoArquivo,
            audioFormat: AudioFormat.WAV, sampleRate: 44800);
        await recorder!.initialized;

        var current1 = await recorder!.current(channel: 1);
        setState(() async {
          current = current1;
        });
      }
    } catch (e) {
      developer.log('As permissões não foram aceitas.');
    }
  }

  start() async {
    try {
      await recorder!.start();
      var recording = await recorder!.current(channel: 1);

      setState(() {
        estaGravando = true;
        current = recording;
        status = "Gravando";
      });
    } catch (e) {
      developer.log('Não consegui iniciar a gravação.');
    }
  }

  stop() async {
    var result = await recorder!.stop();
    setState(() {
      estaGravando = false;
      status = "Gravação concluída";
      current = result;
      terminouGravacao = true;
      currentTime = "0:00:00";
      completedTime = "0:00:00";
    });
    var file = widget.localFileSystem.file(current!.path);
    developer.log(file.path);
  }

  ouvirAudio() async {
    audioPlayer.play(current!.path!, isLocal: true);
    audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        currentTime = duration.toString().split(".")[0];
      });
    });

    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        completedTime = duration.toString().split(".")[0];
      });
    });

    developer.log(current!.path!);
    setState(() {
      isPlaying = true;
      status = "Playing audio";
    });
  }

  stopAudio() {
    audioPlayer.stop();
    setState(() {
      isPlaying = false;
      status = "";
      currentTime = "0:00:00";
    });
  }

  apagarArquivo() {
    var caminho = current!.path!;
    var file = io.File(caminho);
    file.delete();
  }

  showAlertDialog(BuildContext context) {
    Widget apagarButton = ElevatedButton(
        onPressed: () {
          apagarArquivo();
          audioPlayer.stop();

          setState(() {
            isPlaying = false;
            status = "";
            terminouGravacao = false;
          });

          Navigator.of(context).pop();
        },
        child: const Text("Não"));
    Widget salvarButton = ElevatedButton(
        onPressed: () {
          setState(() {
            gravacoes.add(current!.path!);
            isPlaying = false;
            terminouGravacao = false;
            status = "";
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            "Gravação salva!",
            textAlign: TextAlign.center,
          )));
        },
        child: const Text("Sim"));

    AlertDialog alert = AlertDialog(
        title: const Text("Gravação"),
        content: const Text("Gostou da gravação?"),
        backgroundColor: Colors.teal[200],
        elevation: 5.0,
        actions: [
          apagarButton,
          salvarButton,
        ]);
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return alert;
        });
  }
}
