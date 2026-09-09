#!/usr/bin/env Rscript
# =============================================================================
# Greyhound Study 6 — BET AVAILABILITY, properly controlled (between-subjects)
#
# Fixes Study 5's design flaw: bet-availability there rotated trial-by-trial
# within one session, but the hypothesized mechanism (having money generally
# on the line changes your overall mindset) is a session-level thing, not a
# per-trial one - toggling it within a session just contaminates both
# conditions with the same overall mindset. Study 6 instead randomly assigns
# each participant ONCE, before consent, to a whole session with betting on
# every trial or a whole session with no betting ever. Same race pool,
# rotation scheme, and condition counts in both arms - only the group differs,
# and it's assigned by crypto.getRandomValues, not confounded with time,
# sample, or anything else the way the old Study 1/2-vs-3/4 comparison was.
#
# PRIMARY ANALYSIS: participant-level mean confidence (pooled across all 20
# trials, irrespective of condition/outcome), betting group vs no-betting
# group, independent-samples comparison. This script computes it, but with
# this pilot's N, do not treat the result as confirmatory - see the note at
# the end.
#
# Run from the project root:
#   Rscript analysis/analyze_study6.R
# Outputs go to study6_analysis/.
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
})

data_dir <- "study6-pavlovia/data"
out_dir  <- "study6_analysis"
dir.create(out_dir, showWarnings = FALSE)

# ---- load ---------------------------------------------------------------
files <- list.files(data_dir, pattern = "\\.csv$", full.names = TRUE)
files <- files[!grepl("OMARTEST|anon", files)]

raw <- files |>
  map(\(f) read_csv(f, show_col_types = FALSE, guess_max = 100,
                    col_types = cols(outcomeCheckResponse = col_character(),
                                     attentionResponse = col_character(),
                                     consentGivenAt = col_character(),
                                     completedAt = col_character(),
                                     groupAssignedAt = col_character(),
                                     betAvailable = col_logical(),
                                     finalBalance = col_character(),   # blank for no_betting
                                     bonusGBP = col_character(),       # blank for no_betting
                                     bonusAssignment = col_character()))) |>
  list_rbind() |>
  filter(!is.na(condition))

stopifnot(all(raw$studyId == "study6"))  # never mix with Study 1-5

cond_levels <- c("CW", "NW", "NM", "CL")
traj_levels <- c("catch-up", "fall-back", "stable")
group_levels <- c("betting", "no_betting")

# ---- exclusions -----------------------------------------------------------
# Same quality rules as Study 3-5, PLUS a check the README calls out
# explicitly: a participant must have exactly one group value across every
# row. More than one means a corrupted/overwritten localStorage assignment
# (e.g. cleared storage mid-session) - the session isn't trustworthy either
# way, so it's excluded rather than guessed at.
by_pid <- raw |>
  group_by(prolificPID) |>
  summarise(
    n_trials    = n(),
    n_groups    = n_distinct(group),
    group       = first(group),
    att_n       = sum(attentionCheck == TRUE, na.rm = TRUE),
    att_pass    = sum(attentionCheck == TRUE & attentionPass == TRUE, na.rm = TRUE),
    out_n       = sum(outcomeCheck == TRUE, na.rm = TRUE),
    out_pass    = sum(outcomeCheck == TRUE & outcomeCheckPass == TRUE, na.rm = TRUE),
    straight    = any(c(n_distinct(motivation) == 1, n_distinct(pleased) == 1,
                        n_distinct(luck) == 1,       n_distinct(confidence) == 1)),
    med_rt      = median(postraceRT_ms, na.rm = TRUE),
    consented   = all(!is.na(consentGivenAt) & consentGivenAt != ""),
    .groups = "drop"
  ) |>
  mutate(
    incomplete       = n_trials != 20,
    inconsistent_grp = n_groups != 1,
    failed_att       = att_pass < att_n,
    failed_out       = out_pass < out_n,
    too_fast         = med_rt < 2000,
    exclude = incomplete | inconsistent_grp | failed_att | failed_out |
              straight | too_fast | !consented
  )

