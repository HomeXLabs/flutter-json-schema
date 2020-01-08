import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_json_schema/src/models.dart';
import 'package:rxdart/subjects.dart';

class JsonSchemaBloc {
  Map<String, BehaviorSubject<dynamic>> _formData =
      Map<String, BehaviorSubject<dynamic>>();
  Map<String, Stream<dynamic>> formData = Map<String, Stream<dynamic>>();

  StreamController<Map<String, dynamic>> jsonDataAdd =
      StreamController<Map<String, dynamic>>();

  BehaviorSubject<Schema> _jsonSchema =
      BehaviorSubject<Schema>(seedValue: null);
  Stream<Schema> get jsonSchema => _jsonSchema;

  Map<String, dynamic> _data = Map<String, dynamic>();
  PublishSubject<String> _submitData = PublishSubject<String>();
  Stream<String> get submitData => _submitData;

  JsonSchemaBloc() {
    _jsonSchema.stream.listen((schema) {
      initDataBinding(schema.properties);
    });

    jsonDataAdd.stream.listen((data) {
      data.forEach((key, value) {
        if (_formData.containsKey(key)) {
          _formData[key].add(value);
          _data[key] = value;
        }

        if (key == 'submit') {
          _submitData.add(getFormData());
        }
      });
    });
  }

  void readFromJsonString(String jsonSchema, String uiSchema) async {
    Map<String, dynamic> jsonSchemaMap = json.decode(jsonSchema);
    Map<String, dynamic> uiSchemaMap = json.decode(uiSchema);
    _jsonSchema.add(Schema.fromJson(jsonSchemaMap)..setUiSchema(uiSchemaMap));
  }

  void initDataBinding(List<Properties> properties) {
    properties.forEach((prop) {
      _formData[prop.id] = BehaviorSubject<dynamic>();
      formData[prop.id] = _formData[prop.id].stream;
      _formData[prop.id].add(prop.defaultValue);
    });
  }

  String getFormData() {
    return json.encode(_data);
  }

  void dispose() {
    _formData.forEach((key, value) {
      value.close();
    });

    _jsonSchema.close();
    jsonDataAdd.close();
  }
}
