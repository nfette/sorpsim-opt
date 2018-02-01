#include "version.h"

#ifdef GIT_VERSION
const QString SORP_VERSION = GIT_VERSION;
#else
const QString SORP_VERSION = "Custom build";
#endif

