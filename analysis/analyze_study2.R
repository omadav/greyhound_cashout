#!/usr/bin/env Rscript
# =============================================================================
# Greyhound Study 2 — near-miss TRAJECTORY
#
# Separate from analyze_pilot.R on purpose. Study 1 and Study 2 are different
# studies with different stimuli (Study 1 clips end on the result board, Study 2
# clips end at the finish line) and must never be pooled.
#
# Reads study2-pavlovia/data/, applies the pre-registered exclusions, and runs
# the pre-registered tests in order.
#
# Run from the project root:
#   Rscript analysis/analyze_study2.R
# Outputs go to study2_analysis/.
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(patchwork)
})

data_dir <- "study2-pavlovia/data"
out_dir  <- "study2_analysis"
dir.create(out_dir, showWarnings = FALSE)

# ---- load -------------------------------------------------------------------
files <- list.files(data_dir, pattern = "\\.csv$", full.names = TRUE)
files <- files[!grepl("OMARTEST|anon", files)]          # drop our own test runs

# outcomeCheckResponse is 1/2/3 for a placing but the text "further back"
# otherwise, so it types as double in some files and character in others.
raw <- files |>
  map(\(f) read_csv(f, show_col_types = FALSE, guess_max = 100,
                    col_types = cols(outcomeCheckResponse = col_character(),
                                     attentionResponse = col_character()))) |>
  list_rbind() |>
  filter(!is.na(condition))

stopifnot(all(raw$studyId == "study2"))                 # never mix studies

cond_levels <- c("CW", "NW", "NM", "CL")
traj_levels <- c("catch-up", "fall-back", "stable")

# ---- pre-registered exclusions ----------------------------------------------
# complete 20 trials; passed every attention check (slider AND outcome);
# no straight-lining; median trial RT >= 2 s.
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
    .groups = "drop"
  ) |>
  mutate(
    incomplete  = n_trials != 20,
    failed_att  = att_pass < att_n,
    failed_out  = out_pass < out_n,
    too_fast    = med_rt < 2000,
    exclude     = incomplete | failed_att | failed_out | straight | too_fast
  )

message(sprintf(
  "sessions: %d | incomplete: %d | failed slider check: %d | failed outcome check: %d | straight-lined: %d | too fast: %d",
  nrow(by_pid), sum(by_pid$incomplete), sum(by_pid$failed_att),
  sum(by_pid$failed_out), sum(by_pid$straight), sum(by_pid$too_fast)))

keep <- by_pid |> filter(!exclude) |> pull(prolificPID)
df <- raw |> filter(prolificPID %in% keep) |>
  mutate(condition  = factor(condition, levels = cond_levels),
         trajectory = factor(na_if(trajectory, ""), levels = traj_levels),
         raceId     = as.integer(raceId))
N <- length(keep)
message(sprintf("analysis N = %d (of %d)", N, nrow(by_pid)))
write_csv(df, file.path(out_dir, sprintf("study2_combined_n%d.csv", N)))
write_csv(by_pid, file.path(out_dir, "study2_exclusions.csv"))

dvs <- c(confidence = "Pre-race confidence", pleased = "Pleasure",
         motivation = "Motivation to continue", luck = "Luck")

# participant x condition means
pm <- df |> group_by(prolificPID, condition) |>
  summarise(across(all_of(names(dvs)), mean), .groups = "drop")
# participant x trajectory means, near-miss trials only
pt <- df |> filter(condition == "NM") |>
  group_by(prolificPID, trajectory) |>
  summarise(across(all_of(names(dvs)), mean), .groups = "drop")

# ---- within-subject CIs (Cousineau-Morey) -----------------------------------
wsci <- function(dat, group, colname, conf = 0.95) {
  g <- rlang::ensym(group)
  M <- dplyr::n_distinct(dat[[rlang::as_string(g)]]); gm <- mean(dat[[colname]])
  dat |> group_by(prolificPID) |>
    mutate(subj = mean(.data[[colname]]), yn = .data[[colname]] - subj + gm) |>
    ungroup() |> group_by(!!g) |>
    summarise(m = mean(.data[[colname]]), sdn = sd(yn), nn = n(), .groups = "drop") |>
    mutate(sem = sdn / sqrt(nn) * sqrt(M / (M - 1)),
           ci  = qt(1 - (1 - conf) / 2, nn - 1) * sem, lo = m - ci, hi = m + ci)
}

