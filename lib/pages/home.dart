import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

import '../http_service.dart';
import '../notification.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String currentSelectedValue = 'currency';
  String currentSelectedCode = '';
  double? currentPrice;
  List<DropdownMenuItem> codeItems = [];
  List<String> codes = [];
  double? alarmPrice;
  final TextEditingController _alarmPriceController = TextEditingController();
  bool isLoadingPage = false;
  bool loadingPrice = false;
  String advertiseImageLink =
      'https://trade.swissquote.ch/signup/public/form/full/fx/com/individual?lang=ar&partnerid=78a1ea38-81b6-4184-9b29-7274662fb333#full/fx/com/individual/step1';
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Load stock codes of first value (currency).
    _requestPermissions();
    timer = Timer.periodic(const Duration(seconds: 60), (Timer t) async {
      await TradeHttpService()
          .getCodeLivePrice(currentSelectedCode)
          .then((value) {
        setState(() {
          currentPrice = value;
        });
        watchCurrentPriceAlarm();
      });
    });

    Future.delayed(Duration.zero, () async {
      await TradeHttpService().getCodes().then((value) {
        setState(() {
          codes = value;
          currentSelectedCode = codes[0].toString();
        });
      });
      await TradeHttpService()
          .getCodeLivePrice(currentSelectedCode)
          .then((value) {
        setState(() {
          currentPrice = value;
        });
        watchCurrentPriceAlarm();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  watchCurrentPriceAlarm() {
    log('watching current price $currentPrice, $alarmPrice');

    if (currentPrice == null || alarmPrice == null) return;

    if (currentPrice! >= alarmPrice!) {
      NotificaitonService.showFlutterNotification(
        'The code {$currentSelectedCode} price is equal/higher than the alarm price.',
        'Alarm Trade Notification - code $currentSelectedCode',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Alarm'),
      ),
      body: codes.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    _advertiseBoxWidget(),
                    const SizedBox(
                      height: 40,
                    ),
                    // _stockTraderMenuWidget(),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    _stockCodesMenuWidget(),
                    const SizedBox(
                      height: 20,
                    ),
                    _currentPriceWidget(),
                    const SizedBox(
                      height: 40,
                    ),
                    _alarmPriceFieldWidget(),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Container _alarmPriceFieldWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        textAlign: TextAlign.center,
        style: const TextStyle(),
        controller: _alarmPriceController,
        textInputAction: TextInputAction.done,
        keyboardType: const TextInputType.numberWithOptions(),
        decoration: const InputDecoration.collapsed(
            border: InputBorder.none, hintText: 'Enter alarm trade price:'),
        onChanged: (value) {
          setState(() {
            if (value == '') {
              alarmPrice = null;
            } else {
              alarmPrice = double.parse(value);
            }
          });
        },
      ),
    );
  }

  InkWell _advertiseBoxWidget() {
    return InkWell(
        onTap: _launchUrl,
        child: Image.asset('assets/images/advertise_image.png'));
  }

  Container _currentPriceWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
          child: Column(
        children: [
          const Text('Current Price:'),
          const SizedBox(
            height: 8,
          ),
          !loadingPrice
              ? Text(
                  (currentPrice ?? 'N/A').toString(),
                  style: const TextStyle(color: Colors.green, fontSize: 24),
                )
              : const CircularProgressIndicator(),
        ],
      )),
    );
  }

  Container _stockCodesMenuWidget() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(5),
        ),
        child: DropdownSearch<String>(
          popupProps: const PopupProps.menu(
            scrollbarProps: ScrollbarProps(
                thumbVisibility: false, thickness: 0, interactive: false),
            showSearchBox: true,
            showSelectedItems: true,
          ),
          items: codes.map((item) => item).toList(),
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
                border: InputBorder.none,
                labelText: "Code Menu",
                hintText: "Search code here",
                hintStyle: TextStyle(color: Colors.black)),
          ),
          onChanged: (value) async {
            if (value == currentSelectedCode) return;
            setState(() {
              loadingPrice = true;
              currentSelectedCode = value!;
            });
            await TradeHttpService()
                .getCodeLivePrice(currentSelectedCode)
                .then((value) {
              setState(() {
                currentPrice = value;
                loadingPrice = false;
              });
            });
          },
          selectedItem: currentSelectedCode,
        ));
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(advertiseImageLink),
        mode: LaunchMode.externalApplication)) {
      log('couldn\'t launch url ');
    }
  }

  Future<void> _requestPermissions() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // ignore: unused_local_variable
      final bool? granted = await androidImplementation?.requestPermission();
    }
  }
}
