/*-****************************************************************************

 * Copyright (C) 2019 Miguel Figueira - <miguel.figueira@caixamagica.pt>
 * Copyright (C) 2019 - 2020 Adriano Campos - <adrianoribeirocampos@gmail.com>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

import QtQuick 2.6
import QtQuick.Controls 2.1

import "../../scripts/Constants.js" as Constants
import "../../scripts/Functions.js" as Functions
import "../../components" as Components

//Import C++ defined enums
import eidguiV2 1.0

PageDefinitionsSignSettingsForm {

    Keys.onPressed: {
        console.log("PageDefinitionsSignSettingsForm onPressed:" + event.key)
        Functions.detectBackKeys(event.key, Constants.MenuState.SUB_MENU)
    }

    Connections {
        target: controler
    }

    propertyCheckboxRegister{
        onCheckedChanged: {
            propertyCheckboxRegister.checked ? gapi.setRegCertValue(true) :
                                               gapi.setRegCertValue(false)
            if (propertyCheckboxRegister.enabled) {
                restart_dialog.headerTitle = qsTranslate("Popup Card","STR_POPUP_REGISTER_CERTIFICATE") + controler.autoTr
                restart_dialog.open()
            }
        }
    }
    propertyCheckboxRemove{
        onCheckedChanged: {
            propertyCheckboxRemove.checked ? gapi.setRemoveCertValue(true) :
                                             gapi.setRemoveCertValue(false)

            if (propertyCheckboxRemove.enabled) {
                restart_dialog.headerTitle = qsTranslate("Popup Card","STR_POPUP_REMOVE_CERTIFICATE") + controler.autoTr
                restart_dialog.open()
            }
        }
    }
    propertyCheckboxDisable{
        onCheckedChanged: controler.setOutlookSuppressNameChecks(propertyCheckboxDisable.checked);
    }
    Connections {
        target: propertyTextFieldTimeStamp
        onEditingFinished: {
            console.log("Editing TimeStamp finished host: " + propertyTextFieldTimeStamp.text);
            controler.setTimeStampHostValue(propertyTextFieldTimeStamp.text)
        }
    }
    propertyCheckboxTimeStamp{
        onCheckedChanged: if (!propertyCheckboxTimeStamp.checked ){
                              controler.setTimeStampHostValue("http://ts.cartaodecidadao.pt/tsa/server")
                              propertyTextFieldTimeStamp.text = ""
                          }
    }
    propertyCheckboxCMDRegRemember{
        onCheckedChanged: controler.setAskToRegisterCmdCertValue(!propertyCheckboxCMDRegRemember.checked)
    }

    propertyLoadCMDCertsButton {
        onClicked: {
            mainFormID.propertyCmdDialog.open(GAPI.RegisterCert)
        }
    }

    Component.onCompleted: {
        console.log("Page definitionsSignSettings onCompleted")

        propertyCheckboxRegister.enabled = false
        propertyCheckboxRemove.enabled = false
        if (Qt.platform.os === "windows") {
            propertyCheckboxRegister.checked = gapi.getRegCertValue()
            propertyCheckboxRemove.checked = gapi.getRemoveCertValue()
            propertyCheckboxRegister.enabled = true
            propertyCheckboxRemove.enabled = true
        }else{
            propertyRectAppCertificates.visible = false
            propertyRectAppTimeStamp.anchors.top = propertyRectAppCertificates.top
        }

        if (controler.getTimeStampHostValue().length > 0
                && controler.getTimeStampHostValue() !== "http://ts.cartaodecidadao.pt/tsa/server"){
            propertyCheckboxTimeStamp.checked = true
            propertyTextFieldTimeStamp.text = controler.getTimeStampHostValue()
        }else{
            propertyCheckboxTimeStamp.checked = false
        }

        if (Qt.platform.os === "windows") {
            propertyCheckboxDisable.enabled = controler.isOutlookInstalled()
            if (propertyCheckboxDisable.enabled)
                propertyCheckboxDisable.checked = controler.getOutlookSuppressNameChecks()
        } else {
            propertyRectOffice.visible = false
        }

        if (Qt.platform.os === "windows") {
            propertyCheckboxCMDRegRemember.checked = !controler.getAskToRegisterCmdCertValue()
        } else {
            propertyRectLoadCMDCerts.visible = false
        }

        if(propertyRectAppCertificates.visible){
            propertyDateAppCertificates.forceActiveFocus()
        }else{
            propertyDateAppTimeStamp.forceActiveFocus()
        }

        console.log("Page definitionsSignSettings onCompleted finished")
    }
    function toggleSwitch(element){
        element.checked = !element.checked
    }
}
