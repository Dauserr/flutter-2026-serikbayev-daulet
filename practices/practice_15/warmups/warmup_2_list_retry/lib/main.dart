import 'package:flutter/material.dart';

enum ListState { loading, error, empty, data }

class FakeRepository {
  FakeRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;

  Future<List<String>> load() async {
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (fail) throw Exception('network down');

    return ['Ada Lovelace', 'Alan Turing'];
  }
}

class ListModel extends ChangeNotifier {
  ListModel(this._repo);

  final FakeRepository _repo;
  List<String> items = const [];
  Object? error;
  bool loading = false;

  ListState get state {
    if (loading) return ListState.loading;
    if (error != null) return ListState.error;
    if (items.isEmpty) return ListState.empty;
    return ListState.data;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      items = await _repo.load();
    } catch (error) {
      this.error = error;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

void main() {
  final model = ListModel(FakeRepository())..load();

  runApp(MaterialApp(home: ListScreen(model: model)));
}

class ListScreen extends StatelessWidget {
  const ListScreen({super.key, required this.model});

  final ListModel model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warm-up 2')),
      body: ListenableBuilder(
        listenable: model,
        builder: (context, _) {
          return switch (model.state) {
            ListState.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            ListState.error => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load the list'),
                  FilledButton(
                    onPressed: model.load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            ListState.empty => const Center(child: Text('No items')),
            ListState.data => ListView.builder(
              itemCount: model.items.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(model.items[index]));
              },
            ),
          };
        },
      ),
    );
  }
}
