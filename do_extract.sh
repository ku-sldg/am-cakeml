#!/bin/bash

# To configure this script, set the COPLAND_AVM_DIR environment variable to
#   point to the src folder of your local copland-avm Coq development:
#   i.e:  export COPLAND_AVM_DIR="<your-path>/copland-avm/src"


CML_DIR="./extracted"

if [ -n "${COPLAND_AVM_DIR}" ]; then
  rm ${CML_DIR}/*.cml

  cp ${COPLAND_AVM_DIR}/*.cml ${CML_DIR}

  rm ${CML_DIR}/Extraction_Cvm_Cake.cml

  # This is a temporary hack to add explicit type annotations to monadic helpers
  #cp ${CML_DIR}/../stubs/Cvm_Monad_Annotated.sml ${CML_DIR}/Cvm_Monad.cml
  #cp ${CML_DIR}/../stubs/Client_AM_Local_Annotated.sml ${CML_DIR}/Client_AM_Local.cml

  # This is a temporary hack to remove faulty explicit type annotations (type variables causing issues in annotations)
  #cp ${CML_DIR}/../stubs/EqClass_UnAnnotated.sml ${CML_DIR}/EqClass.cml

  # rm ${CML_DIR}/Anno_Term_Defs.cml
  # rm ${CML_DIR}/Ascii.cml
  # rm ${CML_DIR}/Bool.cml
  # rm ${CML_DIR}/EqClass.cml
  # rm ${CML_DIR}/Maps.cml
  # rm ${CML_DIR}/Params_Admits.cml
  # rm ${CML_DIR}/PeanoNat.cml
  # rm ${CML_DIR}/String.cml
else
  echo "Variable 'COPLAND_AVM_DIR' is not set" 
  echo "Run: 'export COPLAND_AVM_DIR=<your-path>/copland-avm/src'"
fi
