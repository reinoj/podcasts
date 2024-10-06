import 'package:flutter/material.dart';

import '../components/podcast.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void getNewRSS(BuildContext context) async {
    bool succeeded = await downloadRss(_addController.text, false);
    if (succeeded) {
      SnackBar snackBar = const SnackBar(content: Text('Successfully added RSS feed.'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      SnackBar snackBar =
          const SnackBar(content: Text('Unable to add RSS feed. Yell at the developer for the reason.'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    _addController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
          child: TextFormField(
            controller: _addController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter RSS link',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => getNewRSS(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          ),
          child: const Text('Add RSS Feed'),
        ),
      ],
    );
  }
}
