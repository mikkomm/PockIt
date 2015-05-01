import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Content 0.1
import Ubuntu.Components.Popups 1.0
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../js/scripts.js" as Scripts

Item {
    id: pckthm

    function get_list() {
        Scripts.get_list();
    }

    function get_search(query) {
        Scripts.get_search(query, 'mylist');
    }

    ListModel {
        id: pockethomeitemsModel
    }

    ListView {
        id:pockethomeitems
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        property var status : 0
        property var _currentSwipedItem: null

        function _updateSwipeState(item)
        {
            if (item.swipping) {
                return
            }

            if (item.swipeState !== "Normal") {
                if (_currentSwipedItem !== item) {
                    if (_currentSwipedItem) {
                        _currentSwipedItem.resetSwipe()
                    }
                    _currentSwipedItem = item
                }
            } else if (item.swipeState !== "Normal" && _currentSwipedItem === item) {
                _currentSwipedItem = null
            }
        }

        model:pockethomeitemsModel
        delegate: ListItemWithActions {
            id: itemsDelegate
            property var removalAnimation

            width: parent.width
            height: itemtitle.height + units.gu(7)
            cheight: itemtitle.height + units.gu(5)

            leftSideAction: Action {
                id: removeAction
                iconName: "delete"
                text: i18n.tr("Remove")
                onTriggered: {
                    removalAnimation.start()
                    Scripts.mod_item(item_id, 'delete');
                }
            }

            rightSideActions: [
                Action {
                    iconName: "share"
                    text: i18n.tr("Share")
                    onTriggered: {
                        PopupUtils.open(shareDialog, pagestack, {"contentType" : ContentType.Links, "path" : url});
                    }
                },
                Action {
                    iconName: "tick"
                    text: i18n.tr("Archive")
                    onTriggered: {
                        removalAnimation.start()
                        Scripts.mod_item(item_id, 'archive')
                        archivehome.get_list();
                    }
                },
                Action {
                    iconName: "starred"
                    text: i18n.tr("Favorite")
                    property var iconColor: is_fav == 1 ? "orange" : UbuntuColors.lightGrey
                    property var is_favo: is_fav == 1 ? 1 : 0
                    onTriggered: {
                        if (is_favo == 1) {
                            Scripts.mod_item(item_id, 'unfavorite')
                            favoriteshome.get_list();
                            iconColor = UbuntuColors.lightGrey
                            is_favo = 0
                        } else {
                            Scripts.mod_item(item_id, 'favorite')
                            favoriteshome.get_list();
                            iconColor = "orange"
                            is_favo = 1
                        }
                    }
                }
            ]

            removalAnimation: SequentialAnimation {
                alwaysRunToEnd: true

                PropertyAction {
                    target: itemsDelegate
                    property: "ListView.delayRemove"
                    value: true
                }

                UbuntuNumberAnimation {
                    target: itemsDelegate
                    property: "height"
                    to: 0
                }

                PropertyAction {
                    target: itemsDelegate
                    property: "ListView.delayRemove"
                    value: false
                }
            }

            onSwippingChanged: {
                pockethomeitems._updateSwipeState(itemsDelegate)
            }

            onSwipeStateChanged: {
                pockethomeitems._updateSwipeState(itemsDelegate)
            }

            Item {
                id: delegateitem
                anchors.fill: parent
                Text {
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(2)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    width: parent.width - itemimagerect.width - units.gu(3)
                    id: itemtitle
                    text: title
                    wrapMode: Text.WordWrap
                    font.pointSize: units.gu(1.5)
                }
                Text {
                    anchors.top: itemtitle.bottom
                    anchors.topMargin: units.gu(1)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    width: parent.width - itemimagerect.width - units.gu(3)
                    id: itemdomain
                    text: domain
                    wrapMode: Text.WordWrap
                    font.pointSize: units.gu(1.1)
                }
                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(2)
                    anchors.left: itemtitle.right
                    anchors.leftMargin: units.gu(1)
                    width: image == '' ? 0 : units.gu(10)
                    height: itemtitle.height + units.gu(5)
                    id: itemimagerect
                    color: "transparent"
                    Image {
                        id: itemimage
                        width: parent.width
                        height: parent.height
                        source: image
                        clip: true
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                    }
                    Image {
                        visible: is_video == 1 ? true : false
                        anchors.centerIn: parent
                        id: videoicon
                        width: parent.width/2
                        height: width
                        source: "../img/play.png"
                        clip: true
                    }
                }
            }
            onItemClicked: {
                pagestack.push(articleView);
                Scripts.parseArticleView(url);
            }
        }
        PullToRefresh {
            refreshing: pockethomeitemsModel.count == 0 && pockethomeitems.status == 0
            onRefresh: get_list()
        }
    }

    Item {
        id: indicat
        anchors.centerIn: parent
        opacity: pockethomeitemsModel.count == 0 && pockethomeitems.status == 0 ? 1 : 0

        Behavior on opacity {
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.SlowDuration
            }
        }

        ActivityIndicator {
            id: activity
            running: true
        }
    }

    Item {
        id: noitem
        visible: pockethomeitemsModel.count == 0 && pockethomeitems.status == 1 ? true : false
        anchors.margins: units.gu(1)
        anchors.fill: parent

        Icon {
            id: noitemicon
            anchors.bottom: noitemlabel.top
            anchors.bottomMargin: units.gu(2)
            anchors.horizontalCenter: noitem.horizontalCenter
            width: units.gu(3)
            height: width
            name: "search"
            visible: pocketHome.state == "default" ? false : true
        }

        Label {
            id: noitemlabel
            anchors.centerIn: parent
            fontSize: "large"
            text: pocketHome.state == "default" ?
                      i18n.tr("<b>YOUR LIST IS EMPTY</b>") :
                      i18n.tr("<b>NO RESULTS FOUND</b>")
        }
    }
}
