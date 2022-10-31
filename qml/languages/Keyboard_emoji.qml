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
import QtQuick.LocalStorage 2.0

import MaliitKeyboard 2.0

import keys 1.0
import "emoji.js" as Emoji

KeyPad {
    anchors.fill: parent

    content: c1

    QtObject {
        id: internal
        property int offset: 0
        property bool loading: true
        property int maxRecent: (c1.numberOfRows - 1) * c1.maxNrOfKeys
        property int oldVisibleIndex: -1
        property var recentEmoji: []
        property var chars
        property var db

        Component.onCompleted: {
            db = LocalStorage.openDatabaseSync("Emoji", "1.0", "Storage for emoji keyboard layout", 1000000);

            db.transaction(
                function(tx) {
                    // Create the database if it doesn't already exist
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Recent(emoji VARCHAR(16), time TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS State(contentX INTEGER, visibleIndex INTEGER)');

                    var rs = tx.executeSql('SELECT emoji FROM Recent ORDER BY time ASC');
                    for (var i = 0; i < rs.rows.length; i++) {
                        recentEmoji.push(rs.rows.item(i).emoji);
                    }
                    for (var i = 0; i < recentEmoji.length % (c1.numberOfRows - 1); i++) {
                        recentEmoji.push("");
                    }
                    chars = recentEmoji.concat(Emoji.emoji);

                    for (var i = 0; i < chars.length; i++) {
                        c1.model.append({char: chars[i]});                        
                    }

                    rs = tx.executeSql('SELECT contentX, visibleIndex FROM State');
                    if (rs.rows.length > 0) {
                        internal.oldVisibleIndex = rs.rows.item(0).visibleIndex;
                        c1.contentX = rs.rows.item(0).contentX;
                    } else {
                        tx.executeSql('INSERT INTO State VALUES(0, 0)');
                        // Start on the smiley page
                        c1.positionViewAtIndex(recentEmoji.length, GridView.Beginning)
                        updatePositionDb();
                    }
                }
            );
        }

        function jumpTo(position) {
            c1.positionViewAtIndex(position, GridView.Beginning);
            c1.startingPosition = false;
            internal.updatePositionDb();
        }

        function updatePositionDb() {
            db.transaction(
                function(tx) {
                    tx.executeSql('UPDATE State SET contentX=?, visibleIndex=?', [c1.contentX, c1.midVisibleIndex]);
                }
            );
        }

        function updateRecent(emoji) {
            internal.loading = false;
            var originalLength = recentEmoji.length;
            var position = recentEmoji.indexOf(emoji);
            c1.positionBeforeInsertion = c1.contentX;
            // If this emoji is already in the recent list we leave it alone
            if (position != -1) {
                return;
            }

            // If the list is full remove the last emoji before inserting
            if (recentEmoji.length >= maxRecent || recentEmoji[recentEmoji.length - 1] == "") {
                recentEmoji.splice(recentEmoji.length - 1, 1);
            } 

            recentEmoji.unshift(emoji);

            // Always append a column at a time
            for (var i = 0; i < recentEmoji.length % (c1.numberOfRows - 1); i++) {
                recentEmoji.push("");
            }

            // We then update the char properties in the model
            for (var i = 0; i < recentEmoji.length; i++) {
                if (i >= originalLength) {
                    c1.model.insert(i, {"char" : recentEmoji[i]});
                } else {
                    c1.model.setProperty(i, "char", recentEmoji[i]);
                }
            }

            db.transaction(
                function(tx) {
                    tx.executeSql('DELETE FROM Recent WHERE emoji = ?', emoji);
                    tx.executeSql('INSERT INTO Recent(emoji) VALUES(?)', emoji);
                    var rs = tx.executeSql('SELECT COUNT(emoji) as totalRecent FROM Recent');
                    if (rs.rows.item(0).totalRecent > maxRecent) {
                        tx.executeSql('DELETE FROM Recent ORDER BY time ASC LIMIT ?', rs.rows.item(0).totalRecent - maxRecent);
                    }
                }
            );     
        }
    }

    GridView {
        id: c1
        objectName: "emojiGrid"
        property int midVisibleIndex: indexAt(contentX + (width / 2), 0) == -1 ? internal.oldVisibleIndex : indexAt(contentX + (width / 2), 0);
        property int numberOfRows: 5
        property int maxNrOfKeys: fullScreenItem.tablet ? 12 : 10
        property int oldWidth: 0
        property int positionBeforeInsertion: 0
        property bool startingPosition: true
        anchors.top: parent.top
        anchors.bottom: categories.top
        anchors.left: parent.left
        anchors.right: parent.right
        model: ListModel { }
        flow: GridView.FlowTopToBottom
        flickDeceleration: Device.gu(500)
        snapMode: GridView.SnapToRow
        cellWidth: fullScreenItem.landscape ? panel.keyWidth * 0.7 : panel.keyWidth
        cellHeight: panel.keyHeight
        cacheBuffer: Device.gu(30)
        onContentWidthChanged: {
            // Shift view to compensate for new emoji being added
            // But only if the view has actually moved (GridView's
            // behaviour is inconsistent depending on how far away
            // from the insertion point we are in the model)
            if (!internal.loading && (positionBeforeInsertion != contentX || startingPosition)) {
                contentX += contentWidth - oldWidth;
            }
            oldWidth = contentWidth;
        }
        onMovementEnded: {
            internal.updatePositionDb();
            startingPosition = false;
        }

        Component {
            id: charDelegate
            CharKey {
                id: emojiKey
                property var emoji: null
                keyWidth: c1.cellWidth
                keyHeight: c1.cellHeight
                visible: label != ""
                label: emoji != null ? emoji.char : ""
                shifted: label
                fontFamily: "Noto Color Emoji"
                fontSize: height / 2
                noMagnifier: true
                onKeySent: {
                    internal.updateRecent(key);
                }
            }
        }

        delegate: Loader {
            // Don't load asynchronously if the user is flicking through the
            // grid, otherwise loading looks messy
            asynchronous: !c1.movingHorizontally
            sourceComponent: charDelegate
            onLoaded: {
                item.emoji = model;
            }
        }

     }

     Row {
        id: categories
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: panel.keyHeight

        //spacing: fullScreenItem.tablet ? panel.keyWidth / 5 : 0

        SymbolShiftKey {
            id: symbolShiftKey
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
            label: ""
            shifted: label
            iconNormal: "go-previous-symbolic"
            iconShifted: iconNormal
        }

        CategoryKey {
            id: recentCat
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
            label: "⏱"
            highlight: (c1.midVisibleIndex < internal.recentEmoji.length && c1.midVisibleIndex > 0)
                       || (c1.contentX == 0 && internal.recentEmoji.length > 0)
            onPressed: {
                Feedback.startPressEffect();
                internal.jumpTo(0);
            }
        }           
 
        CategoryKey {
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
            label: "😀"
            highlight: (c1.midVisibleIndex >= internal.recentEmoji.length 
                        && c1.midVisibleIndex < 540 + internal.recentEmoji.length
                        && !recentCat.highlight)
                       || c1.midVisibleIndex == -1
            onPressed: {
                Feedback.startPressEffect();
                internal.jumpTo(internal.recentEmoji.length);
                if (internal.recentEmoji.length < internal.maxRecent) {
                    c1.startingPosition = true;
                }
            }
        }

        CategoryKey {
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
            label: "🐶"
            highlight: c1.midVisibleIndex >= 540 + internal.recentEmoji.length && c1.midVisibleIndex < 701 + internal.recentEmoji.length
            onPressed: {
                Feedback.startPressEffect();
                internal.jumpTo(540 + internal.recentEmoji.length);
            }
        }

        CategoryKey {
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
            label: "🍏"
            highlight: c1.midVisibleIndex >= 701 + internal.recentEmoji.length && c1.midVisibleIndex < 786 + internal.recentEmoji.length
            onPressed: {
                Feedback.startPressEffect();
                internal.jumpTo(701 + internal.recentEmoji.length);
            }
        }

        CategoryKey {
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
            label: "🎾"
            highlight: c1.midVisibleIndex >= 786 + internal.recentEmoji.length && c1.midVisibleIndex < 931 + internal.recentEmoji.length
            onPressed: {
                Feedback.startPressEffect();
                internal.jumpTo(786 + internal.recentEmoji.length);
            }
        }

        CategoryKey {
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
            label: "🚗"
             highlight: c1.midVisibleIndex >= 931 + internal.recentEmoji.length && c1.midVisibleIndex < 1050 + internal.recentEmoji.length
            onPressed: {
                Feedback.startPressEffect();
                internal.jumpTo(931 + internal.recentEmoji.length);
            }
        }

        CategoryKey {
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
            label: "💡"
            highlight: c1.midVisibleIndex >= 1050 + internal.recentEmoji.length && c1.midVisibleIndex < 1229 + internal.recentEmoji.length
            onPressed: {
                Feedback.startPressEffect();
                internal.jumpTo(1050 + internal.recentEmoji.length);
            }
        }

        CategoryKey {
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
            label: "❤"
            highlight: c1.midVisibleIndex >= 1229 + internal.recentEmoji.length && c1.midVisibleIndex < 1512 + internal.recentEmoji.length
            onPressed: {
                Feedback.startPressEffect();
                internal.jumpTo(1229 + internal.recentEmoji.length);
            }
        }

        CategoryKey {
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
            label: "🌍"
            highlight: c1.midVisibleIndex >= 1512 + internal.recentEmoji.length
            onPressed: {
                Feedback.startPressEffect();
                internal.jumpTo(1512 + internal.recentEmoji.length);
            }
        }

        BackspaceKey {
            keyWidth: panel.keyWidth
            keyHeight: panel.keyHeight
        }
    }
}
