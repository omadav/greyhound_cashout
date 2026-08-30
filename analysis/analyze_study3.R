#!/usr/bin/env Rscript
# =============================================================================
# Greyhound Study 3 — BET SIZE as the behavioural measure
#
# Same task as Study 2 (same races, same trajectory labels, same rotation
# scheduler), plus a bet-size choice before every race (5/25/50/75/95% of
# current balance, CGT-style). This pipeline is deliberately separate from
# analyze_pilot.R and analyze_study2.R - the three studies must never be
# pooled: different samples, different stimuli, and Study 3 alone has real
# betting mechanics (balance, floor, hitFloor).
#
# UNREGISTERED PILOT. No prereg exists yet for Study 3 - this script is for
# eyeballing the pilot (stake usage, floor rate, whether there's any hint of
# the near-miss effect on bet size) before writing the confirmatory prereg.
# Nothing here should be reported as a test result.
#
# Run from the project root:
#   Rscript analysis/analyze_study3.R
# Outputs go to study3_analysis/.
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
})

data_dir <- "study3-pavlovia/data"
out_dir  <- "study3_analysis"
dir.create(out_dir, showWarnings = FALSE)

# ---- load ---------------------------------------------------------------
files <- list.files(data_dir, pattern = "\\.csv$", full.names = TRUE)
files <- files[!grepl("OMARTEST|anon", files)]

raw <- files |>
  map(\(f) read_csv(f, show_col_types = FALSE, guess_max = 100,
                    col_types = cols(outcomeCheckResponse = col_character(),
                                     attentionResponse = col_character(),
                                     consentGivenAt = col_character()))) |>
  list_rbind() |>
  filter(!is.na(condition))

stopifnot(all(raw$studyId == "study3"))  # never mix with Study 1 or 2

cond_levels <- c("CW", "NW", "NM", "CL")
traj_levels <- c("catch-up", "fall-back", "stable")

# ---- exclusions (same rule as Study 2; no prereg yet for Study 3) --------
by_pid <- raw |>
  group_by(prolificPID) |>
  summarise(
    n_trials   = n(),
    att_n      = sum(attentionCheck == TRUE, na.rm = TRUE),
    att_pass   = sum(attentionCheck == TRUE & attentionPass == TRUE, na.rm = TRUE),
    out_n      = sum(outcomeCheck == TRUE, na.rm = TRUE),
    out_pass   = sum(outcomeCheck == TRUE & outcomeCheckPass == TRUE, na.rm = TRUE),
    straight   = any(c(n_distinct(motivation) == 1, n_distinct(pleased) == 1,
                       n_distinct(luck) == 1,       n_distinct(confidence) == 1)),
    med_rt     = median(postraceRT_ms, na.rm = TRUE),
    consented  = all(!is.na(consentGivenAt) & consentGivenAt != ""),
    .groups = "drop"
  ) |>
  mutate(
    incomplete  = n_trials != 20,
    failed_att  = att_pass < att_n,
    failed_out  = out_pass < out_n,
    too_fast    = med_rt < 2000,
    exclude     = incomplete | failed_att | failed_out | straight | too_fast | !consented
  )

message(sprintf(
  "sessions: %d | incomplete: %d | slider check: %d | outcome check: %d | straight: %d | too fast: %d | no consent: %d",
  nrow(by_pid), sum(by_pid$incomplete), sum(by_pid$failed_att), sum(by_pid$failed_out),
  sum(by_pid$straight), sum(by_pid$too_fast), sum(!by_pid$consented)))

keep <- by_pid |> filter(!exclude) |> pull(prolificPID)
df <- raw |> filter(prolificPID %in% keep) |>
  mutate(condition  = factor(condition, levels = cond_levels),
         trajectory = factor(na_if(trajectory, ""), levels = traj_levels),
         raceId     = as.integer(raceId),
         betStakePct = as.numeric(betStakePct))
N <- length(keep)
message(sprintf("analysis N = %d (of %d collected)", N, nrow(by_pid)))

# ---- the long-format CSV, for reproducing everything by hand -------------
# One row per trial per participant, same shape as combined_pilot_nXX.csv and
# study2_combined_nXX.csv. Adds the betting columns unique to Study 3.
write_csv(df, file.path(out_dir, sprintf("study3_combined_n%d.csv", N)))
write_csv(by_pid, file.path(out_dir, "study3_exclusions.csv"))

