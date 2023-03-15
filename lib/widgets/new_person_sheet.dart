import 'package:crowd_monitor/utilities/firestore_utils.dart';
import 'package:crowd_monitor/widgets/error_dialog.dart';
import 'package:crowd_monitor/widgets/loading_dialog.dart';
import 'package:crowd_monitor/widgets/sized_input_field.dart';
import 'package:flutter/material.dart';

class NewPersonSheet extends StatefulWidget {
  const NewPersonSheet({Key? key}) : super(key: key);

  @override
  State<NewPersonSheet> createState() => _NewPersonSheetState();
}

class _NewPersonSheetState extends State<NewPersonSheet> {
  late TextEditingController nameController;

  @override
  void initState() {
    nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  createNewPerson() async {
    final name = nameController.text;
    if (name.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    loadingDialog(context: context, text: 'Creating new person');
    try {
      final data = addNewPerson(name);
      // Popping back with the personData
      goBack(data);
    } catch (e) {
      Navigator.pop(context);
      showErrorDialog(context, e.toString());
    }
  }

  goBack(personData) {
    Navigator.pop(context);
    Navigator.pop(context, personData);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Add new person',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 26),
              SizedInputField(
                controller: nameController,
                hintText: 'Enter the name',
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: createNewPerson,
                child: const Text('Create'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
