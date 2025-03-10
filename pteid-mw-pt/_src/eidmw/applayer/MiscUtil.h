/* ****************************************************************************

 * eID Middleware Project.
 * Copyright (C) 2008-2009 FedICT.
 * Copyright (C) 2019 Caixa Magica Software.
 * Copyright (C) 2011-2012 Vasco Silva - <vasco.silva@caixamagica.pt>
 * Copyright (C) 2012, 2014, 2016-2017 André Guerreiro - <aguerreiro1985@gmail.com>
 * Copyright (C) 2012 lmcm - <lmcm@caixamagica.pt>
 * Copyright (C) 2013 Vasco Dias - <vasco.dias@caixamagica.pt>
 * Copyright (C) 2017 Luiz Lemos - <luiz.lemos@caixamagica.pt>
 * Copyright (C) 2018-2019 Miguel Figueira - <miguelblcfigueira@gmail.com>
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License version
 * 3.0 as published by the Free Software Foundation.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, see
 * http://www.gnu.org/licenses/.

**************************************************************************** */
#pragma once

#ifndef __APL_MISCSUTIL_H__
#define __APL_MISCSUTIL_H__

#include <string>
#include <cstring> //POSIX basename
#ifdef __APPLE__
#include <libgen.h>
#endif
#include <vector>
#include <map>
#include <time.h>
#include "TLVBuffer.h"
#include <openssl/x509.h>

namespace eIDMW
{

#define PTEID_USER_AGENT "User-Agent: PTeID Middleware v3"
#define PTEID_USER_AGENT_VALUE "PTeID Middleware v3"

	EIDMW_APL_API std::vector<std::string> toPEM(char *p_certificate, int certificateLen);
	EIDMW_APL_API char *X509_to_PEM(X509 *x509);
	X509 *PEM_to_X509(char *pem);

	int X509_to_DER(X509 *x509, unsigned char **der);
	X509 *DER_to_X509(unsigned char *der, int len);
	char *DER_to_PEM(unsigned char *der, int len);
	long der_certificate_length(const CByteArray &der_certificate);
	char * certificate_subject_from_der(CByteArray & ba);
	std::string certificate_issuer_serial_from_der(CByteArray & ba);

	char * Openssl_errors_to_string();

	EIDMW_APL_API int PEM_to_DER(char *pem, unsigned char **der);
	
	EIDMW_APL_API char *getCPtr(std::string inStr, int *outLen);

//Use _strdup instead of strdup to silence Win32 warnings
#ifndef WIN32
#define _strdup strdup
#endif

const void *memmem(const void *haystack, size_t n, const void *needle, size_t m);

//Implementation of some utility functions over POSIX and Win32
char * Basename(char *absolute_path);
int Truncate(const char *path);
//Charset conversion
void latin1_to_utf8(unsigned char * in, unsigned char *out);

std::string urlEncode(const std::string &path);

void replace_lastdot_inplace(char *in);

//Base-64 encoding for binary data

char *Base64Encode(const unsigned char *input, long length);
void Base64Decode(const char *array, unsigned int inlen, unsigned char *&decoded, unsigned int &decoded_len);

//Hex string encoding for binary data
void binToHex(const unsigned char *in, size_t in_len, char *out, size_t out_len);

//Common type between 2/3 different cpp files
typedef struct _hashed_file_
{
	CByteArray *hash;
	std::string *URI;
} tHashedFile;

/******************************************************************************//**
  * Util class for timestamp features
  *********************************************************************************/
class CTimestampUtil
{
public:

	/**
	  * Return timestamp in format with delay
	  */
	EIDMW_APL_API static void getTimestamp(std::string &timestamp,long delay,const char *format);

	/**
	  * return true if timestamp > now
	  */
	EIDMW_APL_API static bool checkTimestamp(std::string &timestamp,const char *format);
};

/******************************************************************************//**
  * Util class for path and directory features
  *********************************************************************************/
class CPathUtil
{
public:
	/**
	  * Return the current working directory
	  */
	static std::string getWorkingDir();

	/**
	  * Return the directory from a full path
	  */
	static std::string getDir(const char *path);

	/**
	  * Return true if the file exist
	  */
	static bool existFile(const char *filePath);

	/**
	  * Return true if all files exist
	  */
	EIDMW_APL_API static bool checkExistingFiles(const char **files, unsigned int n_paths);

	static FILE * openFileForWriting(const char *Dir, const char *filename);

	/**
	  * Check directory and create it if not exist
	  */
	static void checkDir(const char *directory);

	/**
	  * Return the name where the crl file could be found (Relative to the cache dir)
	  */
	static std::string getRelativePath(const char *uri);

	/**
	  * Return the name where the crl file could be found on the hard drive
	  */
	static std::string getFullPath(const char *rootPath, const char *relativePath);

	/**
	  * Return the name where the crl file could be found on the hard drive
	  */
	static std::wstring getFullPath(const wchar_t *rootPath, const wchar_t *relativePath);

	/**
	  * Return the name where the crl file could be found on the hard drive
	  */
	static std::string getFullPathFromUri(const char *rootPath, const char *uri);

	/**
	  * Return basename of file ater removing its extension if it exists
	  */
	static std::string remove_ext_from_basename(const char *base);

	/**
	  * Modify each path in the vector filenames to keep the basename and extension but change the folder
      * path to be the folder variable. If there are multiple files with the same basename, prepend a sequential
      * identifier.
	  */
    EIDMW_APL_API static void generate_unique_filenames(const char *folder, std::vector<std::string *> &filenames, const char *suffix = "");
};

class CByteArray;

/******************************************************************************//**
  * Util class for parsing CSV file
  *********************************************************************************/
#define CSV_SEPARATOR ';'

class CSVParser
{
public:

	CSVParser(const CByteArray &data, unsigned char separator);

	virtual ~CSVParser();

	unsigned long count();

	const CByteArray &getData(unsigned long idx);

private:
	void parse(const CByteArray &data, unsigned char separator);

	std::vector<CByteArray *> m_vector;
};

class CTLV;

/******************************************************************************//**
  * Util class for parsing TLV file
  *********************************************************************************/
class TLVParser : public CTLVBuffer
{
public:

	TLVParser();

	virtual ~TLVParser();

    CTLV *GetSubTagData(unsigned char ucTag,unsigned char ucSubTag);

private:
	std::map<unsigned char,CTLVBuffer *> m_subfile;
};
}

#endif // __APL_MISCSUTIL_H__
