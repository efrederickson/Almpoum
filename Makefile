ARCHS = armv7 armv7s arm64
THEOS_DEVICE_IP = 192.168.7.146
CFLAGS = -fobjc-arc
TARGET = iphone:clang:7.1:7.1
THEOS_PACKAGE_DIR_NAME = debs

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Almpoum
Almpoum_FILES = ALAssetsLibrary+CustomPhotoAlbum.m Tweak.xm MLIMGURUploader.m
Almpoum_FRAMEWORKS = AssetsLibrary MobileCoreServices UIKit CoreGraphics AudioToolbox ImageIO

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences"
SUBPROJECTS += almpoumsettings
include $(THEOS_MAKE_PATH)/aggregate.mk
