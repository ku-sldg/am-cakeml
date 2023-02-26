#!/bin/bash

COQ_DIR="/Users/adampetz/Documents/Fall_2022/copland-avm/src"
CML_DIR="./extracted"


cp ${COQ_DIR}/*.cml ${CML_DIR}

rm ${CML_DIR}/Anno_Term_Defs.cml
rm ${CML_DIR}/Ascii.cml
rm ${CML_DIR}/Bool.cml
rm ${CML_DIR}/EqClass.cml
rm ${CML_DIR}/Eqb_Evidence.cml
rm ${CML_DIR}/Maps.cml
#rm ${CML_DIR}/Nat.cml
rm ${CML_DIR}/Params_Admits.cml
rm ${CML_DIR}/PeanoNat.cml
rm ${CML_DIR}/String.cml
