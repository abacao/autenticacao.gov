/*-****************************************************************************

 * Copyright (C) 2017-2019 Adriano Campos - <adrianoribeirocampos@gmail.com>
 * Copyright (C) 2017 André Guerreiro - <aguerreiro1985@gmail.com>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.0
import QtGraphicalEffects 1.0

/* Constants imports */
import "../../scripts/Constants.js" as Constants
import "../../components" as Components

// Work around to QTCREATORBUG-18321
import QtQuick.Templates 2.0 as T

Item {
    anchors.fill: parent

    property variant filesArray: []
    property bool fileLoaded: false
    property alias propertyFileDialog: fileDialog
    property alias propertyBusyIndicator: busyIndicator
    property alias propertyMouseAreaPreCustom: mouseAreaPreCustom
    property alias propertyButtonAdd: buttonAdd
    property alias propertyButtonRemove: buttonRemove
    property alias propertyDropArea: dropArea
    property alias propertyRadioButtonDefault: radioButtonDefault
    property alias propertyRadioButtonCustom: radioButtonCustom

    property real propertySigLineHeight: rectPreDefault.height * 0.1

    property alias propertySigReasonText: sigReasonText
    property alias propertySigSignedByText: sigSignedByText
    property alias propertySigSignedByNameText: sigSignedByNameText
    property alias propertySigNumIdText: sigNumIdText
    property alias propertySigDateText: sigDateText
    property alias propertySigLocationText: sigLocationText

    property alias propertySigReasonTextCustom: sigReasonTextCustom
    property alias propertySigSignedByTextCustom: sigSignedByTextCustom
    property alias propertySigSignedByNameTextCustom: sigSignedByNameTextCustom
    property alias propertySigNumIdTextCustom: sigNumIdTextCustom
    property alias propertySigDateTextCustom: sigDateTextCustom
    property alias propertySigLocationTextCustom: sigLocationTextCustom

    property alias propertySigImg: dragSigImage
    property alias propertySigWaterImg: dragSigWaterImage
    property alias propertySigWaterImgCustom: dragSigWaterImageCustom
    property alias propertyImagePreCustom: imagePreCustom

    property alias propertyCheckBoxNumId: checkboxNumId
    property alias propertyCheckBoxNumId2: checkboxNumId2
    property alias propertyCheckBoxDate: checkboxDate
    property alias propertyCheckBoxDate2: checkboxDate2

    BusyIndicator {
        id: busyIndicator
        running: false
        anchors.centerIn: parent
        // BusyIndicator should be on top of all other content
        z: 1
    }

    Item {
        id: rowMain
        width: parent.width
        height: parent.height

        T.ButtonGroup {
            id: radioGroup
        }

        Item {
            id: rectTop
            width: parent.width
            height: parent.height * 0.5 - ((Constants.HEIGHT_BOTTOM_COMPONENT
                                            + Constants.SIZE_ROW_V_SPACE) * 0.5)
            anchors.leftMargin: Constants.SIZE_ROW_H_SPACE

            DropShadow {
                anchors.fill: rectPreDefault
                horizontalOffset: Constants.FORM_SHADOW_H_OFFSET
                verticalOffset: Constants.FORM_SHADOW_V_OFFSET
                radius: Constants.FORM_SHADOW_RADIUS
                samples: Constants.FORM_SHADOW_SAMPLES
                color: Constants.COLOR_FORM_SHADOW
                source: rectPreDefault
                spread: Constants.FORM_SHADOW_SPREAD
                opacity: Constants.FORM_SHADOW_OPACITY_FORM_EFFECT
            }
            RectangularGlow {
                anchors.fill: rectPreDefault
                glowRadius: Constants.FORM_GLOW_RADIUS
                spread: Constants.FORM_GLOW_SPREAD
                color: Constants.COLOR_FORM_GLOW
                cornerRadius: Constants.FORM_GLOW_CORNER_RADIUS
                opacity: Constants.FORM_GLOW_OPACITY_FORM_EFFECT
            }

            RadioButton {
                id: radioButtonDefault
                text: qsTranslate("PageDefinitionsSignature",
                                  "STR_CUSTOM_SIGN_TITLE")
                T.ButtonGroup.group: radioGroup
                checked: true
                opacity: enabled ? 1.0 : Constants.OPACITY_SIGNATURE_TEXT_DISABLED

                contentItem: Text {
                    text: radioButtonDefault.text
                    font.family: lato.name
                    font.pixelSize: radioButtonDefault.activeFocus
                                    ? Constants.SIZE_TEXT_LABEL_FOCUS
                                    : Constants.SIZE_TEXT_LABEL
                    font.bold: radioButtonDefault.activeFocus
                    color: Constants.COLOR_TEXT_LABEL
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: radioButtonDefault.indicator.width + radioButtonDefault.spacing
                }
                KeyNavigation.tab: checkboxNumId
                KeyNavigation.down: checkboxNumId
                KeyNavigation.right: checkboxNumId
                KeyNavigation.backtab: buttonAdd
                KeyNavigation.up: buttonAdd
                Keys.onEnterPressed: toggleRadio(radioButtonDefault)
                Keys.onReturnPressed: toggleRadio(radioButtonDefault)
            }

            Rectangle {
                id: rectPreDefault
                width: parent.width
                height: parent.height - radioButtonDefault.height
                color: "white"
                anchors.top: radioButtonDefault.bottom

                Item {
                    anchors.fill: rectPreDefault
                    opacity: radioButtonDefault.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                    clip:true
                    Text {
                        id: sigReasonText
                        font.pixelSize: propertySigLineHeight * 0.8
                        font.italic: true
                        height: propertySigLineHeight
                        width: parent.width - 2 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        font.family: lato.name
                        color: Constants.COLOR_TEXT_LABEL
                        text: ""
                        anchors.topMargin: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                    }
                    Image {
                        id: dragSigWaterImage
                        height: propertySigLineHeight * 3
                        width: parent.width * 0.15
                        anchors.top: sigReasonText.bottom
                        anchors.topMargin: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                    }
                    CheckBox {
                        id: checkboxName
                        text: ""
                        height: propertySigLineHeight
                        visible: true
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.capitalization: Font.MixedCase
                        font.bold: activeFocus
                        anchors.top: sigReasonText.bottom
                        anchors.topMargin: -5
                        Accessible.role: Accessible.CheckBox
                        Accessible.name: text
                        checked: true
                        enabled: false
                        opacity: radioButtonDefault.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                    }
                    Text {
                        id: sigSignedByText
                        font.pixelSize: propertySigLineHeight * 0.8
                        height: propertySigLineHeight
                        font.family: lato.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigReasonText.bottom
                        anchors.left: checkboxName.right
                        text: ""
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                    }
                    Text {
                        id: sigSignedByNameText
                        font.pixelSize: propertySigLineHeight * 0.8
                        height: propertySigLineHeight
                        width: parent.width - sigSignedByText.paintedWidth - 3 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        clip: true
                        font.family: lato.name
                        font.bold: true
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigReasonText.bottom
                        anchors.left: sigSignedByText.right
                        text: ""
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                    }
                    CheckBox {
                        id: checkboxNumId
                        text: ""
                        height: propertySigLineHeight
                        visible: true
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.capitalization: Font.MixedCase
                        font.bold: activeFocus
                        anchors.top: sigSignedByText.bottom
                        anchors.topMargin: -5
                        Accessible.role: Accessible.CheckBox
                        Accessible.name: text
                        enabled: radioButtonDefault.checked
                        opacity: radioButtonDefault.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                        KeyNavigation.tab: checkboxDate
                        KeyNavigation.down: checkboxDate
                        KeyNavigation.right: checkboxDate
                        KeyNavigation.backtab: radioButtonDefault
                        KeyNavigation.up: radioButtonDefault
                        Keys.onEnterPressed: checkboxNumId.checked = !checkboxNumId.checked
                        Keys.onReturnPressed: checkboxNumId.checked = !checkboxNumId.checked
                    }

                    Text {
                        id: sigNumIdText
                        font.pixelSize: propertySigLineHeight * 0.8
                        height: propertySigLineHeight
                        width: parent.width - 2 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        clip: true
                        font.family: lato.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigSignedByText.bottom
                        anchors.left: checkboxNumId.right
                        text: ""
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                    }
                    CheckBox {
                        id: checkboxDate
                        text: ""
                        height: propertySigLineHeight
                        visible: true
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.capitalization: Font.MixedCase
                        font.bold: activeFocus
                        anchors.top: sigNumIdText.bottom
                        anchors.topMargin: -5
                        Accessible.role: Accessible.CheckBox
                        Accessible.name: text
                        enabled: radioButtonDefault.checked
                        opacity: radioButtonDefault.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                        KeyNavigation.tab: radioButtonCustom
                        KeyNavigation.down: radioButtonCustom
                        KeyNavigation.right: radioButtonCustom
                        KeyNavigation.backtab: checkboxNumId
                        KeyNavigation.up: checkboxNumId
                        Keys.onEnterPressed: checkboxDate.checked = !checkboxDate.checked
                        Keys.onReturnPressed: checkboxDate.checked = !checkboxDate.checked
                    }
                    Text {
                        id: sigDateText
                        font.pixelSize: propertySigLineHeight * 0.8
                        height: propertySigLineHeight
                        width: parent.width - 2 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        clip: true
                        font.family: lato.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigNumIdText.bottom
                        anchors.left: checkboxDate.right
                        visible: true
                    }
                    Text {
                        id: sigLocationText
                        font.pixelSize: propertySigLineHeight * 0.8
                        height: propertySigLineHeight
                        width: parent.width - 2 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        clip: true
                        font.family: lato.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigDateText.bottom
                        anchors.topMargin: 5
                        text: ""
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                    }

                    Image {
                        id: dragSigImage
                        height: parent.height * 0.25
                        width: parent.width * 0.5
                        anchors.top: sigLocationText.bottom
                        anchors.topMargin: parent.height * 0.1
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                        mipmap: true
                    }
                }
            }
        }

        Item {
            id: rectBottom
            width: parent.width
            height: parent.height * 0.5 - ((Constants.HEIGHT_BOTTOM_COMPONENT
                                            + Constants.SIZE_ROW_V_SPACE) * 0.5)
                    + Constants.HEIGHT_BOTTOM_COMPONENT
            anchors.top: rectTop.bottom
            anchors.topMargin: Constants.SIZE_ROW_V_SPACE

            FileDialog {
                id: fileDialog
                title: qsTranslate("Popup File", "STR_POPUP_FILE_INPUT")
                folder: shortcuts.home
                modality: Qt.WindowModal
                selectMultiple: false
                nameFilters: ["Image files (*.bmp *.jpeg *.jpg *.png)", "All files (*)"]
                Component.onCompleted: visible = false
            }
            DropShadow {
                anchors.fill: rectPreCustom
                horizontalOffset: Constants.FORM_SHADOW_H_OFFSET
                verticalOffset: Constants.FORM_SHADOW_V_OFFSET
                radius: Constants.FORM_SHADOW_RADIUS
                samples: Constants.FORM_SHADOW_SAMPLES
                color: Constants.COLOR_FORM_SHADOW
                source: rectPreCustom
                spread: Constants.FORM_SHADOW_SPREAD
                opacity: Constants.FORM_SHADOW_OPACITY_FORM_EFFECT
            }
            RectangularGlow {
                anchors.fill: rectPreCustom
                glowRadius: Constants.FORM_GLOW_RADIUS
                spread: Constants.FORM_GLOW_SPREAD
                color: Constants.COLOR_FORM_GLOW
                cornerRadius: Constants.FORM_GLOW_CORNER_RADIUS
                opacity: Constants.FORM_GLOW_OPACITY_FORM_EFFECT
            }

            RadioButton {
                id: radioButtonCustom
                text: qsTranslate("PageDefinitionsSignature",
                                  "STR_CUSTOM_SIGN_CUSTOM_TITLE")
                T.ButtonGroup.group: radioGroup
                font.pixelSize: Constants.SIZE_TEXT_LABEL
                enabled: fileLoaded
                opacity: enabled ? 1.0 : Constants.OPACITY_SIGNATURE_TEXT_DISABLED

                contentItem: Text {
                    text: radioButtonCustom.text
                    font.family: lato.name
                    font.pixelSize: radioButtonCustom.activeFocus
                                    ? Constants.SIZE_TEXT_LABEL_FOCUS
                                    : Constants.SIZE_TEXT_LABEL
                    font.bold: radioButtonCustom.activeFocus
                    color: Constants.COLOR_TEXT_LABEL
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: radioButtonCustom.indicator.width + radioButtonCustom.spacing
                }
                KeyNavigation.tab: checkboxNumId2
                KeyNavigation.down: checkboxNumId2
                KeyNavigation.right: checkboxNumId2
                KeyNavigation.backtab: checkboxDate
                KeyNavigation.up: checkboxDate
                Keys.onEnterPressed: toggleRadio(radioButtonCustom)
                Keys.onReturnPressed: toggleRadio(radioButtonCustom)
            }
            Rectangle {
                id: rectPreCustom
                width: parent.width
                height: parent.height - radioButtonCustom.height - Constants.HEIGHT_BOTTOM_COMPONENT
                color: "white"
                anchors.top: radioButtonCustom.bottom

                Item {
                    anchors.fill: rectPreCustom
                    clip: true
                    DropArea {
                        id: dropArea
                        anchors.fill: parent
                        z: 1
                    }

                    Text {
                        id: sigReasonTextCustom
                        font.pixelSize: propertySigLineHeight * 0.8
                        font.italic: true
                        height: propertySigLineHeight
                        width: parent.width - 2 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        font.family: lato.name
                        color: Constants.COLOR_TEXT_LABEL
                        text: ""
                        anchors.topMargin: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                        opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                    }
                    Image {
                        id: dragSigWaterImageCustom
                        height: propertySigLineHeight * 3
                        width: parent.width * 0.15
                        anchors.top: sigReasonTextCustom.bottom
                        anchors.topMargin: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                        opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                    }
                    CheckBox {
                        id: checkboxName2
                        text: ""
                        height: propertySigLineHeight
                        visible: true
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.capitalization: Font.MixedCase
                        font.bold: activeFocus
                        anchors.top: sigReasonTextCustom.bottom
                        anchors.topMargin: -5
                        Accessible.role: Accessible.CheckBox
                        Accessible.name: text
                        checked: true
                        enabled: false
                        opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                    }
                    Text {
                        id: sigSignedByTextCustom
                        font.pixelSize: propertySigLineHeight * 0.8
                        height: propertySigLineHeight
                        font.family: lato.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigReasonTextCustom.bottom
                        anchors.left: checkboxName2.right
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                        opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                    }
                    Text {
                        id: sigSignedByNameTextCustom
                        font.pixelSize: propertySigLineHeight * 0.8
                        height: propertySigLineHeight
                        width: parent.width - sigSignedByTextCustom.paintedWidth - 6
                        clip: true
                        font.family: lato.name
                        font.bold: true
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigReasonTextCustom.bottom
                        anchors.left: sigSignedByTextCustom.right
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                        opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                    }
                    CheckBox {
                        id: checkboxNumId2
                        text: ""
                        height: propertySigLineHeight
                        visible: true
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.capitalization: Font.MixedCase
                        font.bold: activeFocus
                        anchors.top: sigSignedByNameTextCustom.bottom
                        anchors.topMargin: -5
                        Accessible.role: Accessible.CheckBox
                        Accessible.name: text
                        checked: checkboxNumId.checked
                        enabled: radioButtonCustom.checked
                        opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                        KeyNavigation.tab: checkboxDate2
                        KeyNavigation.down: checkboxDate2
                        KeyNavigation.right: checkboxDate2
                        KeyNavigation.backtab: radioButtonCustom
                        KeyNavigation.up: radioButtonCustom
                        Keys.onEnterPressed: checkboxNumId2.checked = !checkboxNumId2.checked
                        Keys.onReturnPressed: checkboxNumId2.checked = !checkboxNumId2.checked
                    }
                    Text {
                        id: sigNumIdTextCustom
                        font.pixelSize: propertySigLineHeight * 0.8
                        height: propertySigLineHeight
                        width: parent.width - 2 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        clip: true
                        font.family: lato.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigSignedByTextCustom.bottom
                        anchors.left: checkboxNumId2.right
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                        opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                    }
                    CheckBox {
                        id: checkboxDate2
                        text: ""
                        height: propertySigLineHeight
                        visible: true
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.capitalization: Font.MixedCase
                        font.bold: activeFocus
                        anchors.top: sigNumIdTextCustom.bottom
                        anchors.topMargin: -5
                        Accessible.role: Accessible.CheckBox
                        Accessible.name: text
                        checked: checkboxDate.checked
                        enabled: radioButtonCustom.checked
                        opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                        KeyNavigation.tab: buttonRemove
                        KeyNavigation.down: buttonRemove
                        KeyNavigation.right: buttonRemove
                        KeyNavigation.backtab: checkboxNumId2
                        KeyNavigation.up: checkboxNumId2
                        Keys.onEnterPressed: checkboxDate2.checked = !checkboxDate2.checked
                        Keys.onReturnPressed: checkboxDate2.checked = !checkboxDate2.checked
                    }
                    Text {
                        id: sigDateTextCustom
                        font.pixelSize: propertySigLineHeight * 0.8
                        height: propertySigLineHeight
                        width: parent.width - 2 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        clip: true
                        font.family: lato.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigNumIdTextCustom.bottom
                        anchors.left: checkboxDate2.right
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                        opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                    }
                    Text {
                        id: sigLocationTextCustom
                        font.pixelSize: propertySigLineHeight * 0.8
                        height: propertySigLineHeight
                        width: parent.width - 2 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        clip: true
                        font.family: lato.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigDateTextCustom.bottom
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                        opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                    }
                    Rectangle {
                        id: rectPreCustomImage
                        height: parent.height * 0.3
                        width: parent.width * 0.5
                        anchors.top: sigLocationTextCustom.bottom
                        anchors.topMargin: parent.height * 0.1
                        x: Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        visible: true
                        border.width : 2
                        border.color : Constants.COLOR_MAIN_SOFT_GRAY

                        Image {
                            id: imagePreCustom
                            width: parent.width - 2 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                            height: parent.height - 2 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            anchors.verticalCenter: parent.verticalCenter
                            visible: fileLoaded
                            opacity: radioButtonCustom.checked ? 1 : Constants.OPACITY_SIGNATURE_IMAGE_DISABLED
                            cache: false
                        }
                        
                        MouseArea {
                            id: mouseAreaPreCustom
                            anchors.fill: parent
                        }
                    }
                    Text {
                        id: textDragMsgImg
                        width: parent.width - rectPreCustomImage.width - 3 * Constants.SIZE_MARGIN_SIGNATURE_SEAL_CONFIG
                        text: qsTranslate("PageDefinitionsSignature",
                                          "STR_CUSTOM_SIGN_FILE_LOAD")
                        font.bold: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.top: sigLocationTextCustom.bottom
                        anchors.topMargin: parent.height * 0.1
                        anchors.left: rectPreCustomImage.right
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        color: Constants.COLOR_TEXT_LABEL
                        visible: !fileLoaded
                        font.family: lato.name
                    }
                }
                Item {
                    id: rectSignLeft
                    width: parent.width * 0.50 - Constants.SIZE_ROW_H_SPACE
                    height: Constants.HEIGHT_BOTTOM_COMPONENT
                    anchors.top: rectPreCustom.bottom
                    x: Constants.SIZE_ROW_H_SPACE / 2

                    Button {
                        id: buttonRemove
                        text: qsTranslate("PageDefinitionsSignature",
                                          "STR_CUSTOM_SIGN_REMOVE_BUTTON")
                        width: Constants.WIDTH_BUTTON
                        height: Constants.HEIGHT_BOTTOM_COMPONENT
                        anchors.right: parent.right
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.family: lato.name
                        font.capitalization: Font.MixedCase
                        highlighted: activeFocus ? true : false
                        anchors.horizontalCenter: parent.horizontalCenter
                        enabled: fileLoaded
                        KeyNavigation.tab: buttonAdd
                        KeyNavigation.down: buttonAdd
                        KeyNavigation.right: buttonAdd
                        KeyNavigation.backtab: radioButtonCustom
                        KeyNavigation.up: radioButtonCustom
                        Keys.onEnterPressed: clicked()
                        Keys.onReturnPressed: clicked()
                    }
                }
                Item {
                    id: rectSignRight
                    width: parent.width * 0.50 - Constants.SIZE_ROW_H_SPACE
                    height: Constants.HEIGHT_BOTTOM_COMPONENT
                    anchors.top: rectPreCustom.bottom
                    anchors.left: rectSignLeft.right
                    anchors.leftMargin: Constants.SIZE_ROW_H_SPACE

                    Button {
                        id: buttonAdd
                        text: qsTranslate("PageDefinitionsSignature",
                                          "STR_CUSTOM_SIGN_ADD_BUTTON")
                        width: Constants.WIDTH_BUTTON
                        height: Constants.HEIGHT_BOTTOM_COMPONENT
                        anchors.right: parent.right
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.family: lato.name
                        font.capitalization: Font.MixedCase
                        highlighted: activeFocus ? true : false
                        anchors.horizontalCenter: parent.horizontalCenter
                        KeyNavigation.tab: radioButtonDefault
                        KeyNavigation.down: radioButtonDefault
                        KeyNavigation.right: radioButtonDefault
                        KeyNavigation.backtab: buttonRemove
                        KeyNavigation.up: buttonRemove
                        Keys.onEnterPressed: clicked()
                        Keys.onReturnPressed: clicked()
                    }
                }
            }
        }
    }
}
