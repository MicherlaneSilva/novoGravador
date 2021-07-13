import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> getDirPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<String> salvar(List<String> gravacoes) async {
  final dirPath = await getDirPath();

  final file = File('$dirPath/lista.txt');

  bool existFile = await file.exists();

  if (!existFile) {
    file.create();
  }
  String dados = getDadosString(gravacoes);
  file.writeAsString(dados, mode: FileMode.append);
  String caminhos = file.readAsStringSync();
  return caminhos;
}

String getDadosString(List<String> gravacoes) {
  String dados = "";

  for (String path in gravacoes) {
    dados += path + ",";
  }

  return dados;
}
