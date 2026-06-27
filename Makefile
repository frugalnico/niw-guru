# niw-guru — build & install
#
# The `niw-guru` command is built from src/niw-guru.in (the build bakes this
# project's absolute path into it). Nothing here compiles a binary; it just
# renders the source script and, optionally, links it onto your PATH.
#
#   make build       Render src/niw-guru.in -> bin/niw-guru
#   make install     Symlink bin/niw-guru onto your PATH
#   make setup       Install deps + immigration skills (./setup.sh)
#   make test        Run the offline test suite
#   make uninstall   Remove the installed symlink
#   make clean       Remove bin/niw-guru

PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin
HERE   := $(CURDIR)

.DEFAULT_GOAL := help
.PHONY: help build install uninstall setup test clean

help:
	@echo "niw-guru — make targets"
	@echo "  make build       Build bin/niw-guru from src/niw-guru.in (home: $(HERE))"
	@echo "  make install     Symlink niw-guru into $(BINDIR) (override with PREFIX=…; use sudo if needed)"
	@echo "  make setup       Install PDF tools + the immigration skills (./setup.sh)"
	@echo "  make test        Run the offline test suite (tests/run-tests.sh)"
	@echo "  make uninstall   Remove $(BINDIR)/niw-guru"
	@echo "  make clean       Remove the built bin/niw-guru"
	@echo ""
	@echo "First-time setup:"
	@echo "  ./setup.sh && make build && make install"
	@echo "  # then:  niw-guru -s <your evidence dir>"

# Build: substitute the project path into the source template.
bin/niw-guru: src/niw-guru.in
	@mkdir -p bin
	sed 's|@NIW_GURU_HOME@|$(HERE)|g' src/niw-guru.in > bin/niw-guru
	chmod +x bin/niw-guru
	@echo "Built bin/niw-guru  (NIW_GURU_HOME=$(HERE))"

build: bin/niw-guru

# Install: link the built command onto PATH so `niw-guru` works from anywhere.
install: build
	@mkdir -p "$(BINDIR)"
	ln -sf "$(HERE)/bin/niw-guru" "$(BINDIR)/niw-guru"
	@echo "Installed: $(BINDIR)/niw-guru -> $(HERE)/bin/niw-guru"
	@command -v niw-guru >/dev/null 2>&1 || echo "Note: $(BINDIR) is not on your PATH — add it, or run ./bin/niw-guru directly."

uninstall:
	rm -f "$(BINDIR)/niw-guru"
	@echo "Removed $(BINDIR)/niw-guru (if it existed)."

setup:
	./setup.sh

test:
	bash tests/run-tests.sh

clean:
	rm -f bin/niw-guru
	@echo "Removed bin/niw-guru"
