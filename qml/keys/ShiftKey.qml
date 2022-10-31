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

import MaliitKeyboard 2.0

AbstractKey {
    label: panel.state == "SYMBOLS" ? "=∆{}" : ""
    shifted: panel.state == "SYMBOLS" ? "?123" : ""
    iconNormal: "keyboard-caps-disabled-symbolic"
    iconShifted: "keyboard-caps-enabled-symbolic"
    iconCapsLock: "keyboard-caps-locked-symbolic"

    action: "shift"

    acceptDoubleClick: true

    property bool doubleClick: false;

    onStateChanged: {
        setKeyState(state);
    }

    onPressed: {
        if (doubleClick) {
            doubleClick = false;
            return;
        }
        Feedback.keyPressed();

        if (state == "NORMAL")
            state = "SHIFTED";
        else if (state == "SHIFTED")
            state = "NORMAL"
        else if (state == "CAPSLOCK")
            state = "NORMAL"
    }

    onPressAndHold: {
        if (panel.state == "SYMBOLS") {
            return;
        }

        Feedback.startPressEffect();

        state = "CAPSLOCK"
    }

    onDoubleClicked: {
        if (panel.state == "SYMBOLS") {
            return;
        }

        Feedback.keyPressed();

        state = "CAPSLOCK"
        doubleClick = true;
    }
}
