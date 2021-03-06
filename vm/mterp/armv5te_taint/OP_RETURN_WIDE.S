%verify "executed"
    /*
     * Return a 64-bit value.  Copies the return value into the "thread"
     * structure, then jumps to the return handler.
     */
    /* return-wide vAA */
    mov     r2, rINST, lsr #8           @ r2<- AA
// begin WITH_TAINT_TRACKING
    add     r2, rFP, r2, lsl #3         @ r2<- &fp[AA]
// end WITH_TAINT_TRACKING
    add     r3, rSELF, #offThread_retval  @ r3<- &self->retval
// begin WITH_TAINT_TRACKING
//    ldmia   r2, {r0-r1}                 @ r0/r1 <- vAA/vAA+1
    ldr     r0, [r2, #0]
    ldr     r1, [r2, #8]
    ldr     r9, [r2, #4]
    str     r9, [rSELF, #offThread_rtaint]
// end WITH_TAINT_TRACKING
    stmia   r3, {r0-r1}                 @ retval<- r0/r1
    b       common_returnFromMethod
