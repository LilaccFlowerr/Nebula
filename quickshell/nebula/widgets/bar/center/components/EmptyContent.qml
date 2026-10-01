import QtQuick
import QtQuick.Layouts
import qs.services
import qs.theme

RowLayout {
    spacing: Theme.spacing.sm

    Text {
        text: SystemInfo.osLogo
        font.family: Theme.font.logos
        font.pixelSize: Theme.button.iconSize
        color: Colors.textOnSurface
    }

    Text {
        text: Time.date
        color: Colors.textOnSurface
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
        font.weight: Font.DemiBold
    }
}
