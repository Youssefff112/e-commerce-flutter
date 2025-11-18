import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mock_data_service.dart';
import 'screens/vendor_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dataService = MockDataService();
  dataService.initialize();

  runApp(VendorApp(dataService: dataService));
}

class VendorApp extends StatelessWidget {
  final MockDataService dataService;

  const VendorApp({super.key, required this.dataService});

  @override
  Widget build(BuildContext context) {
    return Provider<MockDataService>.value(
      value: dataService,
      child: MaterialApp(
        title: 'Cinema Vendor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        home: const VendorHome(),
      ),
    );
  }
}
