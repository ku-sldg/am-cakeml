apdt: apdt.sml
	cakewrap.py --basis ~/cake-x64-64/basis_ffi.c -o apdt apdt.sml

clean:
	rm apdt
