import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import 'fields/radioButtonField.dart';

class DynamicForm extends StatefulWidget {
  final DocumentSnapshot formDefinition;

  DynamicForm({required this.formDefinition});

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  String? uploadedFileName;
  Map<String, dynamic> fieldValues = {};
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> formData = widget.formDefinition.data() as Map<String, dynamic>;
    List<Map<String, dynamic>> formFields = List<Map<String, dynamic>>.from(formData['fields']);

    return Scaffold(
      appBar: AppBar(
        title: Text(formData['titleForm'] ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: formFields.length + 1,
          itemBuilder: (context, index) {
            if (index == formFields.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await requestPermissions();
                    await generateAndSavePdf(formData, formFields);
                  },
                  child: Text('Download PDF'),
                ),
              );
            }
            Map<String, dynamic> fieldData = formFields[index];
            String fieldType = fieldData['name'];
            switch (fieldType) {
              case 'Text Field':
                return buildTextField(fieldData['title'] ?? '');
              case 'Date Field':
                return buildDateField(fieldData['title'] ?? '');
              case 'Number Field':
                return buildNumberField(fieldData['title'] ?? '');
              case 'Dropdown Field':
                return buildDropdownField(fieldData['title'] ?? '', fieldData['options']);
              case 'Radio Buttons Field':
                return RadioButtonsField(title: fieldData['title'] ?? '', options: fieldData['options']);
              case 'Upload File':
                return buildUploadFileField(fieldData['title'] ?? '');
              default:
                return SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }


  Widget buildTextField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(labelText: title),
        onChanged: (value) {
          setState(() {
            fieldValues[title] = value;
            print('Text Field ($title): $value');
          });
        },
      ),
    );
  }


  Widget buildNumberField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(labelText: title),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            fieldValues[title] = value;
            print('Text Field ($title): $value');
          });
        },
      ),
    );
  }
  Widget buildDateField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Builder(
        builder: (BuildContext context) {
          return InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  fieldValues[title] = picked.toString().substring(0, 10);
                  print('Date Field ($title): ${picked.toString().substring(0, 10)}');
                });
              }
            },
            child: ListTile(
              title: Text(title),
              trailing: Icon(Icons.calendar_today),
            ),
          );
        },
      ),
    );
  }


  Widget buildDropdownField(String title, List<dynamic> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: title),
        items: options.map<DropdownMenuItem<String>>((option) {
          return DropdownMenuItem<String>(
            value: option.toString(),
            child: Text(option.toString()),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              fieldValues[title] = value;
              print('Dropdown Field ($title): $value');
            });
          }
        },
      ),
    );
  }


  Widget buildUploadFileField(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                PlatformFile file = result.files.first;
                setState(() {
                  uploadedFileName = file.name;
                  fieldValues[title] = file.name;
                  print('File Upload Field ($title): ${file.name}');
                });
              } else {
                print('File picking canceled');
              }
            },
            child: Text(uploadedFileName ?? 'Upload File'),
          ),
        ],
      ),
    );
  }

  Future<void> generateAndSavePdf(Map<String, dynamic> formData, List<Map<String, dynamic>> formFields) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(formData['titleForm'] ?? '', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              ...formFields.map((field) {
                String key = field['title'] ?? 'Untitled';
                var fieldValue = fieldValues[key] ?? 'Not specified';
                print('PDF Field: $key, Value: $fieldValue');
                return pw.Text("$key: $fieldValue");
              }).toList(),
            ],
          );
        },
      ),
    );

    try {
      final directory = (await getExternalStorageDirectory())?.path ?? (await getApplicationDocumentsDirectory()).path;
      final file = File('$directory/${formData['titleForm'] ?? "form"}.pdf');
      await file.writeAsBytes(await pdf.save());
      OpenFile.open(file.path);
    } catch (e) {
      print("Error saving PDF: $e");
    }
  }


  Future<void> requestPermissions() async {
    await Permission.storage.request();
  }
}


