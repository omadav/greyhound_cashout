#!/usr/bin/env Rscript
# =============================================================================
# Greyhound Study 1 — pilot analysis
# Reads the per-participant CSVs pulled from Pavlovia (pavlovia/data/), keeps
# completers, and produces the DV-by-condition figures, the PGSI moderation, and
# the mixed-effects models.
#
# Run from the project root:
#   Rscript analysis/analyze_pilot.R
# Outputs go to pilot_analysis/.
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)
  library(patchwork)
})

data_dir <- "pavlovia/data"
out_dir  <- "pilot_analysis"
dir.create(out_dir, showWarnings = FALSE)

# ---- load & clean -----------------------------------------------------------
files <- list.files(data_dir, pattern = "\\.csv$", full.names = TRUE)
files <- files[!grepl("anon", files)]                 # drop local test runs

raw <- files |>
  map(\(f) read_csv(f, show_col_types = FALSE, guess_max = 100)) |>
  list_rbind() |>
  filter(!is.na(condition))

# keep only completers (20 trials) and add quality flags
by_pid <- raw |>
  group_by(prolificPID) |>
  summarise(
    n_trials      = n(),
    att_total     = sum(attentionCheck == TRUE, na.rm = TRUE),
    att_passed    = sum(attentionCheck == TRUE & attentionPass == TRUE, na.rm = TRUE),
    straightlined = any(c(
      n_distinct(motivation) == 1, n_distinct(pleased) == 1,
      n_distinct(luck) == 1,      n_distinct(confidence) == 1)),
    .groups = "drop"
  ) |>
  mutate(
    complete    = n_trials == 20,
    failed_att  = att_passed < att_total,
    exclude     = !complete | failed_att | straightlined
  )

message(sprintf("sessions: %d | complete: %d | failed attention: %d | straight-lined: %d",
                nrow(by_pid), sum(by_pid$complete),
                sum(by_pid$failed_att), sum(by_pid$straightlined)))

# analysis set: completers who passed attention checks and did not straight-line
keep <- by_pid |> filter(!exclude) |> pull(prolificPID)
df <- raw |> filter(prolificPID %in% keep)
N  <- length(keep)
message(sprintf("analysis N = %d (after exclusions)", N))

cond_levels <- c("CW", "NW", "NM", "CL")
cond_labs   <- c(CW = "Clear win", NW = "Narrow win", NM = "Near miss", CL = "Clear loss")
cond_cols   <- c(CW = "#009E73", NW = "#56B4E9", NM = "#E69F00", CL = "#D55E00")
dvs <- c(confidence = "Pre-race confidence", pleased = "Pleasure",
         motivation = "Motivation to continue", luck = "Luck")

df <- df |> mutate(condition = factor(condition, levels = cond_levels))
write_csv(df, file.path(out_dir, sprintf("combined_pilot_n%d.csv", N)))

# per-participant x condition means (long)
pm <- df |>
  group_by(prolificPID, condition) |>
  summarise(across(all_of(names(dvs)), mean), .groups = "drop")

pgsi <- df |> group_by(prolificPID) |> summarise(pgsi = first(pgsi_total), .groups = "drop")

# Cousineau-Morey within-subject 95% CIs: normalise out each participant's mean,
# then apply Morey (2008) bias correction sqrt(M/(M-1)). Input = participant x
# condition means (balanced: every participant has all M conditions).
wsci <- function(dat, colname, conf = 0.95) {
  M <- dplyr::n_distinct(dat$condition)
  g <- mean(dat[[colname]])
  dat |>
    group_by(prolificPID) |>
    mutate(subj = mean(.data[[colname]]), yn = .data[[colname]] - subj + g) |>
    ungroup() |>
    group_by(condition) |>
    summarise(m = mean(.data[[colname]]), sdn = sd(yn), nn = n(), .groups = "drop") |>
    mutate(sem = sdn / sqrt(nn) * sqrt(M / (M - 1)),
           ci  = qt(1 - (1 - conf) / 2, nn - 1) * sem,
           lo  = m - ci, hi = m + ci)
}

