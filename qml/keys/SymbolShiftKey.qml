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
    label: panel.state == "SYMBOLS" ? "ABC" : "?123"
    shifted: panel.state == "SYMBOLS" ? "ABC" : "?123"
    action: "symbols";

    property string keyState: "NORMAL"
    property string panelState: "CHARACTERS"

    // Internal proerty for preserving previous active keypad state
    property string __oldKeypadState: keyState

    onPressed: {
        Feedback.keyPressed();

        if (panelState == "CHARACTERS") {
            __oldKeypadState = keyState;
            setKeyState("NORMAL");
            panelState = "SYMBOLS";
        } else {
            setKeyState(__oldKeypadState);
            panelState = "CHARACTERS";
        }
    }
}
