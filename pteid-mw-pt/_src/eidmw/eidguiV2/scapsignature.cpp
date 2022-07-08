/*-****************************************************************************

 * Copyright (C) 2017-2019 André Guerreiro - <aguerreiro1985@gmail.com>
 * Copyright (C) 2017-2021 Adriano Campos - <adrianoribeirocampos@gmail.com>
 * Copyright (C) 2018 Veniamin Craciun - <veniamin.craciun@caixamagica.pt>
 * Copyright (C) 2019 Miguel Figueira - <miguel.figueira@caixamagica.pt>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

#include "scapsignature.h"
#include "eidlib.h"
#include "eidlibException.h"

#include "ScapSettings.h"
#include "gapi.h"
#include "Util.h"
#include "Config.h"

#include "SCAP-services-v3/SCAPH.h"
#include "SCAP-services-v3/SCAPAttributeSupplierBindingProxy.h"
//#include "SCAPServices/SCAP.nsmap"

// Client for WS PADES/PDFSignature
#include "pdfsignatureclient.h"
#include <string>
#include <codecvt>

/*
  SCAPSignature implementation for eidguiV2
*/

void ScapServices::setConnErr( int soapConnErr, void *in_suppliers_resp ) {
    qDebug() << "ScapSignature::setConnErr() - soapConnErr: " << soapConnErr;
    connectionErr.setErr( soapConnErr, in_suppliers_resp );
}

using namespace eIDMW;


std::vector<ns3__AttributeType*> ScapServices::getSelectedAttributes(std::vector<int> attributes_index) {

    std::vector<ns3__AttributeType*> parsedAttributes;
    ns2__AttributesType * parent = NULL;
    int index = 0;

    for (int i=0; i!=attributes_index.size(); i++) {
        index = 0;

        for (int j=0; j < m_attributesList.size(); j++) {

            try {
                parent = m_attributesList.at(j);
            }
            catch (std::out_of_range &e)
            {
                qDebug() << "Invalid attribute index: "
                         << attributes_index[j] << "This shouldn't happen!";
                continue;
            }

            std::vector<ns5__SignatureType *> childs = parent->SignedAttributes->ns3__SignatureAttribute;
            for(uint childPos = 0;  childPos < childs.size(); childPos++)
            {
                ns5__SignatureType * child = childs.at(childPos);
                if ( child->ns5__Object.size() > 0 && index == attributes_index[i] )
                {
                    ns5__ObjectType * objType = child->ns5__Object.at(0);
                    ns3__AttributeType * attr = objType->union_ObjectType.ns3__Attribute;
                    //"Fix" the AttributeSupplier (ID and Name): they can have different values in SCAP and the actual entity Attribute
                    attr->AttributeSupplier->Id = parent->ATTRSupplier->Id;
                    attr->AttributeSupplier->Name = parent->ATTRSupplier->Name;
                    parsedAttributes.push_back(attr);
                    /*qDebug() << "Selected attribute from supplier: " << attr->AttributeSupplier->Name.c_str();*/
                }
                index++;
            }
        }
    }

    return parsedAttributes;
}

bool detectExpiredAttributes(std::vector<ns3__AttributeType*> selected_attributes){
    std::string validity, supplier;

    for (unsigned int i = 0; i < selected_attributes.size(); i++) {
        supplier = selected_attributes.at(i)->AttributeSupplier->Name;
        validity = selected_attributes.at(i)->Validity;

        if (GAPI::isAttributeExpired(validity, supplier)) {
            return true;
        }
    }

    return false;
}

const char * errorTranslation(long error_code) {
	switch (error_code) {
		case EIDMW_TIMESTAMP_ERROR:
			return "Failed to add timestamp";
		case EIDMW_LTV_ERROR:
			return "Failed to add revocation info";
		default:
			return "Other cause: see error code";
	}
}

