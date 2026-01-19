pragma ComponentBehavior: Bound

import "items"
import "services"
import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import QtQuick

GridView {
    id: root

    required property StyledTextField search
    required property PersistentProperties visibilities
    required property real maxHeight

    readonly property int minCellWidth: Math.round(Config.launcher.sizes.itemHeight * 1.4)
    readonly property int columnsCount: Math.max(1, Math.floor(width / minCellWidth))
    readonly property int rowsCount: Math.max(1, Math.ceil(count / columnsCount))

    cellWidth: width / columnsCount
    cellHeight: Math.round(Config.launcher.sizes.itemHeight * 1.6)
    implicitHeight: Math.min(maxHeight, rowsCount * cellHeight)

    clip: true
    focus: true

    model: ScriptModel {
        id: model

        onValuesChanged: root.currentIndex = 0
        values: Emoji.query(search.text)
    }

    highlight: StyledRect {
        radius: Appearance.rounding.normal
        color: Colours.palette.m3onSurface
        opacity: 0.08
    }
    highlightFollowsCurrentItem: true

    StyledScrollBar.vertical: StyledScrollBar {
        flickable: root
    }

    delegate: EmojiGridItem {
        list: root
        width: root.cellWidth
        height: root.cellHeight
    }

    onVisibleChanged: {
        if (visible)
            Emoji.reload();
    }
}
