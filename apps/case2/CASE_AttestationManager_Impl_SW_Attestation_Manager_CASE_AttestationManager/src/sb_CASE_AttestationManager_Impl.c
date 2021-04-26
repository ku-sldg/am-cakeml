// This file will be regenerated, do not edit

#include <sb_CASE_AttestationManager_Impl.h>
#include "../../../aux_code/aux_code/components/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter/includes/sb_CASE_Filter_thr_Impl.h"
#include "../../../aux_code/aux_code/components/adapter_low_impl_SW_adapter_low_adapter_low/includes/sb_adapter_low_impl.h"
#include "../../../aux_code/aux_code/components/adapter_high_impl_SW_adapter_high_adapter_high/includes/sb_adapter_high_impl.h"
#include "../../../aux_code/aux_code/components/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate/includes/sb_CASE_AttestationGate_Impl.h"
#include "../../../aux_code/aux_code/components/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager/includes/sb_CASE_AttestationManager_Impl.h"
#include "../../../aux_code/aux_code/hamr/ext-c/ext.h"
#include "../../../aux_code/aux_code/hamr/ext-c/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter_api.h"
#include "../../../aux_code/aux_code/hamr/ext-c/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter.h"
#include "../../../aux_code/aux_code/hamr/ext-c/adapter_low_impl_SW_adapter_low_adapter_low/adapter_low_impl_SW_adapter_low_adapter_low_api.h"
#include "../../../aux_code/aux_code/hamr/ext-c/adapter_low_impl_SW_adapter_low_adapter_low/adapter_low_impl_SW_adapter_low_adapter_low.h"
#include "../../../aux_code/aux_code/hamr/ext-c/adapter_high_impl_SW_adapter_high_adapter_high/adapter_high_impl_SW_adapter_high_adapter_high.h"
#include "../../../aux_code/aux_code/hamr/ext-c/adapter_high_impl_SW_adapter_high_adapter_high/adapter_high_impl_SW_adapter_high_adapter_high_api.h"
#include "../../../aux_code/aux_code/hamr/ext-c/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate_api.h"
#include "../../../aux_code/aux_code/hamr/ext-c/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate.h"
#include "../../../aux_code/aux_code/hamr/ext-c/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager.h"
#include "../../../aux_code/aux_code/hamr/ext-c/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_api.h"
#include "../../../aux_code/aux_code/hamr/etc_seL4/adapters/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter_adapter.h"
#include "../../../aux_code/aux_code/hamr/etc_seL4/adapters/adapter_low_impl_SW_adapter_low_adapter_low/adapter_low_impl_SW_adapter_low_adapter_low_adapter.h"
#include "../../../aux_code/aux_code/hamr/etc_seL4/adapters/adapter_high_impl_SW_adapter_high_adapter_high/adapter_high_impl_SW_adapter_high_adapter_high_adapter.h"
#include "../../../aux_code/aux_code/hamr/etc_seL4/adapters/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate_adapter.h"
#include "../../../aux_code/aux_code/hamr/etc_seL4/adapters/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_adapter.h"
#include "../../../aux_code/aux_code/types/includes/sb_event_counter.h"
#include "../../../aux_code/aux_code/types/includes/sb_queue_union_art_DataContent_1.h"
#include "../../../aux_code/aux_code/types/includes/sb_types.h"
#include "../../../aux_code/components/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter/includes/sb_CASE_Filter_thr_Impl.h"
#include "../../../aux_code/components/adapter_low_impl_SW_adapter_low_adapter_low/includes/sb_adapter_low_impl.h"
#include "../../../aux_code/components/adapter_high_impl_SW_adapter_high_adapter_high/includes/sb_adapter_high_impl.h"
#include "../../../aux_code/components/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate/includes/sb_CASE_AttestationGate_Impl.h"
#include "../../../aux_code/components/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager/includes/sb_CASE_AttestationManager_Impl.h"
#include "../../../aux_code/hamr/ext-c/ext.h"
#include "../../../aux_code/hamr/ext-c/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter_api.h"
#include "../../../aux_code/hamr/ext-c/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter.h"
#include "../../../aux_code/hamr/ext-c/adapter_low_impl_SW_adapter_low_adapter_low/adapter_low_impl_SW_adapter_low_adapter_low_api.h"
#include "../../../aux_code/hamr/ext-c/adapter_low_impl_SW_adapter_low_adapter_low/adapter_low_impl_SW_adapter_low_adapter_low.h"
#include "../../../aux_code/hamr/ext-c/adapter_high_impl_SW_adapter_high_adapter_high/adapter_high_impl_SW_adapter_high_adapter_high.h"
#include "../../../aux_code/hamr/ext-c/adapter_high_impl_SW_adapter_high_adapter_high/adapter_high_impl_SW_adapter_high_adapter_high_api.h"
#include "../../../aux_code/hamr/ext-c/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate_api.h"
#include "../../../aux_code/hamr/ext-c/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate.h"
#include "../../../aux_code/hamr/ext-c/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager.h"
#include "../../../aux_code/hamr/ext-c/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_api.h"
#include "../../../aux_code/hamr/etc_seL4/adapters/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter/CASE_Filter_thr_Impl_SW_Filter_CASE_Filter_adapter.h"
#include "../../../aux_code/hamr/etc_seL4/adapters/adapter_low_impl_SW_adapter_low_adapter_low/adapter_low_impl_SW_adapter_low_adapter_low_adapter.h"
#include "../../../aux_code/hamr/etc_seL4/adapters/adapter_high_impl_SW_adapter_high_adapter_high/adapter_high_impl_SW_adapter_high_adapter_high_adapter.h"
#include "../../../aux_code/hamr/etc_seL4/adapters/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate/CASE_AttestationGate_Impl_SW_Attestation_Gate_CASE_AttestationGate_adapter.h"
#include "../../../aux_code/hamr/etc_seL4/adapters/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager/CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_adapter.h"
#include "../../../aux_code/types/includes/sb_event_counter.h"
#include "../../../aux_code/types/includes/sb_queue_union_art_DataContent_1.h"
#include "../../../aux_code/types/includes/sb_types.h"
#include <sb_queue_union_art_DataContent_1.h>
#include <sb_queue_union_art_DataContent_1.h>
#include <sb_event_counter.h>
#include <CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_adapter.h>
#include <string.h>
#include <camkes.h>

