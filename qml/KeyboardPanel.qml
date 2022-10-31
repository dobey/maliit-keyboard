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

import QtQuick 2.12
import QtQuick.Layouts 1.12
import "keys/"

import MaliitKeyboard 2.0

Item {
    id: keypanel

    anchors.fill: parent

    property int keyWidth: 0
    property int keyHeight: 0

    property alias model: rowRepeater.model

    property int maxNrOfKeys: 0

    Column {
        id: col
        anchors.fill: parent
        spacing: 2

        Repeater {
            id: rowRepeater
            model: Keyboard.keyLayout.keys
            property int maxKeys: 0

            Row {
                readonly property var keyList: modelData
                readonly property int rowIndex: index
                spacing: 0

                anchors.horizontalCenter: col.horizontalCenter
                Repeater {
                    id: keyRepeater
                    model: keyList

                    Component.onCompleted: {
                        if (model.length > rowRepeater.maxKeys) {
                            rowRepeater.maxKeys = model.length;
                        }
                    }
                    
                    Loader {
                        readonly property KeyInfo key: modelData
                        readonly property bool onLeft: index == 0 && key.type == KeyInfo.Character && keyRepeater.model[numKeys].type == KeyInfo.Character
                        readonly property bool onRight: index == numKeys && key.type == KeyInfo.Character && keyRepeater.model[0].type == KeyInfo.Character
                        readonly property int numKeys: keyRepeater.model.length - 1

                        sourceComponent: {
                            switch (key.type) {
                                case KeyInfo.None:
                                {
                                    return noKey;
                                }
                                case KeyInfo.Character:
                                {
                                    return charKey;
                                }
                                case KeyInfo.Shift:
                                {
                                    return shiftKey;
                                }
                                case KeyInfo.Symbol:
                                {
                                    return symbolKey;
                                }
                                case KeyInfo.Space:
                                {
                                    return spaceKey;
                                }
                                case KeyInfo.Backspace:
                                {
                                    return backspaceKey;
                                }
                                case KeyInfo.Enter:
                                {
                                    return enterKey;
                                }
                                case KeyInfo.Emoji:
                                {
                                    return emojiKey;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    //Component.onCompleted: calculateKeySize();
    onModelChanged: calculateKeySize()
    onWidthChanged: calculateKeySize()
    onHeightChanged: calculateKeySize()

    // we don´t use a QML layout, because we want all keys to be equally sized
    function calculateKeySize() {
        maxNrOfKeys = 0;

        if (model == undefined) {
            return;
        }

        // Don't look at the final row when calculating size, as this is a special case
        for (var i = 0; i < model.length - 1; ++i)
        {
            if (col.children && col.children[i] && col.children[i].children.length - 1 > maxNrOfKeys)
            {
                maxNrOfKeys = col.children[i].children.length - 1;
            }
        }

        keyWidth = width / maxNrOfKeys;
        keyHeight = height / model.length;
    }

    // Check if the current content type is text, or numbers
    function isTextContent() {
        switch (Keyboard.contentType)
        {
            case Keyboard.NumberContentType:
            case Keyboard.FormattedNumberContentType:
            case Keyboard.PhoneNumberContentType:
            {
                return false;
            }
            default:
            {
                return true;
            }
        }
    }
    
    Component {
        id: noKey

        Item {
            width: keypanel.keyWidth
            height: keypanel.keyHeight
        }
    }

    Component {
        id: charKey

        CharKey {
            label: key.normal
            shifted: key.shifted
            extended: key.extended
            extendedShifted: key.extendedShifted

            leftSide: onLeft && keypanel.isTextContent()
            rightSide: onRight && keypanel.isTextContent()

            keyWidth: keypanel.keyWidth
            keyHeight: keypanel.keyHeight

            state: panel.activeKeypadState
            panelState: panel.state

            onPanelStateChanged: {
                panel.state = panelState;
            }

            onSetKeyState: {
                panel.activeKeypadState = newState;
            }
        }
    }

    Component {
        id: shiftKey

        ShiftKey {
            keyWidth: keypanel.keyWidth
            keyHeight: keypanel.keyHeight

            state: panel.activeKeypadState

            onSetKeyState: {
                panel.activeKeypadState = newState;
            }
        }
    }

    Component {
        id: symbolKey

        SymbolShiftKey {
            keyWidth: keypanel.keyWidth
            keyHeight: keypanel.keyHeight

            keyState: panel.activeKeypadState
            panelState: panel.state

            onPanelStateChanged: {
                panel.state = panelState;
            }

            onSetKeyState: {
                panel.activeKeypadState = newState;
            }
        }
    }

    Component {
        id: spaceKey

        SpaceKey {
            keyWidth: keypanel.width - (numKeys * keypanel.keyWidth)
            keyHeight: keypanel.keyHeight
        }
    }

    Component {
        id: backspaceKey

        BackspaceKey {
            keyWidth: keypanel.keyWidth
            keyHeight: keypanel.keyHeight
        }
    }

    Component {
        id: enterKey

        ReturnKey {
            keyWidth: keypanel.keyWidth
            keyHeight: keypanel.keyHeight
        }
    }

    Component {
        id: emojiKey

        LanguageKey {
            keyWidth: keypanel.keyWidth
            keyHeight: keypanel.keyHeight

            onShowLanguageMenu: {
                languageMenu.open();
            }
        }
    }

    LanguageMenu {
        id: languageMenu
        objectName: "languageMenu"
        anchors.centerIn: parent
        height: contentHeight > parent.height ? parent.height : contentHeight
    }

    function closeLanguageMenu()
    {
        languageMenu.close();
    }
}
