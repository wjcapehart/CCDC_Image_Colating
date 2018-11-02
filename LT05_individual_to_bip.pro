PRO LT05_individual_to_bip



  path_row      = "3329"
  in_data_dir    = "/fdrive/Projects/ccdc/"
  out_data_dir   = "/fdrive/Projects/ccdc/bip_files/"
  pr_dir         = path_row + "_Landsat"
  inventory_file = "/fdrive/Projects/ccdc/CCDC_Image_Colating/inventory_"+path_row+"_LT05.txt"

  blank_hdr_file  = "/fdrive/Projects/ccdc/CCDC_Image_Colating/"+path_row+"_landsat5_8band.hdr"


  nx =  7821
  ny =  7131
  nz =     8


  OPENR, 1, inventory_file

    n_files = file_lines (inventory_file)

    file_list = STRARR(n_files)

    READF, 1, file_list

  CLOSE, 1


  final_image = INTARR(nz,nx,ny)

  in_image = INTARR(nx,ny)

  in_cloud = BYTARR(nx,ny)


  FOR i = 0, n_files-1 DO BEGIN

    PRINT, "Processing " +  $
               STRING(i+1,n_files,FORMAT='("[",I3.3,"/",I3.3,"] ")') + $
               file_list(i)

    input_data_path =  in_data_dir + pr_dir + "/" + file_list(i)

    SPAWN, 'ls -1 ' + input_data_path+'/*_sr_band?.img '   +  $
                      input_data_path+'/*_bt_band6.img ' + $
                      input_data_path+'/*_sr_cloud_qa.img', input_filenames

    input_filenames = input_filenames(SORT(input_filenames))

    input_filenames = input_filenames([1,2,3,4,5,0,6,7])

    PRINT, " .. layer " , FORMAT='(A,$)'

    FOR k = 0, nz-1 DO BEGIN


      OPENR, 1, input_filenames(k)

        PRINT, STRING(k+1), FORMAT='(".",I1,$)'

        IF (k ne nz-1) THEN BEGIN
            READU, 1, in_image
            final_image(k,*,*) = in_image
        ENDIF ELSE BEGIN
            READU, 1, in_cloud
            final_image(k,*,*) = in_cloud
        ENDELSE

      CLOSE, 1

    ENDFOR
    PRINT, ""

    out_data_path = out_data_dir + pr_dir + "/" +  file_list(i)

    spawn, "mkdir -vp " + out_data_path


    OPENW, 1, out_data_path  + "/" +  file_list(i) + ".img"
       WRITEU, 1, final_image
    CLOSE, 1

    SPAWN, "cp  " + blank_hdr_file + " " + $
             out_data_path + "/" +  file_list(i) + ".hdr"


  ENDFOR

END
