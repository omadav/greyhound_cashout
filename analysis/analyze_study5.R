#!/usr/bin/env Rscript
# =============================================================================
# Greyhound Study 5 — BET AVAILABILITY as a within-subject factor
#
# Same task as Study 4 (same races, same trajectory labels, same rotation
# scheduler, same balance/floor/payment mechanics, same continuous bet
# slider), plus one new manipulation: on half of every condition's trials
# the bet screen does not appear at all - no points at risk, just watch.
#
# Motivation: Studies 1-2 (no betting mechanic anywhere) show clearly higher
# mean pre-race confidence than Studies 3-4 (betting on every trial) - 48.2 vs
# 37.7 pooled, d=0.53 - but that is a BETWEEN-study comparison, confounded
# with everything else that differs between those studies. This tests it
# within the same person: does merely having a bet available change
# confidence, holding condition and trajectory constant?
#
# UNREGISTERED PILOT. No prereg exists yet for Study 5 - this script is for
# eyeballing the pilot before writing the confirmatory pre-registration.
# Nothing here should be reported as a test result.
#
# Run from the project root:
#   Rscript analysis/analyze_study5.R
# Outputs go to study5_analysis/.
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
})

data_dir <- "study5-pavlovia/data"
out_dir  <- "study5_analysis"
dir.create(out_dir, showWarnings = FALSE)

# ---- load ---------------------------------------------------------------
files <- list.files(data_dir, pattern = "\\.csv$", full.names = TRUE)
files <- files[!grepl("OMARTEST|anon", files)]

raw <- files |>
  map(\(f) read_csv(f, show_col_types = FALSE, guess_max = 100,
                    col_types = cols(outcomeCheckResponse = col_character(),
                                     attentionResponse = col_character(),
                                     consentGivenAt = col_character(),
                                     betAvailable = col_logical()))) |>
  list_rbind() |>
  filter(!is.na(condition))

stopifnot(all(raw$studyId == "study5"))  # never mix with Study 1-4

cond_levels <- c("CW", "NW", "NM", "CL")
traj_levels <- c("catch-up", "fall-back", "stable")

# ---- exclusions (same rule as Study 3/4; no prereg yet for Study 5) ------
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
write_csv(df, file.path(out_dir, sprintf("study5_combined_n%d.csv", N)))
write_csv(by_pid, file.path(out_dir, "study5_exclusions.csv"))

# ---- sanity check: does the bet-available split actually come out 50/50? -
bet_avail_check <- df |> count(condition, betAvailable) |>
  pivot_wider(names_from = betAvailable, values_from = n, values_fill = 0)

# ---- THE primary question: confidence, bet-available vs not --------------
# Pooled across conditions - that is where the power is (see trial-config.js
# header for why). Per participant, per bet-status, mean confidence.
conf_by_bet <- df |> group_by(prolificPID, betAvailable) |>
  summarise(confidence = mean(confidence), .groups = "drop") |>
  pivot_wider(names_from = betAvailable, values_from = confidence) |>
  rename(bet_available = `TRUE`, bet_unavailable = `FALSE`) |>
  filter(!is.na(bet_available), !is.na(bet_unavailable)) |>
  mutate(diff = bet_available - bet_unavailable)

tt_conf <- t.test(conf_by_bet$bet_available, conf_by_bet$bet_unavailable, paired = TRUE)
wt_conf <- wilcox.test(conf_by_bet$bet_available, conf_by_bet$bet_unavailable, paired = TRUE)

# ---- descriptive: confidence by bet-status x condition (thin, exploratory) -
conf_by_bet_cond <- df |> group_by(prolificPID, condition, betAvailable) |>
  summarise(confidence = mean(confidence), .groups = "drop") |>
  group_by(condition, betAvailable) |>
  summarise(mean_confidence = round(mean(confidence), 1), n_participants = n(), .groups = "drop")

# ---- self-report NM vs CL (the classic effect, same DVs as Study 1-4) ----
pm <- df |> group_by(prolificPID, condition) |>
  summarise(across(c(confidence, pleased, motivation, luck), mean), .groups = "drop")
nm_cl <- pm |> select(prolificPID, condition, confidence, pleased, motivation, luck) |>
  pivot_longer(c(confidence, pleased, motivation, luck), names_to = "dv", values_to = "val") |>
  filter(condition %in% c("NM", "CL")) |>
  pivot_wider(names_from = condition, values_from = val) |>
  mutate(diff = NM - CL)
nm_cl_summary <- nm_cl |> group_by(dv) |>
  summarise(NM = round(mean(NM), 1), CL = round(mean(CL), 1), diff = round(mean(diff), 1), .groups = "drop")

# ---- behavioural: bet size on trial t+1 (bet-available trials only) ------
lag1 <- df |> filter(betAvailable) |> arrange(prolificPID, trialNumber) |>
  group_by(prolificPID) |>
  mutate(prev_condition = lag(condition)) |>
  ungroup() |> filter(!is.na(prev_condition))
lag1_summary <- lag1 |> group_by(prev_condition) |>
  summarise(mean_next_stake_pct = round(100 * mean(betStakePct), 1), n = n(), .groups = "drop")

# ---- write it all out -----------------------------------------------------
sink(file.path(out_dir, "study5_stats.txt"))
cat("Greyhound Study 5 (bet availability) - UNREGISTERED PILOT, N =", N, "of", nrow(by_pid), "collected\n")
cat("Exclusions: incomplete", sum(by_pid$incomplete),
    "| slider check", sum(by_pid$failed_att),
    "| outcome check", sum(by_pid$failed_out),
    "| straight-lined", sum(by_pid$straight),
    "| too fast", sum(by_pid$too_fast),
    "| no consent", sum(!by_pid$consented), "\n\n")

cat("=== Sanity check: bet-available split, by condition (should be exact halves) ===\n")
print(as.data.frame(bet_avail_check))

cat("\n\n=== PRIMARY: confidence, bet-available vs bet-unavailable, pooled across conditions ===\n")
cat(sprintf("bet-available:   mean=%.1f\n", mean(conf_by_bet$bet_available)))
cat(sprintf("bet-unavailable: mean=%.1f\n", mean(conf_by_bet$bet_unavailable)))
cat(sprintf("diff = %.2f\n", mean(conf_by_bet$diff)))
cat(sprintf("paired t-test: t(%d) = %.2f, p = %.4f\n", tt_conf$parameter, tt_conf$statistic, tt_conf$p.value))
cat(sprintf("Wilcoxon signed-rank: p = %.4f\n", wt_conf$p.value))
cat(sprintf("dz = %.2f\n", mean(conf_by_bet$diff) / sd(conf_by_bet$diff)))

cat("\n\n=== Descriptive: confidence by bet-status x condition (thin - exploratory only) ===\n")
print(as.data.frame(conf_by_bet_cond))

cat("\n\n=== Self-report NM vs CL (classic near-miss effect, same DVs as Study 1-4) ===\n")
print(as.data.frame(nm_cl_summary))

cat("\n\n=== Behavioural: mean bet stake on trial t+1, by condition on trial t (bet-available trials only) ===\n")
print(as.data.frame(lag1_summary))

cat("\n\nNOTE: no significance tests other than the primary confidence x bet-availability\n")
cat("comparison are meant to be trusted here. This is an unregistered pilot - the point\n")
cat("is to see whether the effect direction/size holds up before writing a confirmatory\n")
cat("pre-registration, not to report a battery of p-values from a small, growing N.\n")
sink()

message(sprintf("saved study5_combined_n%d.csv, study5_exclusions.csv, study5_stats.txt to %s/", N, out_dir))
