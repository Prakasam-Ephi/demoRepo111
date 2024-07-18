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













