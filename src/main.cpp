/*! \file main.cpp
    \brief SorpSim application entry point

    This file is part of SorpSim and is distributed under terms in the file LICENSE.

    Developed by Zhiyao Yang and Dr. Ming Qu for ORNL.

    \author Zhiyao Yang (zhiyaoYang)
    \author Dr. Ming Qu
    \author Nicholas Fette (nfette)

    \copyright 2015, UT-Battelle, LLC
    \copyright 2017-2018, Nicholas Fette

*/


#include "mainwindow.h"
#include <QApplication>
#include <QDomImplementation>
#include <QDebug>

/// start a new mainwindow and leave all interactions to the mainwindow
/// - once the mainwindow is closed, the application is closed as well
/// - first subroutine to run at SorpSim's launch
int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    QDomImplementation::setInvalidDataPolicy(QDomImplementation::ReturnNullNode);

    QDir dir = qApp->applicationDirPath();
    qDebug() << "applicationDirPath() =" << dir;
    qDebug() << "absolutePath() =" << dir.absolutePath();
    qDebug() << "canonicalPath =" << dir.canonicalPath();

    QDir dir2;
    qDebug() << "Default dir =" << dir2;
    qDebug() << "absolutePath =" << dir2.absolutePath();
    qDebug() << "canonicalPath =" << dir2.canonicalPath();

    MainWindow w;
    w.show();
    return a.exec();
}
