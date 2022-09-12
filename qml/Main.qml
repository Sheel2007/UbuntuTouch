/*
 * Copyright (C) 2022  Sheel Shah
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * example is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Ubuntu.Components.Popups 1.3

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'example.sheelshah'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    backgroundColor: UbuntuColors.graphite

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('Shopping List')
	    subtitle: i18n.tr('Never forget what to buy')
	    
	    ActionBar {
		anchors {
		     top: parent.top
		     right: parent.right
		     topMargin: units.gu(1)
		     rightMargin: units.gu(1)
		}
		numberOfSlots: 2
		actions: [
		     Action {
			iconName: "settings"
			text: i18n.tr("Settings")
		     },
		     Action {
			iconName: "info"
			onTriggered: PopupUtils.open(aboutDialog)
			text: i18n.tr("About")
		     }
		]
	     }

	    StyleHints {
	    	foregroundColor: UbuntuColors.orange
	    }
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
		if (textFieldInput.text != "") {
		     shoppinglistModel.addItem(textFieldInput.text)
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
	     placeholderText: i18n.tr('Shopping list item')
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

	     delegate: ListItem {
		width: parent.width
		height: units.gu(3)
		Rectangle {
		     anchors.fill: parent
		     color: {
			if(index % 2)
			     return theme.palette.normal.selection;
			else
			     return UbuntuColors.graphite;
		     }
		     
		     Text {
			text: name
		     }
		}
		
		leadingActions: ListItemActions {
		     actions: [
			Action {
			     iconName: "delete"
			     onTriggered: shoppinglistModel.remove(index)
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
	     	text: i18n.tr('Remove all...')
	     	width: parent.width / 2 - units.gu(0.5)
		onClicked: PopupUtils.open(removeAllDialog)
	     }
	     Button {
	     	id: buttonRemoveSelected
	     	text: i18n.tr('Remove selected...')
	     	width: parent.width / 2 - units.gu(0.5)
		onClicked: PopupUtils.open(removeSelectedDialog)
	     }
	}
	
	Component {
	     id: removeAllDialog
	
	     OKCancelDialog {
		title: i18n.tr('Remove all items')
		text: i18n.tr('Are you sure?')
		onDoAction: console.log('Remove all items')
	     }
	}

	Component {
	     id: removeSelectedDialog
	     
	     OKCancelDialog {
		title: i18n.tr('Remove selected items')
		text: i18n.tr('Are you sure?')
		onDoAction: console.log('Remove selected items')
	     }
	}
    }
    
    ListModel {
	id: shoppinglistModel

	function addItem(name) {
	     shoppinglistModel.append({"name": name})
	}
    }

    Component {
	id: aboutDialog
	AboutDialog {}
	
    }
}
