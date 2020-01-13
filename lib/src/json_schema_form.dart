import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_json_schema/src/checkbox_form_field.dart';
import 'package:flutter_json_schema/src/json_schema_parser.dart';
import 'package:flutter_json_schema/src/models.dart';

class JsonSchemaForm extends StatefulWidget {
  final Schema schema;
  final JsonSchemaParser jsonSchemaParser;

  JsonSchemaForm({@required this.schema, @required this.jsonSchemaParser});

  @override
  State<StatefulWidget> createState() {
    return _JsonSchemaFormState(
      schema: schema,
      jsonSchemaParser: jsonSchemaParser,
    );
  }
}

typedef JsonSchemaFormSetter<T> = void Function(T newValue);

class _JsonSchemaFormState extends State<JsonSchemaForm> {
  final _formKey = GlobalKey<FormState>();
  final Schema schema;
  final JsonSchemaParser jsonSchemaParser;

  String formData;

  _JsonSchemaFormState({
    @required this.schema,
    this.jsonSchemaParser,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            schema.title != null ? schema.title : '',
                            style: TextStyle(
                              fontSize: 25.0,
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.black,
                        ),
                        Container(
                          child: Text(
                            schema.description != null
                                ? schema.description
                                : '',
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: schema.properties.map<Widget>((item) {
                        return getWidget(item);
                      }).toList(),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();

                        setState(() {
                          formData = jsonSchemaParser.formData;
                        });
                      }
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
          (formData?.isNotEmpty ?? false) ? Text(formData) : Container(),
        ],
      ),
    );
  }

  Widget getWidget(Properties properties) {
    switch (properties.type) {
      case 'string':
        return getTextField(properties);
      case 'integer':
        return getNumberField(properties);
      case 'boolean':
        return getCheckBox(properties);
      default:
        return Container();
    }
  }

  Widget getNumberField(Properties properties) {
    return Container(
        child: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            autofocus: (properties.autoFocus ?? false),
            onSaved: (value) {
              updateData(properties, value);
            },
            autovalidate: true,
            validator: (String value) {
              if (properties.required && value.isEmpty) {
                return 'Required';
              }
              if (properties.minLength != null &&
                  value.isNotEmpty &&
                  value.length <= properties.minLength) {
                return 'should NOT be shorter than ${properties.minLength} characters';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: (properties.required
                      ? properties.title + ' *'
                      : properties.title) +
                  (properties.description != null
                      ? ' ' + properties.description
                      : ''),
            )));
  }

  TextInputType getTextInputType(String widget, Options options) {
    TextInputType textInputType;
    if (widget != null) {
      switch (widget) {
        case "textarea":
          textInputType = TextInputType.multiline;
          break;
        case "password":
          textInputType = TextInputType.visiblePassword;
          break;
      }
    }

    if (options != null) {
      switch (options.inputType) {
        case "tel":
          textInputType = TextInputType.phone;
          break;
      }
    }
    return textInputType;
  }

  Widget getTextField(Properties properties) {
    return Container(
        child: TextFormField(
      autofocus: (properties.autoFocus ?? false),
      keyboardType: getTextInputType(properties.widget, properties.options),
      maxLines: properties.widget == "textarea" ? null : 1,
      obscureText: properties.widget == "password",
      initialValue: properties.defaultValue ?? '',
      onSaved: (value) {
        updateData(properties, value);
      },
      autovalidate: true,
      onChanged: (String value) {
        if (properties.emptyValue != null && value.isEmpty) {
          return properties.emptyValue;
        }

        return value;
      },
      validator: (String value) {
        if (properties.required && value.isEmpty) {
          return 'Required';
        }
        if (properties.minLength != null &&
            value.isNotEmpty &&
            value.length <= properties.minLength) {
          return 'should NOT be shorter than ${properties.minLength} characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText:
            properties.required ? properties.title + ' *' : properties.title,
        helperText: properties.help,
      ),
    ));
  }

  Widget getCheckBox(Properties properties) {
    return CheckboxFormField(
      autoValidate: true,
      initialValue: properties.defaultValue,
      title: properties.title,
      validator: (bool val) {
        if (properties.required) {
          if (!val) {
            return "Required";
          }
        }
        return null;
      },
      onSaved: (bool val) {},
      onChange: (value) {
        updateData(properties, value);
        return;
      },
    );
  }

  void updateData(Properties properties, dynamic value) {
    if (jsonSchemaParser.data.containsKey(properties.id)) {
      jsonSchemaParser.data[properties.id] = value;
    }
  }
}
