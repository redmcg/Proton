##
## Nested make
##

SHELL := /bin/bash

ifneq ($(NO_NESTED_MAKE),1)
# Pass all variables/goals to ourselves as a sub-make such that we will get a trailing error message upon failure.  (We
# invoke a lot of long-running build-steps, and make fails to re-print errors when they happened ten thousand lines
# ago.)
export
.DEFAULT_GOAL := default
.PHONY: $(MAKECMDGOALS) default nested_make
default $(MAKECMDGOALS): nested_make

nested_make:
	+$(MAKE) $(MAKECMDGOALS) -f $(firstword $(MAKEFILE_LIST)) NO_NESTED_MAKE=1

else # (Rest of the file is the else)

##
## General/global config
##

# We expect the configure script to conditionally set the following:
#   SRCDIR          - Path to source
#   BUILD_NAME      - Name of the build for manifests etc.
#   WITH_FFMPEG     - 1 if including ffmpeg steps

ifeq ($(SRCDIR),)
	foo := $(error SRCDIR not set, do not include makefile_base directly, run ./configure.sh to generate Makefile)
endif

# If CC is coming from make's defaults or nowhere, use our own default.  Otherwise respect environment.
ifneq ($(filter default undefined,$(origin CC)),)
#	CC = ccache gcc
	CC = gcc
endif
ifneq ($(filter default undefined,$(origin CXX)),)
#	CXX = ccache g++
	CXX = g++
endif

export CC
export CXX

cc-option = $(shell if test -z "`echo 'void*p=1;' | \
              $(1) $(2) -S -o /dev/null -xc - 2>&1 | grep -- $(2) -`"; \
              then echo "$(2)"; else echo "$(3)"; fi ;)

# Selected container mode shell
DOCKER_SHELL_BASE = docker run --rm --init -v $(HOME):$(HOME) -w $(CURDIR) -e HOME=$(HOME) \
                                    -v /etc/passwd:/etc/passwd:ro -u $(shell id -u):$(shell id -g) -h $(shell hostname) \
                                    -v /tmp:/tmp $(SELECT_DOCKER_IMAGE) /dev/init -sg -- /bin/bash

# If STEAMRT64_MODE/STEAMRT32_MODE is set, set the nested SELECT_DOCKER_IMAGE to the _IMAGE variable and eval
# DOCKER_SHELL_BASE with it to create the CONTAINER_SHELL setting.
ifeq ($(STEAMRT64_MODE),docker)
	SELECT_DOCKER_IMAGE := $(STEAMRT64_IMAGE)
	CONTAINER_SHELL64 := $(DOCKER_SHELL_BASE)
else ifneq ($(STEAMRT64_MODE),)
	foo := $(error Unrecognized STEAMRT64_MODE $(STEAMRT64_MODE))
endif
ifeq ($(STEAMRT32_MODE),docker)
	SELECT_DOCKER_IMAGE := $(STEAMRT32_IMAGE)
	CONTAINER_SHELL32 := $(DOCKER_SHELL_BASE)
else ifneq ($(STEAMRT32_MODE),)
	foo := $(error Unrecognized STEAMRT32_MODE $(STEAMRT32_MODE))
endif

SELECT_DOCKER_IMAGE :=

# If we're using containers to sub-invoke the various builds, jobserver won't work, have some silly auto-jobs
# controllable by SUBMAKE_JOBS.  Not ideal.
ifneq ($(CONTAINER_SHELL32)$(CONTAINER_SHELL64),)
	SUBMAKE_JOBS ?= 24
	MAKE := make -j$(SUBMAKE_JOBS)
endif

# Use default shell if no STEAMRT_ variables setup a container to invoke.  Commands will just run natively.
ifndef CONTAINER_SHELL64
	CONTAINER_SHELL64 := $(SHELL)
endif
ifndef CONTAINER_SHELL32
	CONTAINER_SHELL32 := $(SHELL)
endif

# Helper to test
.PHONY: test-container test-container32 test-container64
test-container: test-container64 test-container32

test-container64:
	@echo >&2 ":: Testing 64-bit container"
	$(CONTAINER_SHELL64) -c "echo Hello World!"

test-container32:
	@echo >&2 ":: Testing 32-bit container"
	$(CONTAINER_SHELL32) -c "echo Hello World!"

# Many of the configure steps below depend on the makefile itself, such that they are dirtied by changing the recipes
# that create them.  This can be annoying when working on the makefile, building with NO_MAKEFILE_DEPENDENCY=1 disables
# this.
MAKEFILE_DEP := $(MAKEFILE_LIST)
ifeq ($(NO_MAKEFILE_DEPENDENCY),1)
MAKEFILE_DEP :=
endif

##
## Global config
##

