import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _version = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('StreamBuilder'),
                  icon: Icon(Icons.stream),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('listen'),
                  icon: Icon(Icons.timelapse),
                ),
              ],
              selected: {_version},
              onSelectionChanged: (value) {
                setState(() {
                  _version = value.first;
                });
              },
            ),
          ),
          Expanded(
            child: _version == 0
                ? const _StreamCountdown()
                : const _ListenCountdown(),
          ),
        ],
      ),
    );
  }
}

class _StreamCountdown extends StatefulWidget {
  const _StreamCountdown();

  @override
  State<_StreamCountdown> createState() => _StreamCountdownState();
}

class _StreamCountdownState extends State<_StreamCountdown> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<int>(
        stream: _stream,
        initialData: 10,
        builder: (context, snapshot) {
          return Text(
            '${snapshot.data ?? 10}',
            style: Theme.of(context).textTheme.displayLarge,
          );
        },
      ),
    );
  }
}

class _ListenCountdown extends StatefulWidget {
  const _ListenCountdown();

  @override
  State<_ListenCountdown> createState() => _ListenCountdownState();
}

class _ListenCountdownState extends State<_ListenCountdown> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((value) {
      setState(() {
        _left = value;
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$_left', style: Theme.of(context).textTheme.displayLarge),
    );
  }
}
