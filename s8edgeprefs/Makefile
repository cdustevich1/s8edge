include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = S8EdgePrefs
S8EdgePrefs_FILES = S8ERootListController.m
S8EdgePrefs_INSTALL_PATH = /Library/PreferenceBundles
S8EdgePrefs_FRAMEWORKS = UIKit
S8EdgePrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

# The PreferenceLoader entry lives in layout/Library/PreferenceLoader/Preferences/,
# which Theos stages under the rootless prefix (/var/jb) automatically.
