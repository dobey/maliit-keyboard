/*
 * Copyright (c) 2022 Rodney Dawes
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list
 * of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list
 * of conditions and the following disclaimer in the documentation and/or other materials
 * provided with the distribution.
 * Neither the name of Nokia Corporation nor the names of its contributors may be
 * used to endorse or promote products derived from this software without specific
 * prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include "keysmodel.h"

#include <algorithm>

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>

namespace MaliitKeyboard
{

KeysModel::KeysModel(QObject* parent)
    : QObject(parent)
{
    buildNumericModels();
}

void KeysModel::setLanguage(const QString& language)
{
    qDebug() << "Loading layout:" << language;
    m_keys.clear();
    m_email.clear();
    m_url.clear();
    m_symbols.clear();

    m_language = language;

    m_keys = parseLayoutFile(language);
    m_symbols = parseLayoutFile("symbols");

    /* Set up the eMail and URL layouts, from the language layout */
    m_url = m_email = m_keys;
    m_email[m_email.length() - 1].replace(2, new KeyInfo(KeyInfo::Character, "@", "@"));
    m_url[m_url.length() - 1].replace(2, new KeyInfo(KeyInfo::Character, "/", "/"));

    Q_EMIT keysChanged();
}

QList<QList<KeyInfo*>> KeysModel::parseLayoutFile(const QString& filename)
{
    QList<QList<KeyInfo*>> layout;

    auto langDir = QStringLiteral(MALIIT_KEYBOARD_DATA_DIR) + QDir::separator() + "languages" + QDir::separator();
    QFile lang(langDir + filename + ".json");
    if (filename.startsWith("symbols")) {
        auto symPath = langDir + filename + "-" + m_language + ".json";
        if (QFile::exists(symPath)) {
            lang.setFileName(symPath);
        }
    }
        
    if (!lang.open(QIODevice::ReadOnly)) {
        qCritical() << "Failed to open layout definition file:" << lang.fileName();
        return layout;
    }

    qDebug() << "Reading:" << lang.fileName();
    auto keydata = lang.readAll();
    QJsonParseError err;
    auto keydoc = QJsonDocument::fromJson(keydata, &err);
    auto keyobj = keydoc["keys"].toObject();
    if (err.error != QJsonParseError::NoError) {
        qCritical() << "Error loading layout definition file:" << err.errorString();
        return layout;
    }

    auto keylist = keyobj.keys();
    QList<KeyInfo*> aRow; aRow << new KeyInfo(KeyInfo::Symbol) << new KeyInfo(KeyInfo::Emoji);
    QList<KeyInfo*> bRow;
    QList<KeyInfo*> cRow;
    QList<KeyInfo*> dRow;
    QList<KeyInfo*> eRow;

    auto isSymbols = filename.startsWith("symbols");
    if (!isSymbols) {
        m_shiftlessKeys = keydoc["shiftless"].toBool();
    }
    if (!m_shiftlessKeys || isSymbols) {
        bRow << new KeyInfo(KeyInfo::Shift);
    }
    
    for (const auto& position: keylist) {
        auto jsonKey = keyobj[position].toObject();
        auto key = new KeyInfo(KeyInfo::Character,
                               jsonKey["normal"].toString(),
                               jsonKey["shifted"].toString(),
                               jsonKey["extended"].toString().split(" "),
                               jsonKey["extendedShifted"].toString().split(" "));

        switch (position[0].toLatin1()) {
        case 'A':
            aRow << key;
            break;
        case 'B':
            bRow << key;
            break;
        case 'C':
            cRow << key;
            break;
        case 'D':
            dRow << key;
            break;
        case 'E':
            eRow << key;
            break;
        default:
            qWarning() << "Unhandled key position:" << position;
            break;
        }
    }

    aRow << new KeyInfo(KeyInfo::Enter);
    aRow.insert(3, new KeyInfo(KeyInfo::Space));
    bRow << new KeyInfo(KeyInfo::Backspace);

    if (eRow.length() > 0) {
        layout << eRow;
    }
    layout << dRow << cRow << bRow << aRow;

    return layout;
}

