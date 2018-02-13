# ifneq ("$(shell which x86_64-w64-mingw32-gcc)","")
# compiler = x86_64-w64-mingw32-gcc
# else
# compiler = amd64-mingw32msvc-gcc
# endif
# arch = amd64

ifneq ("$(shell which i686-w64-mingw32-gcc)","")
compiler = i686-w64-mingw32-gcc
else
compiler = i586-mingw32msvc-gcc
endif
arch = 386

# Build the dependencies first (subdirs), then move onto the meat and potatoes.
all: MemoryModule
	CC=$(compiler) CGO_ENABLED=1 GOOS=windows GOARCH=$(arch) go build -x memorymodule.go

# Dependency build. 
SUBDIRS = MemoryModule
subdirs: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@
# Override default subdir build behavior (make) with cmake. 
MemoryModule:
	[ "`ls -A MemoryModule`" ] || git submodule update --init
	cmake -HMemoryModule -BMemoryModule/build
	cmake --build MemoryModule/build --target MemoryModule

# Clean targed. 
CLEANDIRS = $(SUBDIRS:%=clean-%)
clean: $(CLEANDIRS)
	rm -f memorymodule.exe
$(CLEANDIRS): 
	$(MAKE) -C $(@:clean-%=%) clean

test:
	$(MAKE) -C tests test

.PHONY: subdirs $(INSTALLDIRS) $(SUBDIRS) clean test

