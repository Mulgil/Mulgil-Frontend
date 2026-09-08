import 'package:flutter/foundation.dart' show listEquals;

class MindmapNode {
  final String id;
  final String label;

  const MindmapNode({required this.id, required this.label});

  @override
  bool operator ==(Object other) =>
      other is MindmapNode && other.id == id && other.label == label;

  @override
  int get hashCode => Object.hash(id, label);
}

class MindmapEdge {
  final String from;
  final String to;

  const MindmapEdge({required this.from, required this.to});

  @override
  bool operator ==(Object other) =>
      other is MindmapEdge && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

class MindmapGraph {
  final List<MindmapNode> nodes;
  final List<MindmapEdge> edges;

  const MindmapGraph({this.nodes = const [], this.edges = const []});

  bool get isEmpty => nodes.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is MindmapGraph &&
      listEquals(other.nodes, nodes) &&
      listEquals(other.edges, edges);

  @override
  int get hashCode => Object.hash(Object.hashAll(nodes), Object.hashAll(edges));
}