# Duplicate Prolific IDs across separate CSV files (e.g. a resumed session
# after clearing storage, or two genuinely repeated submissions) would show
# up as n_trials > 20 above and get caught by `incomplete`; flagged again
# here explicitly since the README calls out duplicates by name.
dupes <- raw |> count(prolificPID) |> filter(n > 20)

message(sprintf(
  "sessions: %d | incomplete: %d | inconsistent group: %d | slider check: %d | outcome check: %d | straight: %d | too fast: %d | no consent: %d",
  nrow(by_pid), sum(by_pid$incomplete), sum(by_pid$inconsistent_grp),
  sum(by_pid$failed_att), sum(by_pid$failed_out), sum(by_pid$straight),
  sum(by_pid$too_fast), sum(!by_pid$consented)))
if (nrow(dupes)) message(sprintf("WARNING: %d prolificPID(s) with >20 rows - check for duplicate submissions", nrow(dupes)))

keep <- by_pid |> filter(!exclude) |> pull(prolificPID)
df <- raw |> filter(prolificPID %in% keep) |>
  mutate(condition  = factor(condition, levels = cond_levels),
         trajectory = factor(na_if(trajectory, ""), levels = traj_levels),
         group      = factor(group, levels = group_levels),
         raceId     = as.integer(raceId))
N <- length(keep)
message(sprintf("analysis N = %d (of %d collected)", N, nrow(by_pid)))

# ---- the long-format CSV, for reproducing everything by hand -------------
write_csv(df, file.path(out_dir, sprintf("study6_combined_n%d.csv", N)))
write_csv(by_pid, file.path(out_dir, "study6_exclusions.csv"))

# ---- health check: group balance and per-group exclusion rate -------------
group_balance <- by_pid |> count(group, exclude_flag = exclude) |>
  pivot_wider(names_from = exclude_flag, values_from = n, values_fill = 0,
              names_prefix = "exclude_")

# ---- health check: condition/trajectory counts, by group ------------------
cond_check <- df |> count(group, condition) |>
  pivot_wider(names_from = condition, values_from = n, values_fill = 0)
traj_check <- df |> filter(condition %in% c("NM", "NW")) |>
  count(group, condition, trajectory) |>
  pivot_wider(names_from = trajectory, values_from = n, values_fill = 0)

# ---- PRIMARY: confidence, betting vs no_betting, independent samples ------
conf_by_group <- df |> group_by(prolificPID, group) |>
  summarise(confidence = mean(confidence), .groups = "drop")
g_bet <- conf_by_group |> filter(group == "betting") |> pull(confidence)
g_nobet <- conf_by_group |> filter(group == "no_betting") |> pull(confidence)
# Directional hypothesis (betting lowers confidence) is grounded in the
# Study 1-4 cross-study comparison in the report, not fished from this data -
# one-tailed is the honest primary test here; two-tailed kept alongside.
tt_conf   <- t.test(g_bet, g_nobet, alternative = "less")
tt_conf_2 <- t.test(g_bet, g_nobet)
wt_conf   <- wilcox.test(g_bet, g_nobet, alternative = "less")
wt_conf_2 <- wilcox.test(g_bet, g_nobet)
pooled_sd <- sqrt(((length(g_bet)-1)*sd(g_bet)^2 + (length(g_nobet)-1)*sd(g_nobet)^2) /
                    (length(g_bet)+length(g_nobet)-2))
cohen_d <- (mean(g_bet) - mean(g_nobet)) / pooled_sd

# ---- self-report NM vs CL, within each group (does the classic effect hold) -
pm <- df |> group_by(prolificPID, group, condition) |>
  summarise(across(c(confidence, pleased, motivation, luck), mean), .groups = "drop")
nm_cl_by_group <- map_dfr(group_levels, function(g) {
  w <- pm |> filter(group == g) |>
    select(prolificPID, condition, motivation) |>
    pivot_wider(names_from = condition, values_from = motivation) |>
    filter(!is.na(NM), !is.na(CL))
  if (nrow(w) < 2) return(tibble(group = g, n = nrow(w), NM = NA, CL = NA, diff = NA, p = NA))
  tt <- t.test(w$NM, w$CL, paired = TRUE)
  tibble(group = g, n = nrow(w), NM = round(mean(w$NM), 1), CL = round(mean(w$CL), 1),
         diff = round(mean(w$NM - w$CL), 1), p = tt$p.value)
})

