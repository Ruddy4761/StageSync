import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/concert.dart';
import '../models/task.dart';
import '../models/artist.dart';
import '../models/staff.dart';
import '../models/incident.dart';
import '../models/expense.dart';
import '../models/contact.dart';

/// Service for generating a comprehensive PDF concert report.
class PdfService {
  // Theme colors as PDF colors
  static const _primary = PdfColor.fromInt(0xFF8B5CF6);
  static const _secondary = PdfColor.fromInt(0xFFEC4899);
  static const _success = PdfColor.fromInt(0xFF10B981);
  static const _warning = PdfColor.fromInt(0xFFF59E0B);
  static const _danger = PdfColor.fromInt(0xFFEF4444);
  static const _bgDark = PdfColor.fromInt(0xFF1A1A2E);
  static const _bgCard = PdfColor.fromInt(0xFF252540);
  static const _textLight = PdfColor.fromInt(0xFFF1F5F9);
  static const _textGrey = PdfColor.fromInt(0xFF94A3B8);
  static const _white = PdfColors.white;

  /// Generate a full concert PDF report. Returns raw bytes.
  static Future<Uint8List> generateConcertReport({
    required Concert concert,
    required List<ConcertTask> tasks,
    required List<Artist> artists,
    required List<Staff> staff,
    required List<Incident> incidents,
    required List<Expense> expenses,
    required List<EmergencyContact> contacts,
  }) async {
    final doc = pw.Document();

    // Calculate stats
    final doneTasks = tasks.where((t) => t.status == TaskStatus.done).length;
    final openIncidents =
        incidents.where((i) => i.status != IncidentStatus.resolved).length;
    final totalSpent = expenses.fold(0.0, (s, e) => s + e.amount);
    final budgetUsed = concert.totalBudget > 0
        ? (totalSpent / concert.totalBudget * 100).clamp(0, 100)
        : 0.0;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(concert, context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Concert Overview Section
          _sectionTitle('Concert Overview'),
          _overviewTable(concert, doneTasks, tasks.length, openIncidents),
          pw.SizedBox(height: 20),

          // Task Summary
          _sectionTitle('Task Summary'),
          _taskSummaryTable(tasks),
          pw.SizedBox(height: 20),

          // Artist Lineup
          if (artists.isNotEmpty) ...[
            _sectionTitle('Artist Lineup'),
            _artistTable(artists),
            pw.SizedBox(height: 20),
          ],

          // Staff List
          if (staff.isNotEmpty) ...[
            _sectionTitle('Staff List'),
            _staffTable(staff),
            pw.SizedBox(height: 20),
          ],

          // Incident Log
          if (incidents.isNotEmpty) ...[
            _sectionTitle('Incident Log'),
            _incidentTable(incidents),
            pw.SizedBox(height: 20),
          ],

          // Budget Breakdown
          _sectionTitle('Budget Breakdown'),
          _budgetTable(
              concert, expenses, totalSpent, budgetUsed.toDouble()),
          pw.SizedBox(height: 20),

          // Emergency Contacts
          if (contacts.isNotEmpty) ...[
            _sectionTitle('Emergency Contacts'),
            _contactTable(contacts),
          ],
        ],
      ),
    );

    return doc.save();
  }

  // ─── Header ───────────────────────────────────────────────────────

  static pw.Widget _buildHeader(
      Concert concert, pw.Context context) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [_primary, _secondary],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      padding: const pw.EdgeInsets.all(16),
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'StageSync',
                style: pw.TextStyle(
                  color: _white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Concert Operations Report',
                style: pw.TextStyle(color: _white, fontSize: 12),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                concert.name,
                style: pw.TextStyle(
                    color: _white,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                DateFormat('MMMM d, yyyy').format(concert.dateTime),
                style: pw.TextStyle(color: _white, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _textGrey)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by StageSync • ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(color: _textGrey, fontSize: 9),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(color: _textGrey, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ─── Section Helpers ──────────────────────────────────────────────

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(colors: [_primary, _secondary]),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
            color: _white, fontWeight: pw.FontWeight.bold, fontSize: 12),
      ),
    );
  }

  static pw.Widget _cell(String text,
      {bool bold = false,
      PdfColor? color,
      bool center = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _headerCell(String text) => pw.Container(
        color: _bgDark,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: _white,
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
        ),
      );

  // ─── Tables ───────────────────────────────────────────────────────

  static pw.Widget _overviewTable(Concert concert, int doneTasks,
      int totalTasks, int openIncidents) {
    final rows = [
      ['Venue', concert.venue],
      ['Date & Time', DateFormat('MMMM d, yyyy • h:mm a').format(concert.dateTime)],
      ['Capacity', '${concert.capacity} attendees'],
      ['Join Code', concert.joinCode],
      ['Total Budget', 'INR ${NumberFormat('#,##0.00').format(concert.totalBudget)}'],
      ['Task Completion', '$doneTasks / $totalTasks tasks done'],
      ['Open Incidents', '$openIncidents incident(s) unresolved'],
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: _textGrey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
      children: rows
          .map((row) => pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: rows.indexOf(row).isEven
                        ? PdfColors.grey100
                        : PdfColors.white),
                children: [
                  _cell(row[0], bold: true),
                  _cell(row[1]),
                ],
              ))
          .toList(),
    );
  }

  static pw.Widget _taskSummaryTable(List<ConcertTask> tasks) {
    if (tasks.isEmpty) {
      return pw.Text('No tasks recorded.',
          style: pw.TextStyle(color: _textGrey, fontSize: 10));
    }

    PdfColor _statusColor(TaskStatus s) {
      switch (s) {
        case TaskStatus.done:
          return _success;
        case TaskStatus.inProgress:
          return _warning;
        case TaskStatus.delayed:
          return _danger;
        default:
          return _textGrey;
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _textGrey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          children: [
            _headerCell('Task'),
            _headerCell('Priority'),
            _headerCell('Assigned To'),
            _headerCell('Status'),
          ],
        ),
        ...tasks.map((t) => pw.TableRow(
              decoration: pw.BoxDecoration(
                  color: tasks.indexOf(t).isEven
                      ? PdfColors.grey100
                      : PdfColors.white),
              children: [
                _cell(t.title),
                _cell(t.priorityLabel),
                _cell(t.assignedTo),
                _cell(t.statusLabel, color: _statusColor(t.status)),
              ],
            )),
      ],
    );
  }

  static pw.Widget _artistTable(List<Artist> artists) {
    return pw.Table(
      border: pw.TableBorder.all(color: _textGrey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(children: [
          _headerCell('#'),
          _headerCell('Artist Name'),
          _headerCell('Genre'),
          _headerCell('Performance Time'),
        ]),
        ...artists.map((a) => pw.TableRow(
              decoration: pw.BoxDecoration(
                  color: artists.indexOf(a).isEven
                      ? PdfColors.grey100
                      : PdfColors.white),
              children: [
                _cell('${a.order}', center: true),
                _cell(a.name, bold: true),
                _cell(a.genre),
                _cell(a.performanceTime != null
                    ? DateFormat('h:mm a').format(a.performanceTime!)
                    : 'TBD'),
              ],
            )),
      ],
    );
  }

  static pw.Widget _staffTable(List<Staff> staff) {
    return pw.Table(
      border: pw.TableBorder.all(color: _textGrey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(children: [
          _headerCell('Name'),
          _headerCell('Role'),
          _headerCell('Shift'),
          _headerCell('Contact'),
        ]),
        ...staff.map((s) => pw.TableRow(
              decoration: pw.BoxDecoration(
                  color: staff.indexOf(s).isEven
                      ? PdfColors.grey100
                      : PdfColors.white),
              children: [
                _cell(s.name, bold: true),
                _cell(s.role),
                _cell(s.shiftFormatted),
                _cell(s.contactNumber ?? '—'),
              ],
            )),
      ],
    );
  }

  static pw.Widget _incidentTable(List<Incident> incidents) {
    PdfColor _severityColor(IncidentSeverity sev) {
      switch (sev) {
        case IncidentSeverity.high:
          return _danger;
        case IncidentSeverity.medium:
          return _warning;
        default:
          return _success;
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _textGrey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(children: [
          _headerCell('Description'),
          _headerCell('Type'),
          _headerCell('Severity'),
          _headerCell('Status'),
        ]),
        ...incidents.map((i) => pw.TableRow(
              decoration: pw.BoxDecoration(
                  color: incidents.indexOf(i).isEven
                      ? PdfColors.grey100
                      : PdfColors.white),
              children: [
                _cell(i.description),
                _cell(i.typeLabel),
                _cell(i.severityLabel,
                    color: _severityColor(i.severity), bold: true),
                _cell(i.statusLabel),
              ],
            )),
      ],
    );
  }

  static pw.Widget _budgetTable(Concert concert, List<Expense> expenses,
      double totalSpent, double budgetUsed) {
    // Group by category
    final Map<String, double> byCategory = {};
    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }

    final remaining = concert.totalBudget - totalSpent;
    final fmt = NumberFormat('#,##0.00');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Summary row
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          margin: const pw.EdgeInsets.only(bottom: 10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Total Budget',
                    style: pw.TextStyle(color: _textGrey, fontSize: 9)),
                pw.Text('INR ${fmt.format(concert.totalBudget)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                pw.Text('Total Spent',
                    style: pw.TextStyle(color: _textGrey, fontSize: 9)),
                pw.Text('INR ${fmt.format(totalSpent)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        color: _danger)),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text('Remaining',
                    style: pw.TextStyle(color: _textGrey, fontSize: 9)),
                pw.Text('INR ${fmt.format(remaining)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        color: remaining >= 0 ? _success : _danger)),
              ]),
            ],
          ),
        ),

        // Category breakdown
        if (byCategory.isNotEmpty)
          pw.Table(
            border: pw.TableBorder.all(color: _textGrey, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(children: [
                _headerCell('Category'),
                _headerCell('Amount (INR)'),
                _headerCell('% of Spent'),
              ]),
              ...byCategory.entries.map((e) {
                final pct = totalSpent > 0
                    ? (e.value / totalSpent * 100).toStringAsFixed(1)
                    : '0';
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: byCategory.keys.toList().indexOf(e.key).isEven
                          ? PdfColors.grey100
                          : PdfColors.white),
                  children: [
                    _cell(e.key, bold: true),
                    _cell(fmt.format(e.value)),
                    _cell('$pct%', center: true),
                  ],
                );
              }),
            ],
          ),

        // Recent expenses
        if (expenses.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text('Recent Expenses',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Table(
            border: pw.TableBorder.all(color: _textGrey, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(children: [
                _headerCell('Description'),
                _headerCell('Category'),
                _headerCell('Amount (INR)'),
                _headerCell('Date'),
              ]),
              ...expenses.take(15).map((e) => pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: expenses.indexOf(e).isEven
                            ? PdfColors.grey100
                            : PdfColors.white),
                    children: [
                      _cell(e.description),
                      _cell(e.category),
                      _cell(fmt.format(e.amount)),
                      _cell(DateFormat('dd/MM').format(e.date)),
                    ],
                  )),
            ],
          ),
        ],
      ],
    );
  }

  static pw.Widget _contactTable(List<EmergencyContact> contacts) {
    return pw.Table(
      border: pw.TableBorder.all(color: _textGrey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(children: [
          _headerCell('Name'),
          _headerCell('Role'),
          _headerCell('Phone'),
          _headerCell('Type'),
        ]),
        ...contacts.map((c) => pw.TableRow(
              decoration: pw.BoxDecoration(
                  color: contacts.indexOf(c).isEven
                      ? PdfColors.grey100
                      : PdfColors.white),
              children: [
                _cell(c.name, bold: true),
                _cell(c.role),
                _cell(c.phoneNumber, bold: true),
                _cell(c.type.toUpperCase()),
              ],
            )),
      ],
    );
  }
}
