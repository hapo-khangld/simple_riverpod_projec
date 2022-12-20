import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

final currentDate = Provider<DateTime>(
  (ref) => DateTime.now(),
);

enum City {
  hanoi,
  paris,
  tokyo,
}

typedef WeatherEmoji = String;

//Ui writes to and reads from this
Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 1),
    () =>
        {
          City.hanoi: 'sun',
          City.paris: 'snow',
          City.tokyo: 'rain',
        }[city] ??
        'hot',
  );
}

//will be changed by the UI
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);

//Ui reads this
final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return 'no city weather';
  }
});

class HomePage extends ConsumerWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
      ),
      body: Column(
        children: [
          weather.when(
            data: (data) => Text(data, style: const TextStyle(fontSize: 40,),),
            error: (_, __) => const Text('Not City'),
            loading: () => const CircularProgressIndicator(),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currentCityProvider);
                return ListTile(
                  title: Text(
                    city.toString(),
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    ref.read(currentCityProvider.notifier).state = city;
                  },
                );
              },
              itemCount: City.values.length,
            ),
          ),
        ],
      ),
    );
  }
}
