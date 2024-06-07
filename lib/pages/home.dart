import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Color> colors = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadColors());
  }

  void _savePalette() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paletteStrings = prefs.getStringList('savedPalettes') ?? [];
      final newPaletteString = json.encode(
        colors.map((color) => colorToHex(color)).toList(),
      );
      paletteStrings.add(newPaletteString);
      await prefs.setStringList('savedPalettes', paletteStrings);

      // Show a toast message to indicate successful saving (optional)
      Fluttertoast.showToast(
        msg: "Palette saved!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      // Handle errors, e.g., show a toast message or log the error
      print("Error saving palette: $e");
    }
  }

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
      final List<String> newColorsHex = List.generate(5, (index) {
        final color = Color.fromRGBO(
          data['result'][index][0],
          data['result'][index][1],
          data['result'][index][2],
          1.0,
        );
        return colorToHex(color);
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('palettes', newColorsHex);
      print(prefs.getStringList('palettes'));
      setState(() {
        colors = newColorsHex.map((hex) {
          return Color(int.parse(hex.substring(1, 7), radix: 16) + 0xFF000000);
        }).toList();
        print("colors");
        print(colors);
      });
      print("cores geradas:");
      print(colors);
    } else {
      throw Exception('Failed to load colors');
    }
  }

  Future<void> _loadColors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final palettes = prefs.getStringList('palettes');
      if (palettes != null && palettes.isNotEmpty) {
        setState(() {
          colors = palettes
              .map((hex) =>
                  Color(int.parse(hex.substring(1, 7), radix: 16) + 0xFF000000))
              .toList();
        });
      } else {
        fetchColors();
      }
    } catch (e) {
      print("Error loading colors: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Palette Generator'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: GridView.builder(
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 20),
        physics: const BouncingScrollPhysics(),
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
              Fluttertoast.showToast(
                msg: "Código HEX copiado: $hexCode",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black.withOpacity(0.7),
                textColor: Colors.white,
                fontSize: 20.0,
              );
            },
            child: GridTile(
              child: Container(
                color: color,
                child: Center(
                  child: Text(
                    hexCode,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
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
                  minimumSize: MaterialStateProperty.all(const Size(250, 40)),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16)),
                ),
                child: const Text('Generate Pallete',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              FilledButton.tonal(
                onPressed: _savePalette,
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
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
