apdt: concat appendedapdt.sml
	../cakewrap.py --basis ~/cake-x64-64/basis_ffi.c -o apdt appendedapdt.sml

# NOTE: the order of the files fed to cakeappender reflects code dependencies
concat: CoqDefaults.sml CoplandLang.sml Eval.sml
	./cakeappender.py -o appendedapdt.sml CoqDefaults.sml ByteString.sml CoplandLang.sml Eval.sml Main.sml

clean:
	rm apdt appendedapdt.sml
