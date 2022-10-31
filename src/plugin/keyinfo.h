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

#include <QObject>
#include <QString>
#include <QStringList>

namespace MaliitKeyboard
{

class KeyInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Type type READ type CONSTANT)
    Q_PROPERTY(QString normal READ normal CONSTANT)
    Q_PROPERTY(QString shifted READ shifted CONSTANT)
    Q_PROPERTY(QStringList extended READ extended CONSTANT)
    Q_PROPERTY(QStringList extendedShifted READ extendedShifted CONSTANT)

public:
    enum Type {
        None,
        Character,
        Shift,
        Symbol,
        Space,
        Backspace,
        Enter,
        Emoji,
    };
    Q_ENUM(Type);

    explicit KeyInfo(Type type,
                     const QString& normal=QStringLiteral(),
                     const QString& shifted=QStringLiteral(),
                     const QStringList& extended=QStringLiteral("").split(" "),
                     const QStringList& extendedShifted=QStringLiteral("").split(" "),
                     QObject *parent=0);

    Type type() const;
    QString normal() const;
    QString shifted() const;
    QStringList extended() const;
    QStringList extendedShifted() const;

private:
    Q_DISABLE_COPY(KeyInfo);

    Type m_type;
    QString m_normal;
    QString m_shifted;
    QStringList m_extended;
    QStringList m_extendedShifted;
};

}