# ---- betting behaviour: descriptive only ---------------------------------
stake_summary <- df |> count(betStakePct) |>
  mutate(pct_of_trials = round(100 * n / sum(n), 1)) |>
  arrange(betStakePct)

floor_summary <- df |> group_by(prolificPID) |>
  summarise(hit_floor = any(hitFloor == TRUE), .groups = "drop") |>
  count(hit_floor)

balance_summary <- df |> group_by(prolificPID) |>
  summarise(final_balance = last(balanceAfter), .groups = "drop") |>
  summarise(min = min(final_balance), max = max(final_balance),
            mean = round(mean(final_balance), 1), median = median(final_balance))

# ---- self-report NM vs CL (the classic effect, same DVs as Study 1/2) ----
pm <- df |> group_by(prolificPID, condition) |>
  summarise(across(c(confidence, pleased, motivation, luck), mean), .groups = "drop")
nm_cl <- pm |> select(prolificPID, condition, confidence, pleased, motivation, luck) |>
  pivot_longer(c(confidence, pleased, motivation, luck), names_to = "dv", values_to = "val") |>
  filter(condition %in% c("NM", "CL")) |>
  pivot_wider(names_from = condition, values_from = val) |>
  mutate(diff = NM - CL)
nm_cl_summary <- nm_cl |> group_by(dv) |>
  summarise(NM = round(mean(NM), 1), CL = round(mean(CL), 1), diff = round(mean(diff), 1), .groups = "drop")

# ---- behavioural: bet size on trial t+1, by what happened on trial t -----
# Lag-1 by construction, one row per trial after the first within each participant.
lag1 <- df |> arrange(prolificPID, trialNumber) |>
  group_by(prolificPID) |>
  mutate(prev_condition = lag(condition)) |>
  ungroup() |>
  filter(!is.na(prev_condition))
write_csv(lag1 |> select(prolificPID, trialNumber, prev_condition, betStakePct, balanceBefore),
          file.path(out_dir, sprintf("study3_lag1_n%d.csv", N)))

lag1_summary <- lag1 |> group_by(prev_condition) |>
  summarise(mean_next_stake_pct = round(100 * mean(betStakePct), 1), n = n(), .groups = "drop")

nm_cl_bet <- lag1 |> filter(prev_condition %in% c("NM", "CL")) |>
  group_by(prolificPID, prev_condition) |>
  summarise(stake = mean(betStakePct), .groups = "drop") |>
  pivot_wider(names_from = prev_condition, values_from = stake) |>
  filter(!is.na(NM), !is.na(CL)) |>
  mutate(diff = NM - CL)

# ---- write it all out -----------------------------------------------------
sink(file.path(out_dir, "study3_stats.txt"))
cat("Greyhound Study 3 (bet size) - UNREGISTERED PILOT, N =", N, "of", nrow(by_pid), "collected\n")
cat("Exclusions: incomplete", sum(by_pid$incomplete),
    "| slider check", sum(by_pid$failed_att),
    "| outcome check", sum(by_pid$failed_out),
    "| straight-lined", sum(by_pid$straight),
    "| too fast", sum(by_pid$too_fast),
    "| no consent", sum(!by_pid$consented), "\n\n")

cat("=== Betting behaviour (descriptive) ===\n")
cat("\nstake usage, all trials:\n"); print(as.data.frame(stake_summary))
cat("\nfinal balance (started at 100):\n"); print(as.data.frame(balance_summary))
cat("\nsessions hitting the floor (>=1 trial):\n"); print(as.data.frame(floor_summary))

cat("\n\n=== Self-report NM vs CL (classic near-miss effect, same DVs as Study 1/2) ===\n")
print(as.data.frame(nm_cl_summary))

cat("\n\n=== Behavioural: mean bet stake on trial t+1, by condition on trial t ===\n")
print(as.data.frame(lag1_summary))
cat("\nNM vs CL specifically, paired by participant (descriptive - no test, N too small):\n")
print(nm_cl_bet |> summarise(NM = round(mean(NM), 3), CL = round(mean(CL), 3), diff = round(mean(diff), 3)) |> as.data.frame())

cat("\n\nNOTE: no significance tests are run in this script. This is an unregistered\n")
cat("pilot - the point is to look at stake usage and effect DIRECTION before writing\n")
cat("the confirmatory pre-registration, not to report p-values from a small, growing N.\n")
sink()

message(sprintf("saved study3_combined_n%d.csv, study3_lag1_n%d.csv, study3_exclusions.csv, study3_stats.txt to %s/", N, N, out_dir))