# significance helpers
sig_stars <- function(p) ifelse(p < .001, "***", ifelse(p < .01, "**", ifelse(p < .05, "*", "ns")))
paired_t <- function(colname, a = "NM", b = "CL") {
  w <- pm |> select(prolificPID, condition, val = all_of(colname)) |>
    pivot_wider(names_from = condition, values_from = val)
  t.test(w[[a]], w[[b]], paired = TRUE)
}
# a significance bracket between x-positions x1..x2 at height y with a label
bracket <- function(x1, x2, y, label, tick = 2.5, size = 3.6) {
  list(
    annotate("segment", x = x1, xend = x2, y = y, yend = y, colour = "grey20"),
    annotate("segment", x = x1, xend = x1, y = y, yend = y - tick, colour = "grey20"),
    annotate("segment", x = x2, xend = x2, y = y, yend = y - tick, colour = "grey20"),
    annotate("text", x = (x1 + x2) / 2, y = y + 4, label = label, size = size)
  )
}

# ---- Figure 1: DV by condition (mean + within-subject 95% CI, individuals) ---
# imap() calls this as panel_dv(value, name) = panel_dv(label, column_name)
panel_dv <- function(label, colname) {
  summ <- wsci(pm, colname)
  tt <- paired_t(colname)                       # NM vs CL within-subject paired t
  ytop <- max(summ$hi[summ$condition %in% c("NM", "CL")])
  ggplot() +
    geom_line(data = pm, aes(condition, .data[[colname]], group = prolificPID),
              colour = "grey85", linewidth = 0.3) +
    geom_line(data = summ, aes(condition, m, group = 1), colour = "grey30", linewidth = 0.7) +
    geom_errorbar(data = summ, aes(condition, ymin = lo, ymax = hi),
                  width = 0.15, colour = "grey30") +
    geom_point(data = summ, aes(condition, m, colour = condition), size = 3.5) +
    bracket(3, 4, ytop + 8, sprintf("NM vs CL: %s", sig_stars(tt$p.value))) +
    scale_colour_manual(values = cond_cols, guide = "none") +
    scale_x_discrete(labels = cond_labs) +
    coord_cartesian(ylim = c(0, 100)) +
    labs(title = label, x = NULL, y = "mean rating (0-100)") +
    theme_minimal(base_size = 11) +
    theme(plot.title = element_text(face = "bold"),
          axis.text.x = element_text(angle = 15, hjust = 1))
}
fig1 <- wrap_plots(imap(dvs, panel_dv), ncol = 2) +
  plot_annotation(title = sprintf("Study 1 pilot (n=%d): ratings by race outcome", N),
                  subtitle = "mean ± within-subject 95% CI (Cousineau–Morey); grey = individuals; bracket = NM vs CL paired t (*** p<.001, ** p<.01, * p<.05)",
                  theme = theme(plot.title = element_text(face = "bold", size = 14)))
ggsave(file.path(out_dir, "fig1_DV_by_condition.png"), fig1, width = 11, height = 8.5, dpi = 150)

# ---- Figure 2: PGSI moderation of the near-miss effect (continuous) ----------
nm_cl <- pm |>
  select(prolificPID, condition, motivation) |>
  pivot_wider(names_from = condition, values_from = motivation) |>
  mutate(nm_minus_cl = NM - CL) |>
  left_join(pgsi, by = "prolificPID")

