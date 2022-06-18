import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storybook_flutter/src/plugins/plugin.dart';
import 'package:storybook_flutter/src/story.dart';

/// Plugin that adds content as expandable list of stories.
///
/// If `sidePanel` is true, the stories are shown in a left side panel,
/// otherwise as a popup.
class ContentsPlugin extends Plugin {
  const ContentsPlugin({bool sidePanel = false})
      : super(
          icon: sidePanel ? null : _buildIcon,
          panelBuilder: sidePanel ? null : _buildPanel,
          wrapperBuilder: sidePanel ? _buildWrapper : null,
        );
}

Widget _buildIcon(BuildContext _) => const Icon(Icons.list);

Widget _buildPanel(BuildContext _) => const _Contents();

Widget _buildWrapper(BuildContext _, Widget? child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          const Material(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black12)),
              ),
              child: SizedBox(width: 250, child: _Contents()),
            ),
          ),
          Expanded(child: ClipRect(clipBehavior: Clip.hardEdge, child: child)),
        ],
      ),
    );

class _Contents extends StatefulWidget {
  const _Contents({Key? key}) : super(key: key);

  @override
  _ContentsState createState() => _ContentsState();
}

class _ContentsState extends State<_Contents> {
  @override
  Widget build(BuildContext context) {
    final grouped =
        context.watch<StoryNotifier>().stories.groupListsBy((s) => s.section);
    final sections = grouped.keys
        .where((k) => k.isNotEmpty)
        .map((k) => _buildSection(k, grouped[k]!));
    final stories = (grouped[''] ?? []).map(_buildStoryTile);

    return SafeArea(
      top: false,
      right: false,
      child: ListTileTheme(
        style: ListTileStyle.drawer,
        child: ListView(
          padding: EdgeInsets.zero,
          primary: false,
          children: [...sections, ...stories],
        ),
      ),
    );
  }

  Widget _buildStoryTile(Story story) {
    final description = story.description;

    return ListTile(
      selected: story == context.watch<StoryNotifier>().currentStory,
      title: Text(story.title),
      subtitle: description == null ? null : Text(description),
      onTap: () => context.read<StoryNotifier>().currentStoryName = story.name,
    );
  }

  Widget _buildSection(String title, Iterable<Story> stories) => ExpansionTile(
        title: Text(title),
        initiallyExpanded: stories
            .map((s) => s.name)
            .contains(context.watch<StoryNotifier>().currentStoryName),
        children: stories.map(_buildStoryTile).toList(),
      );
}
