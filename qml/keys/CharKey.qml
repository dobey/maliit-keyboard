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

AbstractKey {
    id: key

    property string panelState: "CHARACTERS"

    property int padding: 0

    width: leftSide || rightSide ? keyWidth * 2 : keyWidth

    // to be set in keyboard layouts
    property var extended; // list of extended keys
    property var extendedShifted; // list of extended keys in shifted state
    property var currentExtendedKey; // The currently highlighted extended key


    property bool noMagnifier: false
    property bool skipAutoCaps: false
    property bool switchBackFromSymbols: false

    property bool leftSide: false
    property bool rightSide: false

    /**
     * this property specifies if the key can submit its value or not (e.g. when the popover is shown, it does not commit its value)
     */

    property bool extendedKeysShown: extendedKeysSelector.enabled

    /*
     * label changes when keyboard is in shifted mode
     * extended keys change as well when shifting keyboard, typically lower-uppercase: ê vs Ê
     */
    property var activeExtendedModel: []

    // Allow to manipulate preedit if it need.
    // if allowPreeditHandler is enabled should be assigned preeditHandler.
    property bool allowPreeditHandler: false
    property var preeditHandler: null

    signal keySent(string key)

    onStateChanged: {
        if (state === "NORMAL") {
            activeExtendedModel = extended;
            annotation = activeExtendedModel && activeExtendedModel[0] ? activeExtendedModel[0] : "";
        } else if (state === "SHIFTED" || state === "CAPSLOCK") {
            activeExtendedModel = extendedShifted;
            annotation = activeExtendedModel && activeExtendedModel[0] ? activeExtendedModel[0] : "";
        }
    }

    onPressAndHold: {
        if (activeExtendedModel != undefined && activeExtendedModel[0] != "") {
                Feedback.startPressEffect();

                magnifier.shown = false
                extendedKeysSelector.enabled = true
                extendedKeysSelector.extendedKeysModel = activeExtendedModel
                extendedKeysSelector.currentlyAssignedKey = key
                var extendedKeys = extendedKeysSelector.keys;
                var middleKey = extendedKeys.length > 1 ? Math.floor(extendedKeys.length / 2) - 1: 0;
                if (extendedKeys.length > 5 && extendedKeysSelector.multirow) {
                    middleKey = extendedKeys.length - middleKey - 1;
                }
                extendedKeys[middleKey].highlight = true;
                currentExtendedKey = extendedKeys[middleKey];
        }
    }

    onReleased: {
            if (extendedKeysShown) {
                if (currentExtendedKey) {
                    currentExtendedKey.commit();
                    currentExtendedKey = null;
                } else {
                    extendedKeysSelector.closePopover();
                }
            } else {
                // Read this prior to altering autocaps
                var keyToSend = valueToSubmit;
                if (magnifier.currentlyAssignedKey == key) {
                    magnifier.shown = false;
                }

                if (!key.contains(Qt.point(mouse.x, mouse.y))) {
                    return;
                }

                if (panel.autoCapsTriggered) {
                    panel.autoCapsTriggered = false;
                }
                if (!skipAutoCaps) {
                    if (state === "SHIFTED" && panelState === "CHARACTERS")
                        setKeyState("NORMAL");
                }
                if (switchBackFromSymbols && panelState === "SYMBOLS") {
                    panelState = "CHARACTERS";
                }

                if (allowPreeditHandler && preeditHandler) {
                    preeditHandler.onKeyReleased(keyToSend, action);
                    return;
                }

                event_handler.onKeyReleased(keyToSend, action);
                keySent(valueToSubmit);
            }
    }

    onSwiped: {
        if (extendedKeysShown) {
            currentExtendedKey = extendedKeysSelector.evaluateSelectorSwipe(mouseX, mouseY);
        }
    }

    onPressed: {
        magnifier.currentlyAssignedKey = key
        magnifier.shown = !noMagnifier && Keyboard.enableMagnifier

        Feedback.keyPressed();

        event_handler.onKeyPressed(valueToSubmit, action);
    }

    Magnifier {
        id: magnifier
        x: (leftSide ? key.width - width + (width - panel.keyWidth) / 2
            : 0 - (width - panel.keyWidth) / 2)
        y: key.y - panel.keyHeight
    }
}
