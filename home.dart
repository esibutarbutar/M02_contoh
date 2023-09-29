import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBio extends StatefulWidget {
  const MyBio({Key? key}) : super(key: key);

  @override
  State<MyBio> createState() => _MyBioState();
}

class _MyBioState extends State<MyBio> {
  String? _image;
  double _score = 0;
  DateTime _selectedDate = DateTime.now(); // Variabel untuk menyimpan tanggal terpilih
  final ImagePicker _picker = ImagePicker();
  final String _keyScore = 'score';
  final String _keyImage = 'image';
  final String _keyDate = 'date';
  late SharedPreferences prefs;

  void loadData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = (prefs.getDouble(_keyScore) ?? 0);
      _image = prefs.getString(_keyImage);
      String dateString = prefs.getString(_keyDate) ?? '';
      if (dateString.isNotEmpty) {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(dateString);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> _setScore(double value) async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble(_keyScore, value);
      _score = (prefs.getDouble(_keyScore) ?? 0);
    });
  }

  Future<void> _setImage(String? value) async {
    prefs = await SharedPreferences.getInstance();
    if (value != null) {
      setState(() {
        prefs.setString(_keyImage, value);
        _image = prefs.getString(_keyImage);
      });
    }
  }

  Future<void> _setDate(DateTime date) async {
    prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    setState(() {
      prefs.setString(_keyDate, formattedDate);
      _selectedDate = date; // Perbarui tanggal terpilih
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      _setDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(color: Colors.red[200]),
                child: _image != null
                    ? Image.file(
                        File(_image!),
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.fitHeight,
                      )
                    : Container(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 198, 198, 198)),
                        width: 200,
                        height: 200,
                        child: Icon(Icons.camera_alt, color: Colors.grey[800]),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    _setImage(image?.path);
                    setState(() {
                      if (image != null) {
                        _image = image.path;
                      }
                    });
                  },
                  child: Text("Take Image"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SpinBox(
                  max: 10.0,
                  min: 0.0,
                  value: _score,
                  decimals: 1,
                  step: 0.1,
                  decoration: InputDecoration(labelText: "Decimals"),
                  onChanged: _setScore,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      child: Text('Pilih Tanggal'),
                    ),
                    Text(
                      'Tanggal: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
