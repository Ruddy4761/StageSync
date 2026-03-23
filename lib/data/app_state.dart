import 'dart:async';
import 'package:flutter/material.dart';
import '../models/concert.dart';
import '../models/task.dart';
import '../models/artist.dart';
import '../models/staff.dart';
import '../models/incident.dart';
import '../models/note.dart';
import '../models/expense.dart';
import '../models/contact.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Current user info
  String get currentUserName => _authService.displayName;
  String get currentUserEmail => _authService.email;
  String get currentUserId => _authService.userId;
  bool get isLoggedIn => _authService.isLoggedIn;

  // Concerts
  List<Concert> _concerts = [];
  List<Concert> get concerts => List.unmodifiable(_concerts);

  // Per-concert data (cached from Firestore streams)
  final Map<String, List<ConcertTask>> _tasks = {};
  final Map<String, List<Artist>> _artists = {};
  final Map<String, List<Staff>> _staff = {};
  final Map<String, List<Incident>> _incidents = {};
  final Map<String, List<Note>> _notes = {};
  final Map<String, List<Expense>> _expenses = {};
  final Map<String, List<EmergencyContact>> _contacts = {};

  // Stream subscriptions
  StreamSubscription? _concertsSubscription;
  final Map<String, List<StreamSubscription>> _concertDataSubscriptions = {};

  // --- Auth ---
  Future<({bool success, String? error})> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _authService.signUp(
      name: name,
      email: email,
      password: password,
    );
    if (result.success) {
      _startListeningConcerts();
      notifyListeners();
    }
    return result;
  }

  Future<({bool success, String? error})> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _authService.signIn(
      email: email,
      password: password,
    );
    if (result.success) {
      _startListeningConcerts();
      notifyListeners();
    }
    return result;
  }

  Future<void> signOut() async {
    _stopAllListeners();
    _concerts = [];
    _tasks.clear();
    _artists.clear();
    _staff.clear();
    _incidents.clear();
    _notes.clear();
    _expenses.clear();
    _contacts.clear();
    await _authService.signOut();
    notifyListeners();
  }

  Future<({bool success, String? error})> resetPassword(String email) async {
    return _authService.resetPassword(email);
  }

  /// Check if user is already logged in and start listening
  void initializeAuth() {
    if (_authService.isLoggedIn) {
      _startListeningConcerts();
    }
  }

  // --- Concerts Streaming ---
  void _startListeningConcerts() {
    _concertsSubscription?.cancel();
    _concertsSubscription = _firestoreService
        .streamUserConcerts(currentUserId)
        .listen((concertList) {
      _concerts = concertList;
      // Start listening to subcollection data for each concert
      for (final concert in concertList) {
        if (!_concertDataSubscriptions.containsKey(concert.id)) {
          _listenToConcertData(concert.id);
        }
      }
      notifyListeners();
    });
  }

  void _listenToConcertData(String concertId) {
    final subs = <StreamSubscription>[];

    subs.add(_firestoreService.streamTasks(concertId).listen((tasks) {
      _tasks[concertId] = tasks;
      notifyListeners();
    }));

    subs.add(_firestoreService.streamArtists(concertId).listen((artists) {
      _artists[concertId] = artists;
      notifyListeners();
    }));

    subs.add(_firestoreService.streamStaff(concertId).listen((staff) {
      _staff[concertId] = staff;
      notifyListeners();
    }));

    subs.add(_firestoreService.streamIncidents(concertId).listen((incidents) {
      _incidents[concertId] = incidents;
      notifyListeners();
    }));

    subs.add(_firestoreService.streamNotes(concertId).listen((notes) {
      _notes[concertId] = notes;
      notifyListeners();
    }));

    subs.add(_firestoreService.streamExpenses(concertId).listen((expenses) {
      _expenses[concertId] = expenses;
      notifyListeners();
    }));

    subs.add(_firestoreService.streamContacts(concertId).listen((contacts) {
      _contacts[concertId] = contacts;
      notifyListeners();
    }));

    _concertDataSubscriptions[concertId] = subs;
  }

  void _stopAllListeners() {
    _concertsSubscription?.cancel();
    _concertsSubscription = null;
    for (final subs in _concertDataSubscriptions.values) {
      for (final sub in subs) {
        sub.cancel();
      }
    }
    _concertDataSubscriptions.clear();
  }

  @override
  void dispose() {
    _stopAllListeners();
    super.dispose();
  }

  // --- Concert CRUD ---
  Future<void> addConcert(Concert concert) async {
    // Set creator info
    concert.creatorId = currentUserId;
    concert.memberIds = [currentUserId];

    await _firestoreService.createConcert(concert);

    // Add creator as first staff member
    final creatorStaff = Staff(
      userId: currentUserId,
      name: currentUserName,
      role: concert.creatorRole,
      isCreator: true,
      concertId: concert.id,
    );
    await _firestoreService.addStaff(concert.id, creatorStaff);

    // Add default emergency contacts
    final defaultContacts = [
      EmergencyContact(name: 'Emergency Services', role: 'Medical/Ambulance', phoneNumber: '108', type: 'medical', concertId: concert.id),
      EmergencyContact(name: 'Fire Department', role: 'Fire Emergency', phoneNumber: '101', type: 'fire', concertId: concert.id),
      EmergencyContact(name: 'Police', role: 'Law Enforcement', phoneNumber: '100', type: 'police', concertId: concert.id),
    ];
    for (final contact in defaultContacts) {
      await _firestoreService.addContact(concert.id, contact);
    }
  }

  Future<void> updateConcert(Concert concert) async {
    await _firestoreService.updateConcert(concert);
  }

  Future<void> deleteConcert(String concertId) async {
    _stopConcertListeners(concertId);
    await _firestoreService.deleteConcert(concertId);
  }

  void _stopConcertListeners(String concertId) {
    final subs = _concertDataSubscriptions.remove(concertId);
    if (subs != null) {
      for (final sub in subs) {
        sub.cancel();
      }
    }
    _tasks.remove(concertId);
    _artists.remove(concertId);
    _staff.remove(concertId);
    _incidents.remove(concertId);
    _notes.remove(concertId);
    _expenses.remove(concertId);
    _contacts.remove(concertId);
  }

  /// Join a concert by code
  Future<({bool success, String? error, Concert? concert})> joinConcertByCode(String code) async {
    final concert = await _firestoreService.findConcertByJoinCode(code);
    if (concert == null) {
      return (success: false, error: 'No concert found with this code', concert: null);
    }

    // Check if already a member
    if (concert.memberIds.contains(currentUserId)) {
      return (success: false, error: 'You are already a member of this concert', concert: concert);
    }

    // Add user as member
    await _firestoreService.addMemberToConcert(concert.id, currentUserId);

    // Add as staff
    final newStaff = Staff(
      userId: currentUserId,
      name: currentUserName,
      role: 'Volunteers', // Default role
      isCreator: false,
      concertId: concert.id,
    );
    await _firestoreService.addStaff(concert.id, newStaff);

    return (success: true, error: null, concert: concert);
  }

  Concert? findConcertByJoinCode(String code) {
    try {
      return _concerts.firstWhere(
        (c) => c.joinCode.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // --- Tasks ---
  List<ConcertTask> getTasksForConcert(String concertId) =>
      _tasks[concertId] ?? [];

  Future<void> addTask(ConcertTask task) async {
    await _firestoreService.addTask(task.concertId, task);
  }

  Future<void> updateTask(ConcertTask task) async {
    await _firestoreService.updateTask(task.concertId, task);
  }

  Future<void> deleteTask(String concertId, String taskId) async {
    await _firestoreService.deleteTask(concertId, taskId);
  }

  // --- Artists ---
  List<Artist> getArtistsForConcert(String concertId) =>
      _artists[concertId] ?? [];

  Future<void> addArtist(Artist artist) async {
    await _firestoreService.addArtist(artist.concertId, artist);
  }

  Future<void> updateArtist(Artist artist) async {
    await _firestoreService.updateArtist(artist.concertId, artist);
  }

  Future<void> deleteArtist(String concertId, String artistId) async {
    await _firestoreService.deleteArtist(concertId, artistId);
  }

  Future<void> reorderArtists(String concertId, int oldIndex, int newIndex) async {
    final list = List<Artist>.from(_artists[concertId] ?? []);
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      list[i].order = i + 1;
      await _firestoreService.updateArtist(concertId, list[i]);
    }
  }

  // --- Staff ---
  List<Staff> getStaffForConcert(String concertId) =>
      _staff[concertId] ?? [];

  Future<void> addStaff(Staff member) async {
    await _firestoreService.addStaff(member.concertId, member);
  }

  Future<void> updateStaff(Staff member) async {
    await _firestoreService.updateStaff(member.concertId, member);
  }

  Future<void> deleteStaff(String concertId, String staffId) async {
    await _firestoreService.deleteStaff(concertId, staffId);
  }

  List<String> getStaffNamesForConcert(String concertId) {
    return (_staff[concertId] ?? []).map((s) => s.name).toList();
  }

  // --- Incidents ---
  List<Incident> getIncidentsForConcert(String concertId) =>
      _incidents[concertId] ?? [];

  Future<void> addIncident(Incident incident) async {
    await _firestoreService.addIncident(incident.concertId, incident);
  }

  Future<void> updateIncident(Incident incident) async {
    await _firestoreService.updateIncident(incident.concertId, incident);
  }

  // --- Notes ---
  List<Note> getNotesForConcert(String concertId) =>
      _notes[concertId] ?? [];

  Future<void> addNote(Note note) async {
    await _firestoreService.addNote(note.concertId, note);
  }

  Future<void> toggleNotePin(String concertId, String noteId) async {
    final list = _notes[concertId];
    if (list != null) {
      final idx = list.indexWhere((n) => n.id == noteId);
      if (idx != -1) {
        final newPinned = !list[idx].isPinned;
        await _firestoreService.toggleNotePin(concertId, noteId, newPinned);
      }
    }
  }

  // --- Expenses ---
  List<Expense> getExpensesForConcert(String concertId) =>
      _expenses[concertId] ?? [];

  double getTotalSpent(String concertId) {
    return (_expenses[concertId] ?? [])
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> addExpense(Expense expense) async {
    await _firestoreService.addExpense(expense.concertId, expense);
  }

  Future<void> deleteExpense(String concertId, String expenseId) async {
    await _firestoreService.deleteExpense(concertId, expenseId);
  }

  // --- Emergency Contacts ---
  List<EmergencyContact> getContactsForConcert(String concertId) =>
      _contacts[concertId] ?? [];

  Future<void> addContact(EmergencyContact contact) async {
    await _firestoreService.addContact(contact.concertId, contact);
  }

  Future<void> updateContact(EmergencyContact contact) async {
    await _firestoreService.updateContact(contact.concertId, contact);
  }

  Future<void> deleteContact(String concertId, String contactId) async {
    await _firestoreService.deleteContact(concertId, contactId);
  }

  // --- Concert Budget ---
  Future<void> setConcertBudget(String concertId, double budget) async {
    await _firestoreService.setConcertBudget(concertId, budget);
  }
}