TOOLS_DIR32 := ./obj-tools32
TOOLS_DIR64 := ./obj-tools64
DST_BASE := ./dist
DST_DIR := $(DST_BASE)/dist
DEPLOY_DIR := ./deploy

# TODO Release/debug configuration
INSTALL_PROGRAM_FLAGS :=

# All top level goals.  Lazy evaluated so they can be added below.
GOAL_TARGETS = $(GOAL_TARGETS_LIBS)
# Excluding goals like wine and dist that are either long running or slow per invocation
GOAL_TARGETS_LIBS =
# Any explicit thing, superset
ALL_TARGETS =

##
## Platform-specific variables
##

STRIP := strip
WINE32_AUTOCONF :=
WINE64_AUTOCONF :=

OPTIMIZE_FLAGS := -O2 -march=nocona $(call cc-option,$(CC),-mtune=core-avx2,) -mfpmath=sse
SANITY_FLAGS   := -fwrapv -fno-strict-aliasing
COMMON_FLAGS   := $(OPTIMIZE_FLAGS) $(SANITY_FLAGS)

# Use $(call QUOTE,$(VAR)) to flatten a list to a single element (for feeding to a shell)

# v-- This flattens a list when called. Don't look directly into it.
QUOTE = $(subst $(eval) ,\ ,$(1))
QUOTE_VARIABLE = $(eval $(1) := $$(call QUOTE,$$($(1))))
QUOTE_VARIABLE_LIST = $(foreach a,$(1),$(call QUOTE_VARIABLE,$(a)))

# These variables might need to be quoted, but might not
#
#   That is, $(STRIP) is how you invoke strip, STRIP=$(STRIP_QUOTED) is how you pass it to a shell script properly
#   quoted
STRIP_QUOTED = $(call QUOTE,$(STRIP))
CC_QUOTED    = $(call QUOTE,$(CC))
CXX_QUOTED   = $(call QUOTE,$(CXX))

##
## Target configs
##

LICENSE := $(SRCDIR)/dist.LICENSE

GECKO_VER := 2.47
GECKO32_MSI := wine_gecko-$(GECKO_VER)-x86.msi
GECKO64_MSI := wine_gecko-$(GECKO_VER)-x86_64.msi

FFMPEG := $(SRCDIR)/ffmpeg
FFMPEG_OBJ32 := ./obj-ffmpeg32
FFMPEG_OBJ64 := ./obj-ffmpeg64
FFMPEG_CROSS_CFLAGS :=
FFMPEG_CROSS_LDFLAGS :=

FAUDIO := $(SRCDIR)/FAudio
FAUDIO_OBJ32 := ./obj-faudio32
FAUDIO_OBJ64 := ./obj-faudio64

WINE := $(SRCDIR)/wine
WINE_DST32 := ./dist-wine32
WINE_OBJ32 := ./obj-wine32
WINE_OBJ64 := ./obj-wine64
WINEMAKER := $(abspath $(WINE)/tools/winemaker/winemaker)

# Wine outputs that need to exist for other steps (dist)
WINE_OUT_BIN := $(DST_DIR)/bin/wine64
WINE_OUT_SERVER := $(DST_DIR)/bin/wineserver
WINE_OUT := $(WINE_OUT_BIN) $(WINE_OUT_SERVER)
# Tool-only build outputs needed for other projects
WINEGCC32 := $(TOOLS_DIR32)/bin/winegcc
WINEBUILD32 := $(TOOLS_DIR32)/bin/winebuild
WINE_BUILDTOOLS32 := $(WINEGCC32) $(WINEBUILD32)
WINEGCC64 := $(TOOLS_DIR64)/bin/winegcc
WINEBUILD64 := $(TOOLS_DIR64)/bin/winebuild
WINE_BUILDTOOLS64 := $(WINEGCC64) $(WINEBUILD64)

CMAKE := $(SRCDIR)/cmake
CMAKE_OBJ32 := ./obj-cmake32
CMAKE_OBJ64 := ./obj-cmake64
CMAKE_BIN32 := $(CMAKE_OBJ32)/built/bin/cmake
CMAKE_BIN64 := $(CMAKE_OBJ64)/built/bin/cmake

FONTS := $(SRCDIR)/fonts
FONTS_OBJ := ./obj-fonts

## Object directories
OBJ_DIRS := $(TOOLS_DIR32)        $(TOOLS_DIR64)        \
            $(FFMPEG_OBJ32)       $(FFMPEG_OBJ64)       \
            $(FAUDIO_OBJ32)       $(FAUDIO_OBJ64)       \
            $(WINE_OBJ32)         $(WINE_OBJ64)         \
            $(CMAKE_OBJ32)        $(CMAKE_OBJ64)

$(OBJ_DIRS):
	mkdir -p $@

##
## dist/install -- steps to finalize the install
##

$(DST_DIR):
	mkdir -p $@

