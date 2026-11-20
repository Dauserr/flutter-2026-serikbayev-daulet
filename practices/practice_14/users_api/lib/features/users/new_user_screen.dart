import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [_name, _username, _email]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _unfocus(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  String _message(ApiException error) {
    return switch (error) {
      NoConnectionException() => 'No connection',
      ServerException(:final status) => 'Server error $status',
      BadResponseException(:final detail) => detail ?? 'Bad response',
      NotFoundException() || UnauthorizedException() => 'Request failed',
    };
  }

  Future<void> _save(BuildContext context) async {
    if (_saving) return;
    if (_formKey.currentState!.validate() == false) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _saving = true;
    });

    final draft = User(
      id: 0,
      name: _name.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
      phone: '',
      website: null,
      address: const Address(
        street: '',
        suite: '',
        city: '',
        zipcode: '',
        geo: Geo(lat: 0, lng: 0),
      ),
      company: (name: '', catchPhrase: ''),
    );

    final error = await context.read<UsersModel>().create(draft);

    if (!context.mounted) return;

    setState(() {
      _saving = false;
    });

    if (error == null) {
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_message(error))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
                onTapOutside: _unfocus,
                validator: (value) {
                  if ((value ?? '').trim().length < 2) {
                    return 'Name is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                textInputAction: TextInputAction.next,
                onTapOutside: _unfocus,
                validator: (value) {
                  if ((value ?? '').trim().length < 3) {
                    return 'Username is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onTapOutside: _unfocus,
                onFieldSubmitted: (_) => _save(context),
                validator: (value) {
                  final email = (value ?? '').trim();
                  final at = email.indexOf('@');
                  final dot = email.indexOf('.', at + 1);

                  if (at < 1 || dot <= at + 1 || dot == email.length - 1) {
                    return 'Email looks wrong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : () => _save(context),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
