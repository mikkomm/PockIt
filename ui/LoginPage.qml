import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Content 0.1
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Web 0.2
import "../js/scripts.js" as Scripts

Page {
    id: webPage
    title: i18n.tr("Login")

    Item {
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        WebView {
            id: webView

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height

            // the redirect_uri can be any site
            property string redirect_uri : "https://api.github.com/zen"
            property var request_token : Scripts.getKey('request_token');

            url: "https://getpocket.com/auth/authorize?request_token="+request_token+"&redirect_uri="+encodeURIComponent(redirect_uri)

            onUrlChanged: {
                console.log(url);
                if (url == redirect_uri || url.toString().substring(0, 46) == "https://accounts.google.com/o/oauth2/approval?") {
                    Scripts.get_access_token();
                }
            }
            onLoadingChanged: {
                if (webView.lastLoadFailed) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to authenticate to Pocket. Check your connection and firewall settings."), pagestack.pop)
                }
            }
        }

        UbuntuShape {
            anchors.centerIn: parent
            width: column.width + units.gu(4)
            height: column.height + units.gu(4)
            color: Qt.rgba(0.2,0.2,0.2,0.8)
            opacity: webView.loading ? 1 : 0

            Behavior on opacity {
                UbuntuNumberAnimation {
                    duration: UbuntuAnimation.SlowDuration
                }
            }
            Column {
                id: column
                anchors.centerIn: parent
                spacing: units.gu(1)

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    fontSize: "large"
                    text: webView.loading ? i18n.tr("Loading...")
                    : i18n.tr("Success!")
                }

                ProgressBar {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: units.gu(30)
                    maximumValue: 100
                    minimumValue: 0
                    value: webView.loadProgress
                }
            }
        }
    }
}
