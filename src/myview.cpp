/*! \file myview.cpp
    \brief Provides the class myView.

    This file is part of SorpSim and is distributed under terms in the file LICENSE.

    Developed by Zhiyao Yang and Dr. Ming Qu for ORNL.

    \author Zhiyao Yang (zhiyaoYang)
    \author Dr. Ming Qu

    \copyright 2015, UT-Battelle, LLC

*/


#include "myview.h"
#include "mainwindow.h"
#include "unit.h"
#include <QWheelEvent>
#include <QDebug>
#include <math.h>
#include "myscene.h"
#include <QShortcut>

extern unit * dummy;
extern int globalcount;
extern myScene * theScene;

myView::myView(QWidget *parent)
{
    myScale = 1;
}

void myView::wheelEvent(QWheelEvent *event)
{
    int delta = event->angleDelta().y();
    if (delta > 0 && myScale < 2.5)
    {
        this->scale(1.12,1.12);
        myScale = myScale*1.12;
    }
    if (delta < 0 && myScale > 0.7)
    {
        this->scale(0.89,0.89);
        myScale = myScale*0.89;
    }
    setScale();
}

void myView::keyPressEvent(QKeyEvent *event)
{
    switch (event->key()) {
    case Qt::Key_Left:
        moveBy(-10, 0);
        break;
    case Qt::Key_Right:
        moveBy(10, 0);
        break;
    case Qt::Key_Up:
        moveBy(0, -10);
        break;
    case Qt::Key_Down:
        moveBy(0, 10);
        break;
    default:
        QGraphicsView::keyPressEvent(event);
    }
}

void myView::setScale()
{
    unit *iterator = dummy;
    for(int i = 0; i < globalcount;i++)
    {
        iterator = iterator->next;
        iterator->utext->setScale(1/myScale);
        iterator->unitParameter->setScale(1/myScale);
        for(int j = 0; j < iterator->usp;j++)
        {
            iterator->spParameter[j]->setScale(1/myScale);
            iterator->myNodes[j]->text->setScale(1/myScale);
        }
    }
    if(theScene->copRect!=NULL){
        theScene->copRect->setScale(1/myScale);
    }
}

void myView::moveBy(int x, int y)
{
    if (theScene->selectedItems().isEmpty())
        return;

    if(theScene->selectedItems().first()->zValue()==2)
    {
        QGraphicsRectItem* rect = dynamic_cast<QGraphicsRectItem*>(theScene->selectedItems().first());
        rect->moveBy(x, y);
    }
}
