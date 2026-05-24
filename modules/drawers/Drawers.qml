import Quickshell
import qs.services

Variants {
    model: Screens.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        Exclusions {
            screen: scope.modelData
            bar: drawerWindow.bar
        }

        ContentWindow {
            id: drawerWindow

            screen: scope.modelData
            name: "drawers"
        }
    }
}
