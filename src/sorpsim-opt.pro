#-------------------------------------------------
#
# Project created by QtCreator 2013-10-18T10:52:03
#
#-------------------------------------------------

# Usage: make
# Then you get sorpsim-opt[.exe]
TARGET = sorpsim-opt
TEMPLATE = app

QT       += core gui
QT       += xml
QT       += printsupport
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

# Cannot deploy with MSVC unless this ...
CONFIG   += console

#-----------------------------------------------
# Configure qwt
# You may need to set QWT_ROOT for your platform
# (as environment variable, etc)
#-----------------------------------------------
CONFIG   += qwt
win32{
    # QWT_ROOT=\install\qwt-6.1.3
    INCLUDEPATH += $$(QWT_ROOT)/src
    DEPENDPATH += $$(QWT_ROOT)/src
    CONFIG(release, debug|release): LIBS += -L$$(QWT_ROOT)/lib/ -lqwt
    else:CONFIG(debug, debug|release): LIBS += -L$$(QWT_ROOT)/lib/ -lqwtd
}
else:linux{
    QMAKE_CXXFLAGS += -std=c++11
    # If you installed the package libqwt-qt-dev:
    include($$[QT_INSTALL_ARCHDATA]/mkspecs/features/qwt.prf)
    # Eg. look here: /usr/lib/$$system("arch")-linux-gnu/qt5/mkspecs/features/qwt.prf
    # If above doesn't work, try this
    # This works at build time, but on load, QtCreator might think it isn't found
    # include(qwt.prf)
    # Effectively same as
    #INCLUDEPATH += /usr/include/qwt
    #LIBS += -L/usr/lib -lqwt-qt5

    # Else if you build your own qwt
    # QWT_ROOT=/usr/local/qwt-6.1.3
    #LIBS += -L$$(QWT_ROOT)/lib -lqwt
    #INCLUDEPATH += $$(QWT_ROOT)/include
    #DEPENDPATH += $$(QWT_ROOT)/include
    # Else if you want all the variables defined in qwt features
    #include($$(QWT_ROOT)/features/qwt.prf)
}
else:macx {
    # If you just want to use the traditional method
    #INCLUDEPATH += ${QWT_ROOT}/src
    #LIBS += -F${QWT_ROOT}/lib/ -framework qwt

    # Else if you want all the Or - include the qwt library for Mac compilation
    # directory might be different for different machine settings
    # set QWT_ROOT in your environment
    include($$(QWT_ROOT)/features/qwt.prf)
}




#----------------------------------------------
# Conveniences for building to debug and deploy
#----------------------------------------------

# Try to get the version from latest tag in git
include(gitversion.pri)
message(Version $$VERSION)

# Copies the given files to the destination directory
# https://stackoverflow.com/questions/3984104/qmake-how-to-copy-a-file-to-the-output
# Used to install qwt binary for deployment (or other files as needed)
defineReplace(copySafe){
    files = $$1
    DEST = $$2

    for(FILE, files) {

        # Replace slashes in paths with backslashes for Windows
        win32:FILE ~= s,/,\\,g
        win32:DEST ~= s,/,\\,g

        CMD += $$QMAKE_COPY $$quote($$FILE) $$quote($$DEST) $$escape_expand(\\n\\t)
    }

    return($$CMD)
}

# Usage: make install
# This copies the extra resource files (eg *.xml) to the build directory
# but does not really install the program anywhere.
# There is probably another way, to avoid the confusion.

