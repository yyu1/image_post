;Input is assumed to be float of ALOS HH and HV, and need to be squared to get sigma0 values

PRO create_rfdi, hh_file, hv_file, outfile

  ;get file sizes
  file1_info = file_info(hh_file)
  file2_info = file_info(hv_file)

  ;make sure sizes are the same
  file1_size = file1_info.size
  file2_size = file2_info.size

  if file1_size ne file2_size then begin
    print, 'File sizes do not match, exiting...'
    exit
  endif


	nblocks = file1_size/4/1000
	remainder = file1_size mod 4000ULL

	hh_block = fltarr(nblocks)
	hv_block = fltarr(nblocks)
	hh_sig0 = fltarr(nblocks)
	hv_sig0 = fltarr(nblocks)

	openr, hh_lun, hh_file, /get_lun
	openr, hv_lun, hv_file, /get_lun
	openw, outlun, outfile, /get_lun

	for i=0ULL, 999 do begin
		print, i
		readu, hh_lun, hh_block
		readu, hv_lun, hv_block

		hh_sig0[*] = hh_block*hh_block
		hv_sig0[*] = hv_block*hv_block
		writeu, outlun, (hh_sig0-hv_sig0)/(hh_sig0+hv_sig0)
	endfor

	if (remainder ne 0) then begin
		print, i
		hh_block = fltarr(remainder/4ULL)
		hv_block = fltarr(remainder/4ULL)
		hh_sig0 = fltarr(remainder/4ULL)
		hv_sig0 = fltarr(remainder/4ULL)

		readu, hh_lun, hh_block
		readu, hv_lun, hv_block
		hh_sig0[*] = hh_block*hh_block
		hv_sig0[*] = hv_block*hv_block
		writeu, outlun, (hh_sig0-hv_sig0)/(hh_sig0+hv_sig0)
	endif

	free_lun, hh_lun
	free_lun, hv_lun
	free_lun, outlun

END
