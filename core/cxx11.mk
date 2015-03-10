MODULE_DISABLE_CXX11 := libminui libbinder \

ifneq (1,$(words $(filter $(MODULE_DISABLE_CXX11), $(LOCAL_MODULE))))
  $(combo_2nd_arch_prefix)TARGET_GLOBAL_CPPFLAGS += -std=gnu++11
endif
