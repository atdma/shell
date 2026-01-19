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
        return search.slice(`${Config.launcher.actionPrefix}clipboard `.length);
    }

    function selector(item: var): string {
        return `${item.text}`;
    }

    function reload(): void {
        fetchList.running = true;
    }

    list: entries.instances
    useFuzzy: Config.launcher.useFuzzy.clipboard
    keys: ["text"]
    weights: [1]

    Variants {
        id: entries

        ClipboardEntry {}
    }

    Process {
        id: fetchList

        running: true
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().length ? text.trim().split("\n") : [];
                const parsed = [];
                for (const line of lines) {
                    const tabIndex = line.indexOf("\t");
                    if (tabIndex === -1)
                        continue;
                    const id = line.slice(0, tabIndex).trim();
                    const value = line.slice(tabIndex + 1).trim();
                    if (!id || !value)
                        continue;
                    parsed.push({
                        id,
                        text: value
                    });
                }
                entries.model = parsed;
            }
        }
    }

    component ClipboardEntry: QtObject {
        required property var modelData
        readonly property string id: modelData.id
        readonly property string text: modelData.text

        function onClicked(list: AppList): void {
            list.visibilities.launcher = false;
            Quickshell.execDetached(["bash", "-lc", `cliphist decode ${id} | wl-copy`]);
        }
    }
}
