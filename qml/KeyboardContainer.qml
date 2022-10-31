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
import QtQuick.Window 2.0
import "languages/"
import "keys/"
import MaliitKeyboard 2.0

Item {
    id: panel

    property alias keyWidth: characterKeypadLoader.keyWidth
    property alias keyHeight: characterKeypadLoader.keyHeight

    property bool autoCapsTriggered: false
    property bool delayedAutoCaps: false

    property string activeKeypadState: "NORMAL"

    property Item lastKeyPressed // Used for determining double click validity in PressArea

    state: "CHARACTERS"

    function closeLanguageMenu()
    {
        characterKeypadLoader.closeLanguageMenu();
    }

    function closeExtendedKeys()
    {
        extendedKeysSelector.closePopover();
    }

    KeyboardPanel {
        id: characterKeypadLoader
        objectName: "characterKeyPadLoader"
        anchors.fill: parent
        model: loadKeysModel()
        Component.onCompleted: {
            if (panel.delayedAutoCaps) {
                panel.activeKeypadState = "SHIFTED";
                panel.delayedAutoCaps = false;
            } else {
                panel.activeKeypadState = "NORMAL";
            }
        }
    }

    Loader {
        id: emojiKeypadLoader
        objectName: "emojiKeypadLoader"
        anchors.fill: parent
        asynchronous: true
        active: panel.state === "EMOJI"
        source: "languages/Keyboard_emoji.qml"
    }

    ExtendedKeysSelector {
        id: extendedKeysSelector
        objectName: "extendedKeysSelector"
        anchors.fill: parent
    }

    states: [
        State {
            name: "CHARACTERS"
            PropertyChanges {
                target: characterKeypadLoader
                visible: true
            }
        },
        State {
            name: "SYMBOLS"
            PropertyChanges {
                target: characterKeypadLoader
                visible: true
            }
        },
        State {
            name: "EMOJI"
            PropertyChanges {
                target: characterKeypadLoader
                visible: false
            }
        }
    ]

    onStateChanged: {
        Keyboard.keyboardState = state
    }

    Connections {
        target: Keyboard.keyLayout
        function onKeysChanged()
        {
            characterKeypadLoader.calculateKeySize();
        }
    }

    function loadKeysModel()
    {
        if (panel.state == "SYMBOLS")
        {
            return Keyboard.keyLayout.symbols;
        }

        switch (Keyboard.contentType)
        {
            case Keyboard.NumberContentType:
            {
                return Keyboard.keyLayout.digits;
            }
            case Keyboard.FormattedNumberContentType:
            {
                return Keyboard.keyLayout.numbers;
            }
            case Keyboard.PhoneNumberContentType:
            {
                return Keyboard.keyLayout.phone;
            }
            case Keyboard.EmailContentType:
            {
                return Keyboard.keyLayout.email;
            }
            case Keyboard.UrlContentType:
            {
                return Keyboard.keyLayout.url;
            }
            default:
            {
                return Keyboard.keyLayout.keys;
            }
        }
    }
}
