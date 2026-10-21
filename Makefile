export TARGET = iphone:clang:latest:15.0
export ARCHS = arm64 arm64e
export THEOS_PACKAGE_SCHEME = rootless

# Pass your device on the command line instead of committing it, e.g.:
#   make package install THEOS_DEVICE_IP=192.168.1.50

include $(THEOS)/makefiles/common.mk

GO_EASY_ON_ME = 1

TWEAK_NAME = S8Edge
S8Edge_FILES = Tweak.xm CustoWindow.m
S8Edge_FRAMEWORKS = UIKit QuartzCore CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += s8edgeprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
