import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Content 0.1
import Ubuntu.Components.Popups 1.0
import QtQuick.LocalStorage 2.0
import Ubuntu.Connectivity 1.0
import com.canonical.Oxide 1.0 as Oxide
import QtMultimedia 5.0
import "components"
import "js/scripts.js" as Scripts

MainView {
    id: mainView
    objectName: "mainView"

    applicationName: "com.ubuntu.developer.turan.mahmudov.pocket"

    automaticOrientation: true

    useDeprecatedToolbar: false

    anchorToKeyboard: true

    width: units.gu(50)
    height: units.gu(75)

    // Properties
    property string consumer_key: "37879-9a829576cdc1d9842620f694"

    actions: [
        Action {
            id: searchAction
            text: i18n.tr("Search")
            iconName: "search"
            onTriggered: {

            }
        }
    ]

    // Share
    Connections {
        target: ContentHub
        onShareRequested: {
            var title = transfer.items[0]['title'];
            var url = transfer.items[0]['url'];

            Scripts.add_item(url, title);
        }
    }

    // Network
    Connections {
        target: NetworkingStatus
        onStatusChanged: {
            if (NetworkingStatus.Offline)
                home()
            if (NetworkingStatus.Connecting)
                console.log("Status: Connecting")
            if (NetworkingStatus.Online)
                home()
        }
    }

    // Share
    Component {
        id: shareComponent
        ContentItem { }
    }
    Component {
        id: shareDialog
        ContentShareDialog { }
    }

    // Home
    function home() {
        // Header line
        var component = Qt.createComponent("components/HeaderAreaLine.qml")
        var header = component.createObject(pagestack.header)

        // Chech DB
        Scripts.initializeUser();

        if (NetworkingStatus.online) {
            // Check user
            if (Scripts.getKey('access_token')) {
                pagestack.clear();
                pagestack.push(tabs);
                pockethome.get_list();
            } else {
                // First obtain a request token
                Scripts.get_request_token();
            }
        } else {
            pagestack.clear();
            pagestack.push(networkPage);
        }
    }

    PageStack {
        id: pagestack
        Component.onCompleted: home()

        Tabs {
            id: tabs
            Tab {
                title: i18n.tr("My List")
                page: Page {
                    id: pocketHome
                    title: i18n.tr("PockIt")
                    visible: true
                    state: "default"
                    states: [
                        PageHeadState {
                            name: "default"
                            head: pocketHome.head
                            actions: Action {
                                iconName: "search"
                                onTriggered: pocketHome.state = "search"
                            }
                        },
                        PageHeadState {
                            id: headerState
                            name: "search"
                            head: pocketHome.head
                            backAction: Action {
                                id: leaveSearchAction
                                text: "back"
                                iconName: "back"
                                onTriggered: {
                                    pocketHome.state = "default"
                                    pockethome.get_list();
                                }
                            }
                            contents: TextField {
                                id: searchField
                                anchors {
                                    right: parent.right
                                    rightMargin: units.gu(2)
                                }
                                hasClearButton: true
                                inputMethodHints: Qt.ImhNoPredictiveText
                                placeholderText: i18n.tr("Search by title or URL")
                                onVisibleChanged: {
                                    if (visible) {
                                        forceActiveFocus()
                                    }
                                }
                                onAccepted: {
                                    pockethome.get_search(searchField.text);
                                }
                            }
                        }
                    ]

                    PocketHome {
                        id:pockethome
                        anchors.fill:parent
                    }
                }
            }
            Tab {
                title: i18n.tr("Favorites")
                page: Page {
                    id: favHome
                    title: i18n.tr("Favorites")
                    state: "default"
                    states: [
                        PageHeadState {
                            name: "default"
                            head: favHome.head
                            actions: Action {
                                iconName: "search"
                                onTriggered: favHome.state = "search"
                            }
                        },
                        PageHeadState {
                            id: fheaderState
                            name: "search"
                            head: favHome.head
                            backAction: Action {
                                id: fleaveSearchAction
                                text: "back"
                                iconName: "back"
                                onTriggered: {
                                    favHome.state = "default"
                                    favoriteshome.get_list();
                                }
                            }
                            contents: TextField {
                                id: fsearchField
                                anchors {
                                    right: parent.right
                                    rightMargin: units.gu(2)
                                }
                                hasClearButton: true
                                inputMethodHints: Qt.ImhNoPredictiveText
                                placeholderText: i18n.tr("Search by title or URL")
                                onVisibleChanged: {
                                    if (visible) {
                                        forceActiveFocus()
                                    }
                                }
                                onAccepted: {
                                    favoriteshome.get_search(fsearchField.text);
                                }
                            }
                        }
                    ]

                    FavoritesHome {
                        id:favoriteshome
                        anchors.fill:parent
                        Component.onCompleted: {
                            get_list();
                        }
                    }
                }
            }
            Tab {
                title: i18n.tr("Archive")
                page: Page {
                    id: archiveHome
                    title: i18n.tr("Archive")
                    state: "default"
                    states: [
                        PageHeadState {
                            name: "default"
                            head: archiveHome.head
                            actions: Action {
                                iconName: "search"
                                onTriggered: archiveHome.state = "search"
                            }
                        },
                        PageHeadState {
                            id: aheaderState
                            name: "search"
                            head: archiveHome.head
                            backAction: Action {
                                id: aleaveSearchAction
                                text: "back"
                                iconName: "back"
                                onTriggered: {
                                    archiveHome.state = "default"
                                    archivehome.get_list();
                                }
                            }
                            contents: TextField {
                                id: asearchField
                                anchors {
                                    right: parent.right
                                    rightMargin: units.gu(2)
                                }
                                hasClearButton: true
                                inputMethodHints: Qt.ImhNoPredictiveText
                                placeholderText: i18n.tr("Search by title or URL")
                                onVisibleChanged: {
                                    if (visible) {
                                        forceActiveFocus()
                                    }
                                }
                                onAccepted: {
                                    archivehome.get_search(asearchField.text);
                                }
                            }
                        }
                    ]

                    ArchiveHome {
                        id:archivehome
                        anchors.fill:parent
                        Component.onCompleted: {
                            get_list();
                        }
                    }
                }
            }
        }
    }

    Page {
        id: networkPage
        visible: false
        title: i18n.tr("Network Status")
        Column {
            anchors.centerIn: parent
            Icon {
                id: networkIcon
                anchors.horizontalCenter: networkLabel.horizontalCenter
                width: units.gu(3)
                height: width
                name: "cancel"
            }

            Item {
                width: parent.width
                height: units.gu(2)
            }

            Label {
                id: networkLabel
                text: NetworkingStatus.online ? i18n.tr("<b>ONLINE</b>") : i18n.tr("<b>OFFLINE</b>")
                fontSize: "large"
            }
        }
    }

    Page {
        id: articleView
        visible: false
        title: " "

        property var url
        property var ititle
        property var view

        head.actions: [
            Action {
                id: external
                enabled: articleView.url != ''
                text: i18n.tr("External")
                iconName: "external-link"
                onTriggered: {
                    Qt.openUrlExternally(articleView.url)
                }
            },
            Action {
                id: switchToWebView
                enabled: articleView.url != ''
                text: articleView.view == 'article' ? i18n.tr("Web View") : i18n.tr("Article View")
                iconSource: articleView.view == 'article' ? "img/webView.svg" : "img/articleView.svg"
                onTriggered: {
                    if (articleView.view == 'article') {
                        articleBody.url = articleView.url;
                        articleView.view = 'web';
                    } else {
                        Scripts.parsePageUrl(articleView.url);
                    }
                }
            },
            Action {
                id: refresh
                enabled: articleView.url != ''
                text: i18n.tr("Refresh")
                iconName: "reload"
                onTriggered: {
                    if (articleView.view == 'article') {
                        Scripts.parseArticleView(articleView.url);
                    } else {
                        articleBody.url = articleView.url;
                    }
                }
            },
            /*Action {
                id: listen
                text: i18n.tr("Listen (TTS)")
                iconSource: "img/listen.svg"
                onTriggered: {
                }
            },
            */
            Action {
                id: displaySettings
                text: i18n.tr("Display Settings")
                iconSource: "img/displaySettings.png"
                onTriggered: {
                    PopupUtils.open(stylesComponent, mainView)
                }
            }
        ]

        Oxide.WebView {
            id: articleBody
            anchors.fill: parent
            // Ignore any navigation and instead open the browser
            onNavigationRequested: {
                request.action = Oxide.NavigationRequest.ActionReject;
                Qt.openUrlExternally(request.url);
            }
        }
    }

    Component {
        id: stylesComponent

        Dialog {
            id: stylesDialog
            property real labelwidth: units.gu(10)

            OptionSelector {
                id: colorSelector
                onSelectedIndexChanged: {

                }
                selectedIndex: Scripts.getKey("backgroundColor") == "#ffffff" ? 0 : 1
                model: colorModel
                showDivider: false

                delegate: OptionSelectorDelegate {
                    showDivider: false
                    text: i18n.tr(name)
                }
            }

            ListModel {
                id: colorModel
                ListElement {
                    name: "Light"
                    foreground: "#000000"
                    background: "#ffffff"
                }
                ListElement {
                    name: "Dark"
                    foreground: "#ffffff"
                    background: "#242423"
                }
            }

            OptionSelector {
                id: fontSelector
                onSelectedIndexChanged: {

                }
                selectedIndex: Scripts.getKey("font") == "Ubuntu Light" ? 0
                                                                        : Scripts.getKey("font") == "Arial" ? 1 : 2
                model: fontModel
                showDivider: false

                delegate: OptionSelectorDelegate {
                    showDivider: false
                    text: i18n.tr(name)
                }
            }

            ListModel {
                id: fontModel
                ListElement {
                    name: "Ubuntu Light"
                }
                ListElement {
                    name: "Arial"
                }
                ListElement {
                    name: "Times New Roman"
                }
            }

            Row {
                Label {
                    text: i18n.tr("Font Size")
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    width: labelwidth
                    height: fontScaleSlider.height
                }

                Slider {
                    id: fontScaleSlider
                    width: parent.width - labelwidth
                    minimumValue: 1
                    maximumValue: 6
                    value: reFormatValue(Scripts.getKey("fontSize"))
                    function reFormatValue(v) {
                        var data = {"":0, "xx-small":1, "x-small":2, "small":3, "medium":4, "large":5, "x-large":6};
                        return data[v];
                    }
                    function formatValue(v) {
                        return ["", "xx-small", "x-small", "small", "medium", "large", "x-large"][Math.round(v)]
                    }
                    onValueChanged: {

                    }
                }
            }

            Button {
                text: i18n.tr("Save")
                color: UbuntuColors.orange
                onClicked: {
                    Scripts.setKey("foregroundColor", colorModel.get(colorSelector.selectedIndex).foreground);
                    Scripts.setKey("backgroundColor", colorModel.get(colorSelector.selectedIndex).background);
                    Scripts.setKey("font", fontModel.get(fontSelector.selectedIndex).name);
                    Scripts.setKey("fontSize", fontScaleSlider.formatValue(fontScaleSlider.value));
                    if (articleView.view == 'article') {
                        Scripts.parseArticleView(articleView.url);
                    }
                    PopupUtils.close(stylesDialog)
                }
            }

            Button {
                text: i18n.tr("Close")
                onClicked: PopupUtils.close(stylesDialog)
            }
        }
    }
}

