set(TARGET_ARCH "armv8" CACHE STRING "Options: \"native\", \"armv7\", \"armv8\", or \"other\"." FORCE)
# The stack_size and heap_size variables are ignored here, because they are
# overwritten in CakeMLHelper.cmake
set(CAKE_FLAGS "--target=arm8 --stack_size=1 --heap_size=1" CACHE STRING "Arguments passed to the CakeML compiler" FORCE)
set(STATIC_LINKING on CACHE BOOL "" FORCE)
set(IS_VM_USERAM true)