# ---- Figure 1: the four conditions (H1 replication) -------------------------
panel_cond <- function(label, colname) {
  s <- wsci(pm, condition, colname)
  ggplot(s, aes(condition, m, fill = condition)) +
    geom_col(width = 0.66) +
    geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.15) +
    scale_fill_manual(values = c(CW = "#009E73", NW = "#56B4E9",
                                 NM = "#E69F00", CL = "#D55E00"), guide = "none") +
    coord_cartesian(ylim = c(0, 100)) +
    labs(title = label, x = NULL, y = NULL) +
    theme_minimal(base_size = 12)
}
fig1 <- wrap_plots(imap(dvs, panel_cond), ncol = 2) +
  plot_annotation(
    title = sprintf("Study 2 (n=%d): ratings by outcome", N),
    subtitle = "mean +/- within-subject 95% CI. H1 is the near miss vs clear loss gap.",
    theme = theme(plot.title = element_text(face = "bold", size = 14)))
ggsave(file.path(out_dir, "s2_fig1_by_condition.png"), fig1, width = 11, height = 8.5, dpi = 150)

# ---- Figure 2: near misses split by trajectory (H2, primary) ----------------
panel_traj <- function(label, colname) {
  s <- wsci(pt, trajectory, colname)
  ggplot(s, aes(trajectory, m, fill = trajectory)) +
    geom_col(width = 0.6) +
    geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.14) +
    scale_fill_manual(values = c("catch-up" = "#E69F00", "fall-back" = "#B25400",
                                 "stable" = "#B0982E"), guide = "none") +
    coord_cartesian(ylim = c(0, 100)) +
    labs(title = label, x = NULL, y = NULL) +
    theme_minimal(base_size = 12) +
    theme(axis.text.x = element_text(angle = 12, hjust = 1))
}
fig2 <- wrap_plots(imap(dvs, panel_traj), ncol = 2) +
  plot_annotation(
    title = sprintf("Study 2 (n=%d): NEAR MISS trials only, by trajectory", N),
    subtitle = "mean +/- within-subject 95% CI. H2 predicts catch-up > stable on motivation.",
    theme = theme(plot.title = element_text(face = "bold", size = 14)))
ggsave(file.path(out_dir, "s2_fig2_by_trajectory.png"), fig2, width = 11, height = 8.5, dpi = 150)

# ---- Figure 3: within-clip near-miss cost, by trajectory --------------------
# Same clip is a narrow win for some participants and a near miss for others, so
# NM - NW within a clip cancels everything about that particular race.
clip <- df |>
  filter(condition %in% c("NW", "NM"), !is.na(trajectory)) |>
  group_by(raceId, trajectory, condition) |>
  summarise(across(all_of(names(dvs)), mean), .groups = "drop") |>
  pivot_longer(all_of(names(dvs)), names_to = "colname", values_to = "val") |>
  pivot_wider(names_from = condition, values_from = val) |>
  mutate(delta = NM - NW,
         dv_label = factor(colname, levels = names(dvs), labels = unname(dvs)))

clip_m <- clip |> group_by(dv_label, trajectory) |>
  summarise(m = mean(delta), se = sd(delta) / sqrt(n()), k = n(), .groups = "drop")

fig3 <- ggplot(clip, aes(trajectory, delta, colour = trajectory)) +
  geom_hline(yintercept = 0, linewidth = 0.4, colour = "grey40") +
  geom_point(size = 2.6, alpha = 0.75,
             position = position_jitter(width = 0.07, height = 0, seed = 1)) +
  geom_errorbar(data = clip_m, inherit.aes = FALSE,
                aes(trajectory, ymin = m - se, ymax = m + se), width = 0.13) +
  geom_point(data = clip_m, inherit.aes = FALSE, aes(trajectory, m),
             shape = 95, size = 12) +
  geom_text(data = clip_m, inherit.aes = FALSE,
            aes(trajectory, y = -Inf, label = paste0(k, " clips")),
            vjust = -0.8, size = 2.9, colour = "grey30") +
  facet_wrap(~dv_label, scales = "free_y") +
  scale_y_continuous(expand = expansion(mult = c(0.14, 0.08))) +
  scale_colour_manual(values = c("catch-up" = "#E69F00", "fall-back" = "#B25400",
                                 "stable" = "#B0982E"), guide = "none") +
  labs(title = sprintf("Study 2 (n=%d): within-clip near-miss cost by trajectory", N),
       subtitle = paste("Each point is one race: mean(near miss) - mean(narrow win) for that same clip.",
                        "\nBelow 0 = the near miss cost more than the narrow win. Bar = mean +/- SEM across clips."),
       x = NULL, y = "NM - NW (rating points)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"), strip.text = element_text(face = "bold"))
