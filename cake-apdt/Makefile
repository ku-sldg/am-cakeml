apdt: concat appendedapdt.sml
	cakewrap.py --basis ~/cake-x64-64/basis_ffi.c -o apdt appendedapdt.sml

concat: CoqDefaults.sml CoplandLang.sml Eval.sml
	./cakeappender.py -o appendedapdt.sml CoqDefaults.sml CoplandLang.sml Eval.sml

clean:
	rm apdt appendedapdt.sml
