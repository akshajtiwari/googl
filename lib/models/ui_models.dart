import 'package:flutter/material.dart';

class Notif {
  final String title, body, time;
  final IconData icon;
  final Color color;
  bool read;
  
  Notif(this.title, this.body, this.time, this.icon, this.color, {this.read = false});
}

class SearchResult {
  final String title, subtitle, route;
  final IconData icon;
  
  const SearchResult(this.title, this.subtitle, this.route, this.icon);
}

class StatMeta {
  final String value, label, route;
  final IconData icon;
  final Color color;
  
  const StatMeta(this.value, this.label, this.icon, this.color, this.route);
}