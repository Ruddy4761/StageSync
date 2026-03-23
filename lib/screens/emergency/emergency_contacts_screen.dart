import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/contact.dart';

class EmergencyContactsScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const EmergencyContactsScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: ListenableBuilder(
        listenable: widget.appState,
        builder: (context, _) {
          final contacts =
              widget.appState.getContactsForConcert(widget.concertId);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...contacts.map((contact) => _contactCard(contact)),
              const SizedBox(height: 8),
              // Add custom contact
              GestureDetector(
                onTap: () => _showAddContactDialog(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded,
                          color: AppColors.primaryLight, size: 20),
                      SizedBox(width: 8),
                      Text('Add Custom Contact',
                          style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _contactCard(EmergencyContact contact) {
    Color iconColor;
    IconData icon;
    switch (contact.type) {
      case 'medical':
        iconColor = AppColors.emergencyMedical;
        icon = Icons.local_hospital_rounded;
        break;
      case 'fire':
        iconColor = AppColors.emergencyFire;
        icon = Icons.local_fire_department_rounded;
        break;
      case 'police':
        iconColor = AppColors.emergencyPolice;
        icon = Icons.local_police_rounded;
        break;
      case 'venue':
        iconColor = AppColors.emergencyVenue;
        icon = Icons.location_city_rounded;
        break;
      case 'security':
        iconColor = AppColors.emergencySecurity;
        icon = Icons.security_rounded;
        break;
      default:
        iconColor = AppColors.primary;
        icon = Icons.phone_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text(contact.role,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(contact.phoneNumber,
                    style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Calling ${contact.phoneNumber}...')),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.call_rounded,
                      color: AppColors.neonGreen, size: 20),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Messaging ${contact.phoneNumber}...')),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.neonBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.message_rounded,
                      color: AppColors.neonBlue, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String type = 'custom';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: roleCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                widget.appState.addContact(EmergencyContact(
                  name: nameCtrl.text.trim(),
                  role: roleCtrl.text.trim(),
                  phoneNumber: phoneCtrl.text.trim(),
                  type: type,
                  concertId: widget.concertId,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
