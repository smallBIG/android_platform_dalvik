// begin WITH_TAINT_TRACKING
%default { "store":"str", "postbarrier":"@ no-op ", "prebarrier":"@ no-op ", "sqnum":"0", "volatile":"0" }
// end WITH_TAINT_TRACKING
%verify "executed"
%verify "null object"
%verify "field already resolved"
%verify "field not yet resolved"
%verify "field cannot be resolved"
    /*
     * General 32-bit instance field put.
     *
     * for: iput, iput-boolean, iput-byte, iput-char, iput-short
     */
    /* op vA, vB, field@CCCC */
    mov     r0, rINST, lsr #12          @ r0<- B
    ldr     r3, [rSELF, #offThread_methodClassDex]    @ r3<- DvmDex
    FETCH(r1, 1)                        @ r1<- field ref CCCC
    ldr     r2, [r3, #offDvmDex_pResFields] @ r2<- pDvmDex->pResFields
    GET_VREG(r9, r0)                    @ r9<- fp[B], the object pointer
    ldr     r0, [r2, r1, lsl #2]        @ r0<- resolved InstField ptr
    cmp     r0, #0                      @ is resolved entry null?
    bne     .L${opcode}_finish          @ no, already resolved
8:  ldr     r2, [rSELF, #offThread_method]    @ r2<- current method
    EXPORT_PC()                         @ resolve() could throw
    ldr     r0, [r2, #offMethod_clazz]  @ r0<- method->clazz
    bl      dvmResolveInstField         @ r0<- resolved InstField ptr
    cmp     r0, #0                      @ success?
    bne     .L${opcode}_finish          @ yes, finish up
    b       common_exceptionThrown
%break

    /*
     * Currently:
     *  r0 holds resolved field
     *  r9 holds object
     */
.L${opcode}_finish:
    @bl      common_squeak${sqnum}
    mov     r1, rINST, lsr #8           @ r1<- A+
    ldr     r3, [r0, #offInstField_byteOffset]  @ r3<- byte offset of field
    and     r1, r1, #15                 @ r1<- A
    cmp     r9, #0                      @ check object for null
    GET_VREG(r0, r1)                    @ r0<- fp[A]
// begin WITH_TAINT_TRACKING
    SET_TAINT_FP(r2)
    GET_VREG_TAINT(r10, r1, r2)
// end WITH_TAINT_TRACKING
    beq     common_errNullObject        @ object was null
    FETCH_ADVANCE_INST(2)               @ advance rPC, load rINST
    GET_INST_OPCODE(ip)                 @ extract opcode from rINST
    $prebarrier                         @ releasing store
// begin WITH_TAINT_TRACKING
//    .if     $volatile
//    add     r2, r9, r3                  @ r2<- target address
//    mov	    r1, r10                     @ r1<-taint
//    bl      dvmQuasiAtomicSwap64        @ stores r0/r1 into addr r2
//    .else
    $store  r0, [r9, r3]                @ obj.field (8/16/32 bits)<- r0
    add	    r3, r3, #4
    str	    r10, [r9, r3]
//    .endif
// end WITH_TAINT_TRACKING
    $postbarrier
    GOTO_OPCODE(ip)                     @ jump to next instruction

