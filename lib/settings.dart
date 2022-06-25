import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinimines/definitions.dart';

class Settings extends StatefulWidget {
  final Function setPercentage;
  const Settings({Key? key, required this.setPercentage}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 600 * RelSize(context).pixel(),
            child: TextFormField(
              decoration:
                  const InputDecoration(label: Text("Mine percentage:")),
              onChanged: (val) {
                if (val.isNotEmpty) widget.setPercentage(int.parse(val) / 100);
              },
              initialValue: ((widget.setPercentage() * 100).toInt()).toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),
          )
        ],
      ),
    );
  }
}