# Note regarding target path: folder structures are different on windows by default
# See https://bugreports.qt.io/browse/QTBUG-52347
# CONFIG -= debug_and_release
TARGET_PATH = $$OUT_PWD
win32:CONFIG(debug, debug|release) {TARGET_PATH = $$OUT_PWD/debug}
win32:CONFIG(release, debug|release) {TARGET_PATH = $$OUT_PWD/release}
mythinga.path = $$TARGET_PATH/settings
mythinga.files = settings/*
mythingb.path = $$TARGET_PATH/templates
mythingb.files = templates/*
INSTALLS += mythinga \
#    mythingb

win32 {
# Usage(Windows only): make deploy
# Drops needed Qt libraries into the build directory so you can run without IDE.
deployall.target = deploy
deployall.depends = deployqwt deployqt
WINDEPLOY = windeployqt.exe
deployqt.commands = $$WINDEPLOY $$TARGET_PATH -opengl
# If something goes wrong, probably you need these:
#-printsupport -svg -xml -opengl -widgets -gui --angle -concurrent -core
CONFIG(debug, debug|release){ qwtdll = $$(QWTPATH)/lib/qwtd.dll }
CONFIG(release, debug|release){ qwtdll = $$(QWTPATH)/lib/qwt.dll }
deployqwt.commands = $$copySafe($$qwtdll, $$TARGET_PATH)

QMAKE_EXTRA_TARGETS += deployall deployqt deployqwt
}

macx {
BUNDLE_NAME = $${TARGET}.app
BUNDLE_PATH = $$OUT_PWD/$$BUNDLE_NAME
EXE_PATH = $$BUNDLE_PATH/Contents/MacOS/$$TARGET
QWT_DEST = $$BUNDLE_PATH/Contents/Frameworks/qwt.framework
# Usage: make deploy
# - Installs qwt.framework in the bundle (deployqwt)
# - Runs the Qt deployment tool (deployqt)
# - Edits the Info.plist file for "Get info" dialogs (deployinfo)
deployall.target = deploy
deployall.depends = deployqwt deployqt deployinfo
MACDEPLOY = macdeployqt
deployqt.depends = deployqwt
deployqt.commands = $$MACDEPLOY $$BUNDLE_PATH
deployqwt.depends = deployqwt1 deployqwt2
deployqwt1.target = $$BUNDLE_NAME/Contents/Frameworks/qwt.framework/qwt
deployqwt1.commands = test -d $$BUNDLE_PATH/Contents/Frameworks || mkdir -p $$BUNDLE_PATH/Contents/Frameworks $$escape_expand(\\n\\t)
deployqwt1.commands += $$QMAKE_DEL_TREE $$QWT_DEST $$escape_expand(\\n\\t)
deployqwt1.commands += $$QMAKE_COPY_DIR $$QWT_INSTALL_LIBS/qwt.framework $$QWT_DEST
deployqwt2.depends = $(TARGET)
deployqwt2.commands = install_name_tool -change qwt.framework/Versions/6/qwt @executable_path/../Frameworks/qwt.framework/Versions/6/qwt $$EXE_PATH
deployinfo.depends = $(TARGET)
deployinfo.commands = defaults write $$BUNDLE_PATH/Contents/Info.plist \"CFBundleGetInfoString\" \'$$SORPVERSION\' $$escape_expand(\\n\\t)
deployinfo.commands += defaults write $$BUNDLE_PATH/Contents/Info.plist \"CFBundleIdentifier\" \'info.nfette.sorpsim-opt\'

QMAKE_EXTRA_TARGETS += deployall deployqt deployqwt deployqwt1 deployqwt2 deployinfo

# This goes with something else above ... need to improve structure
macx:mythinga.path = $$BUNDLE_PATH/Contents/Resources/settings
}

SOURCES += main.cpp \
    unitconvert.cpp \
    unit.cpp \
    treedialog.cpp \
    tableselectparadialog.cpp \
    tabledialog.cpp \
    spscene.cpp \
    spdialog.cpp \
    selectparadialog.cpp \
    resultdisplaydialog.cpp \
    resultdialog.cpp \
    plotproperty.cpp \
    node.cpp \
    myview.cpp \
    myscene.cpp \
    mainwindow.cpp \
    linkdialog.cpp \
    link.cpp \
    globaldialog.cpp \
    fluiddialog.cpp \
    editunitdialog.cpp \
    calculate.cpp \
    arrow.cpp \
    altervdialog.cpp \
    adrowdialog.cpp \
    masterdialog.cpp \
    masterpanelcell.cpp \
    syssettingdialog.cpp \
    guessdialog.cpp \
    airarrow.cpp \
    zigzag.cpp \
    packings.cpp \
    coils.cpp \
    ldaccompdialog.cpp \
    splitterdialog.cpp \
    ntuestimatedialog.cpp \
    startdialog.cpp \
    valvedialog.cpp \
    pumpdialog.cpp \
    qgraphicsarc.cpp \
    vicheckdialog.cpp \
    iwfixdialog.cpp \
    ipfixdialog.cpp \
    iffixdialog.cpp \
    icfixdialog.cpp \
    dataComm.cpp \
    insidelink.cpp \
    dehumeffdialog.cpp \
    estntueffdialog.cpp \
    linkfluiddialog.cpp \
    newparaplotdialog.cpp \
    plotsdialog.cpp \
    newpropplotdialog.cpp \
    calcdetaildialog.cpp \
    edittabledialog.cpp \
    helpdialog.cpp \
    sorpsimEngine.cpp \
    overlaysettingdialog.cpp \
    texteditdialog.cpp \
    unitsettingdialog.cpp \
    curvesettingdialog.cpp \
    editpropertycurvedialog.cpp \
    ifixdialog.cpp \
    sorputils.cpp \
    version.cpp

HEADERS  += \
    unitconvert.h \
    unit.h \
    treedialog.h \
    tableselectparadialog.h \
    tabledialog.h \
    spscene.h \
    spdialog.h \
    selectparadialog.h \
    resultdisplaydialog.h \
    resultdialog.h \
    plotproperty.h \
    node.h \
    myview.h \
    myscene.h \
    mainwindow.h \
    linkdialog.h \
    link.h \
    globaldialog.h \
    fluiddialog.h \
    editunitdialog.h \
    calculate.h \
    arrow.h \
    altervdialog.h \
    adrowdialog.h \
    masterdialog.h \
    masterpanelcell.h \
    dataComm.h \
    fem.hpp \
    syssettingdialog.h \
    guessdialog.h \
    airarrow.h \
    zigzag.h \
    packings.h \
    coils.h \
    ldaccompdialog.h \
    splitterdialog.h \
    ntuestimatedialog.h \
    startdialog.h \
    valvedialog.h \
    pumpdialog.h \
    qgraphicsarc.h \
    vicheckdialog.h \
    iwfixdialog.h \
    ipfixdialog.h \
    iffixdialog.h \
    icfixdialog.h \
    insidelink.h \
    dehumeffdialog.h \
    estntueffdialog.h \
    linkfluiddialog.h \
    newparaplotdialog.h \
    plotsdialog.h \
    newpropplotdialog.h \
    calcdetaildialog.h \
    editpropertycurvedialog.h \
    edittabledialog.h \
    helpdialog.h \
    sorpsimEngine.h \
    overlaysettingdialog.h \
    texteditdialog.h \
    unitsettingdialog.h \
    curvesettingdialog.h \
    ifixdialog.h \
    sorputils.h \
    version.h

FORMS    += \
    treedialog.ui \
    tableselectparadialog.ui \
    tabledialog.ui \
    spdialog.ui \
    selectparadialog.ui \
    resultdisplaydialog.ui \
    resultdialog.ui \
    mainwindow.ui \
    linkdialog.ui \
    globaldialog.ui \
    fluiddialog.ui \
    editUnitDialog.ui \
    altervdialog.ui \
    adrowdialog.ui \
    masterdialog.ui \
    syssettingdialog.ui \
    guessdialog.ui \
    ldaccompdialog.ui \
    splitterdialog.ui \
    ntuestimatedialog.ui \
    startdialog.ui \
    valvedialog.ui \
    pumpdialog.ui \
    vicheckdialog.ui \
    iwfixdialog.ui \
    ipfixdialog.ui \
    iffixdialog.ui \
    icfixdialog.ui \
    dehumeffdialog.ui \
    estntueffdialog.ui \
    linkfluiddialog.ui \
    newparaplotdialog.ui \
    plotsdialog.ui \
    newpropplotdialog.ui \
    calcdetaildialog.ui \
    editpropertycurvedialog.ui \
    edittabledialog.ui \
    helpdialog.ui \
    overlaysettingdialog.ui \
    texteditdialog.ui \
    unitsettingdialog.ui \
    curvesettingdialog.ui \
    ifixdialog.ui

RESOURCES += \
    functionIcons.qrc \
    examples.qrc
