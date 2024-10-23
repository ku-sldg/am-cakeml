.PHONY: ci_build ci_test

all:
	make ci_build
	make ci_test

ci_build:
	./CI/Build.sh

ci_test:
	./CI/Test.sh -t cert -h
	./CI/Test.sh -t cert_appr -h
	./CI/Test.sh -t split -h
	./CI/Test.sh -t split_appr -h
	./CI/Test.sh -t bg -h
	./CI/Test.sh -t parmut -h
	./CI/Test.sh -t filehash -h
