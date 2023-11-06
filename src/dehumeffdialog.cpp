/*! \file dehumeffdialog.cpp
    \brief Dialog used to specify liquid desiccant component heat/mass transfer

    This file is part of SorpSim and is distributed under terms in the file LICENSE.

    Developed by Zhiyao Yang and Dr. Ming Qu for ORNL.

    \author Zhiyao Yang (zhiyaoYang)
    \author Dr. Ming Qu
    \author Nicholas Fette (nfette)

    \copyright 2015, UT-Battelle, LLC
    \copyright 2017-2018, Nicholas Fette

*/

#include <QDoubleValidator>
#include <QMessageBox>
#include <QRegularExpression>
#include <QRegularExpressionValidator>
#include <QValidator>

#include "dehumeffdialog.h"
#include "ui_dehumeffdialog.h"
#include "estntueffdialog.h"
#include "mainwindow.h"

extern MainWindow*theMainwindow;
dehumEffDialog*dhefDialog;

dehumEffDialog::dehumEffDialog(unit*unit, QWidget *parent) :
    QDialog(parent),
    ui(new Ui::dehumEffDialog)
{
    ui->setupUi(this);
    myUnit = unit;
    setWindowTitle("Effectiveness Model Setup");
    dhefDialog = this;
    setWindowFlags(Qt::Dialog);
    setWindowModality(Qt::ApplicationModal);
    if(myUnit->iht ==2)//NTU
    {
        ui->NTUButton->setChecked(true);
        ui->NTULine->setText(QString::number(myUnit->ht,'g',4));
    }
    else //if(myUnit->iht==3)//EFF or initialization
    {
        ui->effButton->setChecked(true);
        ui->effLine->setText(QString::number(myUnit->ht,'g',4));
        ui->estNTUButton->setDisabled(true);
        ui->LeLE->setVisible(false);
    }

    ui->LeLE->setText(QString::number(myUnit->le));
    connect(ui->effButton,SIGNAL(toggled(bool)),ui->effLine,SLOT(setEnabled(bool)));
    connect(ui->NTUButton,SIGNAL(toggled(bool)),ui->NTULine,SLOT(setEnabled(bool)));
    connect(ui->NTUButton,SIGNAL(toggled(bool)),ui->leLabel,SLOT(setVisible(bool)));
    connect(ui->NTUButton,SIGNAL(toggled(bool)),ui->LeLE,SLOT(setVisible(bool)));
    connect(ui->NTUButton,SIGNAL(toggled(bool)),ui->estNTUButton,SLOT(setEnabled(bool)));
    connect(ui->effButton,SIGNAL(clicked()),ui->NTULine,SLOT(clear()));
    connect(ui->NTUButton,SIGNAL(clicked()),ui->effLine,SLOT(clear()));

    QLayout *mainLayout = layout();
    mainLayout->setSizeConstraint(QLayout::SetFixedSize);

    QValidator *inputRange = new QDoubleValidator(0,1,7,this);
    QRegularExpressionValidator *regExpValidator = new QRegularExpressionValidator(QRegularExpression("[-.0-9]+$"), this);
    ui->effLine->setValidator(inputRange);
    ui->NTULine->setValidator(regExpValidator);
}

dehumEffDialog::~dehumEffDialog()
{
    dhefDialog = NULL;
    delete ui;
}

void dehumEffDialog::on_OKButton_clicked()
{
    if(ui->NTUButton->isChecked())
    {
        myUnit->ht=ui->NTULine->text().toDouble();
        myUnit->NTUm = myUnit->ht;
        myUnit->iht=2;
        myUnit->le = ui->LeLE->text().toDouble();
    }
    else if(ui->effButton->isChecked())
    {
        myUnit->ht=ui->effLine->text().toDouble();
        myUnit->eff = myUnit->ht;
        myUnit->iht=3;
    }
    accept();
}

void dehumEffDialog::on_cancelButton_clicked()
{
    reject();
}

void dehumEffDialog::on_estNTUButton_clicked()
{
    estNtuEffDialog eDialog(myUnit->myNodes[3],this);
    if(eDialog.exec()==QDialog::Accepted)
        ui->NTULine->setText(QString::number(eDialog.getNTUestimate(),'g',4));
}

void dehumEffDialog::on_effLine_textEdited(const QString &arg1)
{
    if(arg1.toDouble()>1)
    {
        QMessageBox::warning(this, "Warning", "Effectiveness can not be larger than 1. Please revise.");
        ui->effLine->clear();
    }
}

bool dehumEffDialog::event(QEvent *e)
{

    if(e->type()==QEvent::ActivationChange)
    {
        if(qApp->activeWindow()==this)
        {
            theMainwindow->show();
            theMainwindow->raise();
            this->raise();
            this->setFocus();
        }
    }
    return QDialog::event(e);
}
