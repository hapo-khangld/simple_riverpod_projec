import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

@immutable
class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavorite,
  });

  Film copy({required bool isFavorite}) {
    return Film(
      id: id,
      title: title,
      description: description,
      isFavorite: isFavorite,
    );
  }

  @override
  String toString() => 'Film(id: $id, '
      'title: $title, '
      'description: $description, '
      'isFavorite: $isFavorite)';

  @override
  bool operator ==(covariant Film other) => id == other.id && isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll(
        [
          id,
          isFavorite,
        ],
      );
}

const allFilms = [
  Film(
    id: '1',
    title: 'The Shawshank Redemption',
    description: 'Description for the Shawshank Redemption',
    isFavorite: false,
  ),
  Film(
    id: '2',
    title: 'The Godfather',
    description: 'Description for the Godfather',
    isFavorite: false,
  ),
  Film(
    id: '3',
    title: 'The Doraemon',
    description: 'Description for the Doraemon',
    isFavorite: false,
  ),
  Film(
    id: '4',
    title: 'The Avengers: Endgame',
    description: 'Description for the Avengers: Endgame',
    isFavorite: false,
  ),
  Film(
    id: '5',
    title: 'The Harry Potter',
    description: 'Description for the Harry Potter',
    isFavorite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);

  void update(Film film, bool isFavorite) {
    state = state
        .map(
          (thisFilm) => thisFilm.id == film.id
              ? thisFilm.copy(
                  isFavorite: isFavorite,
                )
              : thisFilm,
        )
        .toList();
  }
}

enum FavoritesStatus {
  all,
  favorite,
  notFavorite,
}

// sử dụng stateProvider để cung cấp trạng thái cho widget khi lưu trữ trạng thái của FavoriteStatus.
final favoriteStatusProvider = StateProvider<FavoritesStatus>(
  (ref) => FavoritesStatus.all,
);

//giong mvvm
// sử dụng StateNotiferProvider lưu trữ trạng thái của class FilmNotifer và dữ liệu của 1 List<Film>.
// sử dụng (ref) => FilmsNotifier dể khởi tạo và trả về 1 đối tượng mới của lớp FilmsNotifer.
final allFilmsProvider = StateNotifierProvider<FilmsNotifier, List<Film>>(
  (ref) => FilmsNotifier(),
);


//sử dụng Provider để khởi tạo và gán (trả giá trị ) cho favorites hoặc notFavorites.
// sử dụng ref ở đây để khởi tạo giá trị: nó lắng nghe giá trị của allFilmsProvider tại lớp Film nếu
// giá trị isFavorite bằng true hoặc false.
// ==> rõ hơn thì ref ở đây sẽ truy cập vào giá trị lưu trữ của 'allFilmsProvider'. Sau đó sử dụng where để lọc
// ra các đối tượng "Film" có thuộc tính 'isFavorites' theo yêu cầu.
// favorites films
final favoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where(
        (film) => film.isFavorite,
      ),
);

//not-favorite films
final notFavoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where(
        (film) => !film.isFavorite,
      ),
);

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

class HomePage extends ConsumerWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod example 6'),
      ),
      body: Column(
        children: [
          const FilterWidget(),
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(favoriteStatusProvider);
              switch (filter) {
                case FavoritesStatus.all:
                  return FilmsWidget(provider: allFilmsProvider);
                case FavoritesStatus.favorite:
                  return FilmsWidget(provider: favoriteFilmsProvider);
                case FavoritesStatus.notFavorite:
                  return FilmsWidget(provider: notFavoriteFilmsProvider);
              }
            },
          ),
        ],
      ),
    );
  }
}


//sử dụng AlwaysAliveProviderBase để khai báo 1 provider (không bao giờ bị huỷ). Provider này sẽ là đối tượng chia sẻ
//các dữ liệu với các widget khác nhau trong cây widget.
// để sử dụng provider. sử dụng watch().
// để cập nhật dữ liệu. sử dụng read() để đọc trên đôi tượng widgetRef để lấy một Notifier từ provider và sử dụng update()
//để cập nhật dữ liệu.
class FilmsWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;
  const FilmsWidget({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          final film = films.elementAt(index);
          final favouriteIcon = film.isFavorite ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border);
          return ListTile(
            title: Text(film.title),
            subtitle: Text(film.description),
            trailing: IconButton(
              onPressed: () {
                final isFavorite = !film.isFavorite;
                //làm tường minh code để cập nhập dữ liệu thì như sau.
                // final check = ref.read(allFilmsProvider.notifier);
                // check.update(film, isFavorite);
                // làm gọn code thì như sau:
                ref.read(allFilmsProvider.notifier).update(film, isFavorite);
              },
              icon: favouriteIcon,
            ),
          );
        },
        itemCount: films.length,
      ),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return DropdownButton(
        value: ref.watch(favoriteStatusProvider),
        items: FavoritesStatus.values
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e.toString().split('.').last),
              ),
            )
            .toList(),
        onChanged: (FavoritesStatus? value) {
          //state
          ref.read(favoriteStatusProvider.notifier).state = value!;
          //ở dây, sử dụng favoriteStatusProvider.notifer là giá trị mà provider sử dụng để thông báo cho các
          //widget khác trong cây Widget khi dữ liệu mà nó cung cấp thay đổi.
          // thuộc tính state sử dụng định nghĩa trạng thái hiện tại có nó.
          // ở đây, đang gán giá trị của value cho trạng thái của favoriteStatusProvider xem có đc yêu thích hay ko.
          // Đưa ra các giá trị khác của "status"khi thay đổi.
        },
      );
    });
  }
}
