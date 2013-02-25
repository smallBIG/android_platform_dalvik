HANDLE_OPCODE(OP_RETURN_WIDE /*vAA*/)
    vsrc1 = INST_AA(inst);
    ILOGV("|return-wide v%d", vsrc1);
    retval.j = GET_REGISTER_WIDE(vsrc1);
/* ifdef WITH_TAINT_TRACKING */
		int tag = GET_REGISTER_TAINT_WIDE(vsrc1);
    SET_RETURN_TAINT(tag);
		if(tag != 0){
			TLOGW("SESAME ret frm %s->%s with %d", curMethod->clazz->descriptor, 
					curMethod->name, tag);
		}
/* endif */
    GOTO_returnFromMethod();
OP_END
