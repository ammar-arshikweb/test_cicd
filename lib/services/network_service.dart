import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkStatusService with WidgetsBindingObserver {
  // Singleton
  static final NetworkStatusService _instance = NetworkStatusService._internal();
  factory NetworkStatusService() => _instance;

  NetworkStatusService._internal() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> connectionStatus = ValueNotifier(true);
  late final StreamSubscription _connectivitySubscription;

  Future<void> _init() async {
    WidgetsBinding.instance.addObserver(this);
    await _checkConnection(); // initial check
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) => _checkConnection());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Check connection when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _checkConnection();
    }
  }

  Future<void> _checkConnection() async {
    final hasInternet = await InternetConnectionChecker.instance.hasConnection;
    if (connectionStatus.value != hasInternet) {
      connectionStatus.value = hasInternet;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    connectionStatus.dispose();
  }
}
