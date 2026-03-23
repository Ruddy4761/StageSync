import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/concert.dart';
import '../models/task.dart';
import '../models/artist.dart';
import '../models/staff.dart';
import '../models/incident.dart';
import '../models/note.dart';
import '../models/expense.dart';
import '../models/contact.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===================== CONCERTS =====================

  /// Create a new concert
  Future<void> createConcert(Concert concert) async {
    await _db.collection('concerts').doc(concert.id).set(concert.toMap());
  }

  /// Update an existing concert
  Future<void> updateConcert(Concert concert) async {
    await _db.collection('concerts').doc(concert.id).update(concert.toMap());
  }

  /// Delete a concert and all its subcollections
  Future<void> deleteConcert(String concertId) async {
    // Delete subcollections first
    final subcollections = ['tasks', 'artists', 'staff', 'incidents', 'notes', 'expenses', 'contacts'];
    for (final sub in subcollections) {
      final docs = await _db.collection('concerts').doc(concertId).collection(sub).get();
      for (final doc in docs.docs) {
        await doc.reference.delete();
      }
    }
    await _db.collection('concerts').doc(concertId).delete();
  }

  /// Stream concerts where user is a member
  Stream<List<Concert>> streamUserConcerts(String userId) {
    return _db
        .collection('concerts')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Concert.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Find concert by join code
  Future<Concert?> findConcertByJoinCode(String code) async {
    final snapshot = await _db
        .collection('concerts')
        .where('joinCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return Concert.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  /// Add a user to a concert's member list
  Future<void> addMemberToConcert(String concertId, String userId) async {
    await _db.collection('concerts').doc(concertId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  /// Update concert budget
  Future<void> setConcertBudget(String concertId, double budget) async {
    await _db.collection('concerts').doc(concertId).update({
      'totalBudget': budget,
    });
  }

  // ===================== TASKS =====================

  Stream<List<ConcertTask>> streamTasks(String concertId) {
    return _db
        .collection('concerts')
        .doc(concertId)
        .collection('tasks')
        .orderBy('time')
        .snapshots()
        .map((s) => s.docs.map((d) => ConcertTask.fromMap(d.id, d.data())).toList());
  }

  Future<void> addTask(String concertId, ConcertTask task) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  Future<void> updateTask(String concertId, ConcertTask task) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String concertId, String taskId) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // ===================== ARTISTS =====================

  Stream<List<Artist>> streamArtists(String concertId) {
    return _db
        .collection('concerts')
        .doc(concertId)
        .collection('artists')
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => Artist.fromMap(d.id, d.data())).toList());
  }

  Future<void> addArtist(String concertId, Artist artist) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('artists')
        .doc(artist.id)
        .set(artist.toMap());
  }

  Future<void> updateArtist(String concertId, Artist artist) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('artists')
        .doc(artist.id)
        .update(artist.toMap());
  }

  Future<void> deleteArtist(String concertId, String artistId) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('artists')
        .doc(artistId)
        .delete();
  }

  // ===================== STAFF =====================

  Stream<List<Staff>> streamStaff(String concertId) {
    return _db
        .collection('concerts')
        .doc(concertId)
        .collection('staff')
        .snapshots()
        .map((s) => s.docs.map((d) => Staff.fromMap(d.id, d.data())).toList());
  }

  Future<void> addStaff(String concertId, Staff member) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('staff')
        .doc(member.id)
        .set(member.toMap());
  }

  Future<void> updateStaff(String concertId, Staff member) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('staff')
        .doc(member.id)
        .update(member.toMap());
  }

  Future<void> deleteStaff(String concertId, String staffId) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('staff')
        .doc(staffId)
        .delete();
  }

  // ===================== INCIDENTS =====================

  Stream<List<Incident>> streamIncidents(String concertId) {
    return _db
        .collection('concerts')
        .doc(concertId)
        .collection('incidents')
        .orderBy('time', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Incident.fromMap(d.id, d.data())).toList());
  }

  Future<void> addIncident(String concertId, Incident incident) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('incidents')
        .doc(incident.id)
        .set(incident.toMap());
  }

  Future<void> updateIncident(String concertId, Incident incident) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('incidents')
        .doc(incident.id)
        .update(incident.toMap());
  }

  // ===================== NOTES =====================

  Stream<List<Note>> streamNotes(String concertId) {
    return _db
        .collection('concerts')
        .doc(concertId)
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Note.fromMap(d.id, d.data())).toList());
  }

  Future<void> addNote(String concertId, Note note) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('notes')
        .doc(note.id)
        .set(note.toMap());
  }

  Future<void> toggleNotePin(String concertId, String noteId, bool isPinned) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('notes')
        .doc(noteId)
        .update({'isPinned': isPinned});
  }

  // ===================== EXPENSES =====================

  Stream<List<Expense>> streamExpenses(String concertId) {
    return _db
        .collection('concerts')
        .doc(concertId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Expense.fromMap(d.id, d.data())).toList());
  }

  Future<void> addExpense(String concertId, Expense expense) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toMap());
  }

  Future<void> deleteExpense(String concertId, String expenseId) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // ===================== EMERGENCY CONTACTS =====================

  Stream<List<EmergencyContact>> streamContacts(String concertId) {
    return _db
        .collection('concerts')
        .doc(concertId)
        .collection('contacts')
        .snapshots()
        .map((s) => s.docs.map((d) => EmergencyContact.fromMap(d.id, d.data())).toList());
  }

  Future<void> addContact(String concertId, EmergencyContact contact) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('contacts')
        .doc(contact.id)
        .set(contact.toMap());
  }

  Future<void> updateContact(String concertId, EmergencyContact contact) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('contacts')
        .doc(contact.id)
        .update(contact.toMap());
  }

  Future<void> deleteContact(String concertId, String contactId) async {
    await _db
        .collection('concerts')
        .doc(concertId)
        .collection('contacts')
        .doc(contactId)
        .delete();
  }
}
