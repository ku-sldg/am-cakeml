apdt: concat appendedapdt.sml
	cakewrap.py --basis ~/cake-x64-64/basis_ffi.c -o apdt appendedapdt.sml

concat: CoqDefaults.sml Common.sml APDT.sml Eval.sml NamedAPDT.sml ToStringUtils.sml Main.sml
	./cakeappender.py -o appendedapdt.sml CoqDefaults.sml Common.sml APDT.sml Eval.sml NamedAPDT.sml ToStringUtils.sml Main.sml

clean:
	rm apdt appendedapdt.sml
	
