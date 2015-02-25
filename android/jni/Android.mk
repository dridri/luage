LOCAL_PATH:= $(call my-dir)

# ------------------------------------------------------------------
# Static library
# ------------------------------------------------------------------

include $(CLEAR_VARS)

LOCAL_MODULE := ge

ifneq (,$(filter $(TARGET_ARCH), x86_64 arm64 arm64-v8 mips64))
	ARCH = 64
else
	ARCH = 32
endif

# all:
# 	rm -rf assets/*
# 	cp ../*.lua assets
# 	cp -R ../data assets
# 	cp -R ../languages assets
# 	cp -R ../gelua assets
# 	cp -R ../default_shaders assets
# 	cp -R ../shaders assets

LOCAL_SRC_FILES = ../../src/main.c

LOCAL_LDFLAGS := -fPIC
LOCAL_CFLAGS := -std=gnu99 -fPIC -DPLATFORM_android -I../build

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)

LOCAL_LDLIBS    := -lge -llua52 -lfreetype2-static -ljpeg9 -lpng -lz -lm -llog -landroid -lEGL -lGLESv2
LOCAL_WHOLE_STATIC_LIBRARIES := android_native_app_glue

include $(BUILD_SHARED_LIBRARY)

$(call import-module, android/native_app_glue)
