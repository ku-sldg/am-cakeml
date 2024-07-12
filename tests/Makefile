.PHONY: ci_build ci_test

all:
	make ci_build
	make ci_test

ci_build:
	./CI/Build.sh

ci_test:
	./CI/Test.sh -t cert
	./CI/Test.sh -t bg
	./CI/Test.sh -t parmut
