pragma Singleton

import ".."
import qs.config
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Searcher {
    id: root

    function transformSearch(search: string): string {
        const prefix = `${Config.launcher.actionPrefix}emoji `;
        return search.startsWith(prefix) ? search.slice(prefix.length) : search;
    }

    function reload(): void {
        emojiFile.reload();
    }

    function loadEmojis(raw: string): void {
        try {
            const parsed = JSON.parse(raw);
            const items = Array.isArray(parsed) ? parsed : [];
            const mapped = [];
            for (const item of items) {
                if (!item)
                    continue;

                const emoji = item.emoji ?? "";
                if (!emoji)
                    continue;

                const name = item.name ?? "";
                const group = item.group ?? "";
                const subgroup = item.subgroup ?? "";
                const keywords = item.keywords ?? [];
                const category = item.category ?? (group && subgroup ? `${group} / ${subgroup}` : (group || subgroup || qsTr("Other")));

                mapped.push({
                    emoji,
                    name,
                    group,
                    subgroup,
                    category,
                    keywords
                });
            }
            entries.model = mapped;
        } catch (e) {
            entries.model = [];
        }
    }

    list: entries.instances
    useFuzzy: Config.launcher.useFuzzy.emoji
    keys: ["emoji", "name", "keywords", "category", "group", "subgroup"]
    weights: [0.15, 0.35, 0.25, 0.15, 0.05, 0.05]

    Variants {
        id: entries

        EmojiEntry {}
    }

    FileView {
        id: emojiFile

        path: Qt.resolvedUrl(`${Quickshell.shellDir}/assets/emoji.json`)
        watchChanges: true
        onLoaded: root.loadEmojis(text())
        onFileChanged: reload()
        onLoadFailed: entries.model = []
    }

    component EmojiEntry: QtObject {
        required property var modelData
        readonly property string emoji: modelData.emoji ?? ""
        readonly property string name: modelData.name ?? ""
        readonly property string category: modelData.category ?? ""
        readonly property list<string> keywords: modelData.keywords ?? []

        function onClicked(list: AppList): void {
            if (!emoji)
                return;

            Quickshell.clipboardText = emoji;
            if (list?.visibilities)
                list.visibilities.launcher = false;
        }
    }
}
