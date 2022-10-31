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
#pragma once

#include "keyinfo.h"

#include <QObject>
#include <QString>

namespace MaliitKeyboard
{

class KeysModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool shiftlessKeys READ shiftlessKeys NOTIFY keysChanged)
    Q_PROPERTY(QList<QList<KeyInfo*>> keys READ keys NOTIFY keysChanged)
    Q_PROPERTY(QList<QList<KeyInfo*>> symbols READ symbols NOTIFY keysChanged)

    Q_PROPERTY(QList<QList<KeyInfo*>> numbers READ numbers CONSTANT)
    Q_PROPERTY(QList<QList<KeyInfo*>> digits READ digits CONSTANT)
    Q_PROPERTY(QList<QList<KeyInfo*>> phone READ phone CONSTANT)
    Q_PROPERTY(QList<QList<KeyInfo*>> email READ email NOTIFY keysChanged)
    Q_PROPERTY(QList<QList<KeyInfo*>> url READ url NOTIFY keysChanged)

public:
    explicit KeysModel(QObject *parent=0);

    bool shiftlessKeys() const;
    QList<QList<KeyInfo*>> keys() const;
    QList<QList<KeyInfo*>> symbols() const;
    QList<QList<KeyInfo*>> numbers() const;
    QList<QList<KeyInfo*>> digits() const;
    QList<QList<KeyInfo*>> phone() const;
    QList<QList<KeyInfo*>> email() const;
    QList<QList<KeyInfo*>> url() const;

    void setLanguage(const QString& language);

Q_SIGNALS:
    void keysChanged();

private:
    QList<QList<KeyInfo*>> parseLayoutFile(const QString& filename);
    void buildNumericModels();

    QString m_language;
    bool m_shiftlessKeys;
    QList<QList<KeyInfo*>> m_keys;
    QList<QList<KeyInfo*>> m_symbols;
    QList<QList<KeyInfo*>> m_numbers;
    QList<QList<KeyInfo*>> m_digits;
    QList<QList<KeyInfo*>> m_phone;
    QList<QList<KeyInfo*>> m_email;
    QList<QList<KeyInfo*>> m_url;
};

}
