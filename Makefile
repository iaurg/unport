# Swift Testing ships with the Command Line Tools but is off the default search path without Xcode.
CLT_FRAMEWORKS := /Library/Developer/CommandLineTools/Library/Developer/Frameworks
ifeq ($(wildcard $(shell xcode-select -p)/Platforms),)
TEST_FLAGS := -Xswiftc -F -Xswiftc $(CLT_FRAMEWORKS) -Xlinker -F -Xlinker $(CLT_FRAMEWORKS) -Xlinker -rpath -Xlinker $(CLT_FRAMEWORKS)
endif

.PHONY: app run install test clean

app:
	./scripts/build-app.sh

run: app
	open build/Unport.app

install: app
	rm -rf /Applications/Unport.app
	cp -R build/Unport.app /Applications/

test:
	swift test $(TEST_FLAGS)

clean:
	rm -rf .build build
