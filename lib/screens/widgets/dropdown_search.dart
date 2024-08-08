import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic>) onSelect;
  final bool isVisible;

  CustomDropdown({
    required this.items,
    required this.onSelect,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || items.isEmpty) {
      return SizedBox.shrink(); // Return an empty box if the dropdown is not visible
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final user = items[index];
          return ListTile(
            title: Text(user['name'] ?? 'No Name'),
            subtitle: Text(user['email'] ?? 'No Email'),
            trailing: Text(user['userId']),
            onTap: () {
              onSelect(user);
            },
          );
        },
      ),
    );
  }
}