void proxySettingsForGSoap(ProxyInfo &proxyInfo, soap *sp, std::string &url) {
    std::string proxy_host;
    long proxy_port = 0;
    if (proxyInfo.isAutoConfig()) {
        proxyInfo.getProxyForHost(url, &proxy_host, &proxy_port);
        if (proxy_host.size() > 0)
        {
            sp->proxy_host = proxy_host.c_str();
            sp->proxy_port = proxy_port;
        }
    }
    else if (proxyInfo.isManualConfig()) {
        try {
            if (proxyInfo.getProxyHost().size() == 0) {

                eIDMW::PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_WARNING, "ScapSignature",
                                 "%s: Empty proxy host. Proxy config not applied!", __FUNCTION__);
                return;
            }
            proxy_port = std::stol(proxyInfo.getProxyPort());
            sp->proxy_host = strdup(proxyInfo.getProxyHost().c_str());
            sp->proxy_port = proxy_port;

            if (proxyInfo.getProxyUser().size() > 0)
            {
                sp->proxy_userid = strdup(proxyInfo.getProxyUser().c_str());
                sp->proxy_passwd = strdup(proxyInfo.getProxyPwd().c_str());
            }
        }
        catch (...) {  //Capture 2 types of exceptions thrown by std::stol()
            eIDMW::PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                             "%s: Error parsing proxy port to number value. Proxy config not applied!", __FUNCTION__);
        }

    }
}

/*
*  SCAP signature with citizen signature using CMD
*/
int ScapServices::executeSCAPWithCMDSignature(GAPI *parent, QString &savefilepath, int selected_page,
        double location_x, double location_y, QString &location, QString &reason, bool isTimestamp, bool isLtv,
        std::vector<int> attributes_index, CmdSignedFileDetails cmd_details,
        bool useCustomImage, QByteArray &m_jpeg_scaled_data,
        unsigned int seal_width, unsigned int seal_height) {

    std::vector<ns3__AttributeType*> selected_attributes = getSelectedAttributes(attributes_index);

    if (selected_attributes.size() == 0)
    {
        qDebug() << "Couldn't find any index in m_attributesList!";
        return GAPI::ScapGenericError;
    }

    PDFSignatureClient scap_signature_client;
    ProxyInfo m_proxyInfo;
    int successful;
	PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_DEBUG, "ScapSignature",
		"Performing SCAP signature for %d attributes", selected_attributes.size());

    try {
         successful = scap_signature_client.signPDF(m_proxyInfo, savefilepath, cmd_details.signedCMDFile, cmd_details.citizenName,
            cmd_details.citizenId, isTimestamp, false, PDFSignatureInfo(selected_page, location_x, location_y,
				isLtv, strdup(location.toUtf8().constData()), strdup(reason.toUtf8().constData()), seal_width, seal_height), 
                selected_attributes, useCustomImage, m_jpeg_scaled_data);
    }
    catch (eIDMW::PTEID_Exception &e)
    {
		PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
			"SCAP CMD Error closing SCAP signature: %s Error code: %08x", errorTranslation(e.GetError()), e.GetError());
        throw;
    }
    if (successful == GAPI::ScapSucess) {
        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_CRITICAL, "ScapSignature",
                "SCAP CMD ScapSuccess");
    }
    else if (successful == GAPI::ScapAttributesExpiredError) {
        qDebug() << "Error in SCAP service ScapAttributesExpiredError!";
        parent->signCMDFinished(SCAP_ATTRIBUTES_EXPIRED);
        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                "SCAP CMD Error. ScapAttributesExpiredError");
    }
    else if (successful == GAPI::ScapZeroAttributesError) {
        qDebug() << "Error in SCAP service ScapZeroAttributesError!";
        parent->signCMDFinished(SCAP_ZERO_ATTRIBUTES);
        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                "SCAP CMD Error. ScapZeroAttributesError");
    }
    else if (successful == GAPI::ScapNotValidAttributesError) {
        qDebug() << "Error in SCAP service ScapNotValidAttributesError!";
        parent->signCMDFinished(SCAP_ATTRIBUTES_NOT_VALID);
        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                "SCAP CMD Error. ScapNotValidAttributesError");
    }
    else if (successful == GAPI::ScapTimeOutError) {
        qDebug() << "Error in SCAP service Timeout with CMD service!";
        parent->signalSCAPServiceTimeout();
        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                "SCAP CMD Error. ScapTimeOutError");
    }
    else if (successful == GAPI::ScapClockError) {
        qDebug() << "Error in SCAP service Clock Error with CMD service!";
        parent->signCMDFinished(SCAP_CLOCK_ERROR_CODE);
        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                "SCAP CMD Error. ScapClockError");
    }
    else if (successful == GAPI::ScapSecretKeyError) {
        qDebug() << "Error in SCAP service SecretKey Error with CMD service!";
        parent->signCMDFinished(SCAP_SECRETKEY_ERROR_CODE);
        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                "SCAP CMD Error. ScapSecretKeyError");
    }
    else {
        if (detectExpiredAttributes(selected_attributes)) {
            parent->signCMDFinished(SCAP_ATTR_POSSIBLY_EXPIRED_WARNING);
            PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                    "SCAP CMD Error with possibly expired attributes. ScapPdfSignResult = %d",successful);
        }
        else {
            qDebug() << "Error in SCAP Signature with CMD service!";
            parent->signCMDFinished(SCAP_GENERIC_ERROR_CODE);
            PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                    "SCAP CMD Error. ScapPdfSignResult = %d",successful);
        }
    }
    return successful;
}

