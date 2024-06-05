import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Color> colors = [];
  late List<List<Color>> palettes = [];

  Future<void> fetchColors() async {
    final response = await http.post(
      Uri.parse("http://colormind.io/api/"),
      body: json.encode({"model": "default"}),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        colors = List.generate(5, (index) {
          return Color.fromRGBO(
            data['result'][index][0],
            data['result'][index][1],
            data['result'][index][2],
            1.0,
          );
        });
      });
      savePalettes();
    } else {
      throw Exception('Failed to load colors');
    }
  }

  Future<void> savePalettes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> palettesJson = palettes
        .map((palette) => jsonEncode(palette
            .map((color) => [color.red, color.green, color.blue])
            .toList()))
        .toList();
    await prefs.setStringList('palettes', palettesJson);
  }

  Future<void> loadPalettes() async {
    final prefs = await SharedPreferences.getInstance();
    // log(prefs.getStringList('palettes').toString());
    final palettesJson = prefs.getStringList('palettes');
    if (palettesJson != null) {
      setState(() {
        palettes = palettesJson
            .map((json) => (jsonDecode(json) as List<dynamic>)
                .map((color) =>
                    Color.fromRGBO(color[0], color[1], color[2], 1.0))
                .toList())
            .toList();
      });
    } else {
      palettes = [];
    }
  }

  Future<void> checkSavedPalettes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPalettes = prefs.getStringList('palettes');
    if (savedPalettes != null) {
      log('Palettes found in SharedPreferences:');
      for (var paletteJson in savedPalettes) {
        log(paletteJson);
      }
    } else {
      log('No palettes found in SharedPreferences.');
    }
  }

  @override
  void initState() {
    super.initState();

    loadPalettes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Color Palette Generator'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final hexCode = colorToHex(color);
          return GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: '#$hexCode'));
              // notifica
              Fluttertoast.showToast(
                msg: "Código HEX copiado: #$hexCode",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black.withOpacity(0.7),
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            child: GridTile(
              child: Container(
                color: color,
                child: Center(
                  child: Text(
                    '#$hexCode',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: fetchColors,
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                      const Size(250, 40)), // Tamanho mínimo do botão
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                      horizontal: 16)), // Espaçamento interno do botão
                ),
                child: const Text('Gerar Paleta'),
              ),
              const SizedBox(width: 10),
              FilledButton.tonal(
                onPressed: fetchColors,
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(50, 40)),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String colorToHex(Color color) {
    return '${color.alpha.toRadixString(16).padLeft(2, '0')}'
        '${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }
}