bool sb_AttestationRequest_enqueue(const union_art_DataContent *data) {
  sb_queue_union_art_DataContent_1_enqueue(sb_AttestationRequest_queue_1, (union_art_DataContent*) data);
  sb_AttestationRequest_1_notification_emit();

  return true;
}

sb_queue_union_art_DataContent_1_Recv_t sb_AttestationResponse_recv_queue;

/************************************************************************
 * sb_AttestationResponse_dequeue_poll:
 ************************************************************************/
bool sb_AttestationResponse_dequeue_poll(sb_event_counter_t *numDropped, union_art_DataContent *data) {
  return sb_queue_union_art_DataContent_1_dequeue(&sb_AttestationResponse_recv_queue, numDropped, data);
}

/************************************************************************
 * sb_AttestationResponse_dequeue:
 ************************************************************************/
bool sb_AttestationResponse_dequeue(union_art_DataContent *data) {
  sb_event_counter_t numDropped;
  return sb_AttestationResponse_dequeue_poll(&numDropped, data);
}

/************************************************************************
 * sb_AttestationResponse_is_empty:
 *
 * Helper method to determine if infrastructure port has received new
 * events
 ************************************************************************/
bool sb_AttestationResponse_is_empty(){
  return sb_queue_union_art_DataContent_1_is_empty(&sb_AttestationResponse_recv_queue);
}

bool sb_TrustedIds_enqueue(const union_art_DataContent *data) {
  sb_queue_union_art_DataContent_1_enqueue(sb_TrustedIds_queue_1, (union_art_DataContent*) data);
  sb_TrustedIds_1_notification_emit();

  return true;
}

sb_queue_union_art_DataContent_1_Recv_t sb_InitiateAttestation_recv_queue;

/************************************************************************
 * sb_InitiateAttestation_dequeue_poll:
 ************************************************************************/
bool sb_InitiateAttestation_dequeue_poll(sb_event_counter_t *numDropped, union_art_DataContent *data) {
  return sb_queue_union_art_DataContent_1_dequeue(&sb_InitiateAttestation_recv_queue, numDropped, data);
}

/************************************************************************
 * sb_InitiateAttestation_dequeue:
 ************************************************************************/
bool sb_InitiateAttestation_dequeue(union_art_DataContent *data) {
  sb_event_counter_t numDropped;
  return sb_InitiateAttestation_dequeue_poll(&numDropped, data);
}

/************************************************************************
 * sb_InitiateAttestation_is_empty:
 *
 * Helper method to determine if infrastructure port has received new
 * events
 ************************************************************************/
bool sb_InitiateAttestation_is_empty(){
  return sb_queue_union_art_DataContent_1_is_empty(&sb_InitiateAttestation_recv_queue);
}

bool sb_TerminateAttestation_enqueue(const union_art_DataContent *data) {
  sb_queue_union_art_DataContent_1_enqueue(sb_TerminateAttestation_queue_1, (union_art_DataContent*) data);
  sb_TerminateAttestation_1_notification_emit();

  return true;
}

// send AttestationRequest: Out EventDataPort VPM__CASE_AttestationRequestMsg_impl
Unit HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_AttestationRequest_Send(
  STACK_FRAME
  art_DataContent d) {
  DeclNewStackFrame(caller, "sb_CASE_AttestationManager_Impl.c", "", "HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_AttestationRequest_Send", 0);

  sb_AttestationRequest_enqueue(d);
}

