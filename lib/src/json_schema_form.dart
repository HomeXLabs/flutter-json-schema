import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_json_schema/src/checkbox_form_field.dart';
import 'package:flutter_json_schema/src/json_schema_bloc.dart';
import 'package:flutter_json_schema/src/models.dart';

class JsonSchemaForm extends StatefulWidget {
  final Schema schema;
  final JsonSchemaBloc jsonSchemaBloc;

  JsonSchemaForm({@required this.schema, this.jsonSchemaBloc});

  @override
  State<StatefulWidget> createState() {
    return _JsonSchemaFormState(schema: schema, jsonSchemaBloc: jsonSchemaBloc);
  }
}

typedef JsonSchemaFormSetter<T> = void Function(T newValue);

class _JsonSchemaFormState extends State<JsonSchemaForm> {
  final Schema schema;
  final _formKey = GlobalKey<FormState>();
  final JsonSchemaBloc jsonSchemaBloc;

  _JsonSchemaFormState({@required this.schema, this.jsonSchemaBloc});

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
                        Map<String, dynamic> data = Map<String, dynamic>();
                        data['submit'] = true;
                        jsonSchemaBloc.jsonDataAdd.add(data);
                      }
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder(
              stream: jsonSchemaBloc.submitData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data);
                } else {
                  return Container();
                }
              }),
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

  Widget getNumberField(Properties property) {
    return StreamBuilder(
        stream: jsonSchemaBloc.formData[property.id],
        builder: (context, snapshot) {
          return Container(
              child: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            autofocus: (property.autoFocus ?? false),
            onSaved: (value) {
              Map<String, dynamic> data = Map<String, dynamic>();
              data[property.id] = value;
              jsonSchemaBloc.jsonDataAdd.add(data);
            },
            autovalidate: true,
            validator: (String value) {
              if (property.required && value.isEmpty) {
                return 'Required';
              }
              if (property.minLength != null &&
                  value.isNotEmpty &&
                  value.length <= property.minLength) {
                return 'should NOT be shorter than ${property.minLength} characters';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText:
                  (property.required ? property.title + ' *' : property.title) +
                      (property.description != null
                          ? ' ' + property.description
                          : ''),
            ),
          ));
        });
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

  Widget getTextField(Properties property) {
    return StreamBuilder(
      stream: jsonSchemaBloc.formData[property.id],
      builder: (context, snapshot) {
        return Container(
          child: TextFormField(
            autofocus: (property.autoFocus ?? false),
            keyboardType: getTextInputType(property.widget, property.options),
            maxLines: property.widget == "textarea" ? null : 1,
            obscureText: property.widget == "password",
            initialValue: property.defaultValue ?? '',
            onSaved: (value) {
              Map<String, dynamic> data = Map<String, dynamic>();
              data[property.id] = value;
              jsonSchemaBloc.jsonDataAdd.add(data);
            },
            autovalidate: true,
            onChanged: (String value) {
              if (property.emptyValue != null && value.isEmpty) {
                return property.emptyValue;
              }

              return value;
            },
            validator: (String value) {
              if (property.required && value.isEmpty) {
                return 'Required';
              }
              if (property.minLength != null &&
                  value.isNotEmpty &&
                  value.length <= property.minLength) {
                return 'should NOT be shorter than ${property.minLength} characters';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText:
                  property.required ? property.title + ' *' : property.title,
              helperText: property.help,
            ),
          ),
        );
      },
    );
  }

  Widget getCheckBox(Properties properties) {
    return StreamBuilder(
      stream: jsonSchemaBloc.formData[properties.id],
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CheckboxFormField(
            autoValidate: true,
            initialValue: snapshot.data,
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
            onChange: (val) {
              Map<String, dynamic> data = Map<String, dynamic>();
              data[properties.id] = val;
              jsonSchemaBloc.jsonDataAdd.add(data);
              return;
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    jsonSchemaBloc.dispose();
  }
}