void ScapServices::executeSCAPSignature(GAPI *parent, QString &inputPath, QString &savefilepath, int selected_page,
    double location_x, double location_y, QString &location, QString &reason, bool isTimestamp, bool isLtv,
    std::vector<int> attributes_index, bool useCustomImage, QByteArray &m_jpeg_scaled_data,
    unsigned int seal_width, unsigned int seal_height)
{
    const char* citizenId = NULL;
    PTEID_EIDCard * card = NULL;

    std::vector<ns3__AttributeType*> selected_attributes = getSelectedAttributes(attributes_index);

    if (selected_attributes.size() == 0)
    {
        qDebug() << "Couldn't find any index in m_attributesList!";
        return;
    }

    parent->getCardInstance(card);

    //Error handling triggering signal for the GUI is within GAPI::getCardInstance()
    if (card == NULL)
            return;

    // Creates a temporary file
    QTemporaryFile tempFile;

    if (!tempFile.open()) {
        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_DEBUG, "ScapSignature", "PDF Signature error: Error creating temporary file");
        return;
    }

    char *temp_save_path = strdup(tempFile.fileName().toStdString().c_str());
    qDebug() << "Generating first tempFile: " << temp_save_path;
    int sign_rc = 0;
    

    try {
        
        
        PTEID_PDFSignature pdf_sig(strdup(inputPath.toUtf8().constData()));
        PTEID_SignatureLevel citizen_signature_level = isTimestamp ?
                (isLtv ? PTEID_LEVEL_LT : PTEID_LEVEL_TIMESTAMP) : PTEID_LEVEL_BASIC;
        pdf_sig.setSignatureLevel(citizen_signature_level);      

        // Sign pdf
        sign_rc = card->SignPDF(pdf_sig, selected_page, 0, false, strdup(location.toUtf8().constData()),
                                strdup(reason.toUtf8().constData()), temp_save_path);       
    }
    catch (eIDMW::PTEID_Exception &e)
    {
        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
              "executeSCAPSignature - Exception accessing EIDCard. Error code: %08x",  e.GetError());
        if (e.GetError() != EIDMW_TIMESTAMP_ERROR && e.GetError() != EIDMW_LTV_ERROR) {
            free(temp_save_path);
            throw;
        }
    }

    if (sign_rc == 0)
    {
        try {
                PDFSignatureClient scap_signature_client;
                ProxyInfo m_proxyInfo;

                // Get Citizen info
                PTEID_EId & citizen_info = card->getID();
                QString citizenName = citizen_info.getGivenName();
                citizenName.append(" ");
                citizenName.append(citizen_info.getSurname());
                citizenId = citizen_info.getCivilianIdNumber();

                int successful = scap_signature_client.signPDF(
                            m_proxyInfo, savefilepath, QString(temp_save_path), citizenName,
                            QString(citizenId), isTimestamp, true, PDFSignatureInfo(selected_page, location_x, location_y,
                            isLtv, strdup(location.toUtf8().constData()), strdup(reason.toUtf8().constData()),
                            seal_width, seal_height), selected_attributes, useCustomImage, m_jpeg_scaled_data);
                if (successful == GAPI::ScapSucess) {
                    parent->signalPdfSignSuccess(parent->SignMessageOK);
                    PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_CRITICAL, "ScapSignature",
                            "SCAP CC ScapSuccess");
                }
                else if (successful == GAPI::ScapTimeOutError) {
                    qDebug() << "Error in SCAP service Timeout!";
                    parent->signalSCAPServiceTimeout();
                    PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                            "SCAP CC ScapTimeOutError");
                }
                else if (successful == GAPI::ScapClockError) {
                    qDebug() << "Error in SCAP service Clock Error!";
                    parent->signalSCAPServiceFail(successful);
                    PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                            "SCAP CC ScapClockError");
                }
                else if (successful == GAPI::ScapSecretKeyError) {
                    qDebug() << "Error in SCAP service SecretKey Error!";
                    parent->signalSCAPServiceFail(successful);
                    PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                            "SCAP CC ScapSecretKeyError");
                }
                else {
                    if (detectExpiredAttributes(selected_attributes)) {
                        parent->signalSCAPServiceFail(GAPI::ScapAttrPossiblyExpiredWarning);
                        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                                "SCAP CC Error with possibly expired attributes. ScapPdfSignResult = %d",successful);
                    }
                    else {
                        qDebug() << "Error in SCAP Signature service!";
                        parent->signalSCAPServiceFail(successful);
                        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                                "SCAP CC Error. ScapPdfSignResult = %d",successful);
                    }
                }
            }
            catch (eIDMW::PTEID_Exception &e)
            {
                eIDMW::PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature",
                    "SCAP CC Error closing SCAP signature: %s Error code: %08x", errorTranslation(e.GetError()), e.GetError());
                free(temp_save_path);
                throw;
            }
    } else {
        parent->signalSCAPServiceFail(GAPI::ScapGenericError);
        PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR, "ScapSignature","SCAP CC Card Generic Error");
    }
    free(temp_save_path);
}