// send TrustedIds: Out EventDataPort CASE_Proxies__WhiteList_impl
Unit HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_TrustedIds_Send(
  STACK_FRAME
  art_DataContent d) {
  DeclNewStackFrame(caller, "sb_CASE_AttestationManager_Impl.c", "", "HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_TrustedIds_Send", 0);

  sb_TrustedIds_enqueue(d);
}

// send TerminateAttestation: Out EventDataPort VPM__UNSIGNED_INT_32_impl
Unit HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_TerminateAttestation_Send(
  STACK_FRAME
  art_DataContent d) {
  DeclNewStackFrame(caller, "sb_CASE_AttestationManager_Impl.c", "", "HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_TerminateAttestation_Send", 0);

  sb_TerminateAttestation_enqueue(d);
}

// is_empty AttestationResponse: In EventDataPort
B HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_AttestationResponse_IsEmpty(STACK_FRAME_ONLY) {
  return sb_AttestationResponse_is_empty();
}

// receive AttestationResponse: In EventDataPort union_art_DataContent
Unit HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_AttestationResponse_Receive(
  STACK_FRAME
  Option_8E9F45 result) {
  DeclNewStackFrame(caller, "sb_CASE_AttestationManager_Impl.c", "", "HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_AttestationResponse_Receive", 0);

  union_art_DataContent val;
  if(sb_AttestationResponse_dequeue((union_art_DataContent *) &val)) {
    // wrap payload in Some and place in result
    DeclNewSome_D29615(some);
    Some_D29615_apply(SF &some, (art_DataContent) &val);
    Type_assign(result, &some, sizeof(union Option_8E9F45));
  } else {
    // put None in result
    DeclNewNone_964667(none);
    Type_assign(result, &none, sizeof(union Option_8E9F45));
  }
}


// is_empty InitiateAttestation: In EventDataPort
B HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_InitiateAttestation_IsEmpty(STACK_FRAME_ONLY) {
  return sb_InitiateAttestation_is_empty();
}

// receive InitiateAttestation: In EventDataPort union_art_DataContent
Unit HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_InitiateAttestation_Receive(
  STACK_FRAME
  Option_8E9F45 result) {
  DeclNewStackFrame(caller, "sb_CASE_AttestationManager_Impl.c", "", "HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_seL4Nix_InitiateAttestation_Receive", 0);

  union_art_DataContent val;
  if(sb_InitiateAttestation_dequeue((union_art_DataContent *) &val)) {
    // wrap payload in Some and place in result
    DeclNewSome_D29615(some);
    Some_D29615_apply(SF &some, (art_DataContent) &val);
    Type_assign(result, &some, sizeof(union Option_8E9F45));
  } else {
    // put None in result
    DeclNewNone_964667(none);
    Type_assign(result, &none, sizeof(union Option_8E9F45));
  }
}


void pre_init(void) {
  DeclNewStackFrame(NULL, "sb_CASE_AttestationManager_Impl.c", "", "pre_init", 0);

  printf("Entering pre-init of CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager\n");

  // initialise data structure for outgoing event data port AttestationRequest
  sb_queue_union_art_DataContent_1_init(sb_AttestationRequest_queue_1);

  // initialise data structure for incoming event data port AttestationResponse
  sb_queue_union_art_DataContent_1_Recv_init(&sb_AttestationResponse_recv_queue, sb_AttestationResponse_queue);

  // initialise data structure for outgoing event data port TrustedIds
  sb_queue_union_art_DataContent_1_init(sb_TrustedIds_queue_1);

  // initialise data structure for incoming event data port InitiateAttestation
  sb_queue_union_art_DataContent_1_Recv_init(&sb_InitiateAttestation_recv_queue, sb_InitiateAttestation_queue);

  // initialise data structure for outgoing event data port TerminateAttestation
  sb_queue_union_art_DataContent_1_init(sb_TerminateAttestation_queue_1);

  // initialise slang-embedded components/ports
  HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_adapter_initialiseArchitecture(SF_LAST);

  // call the component's initialise entrypoint
  HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_adapter_initialiseEntryPoint(SF_LAST);

  printf("Leaving pre-init of CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager\n");
}

#ifndef CAKEML_ASSEMBLIES_PRESENT
/************************************************************************
 * int run(void)
 * Main active thread function.
 ************************************************************************/
int run(void) {
  DeclNewStackFrame(NULL, "sb_CASE_AttestationManager_Impl.c", "", "run", 0);

  sb_self_pacer_tick_emit();
  for(;;) {
    sb_self_pacer_tock_wait();
    // call the component's compute entrypoint
    HAMR_VPM_CASE_AttestationManager_Impl_SW_Attestation_Manager_CASE_AttestationManager_adapter_computeEntryPoint(SF_LAST);
    sb_self_pacer_tick_emit();
  }
  return 0;
}
#endif
