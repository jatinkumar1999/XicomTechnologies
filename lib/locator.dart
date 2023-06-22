import 'package:get_it/get_it.dart';
import 'package:task_project/provider/detail_screen_provider.dart';
import 'package:task_project/provider/get_data_provider.dart';

final locator = GetIt.instance;
void setupLocator() {
  locator.registerFactory(() => GetDataProvider());
  locator.registerFactory(() => DetailProvider());
}
