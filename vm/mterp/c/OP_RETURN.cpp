HANDLE_OPCODE($opcode /*vAA*/)
    vsrc1 = INST_AA(inst);
    ILOGV("|return%s v%d",
        (INST_INST(inst) == OP_RETURN) ? "" : "-object", vsrc1);
    retval.i = GET_REGISTER(vsrc1);
/* ifdef WITH_TAINT_TRACKING */
		int tag = GET_REGISTER_TAINT(vsrc1);
    SET_RETURN_TAINT(tag);
		if(tag != 0){
			TLOGW("SESAME ret frm %s->%s with %d", curMethod->clazz->descriptor, 
					curMethod->name, tag);
		}
/* endif */
    GOTO_returnFromMethod();
OP_END
