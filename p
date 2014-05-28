diff --git a/core/binary.mk b/core/binary.mk
index 571ab24..1b01335 100644
--- a/core/binary.mk
+++ b/core/binary.mk
@@ -133,7 +133,7 @@ ifeq ($(strip $(LOCAL_NO_LTO_SUPPORT)),)
     ifeq ($(strip $(LOCAL_IS_HOST_MODULE)),)
       LOCAL_CFLAGS += $(TARGET_LTO_CFLAGS)
       LOCAL_CPPFLAGS += $(TARGET_LTO_CFLAGS)
-      LOCAL_LDFLAGS += $(TARGET_LTO_CFLAGS)
+      LOCAL_LDFLAGS += $(TARGET_LTO_LDFLAGS)
     endif
   endif
 endif
diff --git a/core/combo/TARGET_linux-arm.mk b/core/combo/TARGET_linux-arm.mk
index bde1d6f..b71d00e 100644
--- a/core/combo/TARGET_linux-arm.mk
+++ b/core/combo/TARGET_linux-arm.mk
@@ -178,7 +178,7 @@ TARGET_GLOBAL_LDFLAGS += \
 
 TARGET_GLOBAL_CFLAGS += -mthumb-interwork
 
-TARGET_GLOBAL_CPPFLAGS += -fvisibility-inlines-hidden -use-gold-plugin
+TARGET_GLOBAL_CPPFLAGS += -fvisibility-inlines-hidden -flto -use-gold-plugin
 ifneq ($(DEBUG_NO_STDCXX11),yes)
   TARGET_GLOBAL_CPPFLAGS += -std=gnu++11
 endif
@@ -213,8 +213,10 @@ endif
 # Define LTO (Link-Time Optimization) options.
 
 TARGET_LTO_CFLAGS :=
+TARGET_LTO_LDFLAGS :=
 ifneq ($(DEBUG_NO_LTO),yes)
-TARGET_LTO_CFLAGS := -flto -fno-toplevel-reorder
+TARGET_LTO_CFLAGS := -flto -fno-toplevel-reorder -fuse-linker-plugin
+TARGET_LTO_LDFLAGS := -Wl,-flto
 endif
 
 # Define FDO (Feedback Directed Optimization) options.
diff --git a/core/combo/arch/arm/armv7-a.mk b/core/combo/arch/arm/armv7-a.mk
index 4a51977..dc96a92 100644
--- a/core/combo/arch/arm/armv7-a.mk
+++ b/core/combo/arch/arm/armv7-a.mk
@@ -4,13 +4,36 @@
 ARCH_ARM_HAVE_ARMV7A            := true
 ARCH_ARM_HAVE_VFP               := true
 
+ifeq ($(strip $(TARGET_CPU_VARIANT)), cortex-a15)
+	arch_variant_cflags := -mcpu=cortex-a15
+else
+ifeq ($(strip $(TARGET_CPU_VARIANT)),cortex-a9)
+	arch_variant_cflags := -mcpu=cortex-a9
+else
+ifeq ($(strip $(TARGET_CPU_VARIANT)),cortex-a8)
+	arch_variant_cflags := -mcpu=cortex-a8
+else
+ifeq ($(strip $(TARGET_CPU_VARIANT)),cortex-a7)
+	arch_variant_cflags := -mcpu=cortex-a7
+else
+	arch_variant_cflags := -march=armv7-a
+endif
+endif
+endif
+endif
+
+
 # Note: Hard coding the 'tune' value here is probably not ideal,
 # and a better solution should be found in the future.
 #
-arch_variant_cflags := \
-    -march=armv7-a \
+arch_variant_cflags += \
     -mfloat-abi=softfp \
     -mfpu=vfpv3-d16
 
+ifneq ($(strip $(TARGET_CPU_VARIANT)),cortex-a8)
+arch_variant_ldflags := \
+	-Wl,--no-fix-cortex-a8
+else
 arch_variant_ldflags := \
 	-Wl,--fix-cortex-a8
+endif