std::vector<ns3__AttributeSupplierType *> ScapServices::getAttributeSuppliers()
{
	const char * as_endpoint = "/DSS/ASService";

    //TODO: should we cache the suppliers list ??

	//qDebug() << "getAttributeSuppliers(): " << m_suppliersList.size();

	soap * sp = soap_new2(SOAP_C_UTFSTRING, SOAP_C_UTFSTRING);

	char * ca_path = NULL;
	std::string cacerts_file;

    //Define appropriate network timeouts
    sp->recv_timeout = RECV_TIMEOUT;
    sp->send_timeout = SEND_TIMEOUT;
    sp->connect_timeout = CONNECT_TIMEOUT;

#ifdef __linux__
	ca_path = "/etc/ssl/certs";
	//Load CA certificates from file provided with pteid-mw
#else
	cacerts_file = utilStringNarrow(CConfig::GetString(CConfig::EIDMW_CONFIG_PARAM_GENERAL_CERTS_DIR)) + "/cacerts.pem";
#endif

	int ret = soap_ssl_client_context(sp, SOAP_SSL_DEFAULT,
		NULL,
		NULL,
		cacerts_file.size() > 0 ? cacerts_file.c_str() : NULL, /* cacert file to store trusted certificates (needed to verify server) */
		ca_path,
		NULL);

	if (ret != SOAP_OK) {
		eIDMW::PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR
			, "ScapSignature"
			, "Error in getAttributeSuppliers: Gsoap returned %d "
			, ret);
	}

	// Get Endpoint from settings
	ScapSettings settings;
	std::string port = settings.getScapServerPort().toStdString();
	std::string sup_endpoint = std::string("https://") + settings.getScapServerHost().toStdString() + ":" + port + as_endpoint;

	//Proxy support using the gsoap BindingProxy
    ProxyInfo proxyInfo;
    proxySettingsForGSoap(proxyInfo, sp, sup_endpoint);

    ns9__AttributeSupplierResponseType suppliers_resp;

    const char * c_sup_endpoint = sup_endpoint.c_str();
    const char * entities_soapAction = 
     "http://www.cartaodecidadao.pt/CCC/Attribute/AttributeSupplier/services/AttributeSupplierService/EntitySupplierList";

    AttributeSupplierBindingProxy suppliers_proxy(sp);
    //suppliers_proxy.soap_endpoint = c_sup_endpoint;

    //int ret = suppliers_proxy.AttributeSuppliers(suppliers_resp);
    ret = suppliers_proxy.AttributeSuppliers(c_sup_endpoint, entities_soapAction, suppliers_resp);

    setConnErr( ret, &suppliers_resp );

    if (ret != SOAP_OK) {
        eIDMW::PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR
                        , "ScapSignature"
                        , "Error in getAttributeSuppliers: Gsoap returned %d, Attribute suppliers end point: %s, host: %s, port: %s"
                        , ret
                        , c_sup_endpoint
                        , settings.getScapServerHost().toStdString().c_str()
                        , settings.getScapServerPort().toStdString().c_str() );

        if ( ( suppliers_proxy.soap->fault != NULL )
			&& (suppliers_proxy.soap->fault->faultstring != NULL)) {

            eIDMW::PTEID_LOG(eIDMW::PTEID_LOG_LEVEL_ERROR
                            , "ScapSignature", "SOAP Fault: %s"
                            , suppliers_proxy.soap->fault->faultstring );
        }
    }

    m_suppliersList = suppliers_resp.AttributeSupplier;
    qDebug() << "Reloaded list of attribute suppliers Size= " << m_suppliersList.size();

    return m_suppliersList;
}