DIST_LICENSE := $(DST_BASE)/LICENSE
DIST_GECKO_DIR := $(DST_DIR)/share/wine/gecko
DIST_GECKO32 := $(DIST_GECKO_DIR)/$(GECKO32_MSI)
DIST_GECKO64 := $(DIST_GECKO_DIR)/$(GECKO64_MSI)
DIST_FONTS := $(DST_DIR)/share/fonts

DIST_TARGETS := $(DIST_GECKO32) $(DIST_GECKO64) \
                $(DIST_FONTS) $(DIST_LICENSE)

DEPLOY_COPY_TARGETS := $(DIST_COPY_TARGETS) $(DIST_LICENSE)

$(DIST_LICENSE): $(LICENSE)
	cp -a $< $@

$(DIST_COPY_TARGETS): | $(DST_DIR)
	cp -a $(SRCDIR)/$(notdir $@) $@

$(DIST_GECKO_DIR):
	mkdir -p $@

$(DIST_GECKO64): | $(DIST_GECKO_DIR)
	if [ -e "$(SRCDIR)/../gecko/$(GECKO64_MSI)" ]; then \
		cp "$(SRCDIR)/../gecko/$(GECKO64_MSI)" "$@"; \
	else \
		mkdir -p $(SRCDIR)/contrib/; \
		if [ ! -e "$(SRCDIR)/contrib/$(GECKO64_MSI)" ]; then \
			echo ">>>> Downloading wine-gecko. To avoid this in future, put it here: $(SRCDIR)/../gecko/$(GECKO64_MSI)"; \
			wget -O "$(SRCDIR)/contrib/$(GECKO64_MSI)" "https://dl.winehq.org/wine/wine-gecko/$(GECKO_VER)/$(GECKO64_MSI)"; \
		fi; \
		cp "$(SRCDIR)/contrib/$(GECKO64_MSI)" "$@"; \
	fi

$(DIST_GECKO32): | $(DIST_GECKO_DIR)
	if [ -e "$(SRCDIR)/../gecko/$(GECKO32_MSI)" ]; then \
		cp "$(SRCDIR)/../gecko/$(GECKO32_MSI)" "$@"; \
	else \
		mkdir -p $(SRCDIR)/contrib/; \
		if [ ! -e "$(SRCDIR)/contrib/$(GECKO32_MSI)" ]; then \
			echo ">>>> Downloading wine-gecko. To avoid this in future, put it here: $(SRCDIR)/../gecko/$(GECKO32_MSI)"; \
			wget -O "$(SRCDIR)/contrib/$(GECKO32_MSI)" "https://dl.winehq.org/wine/wine-gecko/$(GECKO_VER)/$(GECKO32_MSI)"; \
		fi; \
		cp "$(SRCDIR)/contrib/$(GECKO32_MSI)" "$@"; \
	fi

