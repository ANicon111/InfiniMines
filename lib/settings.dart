import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinimines/definitions.dart';

class Settings extends StatefulWidget {
  final Function setPercentage;
  final Function setSafeArea;
  final Function setTheme;
  final String currentTheme;
  const Settings(
      {Key? key,
      required this.setPercentage,
      required this.setTheme,
      required this.currentTheme,
      required this.setSafeArea})
      : super(key: key);

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
            width: 600 * RelSize(context).pixel,
            child: TextFormField(
              style: TextStyle(fontSize: 16 * RelSize(context).pixel),
              decoration: const InputDecoration(
                  label: Text(
                "Mine percentage:",
              )),
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
          ),
          SizedBox(
            width: 600 * RelSize(context).pixel,
            child: TextFormField(
              style: TextStyle(fontSize: 16 * RelSize(context).pixel),
              decoration: const InputDecoration(
                  label: Text(
                "Safe area:",
              )),
              onChanged: (val) {
                if (val.isNotEmpty) widget.setSafeArea(int.parse(val));
              },
              initialValue: (widget.setSafeArea()).toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
            ),
          ),
          SizedBox(
            width: 960 * RelSize(context).pixel,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 25 * RelSize(context).pixel,
                  ),
                  child: Text(
                    "Themes:",
                    style: TextStyle(fontSize: 20 * RelSize(context).pixel),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ThemeOption(
                      currentTheme: widget.currentTheme,
                      setTheme: widget.setTheme,
                      theme: "grassy",
                      themeName: "Grassy",
                    ),
                    ThemeOption(
                      currentTheme: widget.currentTheme,
                      setTheme: widget.setTheme,
                      theme: "plain",
                      themeName: "Plain",
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ThemeOption extends StatelessWidget {
  const ThemeOption({
    super.key,
    required this.currentTheme,
    required this.theme,
    required this.setTheme,
    required this.themeName,
  });

  final String currentTheme;
  final String theme;
  final String themeName;
  final Function setTheme;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10 * RelSize(context).pixel),
        child: Ink(
          width: 300 * RelSize(context).pixel,
          decoration: BoxDecoration(
            color: currentTheme == theme
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(
              Radius.circular(35 * RelSize(context).pixel),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.all(
              Radius.circular(35 * RelSize(context).pixel),
            ),
            hoverColor: Theme.of(context).hoverColor,
            onTap: () {
              setTheme(theme);
            },
            child: Padding(
              padding: EdgeInsets.all(10 * RelSize(context).pixel),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(35 * RelSize(context).pixel),
                    ),
                    child: Image.asset(
                      "assets/$theme/preview.png",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 5 * RelSize(context).pixel,
                    ),
                    child: Text(
                      themeName,
                      style: TextStyle(fontSize: 20 * RelSize(context).pixel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
