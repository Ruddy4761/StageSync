/// All discrete actions a user might perform in the app.
enum AppPermission {
  // Tasks
  addTask,
  editTask,
  deleteTask,
  // Artists
  addArtist,
  editArtist,
  deleteArtist,
  // Staff
  addStaff,
  editStaff,
  deleteStaff,
  // Incidents
  logIncident,
  resolveIncident,
  editIncident,
  deleteIncident,
  // Notes
  addNote,
  deleteNote,
  // Budget / Expenses
  viewBudget,
  addExpense,
  editExpense,
  deleteExpense,
  // Emergency Contacts
  addContact,
  editContact,
  deleteContact,
  // Concert
  editConcert,
  deleteConcert,
}

class PermissionService {
  // Role name constants (match Staff.availableRoles exactly)
  static const String roleEventManager = 'Event Manager';
  static const String roleSound = 'Sound';
  static const String roleLighting = 'Lighting';
  static const String roleSecurity = 'Security';
  static const String roleStageCrew = 'Stage Crew';
  static const String roleVolunteers = 'Volunteers';
  static const String roleArtistManager = 'Artist Manager';

  /// Returns true if the given role (+ isCreator flag) has the permission.
  static bool hasPermission(
      String role, bool isCreator, AppPermission permission) {
    // Creators have ALL permissions
    if (isCreator) return true;

    switch (permission) {
      // ── Tasks ────────────────────────────────────────────────────
      case AppPermission.addTask:
        return [
          roleEventManager,
          roleSound,
          roleLighting,
          roleStageCrew,
          roleArtistManager,
        ].contains(role);

      case AppPermission.editTask:
        return [
          roleEventManager,
          roleSound,
          roleLighting,
          roleStageCrew,
          roleArtistManager,
        ].contains(role);

      case AppPermission.deleteTask:
        return role == roleEventManager;

      // ── Artists ──────────────────────────────────────────────────
      case AppPermission.addArtist:
        return [roleEventManager, roleStageCrew, roleArtistManager]
            .contains(role);

      case AppPermission.editArtist:
        return [roleEventManager, roleStageCrew, roleArtistManager]
            .contains(role);

      case AppPermission.deleteArtist:
        return [roleEventManager, roleArtistManager].contains(role);

      // ── Staff ────────────────────────────────────────────────────
      case AppPermission.addStaff:
        return role == roleEventManager;

      case AppPermission.editStaff:
        return role == roleEventManager;

      case AppPermission.deleteStaff:
        return false; // Creator only (handled above)

      // ── Incidents ────────────────────────────────────────────────
      case AppPermission.logIncident:
        return [
          roleEventManager,
          roleSound,
          roleLighting,
          roleSecurity,
        ].contains(role);

      case AppPermission.resolveIncident:
        return [
          roleEventManager,
          roleSound,
          roleLighting,
          roleSecurity,
        ].contains(role);

      case AppPermission.editIncident:
        return [
          roleEventManager,
          roleSound,
          roleLighting,
          roleSecurity,
        ].contains(role);

      case AppPermission.deleteIncident:
        return role == roleEventManager;

      // ── Notes ────────────────────────────────────────────────────
      case AppPermission.addNote:
        return true; // Everyone can add notes

      case AppPermission.deleteNote:
        return role == roleEventManager;

      // ── Budget / Expenses ────────────────────────────────────────
      case AppPermission.viewBudget:
        return [roleEventManager, roleArtistManager].contains(role);

      case AppPermission.addExpense:
        return role == roleEventManager;

      case AppPermission.editExpense:
        return role == roleEventManager;

      case AppPermission.deleteExpense:
        return role == roleEventManager;

      // ── Emergency Contacts ───────────────────────────────────────
      case AppPermission.addContact:
        return [roleEventManager, roleSecurity].contains(role);

      case AppPermission.editContact:
        return [roleEventManager, roleSecurity].contains(role);

      case AppPermission.deleteContact:
        return role == roleEventManager;

      // ── Concert ──────────────────────────────────────────────────
      case AppPermission.editConcert:
        return role == roleEventManager;

      case AppPermission.deleteConcert:
        return false; // Creator only (handled above)
    }
  }
}
