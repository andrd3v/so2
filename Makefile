ARCHS = arm64
TARGET := iphone:clang:latest:latest
DEBUG = 1
FINALPACKAGE = 0
FOR_RELEASE = 0
THEOS_PACKAGE_SCHEME = roothide
include $(THEOS)/makefiles/common.mk
#TARGET_CC = /Users/andr/IB/reverse/Hikari-LLVM15/build/bin/clang
#TARGET_CXX = /Users/andr/IB/reverse/Hikari-LLVM15/build/bin/clang++

TWEAK_NAME = drugs

$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController

$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -fexceptions -DNDEBUG -Wall -Wextra -g3 -O0 -DDEBUG -Wc++17-narrowing -Wno-narrowing -Wundefined-bool-conversion -Wreturn-stack-address -Wno-error=format-security -fvisibility=hidden -fpermissive -fexceptions -w -s -Wno-error=format-security -fvisibility=hidden -Werror -fpermissive
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -fvisibility=hidden -Wc++17-narrowing -Wno-narrowing -Wundefined-bool-conversion -Wreturn-stack-address -Wno-error=format-security -Wno-undefined-bool-conversion -Wno-unused-variable -Wno-unused-function -Wno-unused-parameter -Wno-deprecated-declarations -Wno-unused-value -Wno-module-import-in-extern-c -fvisibility=hidden -fpermissive -fexceptions -w -s -Wno-error=format-security -fvisibility=hidden -Werror -fpermissive -Wall -Wextra -g3 -O0 -DDEBUG -fexceptions #-mllvm -enable-acdobf -mllvm -bcf_cond_compl=3 -mllvm -bcf_prob=80 -mllvm -bcf_loop=15 -mllvm -enable-funcwra -mllvm -fw_prob=80 -mllvm -fw_times=15 -mllvm -enable-indibran -mllvm -enable-strcry -mllvm -enable-fco -mllvm -enable-constenc -w -mllvm -enable-adb
$(TWEAK_NAME)_OBJ_FILES = $(shell find . -type f \( -iname "*.a" \))
$(TWEAK_NAME)_LOGOS_DEFAULT_GENERATOR = internal
$(TWEAK_NAME)_FILES = $(shell find . -type f \( -iname "*.cpp" -o -iname "*.m" -o -iname "*.c" -o -iname "*.mm" -o -iname "*.xm" -o -iname "*.x" \))



include $(THEOS_MAKE_PATH)/tweak.mk


after-stage::
	@echo "Moving dylib to packages directory"
	mv $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/drugs.dylib packages
