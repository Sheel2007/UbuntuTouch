/*
 * Copyright (C) 2022  Koen Vervloesem
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * shoppinglist is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtQuick.LocalStorage 2.7

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'shoppinglist.koenvervloesem'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

	backgroundColor: UbuntuColors.graphite

    property bool selectionMode: true
	property string dbName: "ShoppingListDB"
	property string dbVersion: "1.0"
	property string dbDescription: "Database for shopping list app"
	property int dbEstimatedSize: 10000
	property var db: LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription, dbEstimatedSize)
	property string shoppingListTable: "ShoppingList"

	function initializeShoppingList() {

		db.transaction(function(tx) {
			tx.executeSql('CREATE TABLE IF NOT EXISTS ' + shoppingListTable + ' (name TEXT, selected BOOLEAN)');
			var results = tx.executeSql('SELECT rowid, name, selected FROM ' + shoppingListTable);

			//Update ListModel
			for (var i = 0; i < result.rows.length; i++) {
				shoppinglistModel.append({"rowid": results.rows.item(i).rowid,
											"name": results.rows.item(i).name,
											"selected": Boolean(results.rows.item(i).selected
											)});
				getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
			}
		})
	}

    ListModel {
        id: shoppinglistModel

        function addItem(name, selected) {
			db.transaction(function(tx) {
					var result = tx.executeSql('INSERT INTO ' + shoppingListTable + ' (name, selected) VALUES( ?, ? )', [name, selected]);
					var rowid = Number(result.insertId);
					shoppinglistModel.append({"name": name, "price": 0, "selected": selected});
					getItemPrice(shoppinglistModel.get(shoppinglistModel.count - 1));
				}
			)
        }

        function removeSelectedItems() {
			db.transaction(function(tx) {
					tx.executeSql('DELETE FROM ' + shoppingListTable + ' WHERE selected=?', [Boolean(true)]);
				}
			)


            for(var i=shoppinglistModel.count-1; i>=0; i--) {
                if(shoppinglistModel.get(i).selected)
                    shoppinglistModel.remove(i);
            }
        }

		function removeAllItems() {
			db.transaction(function(tx) {
					tx.executeSql('DELETE FROM ' + shoppingListTable);
				}
			)
			shoppinglistModel.clear();
		}

		property string itemPriceUrl: "http://192.168.1.153:5000/itemprice?itemname="

		function getItemPrice(item) {
			var xhr = new XMLHttpRequest();
			xhr.onreadystatechange = function() {
				if (xhr.readyState === XMLHttpRequest.DONE) {
					item.price = result.price;
				}
			}

			xhr.open("GET", itemPriceUrl + encodeURIComponent(item.name));
			xhr.send();
		}

		function removeItem(index) {
			var rowid = shoppinglistModel.get(index).rowid;
			db.transaction(function(tx) {
					tx.executeSql('DELETE FROM ' + shoppingListTable + ' WHERE rowid=?', [rowid]);
				}
			)
			shoppinglistModel.remove(index);
		}

		function toggleSelectionStatus(index) {
			if(root.selectionMode) {
				var rowid = shoppinglistModel.get(index).rowid;
				var selected = !shoppinglistModel.get(index).selected;

				db.transaction(function(tx) {
						tx.executeSql('UPDATE ' + shoppingListTable + ' SET selected=? WHERE rowid=?', [Boolean(selected), rowid]);
					}
				)

				shoppinglistModel.get(index).selected = selected;
				shoppinglistView.refresh();
			}
		}
    }

    Component {
        id: removeAllDialog

        OKCancelDialog {
            title: i18n.tr("Remove all items")
            text: i18n.tr("Are you sure?")
            onDoAction: shoppinglistModel.removeAllItems()
        }
    }

    Component {
        id: removeSelectedDialog

        OKCancelDialog {
            title: i18n.tr("Remove selected items")
            text: i18n.tr("Are you sure?")
            onDoAction: {
                shoppinglistModel.removeSelectedItems();
                root.selectionMode = true;
            }
            onCancelAction: root.selectionMode = true
        }   
    }

    Component {
        id: aboutDialog
        AboutDialog {}
    }

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('Shopping List')
            subtitle: i18n.tr('Never forget what to buy')

            ActionBar {
                anchors {
                    top: header.top
                    right: parent.right
                    topMargin: units.gu(1)
                    rightMargin: units.gu(1)
                }
                numberOfSlots: 1
                actions: [
                    Action {
                        iconName: "settings"
                        text: i18n.tr("Settings")
                    },
                    Action {
                        iconName: "info"
                        text: i18n.tr("About")
                        onTriggered: PopupUtils.open(aboutDialog)
                    }
                ]
            }

			StyleHints {
				foregroundColor: UbuntuColors.orange
			}
			Component.onCompleted: initializeShoppingList()
        }

        Button {
            id: buttonAdd
            anchors {
                top: header.bottom
                right: parent.right
                topMargin: units.gu(2)
                rightMargin: units.gu(2)
            }
            text: i18n.tr('Add')
            onClicked: {
                if(textFieldInput.text != "") {
                    shoppinglistModel.addItem(textFieldInput.text, false);
                    textFieldInput.text = "";
                }
            }
        }

        TextField {
            id: textFieldInput
            anchors {
                top: header.bottom
                left: parent.left
                topMargin: units.gu(2)
                leftMargin: units.gu(2)
            }
            placeholderText: i18n.tr("Shopping list item")
        }

        ListView {
            id: shoppinglistView
            anchors {
                top: textFieldInput.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                topMargin: units.gu(2)
            }
            model: shoppinglistModel

            function refresh() {
                // Refresh the list to update the selected status
                var tmp = model;
                model = null;
                model = tmp;
            }

            delegate: ListItem {
                width: parent.width
                height: units.gu(3)
                Rectangle {
                    anchors.fill: parent
                    color: index % 2 ? theme.palette.normal.selection : UbuntuColors.graphite;
                    CheckBox {
                        id: itemCheckbox
                        visible: root.selectionMode
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                        checked: shoppinglistModel.get(index).selected
                    }
                    Text {
                        id: itemText
                        text: name 
                        anchors {
                            left: root.selectionMode ? itemCheckbox.right : parent.left
                            leftMargin: root.selectionMode ? units.gu(1) : units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }               
	                }

					Text {
						text: price
						anchors {
							right: parent.right
							rightMargin: units.gu(2)
							verticalCenter: parent.verticalCenter
						}
					}


                    MouseArea {
                        anchors.fill: parent
                        onPressAndHold: root.selectionMode = true;
                        onClicked: shoppinglistModel.toggleSelectionStatus(index)
                    }
                }
                leadingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "delete"
                            onTriggered: shoppinglistModel.removeItem(index)
                        }
                    ]
                }
            }
        }

        Row {
            spacing: units.gu(1)
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                topMargin: units.gu(1)
                bottomMargin: units.gu(2)
                leftMargin: units.gu(2)
                rightMargin: units.gu(2)
            }
            Button {
                id: buttonRemoveAll
                text: i18n.tr("Remove all...")
                width: parent.width / 2 - units.gu(0.5)
                onClicked: PopupUtils.open(removeAllDialog)
            }
            Button {
                id: buttonRemoveSelected
                text: i18n.tr("Remove selected...")
                width: parent.width / 2 - units.gu(0.5)
                onClicked: PopupUtils.open(removeSelectedDialog)
            }
        }     
    }
}
