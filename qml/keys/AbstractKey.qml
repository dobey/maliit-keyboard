/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtQuick.Controls 2.12

import MaliitKeyboard 2.0

Item {
    id: key

    // width and height of visible key area
    property int keyWidth: 0
    property int keyHeight: 0

    width: keyWidth
    height: keyHeight

    // to be set in keyboard layouts
    property string iconNormal
    property string iconShifted
    property string iconCapsLock
    property string label
    property string shifted
    property bool highlight: false;
    property double textCenterOffset: Device.gu(-0.15)

    property string valueToSubmit: keyLabel.text

    property alias acceptDoubleClick: keyMouseArea.acceptDoubleClick

    property string action

    property double rowMargin: fullScreenItem.landscape ? Device.rowMarginLandscape
                                                        : Device.rowMarginPortrait
    property double keyMargin: Device.keyMargins

    // These properties are used by autopilot to determine the visible
    // portion of the key to press
    readonly property double leftOffset: keyButton.anchors.leftMargin
    readonly property double rightOffset: keyButton.anchors.rightMargin

    // Scale the font so the label fits if a long word is set
    property int fontSize: (fullScreenItem.landscape ? (height / 2) : (height / 2.8))
                           * (4 / (label.length >= 2 ? (label.length <= 6 ? label.length + 2.5 : 8) : 4));
    property alias fontFamily: keyLabel.font.family

    /// annotation shows a small label in the upper right corner
    // if the annotiation property is set, it will be used. If not, the first position in extended[] list or extendedShifted[] list will
    // be used, depending on the state. If no extended/extendedShifted arrays exist, no annotation is shown
    property string annotation: ""

    /*! indicates if the key is currently pressed/down*/
    readonly property bool currentlyPressed: keyMouseArea.pressed

    signal pressed(variant mouse)
    signal released(variant mouse)
    signal pressAndHold(variant mouse)
    signal doubleClicked(variant mouse)
    signal swiped(real mouseX, real mouseY)

    // For keys which need to alter the global state of keys (normal vs shifted)
    signal setKeyState(string newState)

    // Make it possible for the visible area of the key to differ from the
    // actual key size. This allows us to extend the touch area of the bottom
    // row of keys all the way to the bottom of the keyboard, whilst
    // maintaining the same visual appearance.
    Item {
        anchors.top: parent.top
        height: key.keyHeight
        width: parent.width

        ToolButton {
            id: keyButton
            anchors.fill: parent
            anchors.leftMargin: key.leftSide ? (parent.width - key.keyWidth) + key.keyMargin : key.keyMargin
            anchors.rightMargin: key.rightSide ? (parent.width - key.keyWidth) + key.keyMargin : key.keyMargin

            // Disable hover so that highlight doesn't stick on touch screens
            hoverEnabled: false

            // Tell the ToolButton to be drawn as pressed, when pressed
            down: key.currentlyPressed && !extendedKeysSelector.enabled

            // Icon of the key
            icon.name: key.iconNormal
            icon.height: key.fontSize
            icon.width: key.fontSize

            display: label == "" ? AbstractButton.IconOnly : AbstractButton.TextOnly

            /// label of the key
            //  the label is also the value subitted to the app

            Label {
                id: keyLabel
                text: label
                font.pixelSize: key.fontSize
                font.weight: Font.Light
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.leftMargin: Device.gu(0.2)
                anchors.rightMargin: Device.gu(0.2)
                anchors.verticalCenter: parent.verticalCenter 
                anchors.verticalCenterOffset: key.textCenterOffset
                horizontalAlignment: Text.AlignHCenter
                // Avoid eliding characters that are slightly too wide (e.g. some emoji and chinese characters)
                elide: text.length <= 4 ? Text.ElideNone : Text.ElideRight
            }

            /// shows an annotation
            // used e.g. for indicating the existence of extended keys

            Label {
                id: annotationLabel

                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: Device.annotationTopMargin
                anchors.rightMargin: Device.annotationRightMargin
                font.pixelSize: key.fontSize / 2.25
                font.weight: Font.Light
            }

        }
    }

    // make sure the icon and/or labels change with the state
    state: "NORMAL"
    states: [
        State {
            name: "NORMAL"
            PropertyChanges {
                target: keyButton
                icon.name: iconNormal
            }
            PropertyChanges {
                target: keyLabel
                text: label
            }
            PropertyChanges {
                target: annotationLabel
                text: annotation
            }
        },
        State {
            name: "SHIFTED"
            extend: "NORMAL"
            PropertyChanges {
                target: keyButton
                icon.name: iconShifted ? iconShifted : iconNormal
            }
            PropertyChanges {
                target: keyLabel
                text: shifted
            }
        },
        State {
            name: "CAPSLOCK"
            extend: "SHIFTED"
            PropertyChanges {
                target: keyButton
                icon.name: iconCapsLock ? iconCapsLock : iconShifted ? iconShifted : iconNormal
            }
            PropertyChanges {
                target: keyLabel
                text: shifted
            }
        }
    ]

    MouseArea {
        id: keyMouseArea
        anchors.fill: parent

        property bool acceptDoubleClick: false

        onPressAndHold: {
            key.pressAndHold(mouse);
        }

        onPositionChanged: {
            key.swiped(mouse.x, mouse.y);
        }

        onReleased: {
            key.released(mouse);
        }

        onPressed: {
            key.pressed(mouse);
        }

        onDoubleClicked: {
            key.doubleClicked(mouse);
        }
    }
}