void KeysModel::buildNumericModels()
{
    /* Digits layout */
    QList<KeyInfo*> dig4;
    dig4 << new KeyInfo(KeyInfo::Character, "1");
    dig4 << new KeyInfo(KeyInfo::Character, "2");
    dig4 << new KeyInfo(KeyInfo::Character, "3");
    QList<KeyInfo*> dig3;
    dig3 << new KeyInfo(KeyInfo::Character, "4");
    dig3 << new KeyInfo(KeyInfo::Character, "5");
    dig3 << new KeyInfo(KeyInfo::Character, "6");
    QList<KeyInfo*> dig2;
    dig2 << new KeyInfo(KeyInfo::Character, "7");
    dig2 << new KeyInfo(KeyInfo::Character, "8");
    dig2 << new KeyInfo(KeyInfo::Character, "9");
    QList<KeyInfo*> dig1;
    dig1 << new KeyInfo(KeyInfo::Backspace);
    dig1 << new KeyInfo(KeyInfo::Character, "0");
    dig1 << new KeyInfo(KeyInfo::Enter);

    m_digits << dig4 << dig3 << dig2 << dig1;

    /* Formatted numbers layout */
    QList<KeyInfo*> num4;
    num4 << new KeyInfo(KeyInfo::Character, "1");
    num4 << new KeyInfo(KeyInfo::Character, "2");
    num4 << new KeyInfo(KeyInfo::Character, "3");
    num4 << new KeyInfo(KeyInfo::Character, "-");
    QList<KeyInfo*> num3;
    num3 << new KeyInfo(KeyInfo::Character, "4");
    num3 << new KeyInfo(KeyInfo::Character, "5");
    num3 << new KeyInfo(KeyInfo::Character, "6");
    num3 << new KeyInfo(KeyInfo::Character, ",");
    QList<KeyInfo*> num2;
    num2 << new KeyInfo(KeyInfo::Character, "7");
    num2 << new KeyInfo(KeyInfo::Character, "8");
    num2 << new KeyInfo(KeyInfo::Character, "9");
    num2 << new KeyInfo(KeyInfo::Backspace);
    QList<KeyInfo*> num1;
    num1 << new KeyInfo(KeyInfo::Character, ".");
    num1 << new KeyInfo(KeyInfo::Character, "0");
    num1 << new KeyInfo(KeyInfo::None);
    num1 << new KeyInfo(KeyInfo::Enter);

    m_numbers << num4 << num3 << num2 << num1;

    /* Phone keypad layout */
    QList<KeyInfo*> phone4;
    phone4 << new KeyInfo(KeyInfo::Character, "1");
    phone4 << new KeyInfo(KeyInfo::Character, "2");
    phone4 << new KeyInfo(KeyInfo::Character, "3");
    phone4 << new KeyInfo(KeyInfo::Character, "-", "", QStringList("+"));
    QList<KeyInfo*> phone3;
    phone3 << new KeyInfo(KeyInfo::Character, "4");
    phone3 << new KeyInfo(KeyInfo::Character, "5");
    phone3 << new KeyInfo(KeyInfo::Character, "6");
    phone3 << new KeyInfo(KeyInfo::Character, ".", "", QStringList(","));
    QList<KeyInfo*> phone2;
    phone2 << new KeyInfo(KeyInfo::Character, "7");
    phone2 << new KeyInfo(KeyInfo::Character, "8");
    phone2 << new KeyInfo(KeyInfo::Character, "9");
    phone2 << new KeyInfo(KeyInfo::Backspace);
    QList<KeyInfo*> phone1;
    phone1 << new KeyInfo(KeyInfo::Character, "*");
    phone1 << new KeyInfo(KeyInfo::Character, "0");
    phone1 << new KeyInfo(KeyInfo::Character, "#");
    phone1 << new KeyInfo(KeyInfo::Enter);

    m_phone << phone4 << phone3 << phone2 << phone1;
}

bool KeysModel::shiftlessKeys() const
{
    return m_shiftlessKeys;
}

QList<QList<KeyInfo*>> KeysModel::keys() const
{
    return m_keys;
}

QList<QList<KeyInfo*>> KeysModel::symbols() const
{
    return m_symbols;
}

QList<QList<KeyInfo*>> KeysModel::numbers() const
{
    return m_numbers;
}

QList<QList<KeyInfo*>> KeysModel::digits() const
{
    return m_digits;
}

QList<QList<KeyInfo*>> KeysModel::phone() const
{
    return m_phone;
}

QList<QList<KeyInfo*>> KeysModel::email() const
{
    return m_email;
}

QList<QList<KeyInfo*>> KeysModel::url() const
{
    return m_url;
}

}
