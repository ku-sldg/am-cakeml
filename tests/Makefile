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


maestro_attest:
	./CI/Test.sh -t attest -s

maestro_attest_appr:
	./CI/Test.sh -t attest

demo_micro:
	./Demo.sh -t micro

demo_micro_noclient:
	./Demo.sh -t micro -r

demo_micro_provision:
	./Demo.sh -t micro_provision_evidence

demo_theorem:
	./Demo.sh -t run_coq_all_appr

demo_theorem_noclient:
	./Demo.sh -t run_coq_all_appr -r

demo_theorem_provision_noclient:
	./Demo.sh -t theorem_provision_evidence -r
