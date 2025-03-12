.PHONY: ci_build ci_test

ci:
	make ci_build
	make ci_test

ci_build:
	./CI/Build.sh

ci_test:
	./CI/Test.sh -t cert -h -s
	./CI/Test.sh -t cert_appr -h
	./CI/Test.sh -t split -h -s
	./CI/Test.sh -t split_appr -h
	./CI/Test.sh -t bg -h -s
	./CI/Test.sh -t parmut -h -s
	./CI/Test.sh -t large_output -h -s