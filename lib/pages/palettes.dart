import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ColorPalette {
  final List<Color> colors;

  const ColorPalette(this.colors);
}

class PalettesPage extends StatefulWidget {
  const PalettesPage({super.key}); // No need for the palette parameter anymore

  @override
  State<PalettesPage> createState() => _PalettesPageState();
}

class _PalettesPageState extends State<PalettesPage> {
  List<ColorPalette> savedPalettes = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPalettes();
  }

  Future<void> _loadSavedPalettes() async {
    final prefs = await SharedPreferences.getInstance();
    final paletteStrings = prefs.getStringList('savedPalettes') ?? [];
    setState(() {
      savedPalettes = paletteStrings.map((paletteString) {
        final colorList = json.decode(paletteString) as List<dynamic>;
        return ColorPalette(
          colorList
              .map((color) => Color(
                  int.parse(color.substring(1, 7), radix: 16) + 0xFF000000))
              .toList(),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paletas Salvas'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: savedPalettes.isEmpty
          ? const Center(
              child: Text(
                'Você não salvou nenhuma paleta... ainda!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                  top: 10, left: 10, right: 10, bottom: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: savedPalettes.length,
              itemBuilder: (context, index) {
                final palette = savedPalettes[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      for (final color in palette.colors)
                        Expanded(
                          child: Container(
                            height: 50,
                            color: color,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      // floating button to erase all saved palettes
      floatingActionButton: savedPalettes.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('savedPalettes');
                setState(() {
                  savedPalettes = [];
                });
              },
              child: const Icon(Icons.delete_forever),
            )
          : null,
    );
  }
}