ct <- cor.test(nm_cl$pgsi, nm_cl$nm_minus_cl)
r  <- ct$estimate
fig2 <- ggplot(nm_cl, aes(pgsi, nm_minus_cl)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60") +
  geom_smooth(method = "lm", se = TRUE, colour = "#CC3311", fill = "#CC331133") +
  geom_point(size = 3, alpha = 0.8, colour = "#33447A") +
  labs(title = "Near-miss effect on motivation grows with PGSI",
       subtitle = sprintf("each point = one participant; r = %.2f, p = %.3f (n = %d)", r, ct$p.value, N),
       x = "PGSI total (0–27)",
       y = "Near-miss effect  (NM − CL motivation)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))
ggsave(file.path(out_dir, "fig2_PGSI_moderation.png"), fig2, width = 7, height = 5, dpi = 150)

# ---- Figure 3: DV by condition, split by PGSI band (0-2 vs 3+) ---------------
band <- pgsi |> mutate(band = if_else(pgsi >= 3, "elevated (PGSI 3+)", "low (PGSI 0-2)"))
pmb  <- pm |> left_join(band, by = "prolificPID")
band_cols <- c("elevated (PGSI 3+)" = "#CC3311", "low (PGSI 0-2)" = "#4477AA")

panel_band <- function(label, colname) {
  # within-subject CIs computed within each PGSI band
  s <- pmb |> group_by(band) |> group_modify(~ wsci(.x, colname)) |> ungroup()
  ggplot(s, aes(condition, m, colour = band, group = band)) +
    geom_line(linewidth = 0.8) +
    geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.12) +
    geom_point(size = 2.5) +
    scale_colour_manual(values = band_cols) +
    scale_x_discrete(labels = cond_labs) +
    coord_cartesian(ylim = c(0, 100)) +
    labs(title = label, x = NULL, y = "mean rating (0-100)", colour = NULL) +
    theme_minimal(base_size = 11) +
    theme(plot.title = element_text(face = "bold"),
          axis.text.x = element_text(angle = 15, hjust = 1))
}
n_lo <- sum(band$band == "low (PGSI 0-2)"); n_hi <- sum(band$band == "elevated (PGSI 3+)")
fig3 <- wrap_plots(imap(dvs, panel_band), ncol = 2, guides = "collect") +
  plot_annotation(
    title = sprintf("Ratings by outcome, split by PGSI band  (low n=%d, elevated n=%d)", n_lo, n_hi),
    theme = theme(plot.title = element_text(face = "bold", size = 14))) &
  theme(legend.position = "bottom")
ggsave(file.path(out_dir, "fig3_PGSI_bands.png"), fig3, width = 11, height = 8.5, dpi = 150)

# ---- Figure 4: near-miss split by trajectory (exploratory; Luke's question) --
# Trajectory coding of the close races (fall-back = led then caught at the line;
# catch-up = closing at the line but fell short; stable/other = neither clear).
traj <- tibble::tribble(
  ~raceId, ~trajectory,
   3, "catch-up",   4, "catch-up",  16, "catch-up",
   5, "fall-back",  7, "fall-back",  9, "fall-back", 15, "fall-back",
   2, "stable",    14, "stable",    20, "stable",    21, "stable", 22, "stable")

dft <- df |>
  mutate(raceId = as.integer(raceId)) |>
  left_join(traj, by = "raceId") |>
  mutate(cond6 = if_else(condition == "NM" & !is.na(trajectory),
                         paste0("NM: ", trajectory), as.character(condition)),
         cond6 = factor(cond6, levels = c("CW", "NW", "NM: catch-up",
                                          "NM: fall-back", "NM: stable", "CL")))

pmc <- dft |> group_by(prolificPID, cond6) |>
  summarise(motivation = mean(motivation), .groups = "drop")
sc <- pmc |> group_by(cond6) |>
  summarise(m = mean(motivation), se = sd(motivation) / sqrt(n()), .groups = "drop") |>
  left_join(dft |> count(cond6, name = "n_trials"), by = "cond6")

# No significance test on the trajectory split: trajectory is a FIXED property of
# the clip (not an assignment), so catch-up / fall-back / stable are disjoint video
# sets (3 / 4 / 5 clips). The contrast is confounded with clip identity and cannot
# generalise beyond those specific races — descriptive only. See stimulus_notes.md.
n_vids <- c("CW" = "", "NW" = "", "NM: catch-up" = " (3 videos)",
            "NM: fall-back" = " (4 videos)", "NM: stable" = " (5 videos)", "CL" = "")
sc <- sc |> mutate(vidlab = n_vids[as.character(cond6)])

cond6_cols <- c("CW" = "#009E73", "NW" = "#56B4E9", "NM: catch-up" = "#E69F00",
                "NM: fall-back" = "#B25400", "NM: stable" = "#B0982E", "CL" = "#D55E00")
fig4 <- ggplot(sc, aes(cond6, m, fill = cond6)) +
  geom_col(width = 0.66) +
  geom_errorbar(aes(ymin = m - se, ymax = m + se), width = 0.15) +
  geom_text(aes(label = paste0(n_trials, " trials", vidlab), y = 5), colour = "white", size = 2.8) +
  scale_fill_manual(values = cond6_cols, guide = "none") +
  coord_cartesian(ylim = c(0, 100)) +
  labs(title = sprintf("Motivation by outcome, near-miss split by trajectory (descriptive, n=%d)", N),
       subtitle = paste0("catch-up = closing at the line; fall-back = led then caught; stable/other = neither.\n",
                         "DESCRIPTIVE ONLY: trajectory is confounded with clip identity (3 / 4 / 5 videos), so no\n",
                         "significance test is shown — the split cannot generalise beyond these specific clips."),
       x = NULL, y = "mean motivation (0-100)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        axis.text.x = element_text(angle = 15, hjust = 1))
ggsave(file.path(out_dir, "fig4_NM_trajectory.png"), fig4, width = 8.5, height = 5.5, dpi = 150)

# ---- Stats ------------------------------------------------------------------
sink(file.path(out_dir, "stats.txt"))
cat("Greyhound Study 1 pilot — N =", N, "\n\n")

cat("Condition means:\n")
print(pm |> group_by(condition) |>
        summarise(across(all_of(names(dvs)), \(x) round(mean(x), 1))))

cat("\nPaired t-test, NM vs CL motivation:\n")
print(t.test(nm_cl$NM, nm_cl$CL, paired = TRUE))

cat("\nCorrelation, (NM-CL motivation) x PGSI:\n")
print(cor.test(nm_cl$pgsi, nm_cl$nm_minus_cl))

cat("\nMixed-effects model: motivation ~ condition + (1 | participant)\n")
m1 <- lmer(motivation ~ condition + (1 | prolificPID), data = df)
print(anova(m1))
cat("\nFixed effects (CW = reference):\n"); print(summary(m1)$coefficients)

cat("\nPGSI x condition interaction: motivation ~ condition * pgsi_c + (1 | participant)\n")
dfm <- df |> left_join(pgsi, by = "prolificPID") |> mutate(pgsi_c = pgsi - mean(pgsi))
m2 <- lmer(motivation ~ condition * pgsi_c + (1 | prolificPID), data = dfm)
print(anova(m2))

cat("\n\n=== EXPLORATORY: near-miss trajectory split (Luke's question) ===\n")
cat("\nMotivation by detailed condition (near miss split):\n")
print(sc |> mutate(m = round(m, 1), se = round(se, 1)))
nm_only <- dft |> filter(condition == "NM", !is.na(trajectory)) |>
  mutate(trajectory = factor(trajectory, levels = c("stable", "fall-back", "catch-up")))
cat("\nNM trials available by trajectory:\n"); print(count(nm_only, trajectory))
cat("\nMixed model on NM trials only: motivation ~ trajectory + (1 | participant)\n")
mt <- lmer(motivation ~ trajectory + (1 | prolificPID), data = nm_only)
print(anova(mt))
cat("\nFixed effects (stable = reference):\n"); print(summary(mt)$coefficients)
sink()

message("saved figs 1-4, stats.txt, combined_pilot_n", N, ".csv")
