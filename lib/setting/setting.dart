import 'package:flutter/material.dart';
import 'package:haggah/setting/settings_model.dart';
import 'package:haggah/util/theme.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        title: const Text("설정"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 40,
                  child: Text(
                    '시스템',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('테마'),
                    Consumer<AppSettingState>(
                      builder: (_, setting, __) => Row(
                        children: [
                          Column(
                            children: [
                              const Text('시스템'),
                              Radio<ThemeMode>(
                                groupValue: setting.themeMode,
                                value: ThemeMode.system,
                                onChanged: (v) {
                                  setting.themeMode = v ?? setting.themeMode;
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('아침'),
                              Radio<ThemeMode>(
                                groupValue: setting.themeMode,
                                value: ThemeMode.light,
                                onChanged: (v) {
                                  setting.themeMode = v ?? setting.themeMode;
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('저녁'),
                              Radio<ThemeMode>(
                                groupValue: setting.themeMode,
                                value: ThemeMode.dark,
                                onChanged: (v) {
                                  setting.themeMode = v ?? setting.themeMode;
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          ...lineDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 40,
                  child: Text(
                    '말씀 듣기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('음성 속도'),
                      Consumer<AppSettingState>(
                        builder: (_, state, __) {
                          return SizedBox(
                            width: 150,
                            child: Slider(
                              value: state.speechRate,
                              onChanged: (val) {
                                state.speechRate = val;
                              },
                              min: 0,
                              max: 2,
                              divisions: 20,
                              label: '${state.speechRate}',
                              inactiveColor: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('반복'),
                      Consumer<AppSettingState>(
                        builder: (_, state, __) {
                          return Switch(
                            value: state.repeat,
                            onChanged: (v) {
                              state.repeat = v;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...lineDivider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 40,
                  child: Text(
                    '말씀 보관함',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('구절 펼치기'),
                      Consumer<AppSettingState>(
                        builder: (_, state, __) {
                          return Switch(
                            value: state.expandByDefault,
                            onChanged: (v) {
                              state.expandByDefault = v;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...lineDivider(),
          const SizedBox(
            height: 40,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '미리보기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Transform.scale(
            alignment: Alignment.topCenter,
            scale: 0.75,
            child: Column(
              key: UniqueKey(),
              children: [
                previewVerse(isLightMode, 0, '창 1 : 1', '태초에 하나님이 천지를 창조하시니라'),
                previewVerse(
                    isLightMode, 1, '시 23 : 1', '여호와는 나의 목자시니 내게 부족함이 없으리로다'),
                previewVerse(isLightMode, 2, '전 12 : 1',
                    '너는 청년의 때에 너의 창조주를 기억하라 곧 곤고한 날이 이르기 전에, 나는 아무 낙이 없다고 할 해들이 가깝기 전에'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> lineDivider() => [
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(thickness: 1),
        ),
        const SizedBox(height: 20),
      ];

  Widget previewVerse(bool isLightMode, int i, String adderss, String span) =>
      Padding(
        padding: const EdgeInsets.all(5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: (isLightMode ? odEvColor : dOdEvColor)[i.isOdd ? 100 : 200],
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            border: Border.all(
                color: isLightMode ? odEvColor[300]! : dOdEvColor[300]!,
                width: 0.5),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              controlAffinity: ListTileControlAffinity.leading,
              expandedAlignment: Alignment.centerLeft,
              leading: SizedBox(
                width: 30,
                height: 24,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                ),
                onPressed: () {},
              ),
              title: Text(
                adderss,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                  child: Text.rich(
                    TextSpan(text: span),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 15,
                      textBaseline: TextBaseline.ideographic,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