$(DIST_FONTS): fonts
	mkdir -p $@
	cp $(FONTS_OBJ)/*.ttf "$@"

.PHONY: dist

ALL_TARGETS += dist
GOAL_TARGETS += dist

dist: $(DIST_TARGETS) wine | $(DST_DIR)

.PHONY: module32 module64 module

module32: SHELL = $(CONTAINER_SHELL32)
module32:
	cd $(WINE_OBJ32)/dlls/$(module) && make

module64: SHELL = $(CONTAINER_SHELL64)
module64:
	cd $(WINE_OBJ64)/dlls/$(module) && make

module: module32 module64

##
## ffmpeg
##

ifeq ($(WITH_FFMPEG),1)

FFMPEG_CONFIGURE_FILES32 := $(FFMPEG_OBJ32)/Makefile
FFMPEG_CONFIGURE_FILES64 := $(FFMPEG_OBJ64)/Makefile

# 64bit-configure
$(FFMPEG_CONFIGURE_FILES64): SHELL = $(CONTAINER_SHELL64)
$(FFMPEG_CONFIGURE_FILES64): $(FFMPEG)/configure $(MAKEFILE_DEP) | $(FFMPEG_OBJ64)
	cd $(dir $@) && \
		$(abspath $(FFMPEG))/configure \
			--cc=$(CC_QUOTED) --cxx=$(CXX_QUOTED) \
			--prefix=$(abspath $(TOOLS_DIR64)) \
			--disable-static \
			--enable-shared \
			--disable-programs \
			--disable-doc \
			--disable-avdevice \
			--disable-avformat \
			--disable-swresample \
			--disable-swscale \
			--disable-postproc \
			--disable-avfilter \
			--disable-alsa \
			--disable-iconv \
			--disable-libxcb_shape \
			--disable-libxcb_shm \
			--disable-libxcb_xfixes \
			--disable-sdl2 \
			--disable-xlib \
			--disable-zlib \
			--disable-bzlib \
			--disable-libxcb \
			--disable-vaapi \
			--disable-vdpau \
			--disable-everything \
			--enable-decoder=wmav2 \
			--enable-decoder=adpcm_ms && \
		[ ! -f ./Makefile ] || touch ./Makefile
# ^ ffmpeg's configure script doesn't update the timestamp on this guy in the case of a no-op

# 32-bit configure
$(FFMPEG_CONFIGURE_FILES32): SHELL = $(CONTAINER_SHELL32)
$(FFMPEG_CONFIGURE_FILES32): $(FFMPEG)/configure $(MAKEFILE_DEP) | $(FFMPEG_OBJ32)
	cd $(dir $@) && \
		$(abspath $(FFMPEG))/configure \
			--cc=$(CC_QUOTED) --cxx=$(CXX_QUOTED) \
			--prefix=$(abspath $(TOOLS_DIR32)) \
			--extra-cflags=$(FFMPEG_CROSS_CFLAGS) --extra-ldflags=$(FFMPEG_CROSS_LDFLAGS) \
			--disable-static \
			--enable-shared \
			--disable-programs \
			--disable-doc \
			--disable-avdevice \
			--disable-avformat \
			--disable-swresample \
			--disable-swscale \
			--disable-postproc \
			--disable-avfilter \
			--disable-alsa \
			--disable-iconv \
			--disable-libxcb_shape \
			--disable-libxcb_shm \
			--disable-libxcb_xfixes \
			--disable-sdl2 \
			--disable-xlib \
			--disable-zlib \
			--disable-bzlib \
			--disable-libxcb \
			--disable-vaapi \
			--disable-vdpau \
			--disable-everything \
			--enable-decoder=wmav2 \
			--enable-decoder=adpcm_ms && \
		[ ! -f ./Makefile ] || touch ./Makefile
# ^ ffmpeg's configure script doesn't update the timestamp on this guy in the case of a no-op

## ffmpeg goals
FFMPEG_TARGETS = ffmpeg ffmpeg_configure ffmpeg32 ffmpeg64 ffmpeg_configure32 ffmpeg_configure64

ALL_TARGETS += $(FFMPEG_TARGETS)
GOAL_TARGETS_LIBS += ffmpeg

.PHONY: $(FFMPEG_TARGETS)

ffmpeg_configure: $(FFMPEG_CONFIGURE_FILES32) $(FFMPEG_CONFIGURE_FILES64)

ffmpeg_configure64: $(FFMPEG_CONFIGURE_FILES64)

ffmpeg_configure32: $(FFMPEG_CONFIGURE_FILES32)

ffmpeg: ffmpeg32 ffmpeg64

ffmpeg64: SHELL = $(CONTAINER_SHELL64)
ffmpeg64: $(FFMPEG_CONFIGURE_FILES64)
	+$(MAKE) -C $(FFMPEG_OBJ64)
	+$(MAKE) -C $(FFMPEG_OBJ64) install
	mkdir -pv $(DST_DIR)/lib64
	cp -L $(TOOLS_DIR64)/lib/{libavcodec,libavutil}* $(DST_DIR)/lib64

ffmpeg32: SHELL = $(CONTAINER_SHELL32)
ffmpeg32: $(FFMPEG_CONFIGURE_FILES32)
	+$(MAKE) -C $(FFMPEG_OBJ32)
	+$(MAKE) -C $(FFMPEG_OBJ32) install
	mkdir -pv $(DST_DIR)/lib
	cp -L $(TOOLS_DIR32)/lib/{libavcodec,libavutil}* $(DST_DIR)/lib

endif # ifeq ($(WITH_FFMPEG),1)

##
## FAudio
##

FAUDIO_CMAKE_FLAGS = -DCMAKE_BUILD_TYPE=Release -DFORCE_ENABLE_DEBUGCONFIGURATION=ON -DLOG_ASSERTIONS=ON -DCMAKE_INSTALL_LIBDIR="lib" -DXNASONG=OFF
ifeq ($(WITH_FFMPEG),1)
FAUDIO_CMAKE_FLAGS += -DFFMPEG=ON
endif # ifeq ($(WITH_FFMPEG),1)

FAUDIO_TARGETS = faudio faudio32 faudio64

ALL_TARGETS += $(FAUDIO_TARGETS)
GOAL_TARGETS_LIBS += faudio

.PHONY: faudio faudio32 faudio64

faudio: faudio32 faudio64

FAUDIO_CONFIGURE_FILES32 := $(FAUDIO_OBJ32)/Makefile
FAUDIO_CONFIGURE_FILES64 := $(FAUDIO_OBJ64)/Makefile

$(FAUDIO_CONFIGURE_FILES32): SHELL = $(CONTAINER_SHELL32)
$(FAUDIO_CONFIGURE_FILES32): $(FAUDIO)/CMakeLists.txt $(MAKEFILE_DEP) $(CMAKE_BIN32) | $(FAUDIO_OBJ32)
	cd $(dir $@) && \
		../$(CMAKE_BIN32) $(abspath $(FAUDIO)) \
			-DCMAKE_INSTALL_PREFIX="$(abspath $(TOOLS_DIR32))" \
			$(FAUDIO_CMAKE_FLAGS) \
			-DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32"

$(FAUDIO_CONFIGURE_FILES64): SHELL = $(CONTAINER_SHELL64)
$(FAUDIO_CONFIGURE_FILES64): $(FAUDIO)/CMakeLists.txt $(MAKEFILE_DEP) $(CMAKE_BIN64) | $(FAUDIO_OBJ64)
	cd $(dir $@) && \
		../$(CMAKE_BIN64) $(abspath $(FAUDIO)) \
			-DCMAKE_INSTALL_PREFIX="$(abspath $(TOOLS_DIR64))" \
			$(FAUDIO_CMAKE_FLAGS)

faudio32: SHELL = $(CONTAINER_SHELL32)
faudio32: $(FAUDIO_CONFIGURE_FILES32)
	+$(MAKE) -C $(FAUDIO_OBJ32) VERBOSE=1
	+$(MAKE) -C $(FAUDIO_OBJ32) install VERBOSE=1
	mkdir -p $(DST_DIR)/lib
	cp -L $(TOOLS_DIR32)/lib/libFAudio* $(DST_DIR)/lib/
	[ x"$(STRIP)" = x ] || $(STRIP) $(DST_DIR)/lib/libFAudio.so

faudio64: SHELL = $(CONTAINER_SHELL64)
faudio64: $(FAUDIO_CONFIGURE_FILES64)
	+$(MAKE) -C $(FAUDIO_OBJ64) VERBOSE=1
	+$(MAKE) -C $(FAUDIO_OBJ64) install VERBOSE=1
	mkdir -p $(DST_DIR)/lib64
	cp -L $(TOOLS_DIR64)/lib/libFAudio* $(DST_DIR)/lib64/
	[ x"$(STRIP)" = x ] || $(STRIP) $(DST_DIR)/lib64/libFAudio.so

##
## wine
##

## Create & configure object directory for wine

WINE_CONFIGURE_FILES32 := $(WINE_OBJ32)/Makefile
WINE_CONFIGURE_FILES64 := $(WINE_OBJ64)/Makefile

WINE_COMMON_MAKE_ARGS := \
	STRIP="$(STRIP_QUOTED)" \
	INSTALL_PROGRAM_FLAGS="$(INSTALL_PROGRAM_FLAGS)"

WINE64_MAKE_ARGS := \
	$(WINE_COMMON_MAKE_ARGS) \
	prefix="$(abspath $(TOOLS_DIR64))" \
	libdir="$(abspath $(TOOLS_DIR64))/lib64" \
	dlldir="$(abspath $(TOOLS_DIR64))/lib64/wine"

WINE32_MAKE_ARGS := \
	$(WINE_COMMON_MAKE_ARGS) \
	prefix="$(abspath $(TOOLS_DIR32))" \
	libdir="$(abspath $(TOOLS_DIR32))/lib" \
	dlldir="$(abspath $(TOOLS_DIR32))/lib/wine"

# 64bit-configure
$(WINE_CONFIGURE_FILES64): SHELL = $(CONTAINER_SHELL64)
$(WINE_CONFIGURE_FILES64): $(MAKEFILE_DEP) | faudio64 $(WINE_OBJ64)
	cd $(dir $@) && \
		STRIP=$(STRIP_QUOTED) \
		CFLAGS="-I$(abspath $(TOOLS_DIR64))/include -I$(abspath $(SRCDIR))/contrib/include -g $(COMMON_FLAGS)" \
		LDFLAGS=-L$(abspath $(TOOLS_DIR64))/lib \
		PKG_CONFIG_PATH=$(abspath $(TOOLS_DIR64))/lib/pkgconfig \
		CC=$(CC_QUOTED) \
		CXX=$(CXX_QUOTED) \
		../$(WINE)/configure \
			$(WINE64_AUTOCONF) \
			--without-curses \
			--enable-win64 --disable-tests --prefix=$(abspath $(DST_DIR))

# 32-bit configure
$(WINE_CONFIGURE_FILES32): SHELL = $(CONTAINER_SHELL32)
$(WINE_CONFIGURE_FILES32): $(MAKEFILE_DEP) | faudio32 $(WINE_OBJ32)
	cd $(dir $@) && \
		STRIP=$(STRIP_QUOTED) \
		CFLAGS="-I$(abspath $(TOOLS_DIR32))/include -I$(abspath $(SRCDIR))/contrib/include -g $(COMMON_FLAGS)" \
		LDFLAGS=-L$(abspath $(TOOLS_DIR32))/lib \
		PKG_CONFIG_PATH=$(abspath $(TOOLS_DIR32))/lib/pkgconfig \
		CC=$(CC_QUOTED) \
		CXX=$(CXX_QUOTED) \
		../$(WINE)/configure \
			$(WINE32_AUTOCONF) \
			--without-curses \
			--disable-tests --prefix=$(abspath $(WINE_DST32))

## wine goals
WINE_TARGETS = wine wine_configure wine32 wine64 wine_configure32 wine_configure64

ALL_TARGETS += $(WINE_TARGETS)
GOAL_TARGETS += wine

.PHONY: $(WINE_TARGETS)

wine_configure: $(WINE_CONFIGURE_FILES32) $(WINE_CONFIGURE_FILES64)

wine_configure64: $(WINE_CONFIGURE_FILES64)

wine_configure32: $(WINE_CONFIGURE_FILES32)

wine: wine32 wine64

# WINE_OUT and WINE_BUILDTOOLS are outputs needed by other rules, though we don't explicitly track all state here --
# make all or make wine are needed to ensure all deps are up to date, this just ensures 'make dist' or 'make vrclient'
# will drag in wine if you've never built wine.
.INTERMEDIATE: wine64-intermediate wine32-intermediate

$(WINE_BUILDTOOLS64) $(WINE_OUT) wine64: wine64-intermediate

wine64-intermediate: SHELL = $(CONTAINER_SHELL64)
wine64-intermediate: $(WINE_CONFIGURE_FILES64)
	+$(MAKE) -C $(WINE_OBJ64) $(WINE_COMMON_MAKE_ARGS)
	+$(MAKE) -C $(WINE_OBJ64) $(WINE_COMMON_MAKE_ARGS) install-lib
	+$(MAKE) -C $(WINE_OBJ64) $(WINE64_MAKE_ARGS) install-lib install-dev
	rm -f $(DST_DIR)/bin/{msiexec,notepad,regedit,regsvr32,wineboot,winecfg,wineconsole,winedbg,winefile,winemine,winepath}
	rm -rf $(DST_DIR)/share/man/

## This installs 32-bit stuff manually, see
##   https://wiki.winehq.org/Packaging#WoW64_Workarounds
$(WINE_BUILDTOOLS32) wine32: wine32-intermediate

wine32-intermediate: SHELL = $(CONTAINER_SHELL32)
wine32-intermediate: $(WINE_CONFIGURE_FILES32)
	+$(MAKE) -C $(WINE_OBJ32) $(WINE_COMMON_MAKE_ARGS)
	+$(MAKE) -C $(WINE_OBJ32) $(WINE_COMMON_MAKE_ARGS) install-lib
	+$(MAKE) -C $(WINE_OBJ32) $(WINE32_MAKE_ARGS) install-lib install-dev
	mkdir -p $(DST_DIR)/{lib,bin}
	cp -a $(WINE_DST32)/lib $(DST_DIR)/
	cp -a $(WINE_DST32)/bin/wine $(DST_DIR)/bin/
	cp -a $(WINE_DST32)/bin/wine-preloader $(DST_DIR)/bin/

##
## cmake -- necessary for FAudio, not part of steam runtime
##

# TODO Don't bother with this in native mode

## Create & configure object directory for cmake

CMAKE_CONFIGURE_FILES32 := $(CMAKE_OBJ32)/Makefile
CMAKE_CONFIGURE_FILES64 := $(CMAKE_OBJ64)/Makefile

# 64-bit configure
$(CMAKE_CONFIGURE_FILES64): SHELL = $(CONTAINER_SHELL64)
$(CMAKE_CONFIGURE_FILES64): $(MAKEFILE_DEP) | $(CMAKE_OBJ64)
	cd "$(CMAKE_OBJ64)" && \
		../$(CMAKE)/configure --parallel=$(SUBMAKE_JOBS) --prefix=$(abspath $(CMAKE_OBJ64))/built

# 32-bit configure
$(CMAKE_CONFIGURE_FILES32): SHELL = $(CONTAINER_SHELL32)
$(CMAKE_CONFIGURE_FILES32): $(MAKEFILE_DEP) | $(CMAKE_OBJ32)
	cd "$(CMAKE_OBJ32)" && \
		../$(CMAKE)/configure --parallel=$(SUBMAKE_JOBS) --prefix=$(abspath $(CMAKE_OBJ32))/built


## cmake goals
CMAKE_TARGETS = cmake cmake_configure cmake32 cmake64 cmake_configure32 cmake_configure64

ALL_TARGETS += $(CMAKE_TARGETS)

.PHONY: $(CMAKE_TARGETS)

cmake_configure: $(CMAKE_CONFIGURE_FILES32) $(CMAKE_CONFIGURE_FILES64)

cmake_configure32: $(CMAKE_CONFIGURE_FILES32)

cmake_configure64: $(CMAKE_CONFIGURE_FILES64)

cmake: cmake32 cmake64

# These have multiple targets that come from one invocation.  The way to do that is to have both targets on a single
# intermediate.
.INTERMEDIATE: cmake64-intermediate cmake32-intermediate

$(CMAKE_BIN64) cmake64: cmake64-intermediate

cmake64-intermediate: SHELL = $(CONTAINER_SHELL64)
cmake64-intermediate: $(CMAKE_CONFIGURE_FILES64) $(filter $(MAKECMDGOALS),cmake64)
	+$(MAKE) -C $(CMAKE_OBJ64)
	+$(MAKE) -C $(CMAKE_OBJ64) install
	touch $(CMAKE_BIN64)

$(CMAKE_BIN32) cmake32: cmake32-intermediate

cmake32-intermediate: SHELL = $(CONTAINER_SHELL32)
cmake32-intermediate: $(CMAKE_CONFIGURE_FILES32) $(filter $(MAKECMDGOALS),cmake32)
	+$(MAKE) -C $(CMAKE_OBJ32)
	+$(MAKE) -C $(CMAKE_OBJ32) install
	touch $(CMAKE_BIN32)

ALL_TARGETS += fonts
GOAL_TARGETS += fonts

.PHONY: fonts

FONTFORGE = fontforge -quiet
FONTSCRIPT = $(FONTS)/scripts/generatefont.pe
FONTLINKPATH = ../../../../fonts

LIBERATION_SRCDIR = $(FONTS)/liberation-fonts/src

LIBERATION_SANS_REGULAR_SFD = LiberationSans-Regular.sfd
LIBERATION_SANS_BOLD_SFD = LiberationSans-Bold.sfd
LIBERATION_SERIF_REGULAR_SFD = LiberationSerif-Regular.sfd
LIBERATION_MONO_REGULAR_SFD = LiberationMono-Regular.sfd

LIBERATION_SANS_REGULAR_TTF = $(addprefix $(FONTS_OBJ)/, $(LIBERATION_SANS_REGULAR_SFD:.sfd=.ttf))
LIBERATION_SANS_BOLD_TTF = $(addprefix $(FONTS_OBJ)/, $(LIBERATION_SANS_BOLD_SFD:.sfd=.ttf))
LIBERATION_SERIF_REGULAR_TTF = $(addprefix $(FONTS_OBJ)/, $(LIBERATION_SERIF_REGULAR_SFD:.sfd=.ttf))
LIBERATION_MONO_REGULAR_TTF = $(addprefix $(FONTS_OBJ)/, $(LIBERATION_MONO_REGULAR_SFD:.sfd=.ttf))

LIBERATION_SFDS = $(LIBERATION_SANS_REGULAR_SFD) $(LIBERATION_SANS_BOLD_SFD) $(LIBERATION_SERIF_REGULAR_SFD) $(LIBERATION_MONO_REGULAR_SFD)
FONT_TTFS = $(LIBERATION_SANS_REGULAR_TTF) $(LIBERATION_SANS_BOLD_TTF) \
            $(LIBERATION_SERIF_REGULAR_TTF) $(LIBERATION_MONO_REGULAR_TTF)
FONTS_SRC = $(FONT_TTFS:.ttf=.sfd)

#The use of "Arial" here is for compatibility with programs that require that exact string. This font is not Arial.
$(LIBERATION_SANS_REGULAR_TTF): $(FONTS_SRC) $(FONTSCRIPT)
	$(FONTFORGE) -script $(FONTSCRIPT) $(@:.ttf=.sfd) "Arial" "Arial" "Arial"

#The use of "Arial" here is for compatibility with programs that require that exact string. This font is not Arial.
$(LIBERATION_SANS_BOLD_TTF): $(FONTS_SRC) $(FONTSCRIPT)
	$(FONTFORGE) -script $(FONTSCRIPT) $(@:.ttf=.sfd) "Arial-Bold" "Arial" "Arial Bold"

#The use of "Times New Roman" here is for compatibility with programs that require that exact string. This font is not Times New Roman.
$(LIBERATION_SERIF_REGULAR_TTF): $(FONTS_SRC) $(FONTSCRIPT)
	$(FONTFORGE) -script $(FONTSCRIPT) $(@:.ttf=.sfd) "TimesNewRoman" "Times New Roman" "Times New Roman"

#The use of "Courier New" here is for compatibility with programs that require that exact string. This font is not Courier New.
$(LIBERATION_MONO_REGULAR_TTF): $(FONTS_SRC) $(FONTSCRIPT)
	patch $(@:.ttf=.sfd) $(FONTS)/patches/$(LIBERATION_MONO_REGULAR_SFD:.sfd=.patch)
	$(FONTFORGE) -script $(FONTSCRIPT) $(@:.ttf=.sfd) "CourierNew" "Courier New" "Courier New"

$(FONTS_OBJ):
	mkdir -p $@

$(FONTS_SRC): $(FONTS_OBJ)
	cp -n $(addprefix $(LIBERATION_SRCDIR)/, $(LIBERATION_SFDS)) $<

fonts: $(LIBERATION_SANS_REGULAR_TTF) $(LIBERATION_SANS_BOLD_TTF) \
       $(LIBERATION_SERIF_REGULAR_TTF) $(LIBERATION_MONO_REGULAR_TTF) | $(FONTS_SRC)

##
## Targets
##

.PHONY: all all64 all32 default help targets

# Produce a working dist directory by default
default: all dist
.DEFAULT_GOAL := default

# For suffixes 64/32/_configure64/_configure32 automatically check if they exist compared to ALL_TARGETS and make
# all_configure32/etc aliases
GOAL_TARGETS64           := $(filter $(addsuffix 64,$(GOAL_TARGETS)),$(ALL_TARGETS))
GOAL_TARGETS32           := $(filter $(addsuffix 32,$(GOAL_TARGETS)),$(ALL_TARGETS))
GOAL_TARGETS_LIBS64      := $(filter $(addsuffix 64,$(GOAL_TARGETS_LIBS)),$(ALL_TARGETS))
GOAL_TARGETS_LIBS32      := $(filter $(addsuffix 32,$(GOAL_TARGETS_LIBS)),$(ALL_TARGETS))
GOAL_TARGETS_CONFIGURE   := $(filter $(addsuffix _configure,$(GOAL_TARGETS)),$(ALL_TARGETS))
GOAL_TARGETS_CONFIGURE64 := $(filter $(addsuffix _configure64,$(GOAL_TARGETS)),$(ALL_TARGETS))
GOAL_TARGETS_CONFIGURE32 := $(filter $(addsuffix _configure32,$(GOAL_TARGETS)),$(ALL_TARGETS))

# Anything in all-targets that didn't end up in here
OTHER_TARGETS := $(filter-out $(ALL_TARGETS),$(GOAL_TARGETS) $(GOAL_TARGETS64) $(GOAL_TARGETS32) \
                                             $(GOAL_TARGETS_LIBS64) $(GOAL_TARGETS_LIBS32) $(GOAL_TARGETS_CONFIGURE) \
                                             $(GOAL_TARGETS_CONFIGURE64) $(GOAL_TARGETS_CONFIGURE32))

help: targets
targets:
	$(info Default targets      (make all):              $(strip $(GOAL_TARGETS)))
	$(info Default targets      (make all_lib):          $(strip $(GOAL_TARGETS_LIBS)))
	$(info Default targets      (make all_configure):    $(strip $(GOAL_TARGETS_CONFIGURE)))
	$(info Default targets      (make all64):            $(strip $(GOAL_TARGETS64)))
	$(info Default targets      (make all32):            $(strip $(GOAL_TARGETS32)))
	$(info Default targets      (make all64_lib):        $(strip $(GOAL_TARGETS_LIBS64)))
	$(info Default targets      (make all32_lib):        $(strip $(GOAL_TARGETS_LIBS32)))
	$(info Reconfigure targets  (make all64_configure):  $(strip $(GOAL_TARGETS_CONFIGURE64)))
	$(info Reconfigure targets  (make all32_configure):  $(strip $(GOAL_TARGETS_CONFIGURE32)))
	$(info Other targets:    $(OTHER_TARGETS))

# All target
all: $(GOAL_TARGETS)
	@echo ":: make $@ succeeded"

all32: $(GOAL_TARGETS32)
	@echo ":: make $@ succeeded"

all64: $(GOAL_TARGETS64)
	@echo ":: make $@ succeeded"

# Libraries (not wine) only -- wine has a length install step that runs unconditionally, so this is useful for updating
# incremental builds when not iterating on wine itself.
all_lib: $(GOAL_TARGETS_LIBS)
	@echo ":: make $@ succeeded"

all32_lib: $(GOAL_TARGETS_LIBS32)
	@echo ":: make $@ succeeded"

all64_lib: $(GOAL_TARGETS_LIBS64)
	@echo ":: make $@ succeeded"

# Explicit reconfigure all targets
all_configure: $(GOAL_TARGETS_CONFIGURE)
	@echo ":: make $@ succeeded"

all32_configure: $(GOAL_TARGETS_CONFIGURE32)
	@echo ":: make $@ succeeded"

all64_configure: $(GOAL_TARGETS_CONFIGURE64)
	@echo ":: make $@ succeeded"

endif # End of NESTED_MAKE from beginning
