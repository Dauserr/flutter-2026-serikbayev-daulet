import 'package:flutter/material.dart';

import 'summary_card.dart';

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirm, _birthText]) {
      controller.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _unfocus(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _submit() {
    if (_agreed == false) return;
    if (_formKey.currentState!.validate() == false) return;

    FocusManager.instance.primaryFocus?.unfocus();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));

    setState(() {
      _done = true;
    });
  }

  Future<void> _pickBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date == null || mounted == false) return;

    setState(() {
      _birth = date;
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      _birthText.text = '$day.$month.${date.year}';
    });
  }

  void _startOver() {
    setState(() {
      for (final controller in [
        _name,
        _email,
        _password,
        _confirm,
        _birthText,
      ]) {
        controller.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
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
            controller: _email,
            focusNode: _emailFocus,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@kbtu.kz',
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onTapOutside: _unfocus,
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
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            onTapOutside: _unfocus,
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if ((value ?? '').length < 8) {
                return 'Password is too short';
              }
              return null;
            },
          ),
          Text(
            '${_password.text.length} of 8',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirm,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            onTapOutside: _unfocus,
            validator: (value) {
              if ((value ?? '').isEmpty) {
                return 'Confirm your password';
              }
              if (value != _password.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _group,
            decoration: const InputDecoration(labelText: 'Group'),
            items: [
              for (final group in groups)
                DropdownMenuItem(value: group, child: Text(group)),
            ],
            onChanged: (value) {
              setState(() {
                _group = value;
              });
            },
            validator: (value) {
              return value == null ? 'Choose a group' : null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _birthText,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              suffixIcon: Icon(Icons.calendar_month),
            ),
            onTap: _pickBirth,
            onTapOutside: _unfocus,
            validator: (_) {
              return _birth == null ? 'Choose a birth date' : null;
            },
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('I agree to the rules'),
            value: _agreed,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              setState(() {
                _agreed = value ?? false;
              });
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _agreed ? _submit : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _done
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SummaryCard(
                    name: _name.text.trim(),
                    email: _email.text.trim(),
                    group: _group ?? '',
                    birthDate: _birthText.text,
                  ),
                  TextButton(
                    onPressed: _startOver,
                    child: const Text('Start over'),
                  ),
                ],
              )
            : _buildForm(),
      ),
    );
  }
}
