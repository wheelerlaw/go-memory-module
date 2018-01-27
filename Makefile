ifneq ("$(shell which i686-w64-mingw32-gcc)","")
compiler = i686-w64-mingw32-gcc
else
compiler = i586-mingw32msvc-gcc
endif

# Build the dependencies first (subdirs), then move onto the meat and potatoes.
all: MemoryModule
	CC=$(compiler) CGO_ENABLED=1 GOOS=windows GOARCH=386 go build -x memorymodule.go

# Dependency build. 
SUBDIRS = MemoryModule
subdirs: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@
# Override default subdir build behavior (make) with cmake. 
MemoryModule:
	[ "`ls -A MemoryModule`" ] || git submodule update --init
	$(MAKE) -C $@
	# cmake -HMemoryModule -BMemoryModule/build
	# cmake --build MemoryModule/build --target MemoryModule

# Clean targed. 
CLEANDIRS = $(SUBDIRS:%=clean-%)
clean: $(CLEANDIRS)
	rm -f memorymodule.exe
$(CLEANDIRS): 
	$(MAKE) -C $(@:clean-%=%) clean

test:
	$(MAKE) -C tests test

.PHONY: subdirs $(INSTALLDIRS) $(SUBDIRS) clean test

