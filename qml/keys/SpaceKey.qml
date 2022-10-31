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
import QtQuick.Window 2.12
import MaliitKeyboard 2.0

import "languages.js" as Languages

AbstractKey {
    id: spaceKey

    label: " ";
    shifted: " ";

    action: "space"

    Rectangle {
        anchors.margins: 8
        anchors.fill: parent
        color: "#888888"
        radius: 8 / Screen.devicePixelRatio
        opacity: spaceKey.currentlyPressed ? 0.0 : 0.25
    }

    Label {
        anchors.centerIn: parent
        font.weight: Font.Light
        opacity: 0.6
        font.pixelSize: parent.fontSize * 0.6
        text: Languages.languageIdToName(Keyboard.activeLanguage)
        horizontalAlignment: Text.AlignHCenter
    }

    onPressAndHold: {
        fullScreenItem.prevSwipePositionX = mouse.x
        fullScreenItem.prevSwipePositionY = mouse.y
        fullScreenItem.cursorSwipe = true
    }

    onPressed: {
        Feedback.keyPressed()
        fullScreenItem.timerSwipe.stop()
    }

    onReleased: {
        if (!contains(Qt.point(mouse.x, mouse.y))) {
            return;
        }
        MaliitEventHandler.onKeyReleased(label, action)
        if (panel.state === "SYMBOLS") {
            panel.state = "CHARACTERS"
        }
    }
}
