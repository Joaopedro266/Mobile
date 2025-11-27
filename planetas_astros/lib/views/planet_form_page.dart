import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/firestore_service.dart';
import '../model/planet.dart';

class PlanetFormPage extends StatefulWidget {
  final Planet? planet;
  const PlanetFormPage({super.key, this.planet});

  @override
  State<PlanetFormPage> createState() => _PlanetFormPageState();
}

class _PlanetFormPageState extends State<PlanetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tipoController = TextEditingController();
  final _corController = TextEditingController();
  final _diametroController = TextEditingController();
  final _massaController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  late Planet _editedPlanet;
  Color currentColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _editedPlanet = widget.planet != null
        ? Planet.fromMap(widget.planet!.toMap(), widget.planet!.id!)
        : Planet(nome: "", tipo: "", corPredominante: "#FFFFFF");

    _nameController.text = _editedPlanet.nome;
    _tipoController.text = _editedPlanet.tipo;
    _corController.text = _editedPlanet.corPredominante;
    _diametroController.text = _editedPlanet.diametro?.toString() ?? "";
    _massaController.text = _editedPlanet.massa?.toString() ?? "";

    currentColor = _hexToColor(_corController.text);
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey.shade700;
    }
  }

  void _showColorPicker() {
    Color tempColor = currentColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('Cor',
              style: TextStyle(color: Colors.white, fontFamily: 'Pixelate')),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
              colorPickerWidth: 300.0,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
              labelTypes: const [],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR',
                  style: TextStyle(
                      color: Colors.redAccent, fontFamily: 'Pixelate')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK',
                  style: TextStyle(
                      color: Colors.greenAccent, fontFamily: 'Pixelate')),
              onPressed: () {
                setState(() {
                  currentColor = tempColor;
                  _corController.text =
                      '#${tempColor.value.toRadixString(16).substring(2).toUpperCase()}';
                  _editedPlanet.corPredominante = _corController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _savePlanet() async {
    if (_formKey.currentState!.validate()) {
      _editedPlanet.nome = _nameController.text;
      _editedPlanet.tipo = _tipoController.text;
      _editedPlanet.corPredominante = _corController.text;

      _editedPlanet.diametro = double.tryParse(_diametroController.text);
      _editedPlanet.massa = double.tryParse(_massaController.text);

      await _firestoreService.savePlanet(_editedPlanet);

      Navigator.pop(context, _editedPlanet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _editedPlanet.nome.isEmpty
              ? "NOVO ASTRO"
              : _editedPlanet.nome.toUpperCase(),
          style: const TextStyle(
              color: Colors.greenAccent, fontFamily: 'Pixelate'),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.save, color: Colors.black),
        onPressed: _savePlanet,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/imgs/background.jpg",
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.9),
                colorBlendMode: BlendMode.darken),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    border:
                        Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInput(_nameController, "NOME DO ASTRO",
                            required: true),
                        const SizedBox(height: 10),
                        _buildInput(_tipoController, "TIPO", required: true),
                        const SizedBox(height: 10),
                        _buildInput(
                            _diametroController, "RAIO / DIÂMETRO (Opcional)",
                            keyboard: TextInputType.number),
                        const SizedBox(height: 10),
                        _buildInput(_massaController, "MASSA (Opcional)",
                            keyboard: TextInputType.number),
                        const SizedBox(height: 10),
                        _buildColorButton(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton() {
    return GestureDetector(
      onTap: _showColorPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          border: Border.all(color: Colors.greenAccent, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "COR: ${_corController.text}",
              style: const TextStyle(
                fontFamily: 'Pixelate',
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: currentColor,
                border: Border.all(color: Colors.white, width: 1),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label,
      {bool required = false, TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white, fontFamily: 'Pixelate'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.greenAccent, fontFamily: 'Pixelate'),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.greenAccent)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        contentPadding: const EdgeInsets.all(10),
      ),
      validator: required
          ? (text) {
              if (text == null || text.isEmpty) return "Campo obrigatório";
              return null;
            }
          : null,
    );
  }
}
