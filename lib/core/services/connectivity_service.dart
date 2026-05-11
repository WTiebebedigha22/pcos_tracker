import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Updated to return a List or the first element of the list
  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  Future<bool> isConnected() async {
    final List<ConnectivityResult> results = 
        await _connectivity.checkConnectivity();

    // Returns true if the list contains anything other than 'none'
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
}