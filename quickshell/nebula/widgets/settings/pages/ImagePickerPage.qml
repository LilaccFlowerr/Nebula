import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: page

    signal navigate(string target)

    function choose(path) {
        if (GlobalStates.pickFor === "logo") {
            GlobalStates.pickFor = "";
            Settings.bar.logoImage = path;
            navigate("section:left");
            return;
        }
        if (Widgets.replacing !== "") {
            const id = Widgets.replacing;
            Widgets.replacing = "";
            Widgets.update(id, { source: path });
            navigate("widget:" + id);
            return;
        }
        navigate("widget:" + Widgets.add("image", { source: path }));
    }

    spacing: Theme.spacing.lg

    ImageBrowser {
        Layout.fillWidth: true
        onChosen: path => page.choose(path)
    }
}
