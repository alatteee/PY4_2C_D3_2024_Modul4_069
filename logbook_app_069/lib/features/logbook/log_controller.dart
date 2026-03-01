import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/log_model.dart';
import 'package:logbook_app_069/services/mongo_service.dart';
import 'package:logbook_app_069/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  // Kunci unik untuk penyimpanan lokal di Shared Preferences
  static const String _storageKey = 'user_logs_data';

  String _currentQuery = '';

  // Getter opsional untuk akses cepat list saat ini
  List<LogModel> get logs => logsNotifier.value;

  LogController();

  void searchLog(String query) {
    _currentQuery = query;
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void _syncFilteredLogs() {
    searchLog(_currentQuery);
  }

  /// CREATE: Menambah data ke Cloud + update UI lokal
  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      id: ObjectId(),
      title: title,
      description: desc,
      date: DateTime.now(),
      category: category,
    );

    try {
      // 1. Kirim ke MongoDB Atlas
      await MongoService().insertLog(newLog);

      // 2. Update state lokal jika sukses
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.add(newLog);
      logsNotifier.value = currentLogs;
      _syncFilteredLogs();

      await LogHelper.writeLog(
        "SUCCESS: Tambah data '${newLog.title}' ke Cloud & UI",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Add - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  /// UPDATE: Memperbarui data di Cloud berdasarkan index di UI
  Future<void> updateLog(int index, String title, String desc, String category) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id, // ID harus tetap sama agar MongoDB mengenali dokumen ini
      title: title,
      description: desc,
      date: DateTime.now(),
      category: category,
    );

    try {
      // 1. Update di MongoDB
      await MongoService().updateLog(updatedLog);

      // 2. Jika sukses, baru perbarui state lokal
      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;
      _syncFilteredLogs();

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Update - $e",
        source: "log_controller.dart",
        level: 1,
      );
      // Jika gagal, UI tetap pakai data lama
    }
  }

  /// DELETE: Menghapus data dari Cloud + UI
  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) {
        throw Exception(
          "ID Log tidak ditemukan, tidak bisa menghapus di Cloud.",
        );
      }

      // 1. Hapus di MongoDB Atlas
      await MongoService().deleteLog(targetLog.id!);

      // 2. Jika sukses, baru hapus dari state lokal
      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;
      _syncFilteredLogs();

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Hapus - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  // --- OPSIONAL: PERSISTENSI LOKAL (BRIDGING JSON) ---

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      logsNotifier.value.map((e) => e.toLocalMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  /// LOAD: Mengambil data dari Cloud sebagai sumber utama
  Future<void> loadFromDisk() async {
    try {
      final cloudData = await MongoService().getLogs();
      logsNotifier.value = cloudData;
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal mengambil data dari Cloud - $e",
        source: "log_controller.dart",
        level: 1,
      );
      // Jika ingin, di sini bisa ditambah fallback ke SharedPreferences
    }
    _syncFilteredLogs();
  }
}