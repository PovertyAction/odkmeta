vers 11.2

matamac

mata:

void error_parsing(`RS' rc, `SS' opt, |`SS' subopt)
{
	// [ID 61]
	if (subopt != "")
		errprintf("invalid %s suboption\n", subopt)
	errprintf("invalid %s() option\n", opt)
	exit(rc)
}

void error_overlap(`SS' overlap, `SR' opts, |`RS' subopts)
{
	// No [ID] required.
	errprintf("%s cannot be specified to both options %s() and %s()\n",
		adorn_quotes(overlap, "list"), opts[1], opts[2])
	if (args() < 3 | !subopts)
		exit(198)
}

end
