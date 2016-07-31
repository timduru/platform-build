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

TTARGET := $(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)

#default fallback
arch_variant_cflags := -march=armv7-a
# Generic ARM might be a Cortex A8 -- better safe than sorry
arch_variant_ldflags := \
                -Wl,--fix-cortex-a8

ifneq (,$(filter cortex-a15 krait denver,$(TTARGET)))
        # TODO: krait is not a cortex-a15, we set the variant to cortex-a15 so that
        #       hardware divide operations are generated. This should be removed and a
        #       krait CPU variant added to GCC. For clang we specify -mcpu for krait in
        #       core/clang/arm.mk.
        arch_variant_cflags := -mcpu=cortex-a15 -mtune=cortex-a15

        # Fake an ARM compiler flag as these processors support LPAE which GCC/clang
        # don't advertise.
        arch_variant_cflags += -D__ARM_FEATURE_LPAE=1
        arch_variant_ldflags := \
                -Wl,--no-fix-cortex-a8
else
ifneq (,$(filter cortex-a9 cortex-a8 cortex-a7,$(TTARGET)))
        arch_variant_cflags := -mcpu=$(TTARGET) -mtune=$(TTARGET)
        arch_variant_ldflags := \
                -Wl,--no-fix-cortex-a8
endif
endif

# Note: Hard coding the 'tune' value here is probably not ideal,
# and a better solution should be found in the future.
#
arch_variant_cflags += \
    -mfloat-abi=softfp \
    -mfpu=vfpv3-d16

