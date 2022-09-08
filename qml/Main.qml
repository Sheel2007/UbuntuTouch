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

	    onClicked: shoppinglistModel.append({"name": textFieldInput.text})
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
		Text {
		     text: name
		     anchors {
			left: parent.left
			leftMargin: units.gu(2)
			verticalCenter: parent.verticalCenter
		     }
		}
	     }
	}
    }
    
    ListModel {
	id: shoppinglistModel
    }
}
