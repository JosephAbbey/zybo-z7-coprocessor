# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "D:\\repos\\zybo-z7-coprocessor\\software\\vitis_workspace\\zybo-z7-coprocessor\\ps7_cortexa9_0\\standalone_ps7_cortexa9_0\\bsp\\include\\sleep.h"
  "D:\\repos\\zybo-z7-coprocessor\\software\\vitis_workspace\\zybo-z7-coprocessor\\ps7_cortexa9_0\\standalone_ps7_cortexa9_0\\bsp\\include\\xiltimer.h"
  "D:\\repos\\zybo-z7-coprocessor\\software\\vitis_workspace\\zybo-z7-coprocessor\\ps7_cortexa9_0\\standalone_ps7_cortexa9_0\\bsp\\include\\xtimer_config.h"
  "D:\\repos\\zybo-z7-coprocessor\\software\\vitis_workspace\\zybo-z7-coprocessor\\ps7_cortexa9_0\\standalone_ps7_cortexa9_0\\bsp\\lib\\libxiltimer.a"
  )
endif()