ggsave(file.path(out_dir, "s2_fig3_within_clip.png"), fig3, width = 11, height = 4.6, dpi = 150)

# ---- Stats, in pre-registered order -----------------------------------------
sink(file.path(out_dir, "study2_stats.txt"))
cat("Greyhound Study 2 - N =", N, "of", nrow(by_pid), "collected\n")
cat("Exclusions: incomplete", sum(by_pid$incomplete),
    "| slider check", sum(by_pid$failed_att),
    "| outcome check", sum(by_pid$failed_out),
    "| straight-lined", sum(by_pid$straight),
    "| too fast", sum(by_pid$too_fast), "\n\n")

cat("Condition means:\n")
print(pm |> group_by(condition) |>
        summarise(across(all_of(names(dvs)), \(x) round(mean(x), 1))))

cat("\n=== H1 (replication): near miss vs clear loss, motivation ===\n")
h1 <- pm |> select(prolificPID, condition, motivation) |>
  pivot_wider(names_from = condition, values_from = motivation)
print(t.test(h1$NM, h1$CL, paired = TRUE))

cat("\n=== H2 (PRIMARY): catch-up vs stable near misses, motivation ===\n")
h2 <- pt |> select(prolificPID, trajectory, motivation) |>
  pivot_wider(names_from = trajectory, values_from = motivation)
print(t.test(h2$`catch-up`, h2$stable, paired = TRUE))
cat(sprintf("dz = %.3f\n", mean(h2$`catch-up` - h2$stable) / sd(h2$`catch-up` - h2$stable)))

cat("\n=== H3: catch-up vs fall-back ===\n")
print(t.test(h2$`catch-up`, h2$`fall-back`, paired = TRUE))

cat("\n=== Trajectory means (near-miss trials only) ===\n")
print(pt |> group_by(trajectory) |>
        summarise(across(all_of(names(dvs)), \(x) round(mean(x), 1)), n = n()))

cat("\n=== Repeated-measures ANOVA: motivation ~ trajectory ===\n")
nm_only <- df |> filter(condition == "NM", !is.na(trajectory))
print(anova(lmer(motivation ~ trajectory + (1 | prolificPID), data = nm_only)))

cat("\n=== Mixed model with clip as a crossed random effect ===\n")
m <- lmer(motivation ~ trajectory + (1 | prolificPID) + (1 | raceId), data = nm_only)
print(anova(m)); print(summary(m)$coefficients)

cat("\n=== SENSITIVITY (pre-registered): H2 with race 16 dropped ===\n")
pt16 <- df |> filter(condition == "NM", !is.na(trajectory), raceId != 16) |>
  group_by(prolificPID, trajectory) |>
  summarise(motivation = mean(motivation), .groups = "drop") |>
  pivot_wider(names_from = trajectory, values_from = motivation)
print(t.test(pt16$`catch-up`, pt16$stable, paired = TRUE))

cat("\n=== Manipulation check: pre-race confidence must NOT differ ===\n")
print(t.test(h2$`catch-up`, h2$stable, paired = TRUE)$p.value)
conf <- pt |> select(prolificPID, trajectory, confidence) |>
  pivot_wider(names_from = trajectory, values_from = confidence)
cat("confidence catch-up vs stable:\n"); print(t.test(conf$`catch-up`, conf$stable, paired = TRUE))

cat("\n=== Secondary DVs, catch-up vs stable ===\n")
for (v in c("pleased", "luck")) {
  w <- pt |> select(prolificPID, trajectory, all_of(v)) |>
    pivot_wider(names_from = trajectory, values_from = all_of(v))
  cat("\n--", dvs[[v]], "--\n"); print(t.test(w$`catch-up`, w$stable, paired = TRUE))
}

cat("\n=== Within-clip deltas (motivation) ===\n")
print(clip |> filter(colname == "motivation") |>
        select(raceId, trajectory, NW, NM, delta) |>
        arrange(trajectory, raceId) |>
        mutate(across(c(NW, NM, delta), \(x) round(x, 1))) |> as.data.frame())

cat("\n=== Counterbalancing check: role counts per clip ===\n")
print(df |> filter(condition %in% c("NW", "NM")) |>
        count(raceId, trajectory, condition) |>
        pivot_wider(names_from = condition, values_from = n, values_fill = 0) |>
        arrange(trajectory, raceId) |> as.data.frame())
sink()

message(sprintf("saved figures + study2_stats.txt to %s/", out_dir))