# ---- bonus sanity check (betting group only has a real bonusGBP) ----------
bonus_check <- df |> group_by(prolificPID, group) |>
  summarise(bonusGBP = first(bonusGBP), .groups = "drop") |>
  group_by(group) |>
  summarise(n = n(), n_blank = sum(bonusGBP == "" | is.na(bonusGBP)),
            n_valued = sum(bonusGBP != "" & !is.na(bonusGBP)), .groups = "drop")

# ---- write it all out -----------------------------------------------------
sink(file.path(out_dir, "study6_stats.txt"))
cat("Greyhound Study 6 (bet availability, between-subjects) - UNCONFIRMATORY FIRST LOOK, N =",
    N, "of", nrow(by_pid), "collected\n")
cat("Exclusions: incomplete", sum(by_pid$incomplete),
    "| inconsistent group", sum(by_pid$inconsistent_grp),
    "| slider check", sum(by_pid$failed_att),
    "| outcome check", sum(by_pid$failed_out),
    "| straight-lined", sum(by_pid$straight),
    "| too fast", sum(by_pid$too_fast),
    "| no consent", sum(!by_pid$consented), "\n")
if (nrow(dupes)) cat("WARNING:", nrow(dupes), "prolificPID(s) with >20 rows - check for duplicate submissions\n")
cat("\n")

cat("=== Health check: group balance (should be roughly 50/50; 'random' means approximate) ===\n")
print(as.data.frame(group_balance))

cat("\n\n=== Health check: condition counts by group (each row should read 4 CW / 6 NW / 6 NM / 4 CL) ===\n")
print(as.data.frame(cond_check))

cat("\n\n=== Health check: NM/NW trajectory counts by group (each should read 2/2/2) ===\n")
print(as.data.frame(traj_check))

cat("\n\n=== Health check: bonus field sanity (betting group should be all valued, no_betting all blank) ===\n")
print(as.data.frame(bonus_check))

cat("\n\n=== PRIMARY: confidence, betting vs no-betting, independent samples ===\n")
cat(sprintf("betting:    n=%d, mean=%.1f, sd=%.1f\n", length(g_bet), mean(g_bet), sd(g_bet)))
cat(sprintf("no_betting: n=%d, mean=%.1f, sd=%.1f\n", length(g_nobet), mean(g_nobet), sd(g_nobet)))
cat(sprintf("diff = %.2f\n", mean(g_bet) - mean(g_nobet)))
cat(sprintf("H1 (directional, from Study 1-4 pattern): betting < no_betting\n"))
cat(sprintf("independent t-test, one-tailed: t(%.1f) = %.2f, p = %.4f  (two-tailed p = %.4f)\n",
            tt_conf$parameter, tt_conf$statistic, tt_conf$p.value, tt_conf_2$p.value))
cat(sprintf("Wilcoxon rank-sum, one-tailed: p = %.4f  (two-tailed p = %.4f)\n",
            wt_conf$p.value, wt_conf_2$p.value))
cat(sprintf("Cohen's d = %.2f\n", cohen_d))

cat("\n\n=== Self-report NM vs CL (classic near-miss effect), within each group ===\n")
print(as.data.frame(nm_cl_by_group))

cat("\n\nNOTE: this is a first look at data quality and direction, not a powered test.\n")
cat("Study 6's whole point is a clean, single, adequately powered confirmatory run.\n")
cat("A null or a 'significant' result at this N is equally uninformative - see the\n")
cat("power table worked out in conversation. One-tailed (justified by the Study 1-4\n")
cat("direction): d=0.53 anchor needs ~45/arm, d=0.4 needs ~78/arm for 80% power.\n")
cat("Do not report the primary p-value above as if it settles anything until N\n")
cat("reaches the pre-registered target.\n")
sink()

message(sprintf("saved study6_combined_n%d.csv, study6_exclusions.csv, study6_stats.txt to %s/", N, out_dir))
