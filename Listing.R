# creating rows for AEBODSYS variable in the AEDECOD variable with blank values

Listing_AEBODSYS_data <- ADAE_original |>
  left_join(ADSL_original |> select(USUBJID, SAFFL), by = "USUBJID") |>
  filter(SAFFL == "Y") |>
  select(USUBJID, AEBODSYS) |>
  group_by(USUBJID) |>
  unique() |>
  mutate(
    AEDECOD=AEBODSYS,
    ID_var=1
  ) |>
  ungroup()

# Creating intermediate dataset for listing

Listing_data <- ADAE_original |>
  left_join(ADSL_original |> select(USUBJID, SAFFL), by = "USUBJID") |>
  filter(SAFFL == "Y") |>
  mutate(ID_var=2) |>
  derive_vars_dy(
    reference_date = TRTSDTM,
    source_vars = exprs(ASTDY=ASTDTM, AENDY=AENDTM)
  ) |>
  bind_rows(Listing_AEBODSYS_data) |>
  arrange(USUBJID, AEBODSYS, ID_var) |>
  select(USUBJID, AEDECOD, AESEV, ASTDT, AENDT, ASTDY,AENDY) |>
  mutate(across(.cols=everything(), .fns=as.character)) |>
  convert_na_to_blanks()


# Table appearance

Listing_data |>
  mutate(USUBJID=gsub("_"," ",USUBJID)) |>
  rtf_page(orientation = "landscape") |>
  rtf_colheader(
    colheader = " Unique Subject Identifier | System Organ Class/Preffered Term | Severity/Intensity | Start Date/Time of Adverse Event | End Date/Time of Adverse Event | Study Day of Start of Adverse Event | Study Day of End of Adverse Event",
    col_rel_width = c(rep(6,2),rep(3,3),rep(2,2))
  ) |>
  rtf_body(
    border_top = rep("single",7),
    border_bottom = rep("single",7),
    group_by = c("USUBJID","AEDECOD"),
    col_rel_width=c(rep(6,2),rep(3,3),rep(2,2)),
    text_justification = c(rep("l",2),rep("c",5))
  ) |>
  rtf_encode() |>
  write_rtf("listing.rtf")









