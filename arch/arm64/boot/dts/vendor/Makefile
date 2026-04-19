vendor := $(srctree)/$(src)

ifneq "$(wildcard $(vendor)/moorechip)" ""
	subdir-y += moorechip
else ifneq "$(wildcard $(vendor)/qcom)" ""
	subdir-y += qcom
endif
