# Configuration for Linux on ARM.
# Generating binaries for the ARMv7-a architecture and higher
#
ARCH_ARM_HAVE_ARMV7A            := true
ARCH_ARM_HAVE_VFP               := true

ifeq ($(strip $(TARGET_ARCH_VARIANT_FPU)),neon)
ARCH_ARM_HAVE_NEON              := true
else
ARCH_ARM_HAVE_NEON              :=
endif

ifeq ($(strip $(TARGET_ARCH_VARIANT_CPU)),)
TARGET_ARCH_VARIANT_CPU         := cortex-a9
endif

ifeq ($(strip $(TARGET_CPU_SMP)),true)
ARCH_ARM_HAVE_TLS_REGISTER      := true
endif


ifeq ($(strip $(TARGET_CPU_VARIANT)), cortex-a15)
	arch_variant_cflags := -mcpu=cortex-a15
else
ifeq ($(strip $(TARGET_CPU_VARIANT)),cortex-a9)
	arch_variant_cflags := -mcpu=cortex-a9 -march=armv7-a
else
ifeq ($(strip $(TARGET_CPU_VARIANT)),cortex-a8)
	arch_variant_cflags := -mcpu=cortex-a8
else
ifeq ($(strip $(TARGET_CPU_VARIANT)),cortex-a7)
	arch_variant_cflags := -mcpu=cortex-a7
else
	arch_variant_cflags := -march=armv7-a
endif
endif
endif
endif


# Note: Hard coding the 'tune' value here is probably not ideal,
# and a better solution should be found in the future.
#
arch_variant_cflags += \
    -mfloat-abi=softfp \
    -mfpu=vfpv3-d16

ifneq ($(strip $(TARGET_CPU_VARIANT)),cortex-a8)
arch_variant_ldflags := \
	-Wl,--no-fix-cortex-a8
else
arch_variant_ldflags := \
	-Wl,--fix-cortex-a8
endif
