#!/usr/bin/env Rscript
# =============================================================================
# Builds every number, table and figure used in manuscript.tex.
#
# Run from the project root:   Rscript manuscript/make_assets.R
#
# It sources the analysis code of analysis/greyhound_report.Rmd (via
# knitr::purl), so the manuscript and the report are computed by the same code
# from the same raw files, and cannot drift apart. Re-run after any new data,
# then recompile the manuscript.
#
# Outputs:
#   manuscript/numbers.tex   \res{key} macros for every number quoted in text
#   manuscript/tables/*.tex  tabular bodies (captions live in manuscript.tex)
#   manuscript/figures/*.pdf
#
# Study numbering: the manuscript's Study 5 is the repo's study6 (the repo's
# study5 was a within-subject pilot that was abandoned before analysis).
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse); library(lme4); library(lmerTest); library(BayesFactor)
  library(patchwork)
})

out  <- "manuscript"
dir.create(file.path(out, "tables"),  showWarnings = FALSE)
dir.create(file.path(out, "figures"), showWarnings = FALSE)

# ---- run the report's analysis code ------------------------------------------
tmp <- tempfile(fileext = ".R")
knitr::purl("analysis/greyhound_report.Rmd", output = tmp, documentation = 0, quiet = TRUE)
pdf(NULL)
invisible(capture.output(suppressWarnings(suppressMessages(sys.source(tmp, envir = globalenv())))))
invisible(dev.off())

studies <- list(
  s1 = list(raw = s1, pm = s1_pm, bypid = s1_bypid, label = "Study 1"),
  s2 = list(raw = s2, pm = s2_pm, bypid = s2_bypid, label = "Study 2"),
  s3 = list(raw = s3, pm = s3_pm, bypid = s3_bypid, label = "Study 3"),
  s4 = list(raw = s4, pm = s4_pm, bypid = s4_bypid, label = "Study 4"),
  s5 = list(raw = s6, pm = s6_pm, bypid = s6_bypid, label = "Study 5"))

# ---- formatting helpers --------------------------------------------------------
nolead <- function(x) sub("^(-?)0\\.", "\\1.", x)
fp  <- function(p) ifelse(p < .001, "< .001", paste("=", nolead(sprintf("%.3f", p))))
fpt <- function(p) ifelse(p < .001, "$<$ .001", nolead(sprintf("%.3f", p)))   # table cell
f1  <- function(x) sprintf("%.1f", x)
f2  <- function(x) sprintf("%.2f", x)
fdf <- function(df) ifelse(abs(df - round(df)) < 1e-6, sprintf("%d", as.integer(round(df))), sprintf("%.1f", df))
fbf <- function(bf) ifelse(bf >= 1000, "> 1000", ifelse(bf >= 100, sprintf("%.0f", bf),
                     ifelse(bf >= 10, sprintf("%.1f", bf), sprintf("%.2f", bf))))
bf_op <- function(bf) ifelse(bf >= 1000, "> 1000", paste("=", fbf(bf)))
minus <- function(s) gsub("(?<![A-Za-z])-(?=[0-9.])", "$-$", s, perl = TRUE)   # minus signs on numbers only, not hyphenated words
# R's pdf device draws "-" as a minus sign; a soft hyphen (U+00AD) is drawn as a real hyphen
hy <- function(s) gsub("-", "\u00ad", s, fixed = TRUE)

# ---- \res{key} store -----------------------------------------------------------
res <- list()
put <- function(key, value) res[[key]] <<- as.character(value)
stat_paired <- function(r) sprintf("$t(%s) = %s$, $p %s$, $d_z = %s$, $\\mathrm{BF}_{10} %s$",
                                   fdf(r$df), f2(r$t), fp(r$p), f2(r$dz), bf_op(r$BF10))

paired <- function(a, b) {        # paired t + JZS Bayes factor, participant level
  ok <- !is.na(a) & !is.na(b); a <- a[ok]; b <- b[ok]
  tt <- t.test(a, b, paired = TRUE)
  bf <- extractBF(ttestBF(a, b, paired = TRUE))$bf
  tibble(n = length(a), mA = mean(a), mB = mean(b), diff = mean(a - b),
         t = unname(tt$statistic), df = unname(tt$parameter), p = tt$p.value,
         dz = mean(a - b) / sd(a - b), BF10 = bf, BF01 = 1 / bf)
}

write_tab <- function(lines, file) writeLines(lines, file.path(out, "tables", file))

# =============================================================================
# 1. Samples: collected, exclusions, analysed, duration, PGSI
# =============================================================================
excl_row <- function(bp) {
  g <- function(col) if (col %in% names(bp)) bp[[col]] else NULL
  c(collected    = nrow(bp),
    incomplete   = sum(bp$n_trials != 20),
    attention    = sum(bp$att_p < bp$att_n),
    outcome      = if (!is.null(g("out_n"))) sum(bp$out_p < bp$out_n) else NA,
    straight     = sum(bp$straight),
    rt           = if (!is.null(g("med_rt"))) sum(bp$med_rt < 2000, na.rm = TRUE) else NA,
    consent      = if (!is.null(g("consented"))) sum(!bp$consented) else NA,
    group        = if (!is.null(g("n_groups"))) sum(bp$n_groups != 1) else NA,
    excluded     = sum(bp$exclude),
    analysed     = sum(!bp$exclude))
}
excl <- map(studies, \(s) excl_row(s$bypid))
iwalk(excl, function(v, k) iwalk(as.list(v), \(x, nm) put(paste0(k, "-", nm), ifelse(is.na(x), "--", x))))
iwalk(excl, \(v, k) put(paste0(k, "-pctexcl"), sprintf("%.0f", 100 * v[["excluded"]] / v[["collected"]])))

row_names <- c(collected = "Completed sessions", incomplete = "Incomplete",
               attention = "Failed slider (attention) check", outcome = "Failed outcome check",
               straight = "Straight-lined a rating", rt = "Median rating RT $<$ 2 s",
               consent = "No consent record", group = "Inconsistent group assignment",
               excluded = "Total excluded", analysed = "Analyzed")
tab <- map_chr(names(row_names), function(r) {
  cells <- map_chr(excl, \(v) ifelse(is.na(v[[r]]), "--", as.character(v[[r]])))
  lab <- if (r %in% c("excluded", "analysed")) paste0("\\textbf{", row_names[[r]], "}") else row_names[[r]]
  paste0(lab, " & ", paste(cells, collapse = " & "), " \\\\",
         if (r == "group") " \\midrule" else "")
})
write_tab(c("\\begin{tabular}{lccccc}", "\\toprule",
            "Criterion & Study 1 & Study 2 & Study 3 & Study 4 & Study 5 \\\\", "\\midrule",
            tab, "\\bottomrule", "\\end{tabular}"), "tab_exclusions.tex")

# Task duration: session start to the last race's submission, analysed participants
dur <- map(studies, function(s) {
  s$raw |> group_by(prolificPID) |>
    summarise(mins = as.numeric(difftime(max(lubridate::ymd_hms(submittedAt)),
                                         min(lubridate::ymd_hms(sessionStartedAt)), units = "mins")),
              .groups = "drop") |> pull(mins) |> median(na.rm = TRUE)
})
iwalk(dur, \(m, k) put(paste0(k, "-duration"), sprintf("%.0f", m)))
put("dur-min", sprintf("%.0f", min(unlist(dur)))); put("dur-max", sprintf("%.0f", max(unlist(dur))))

# PGSI (Ferris & Wynne, 2001) categories, analysed participants
pgsi_tab <- map_dfr(studies, function(s) {
  p <- s$raw |> group_by(prolificPID) |> summarise(pgsi = first(pgsi_total), .groups = "drop") |> pull(pgsi)
  tibble(n = length(p), M = mean(p), SD = sd(p), Mdn = median(p),
         zero = 100 * mean(p == 0), low = 100 * mean(p %in% 1:2),
         moderate = 100 * mean(p >= 3 & p <= 7), problem = 100 * mean(p >= 8))
}, .id = "study")
pwalk(pgsi_tab, function(study, n, M, SD, Mdn, zero, low, moderate, problem) {
  put(paste0(study, "-pgsiM"), f2(M)); put(paste0(study, "-pgsiSD"), f2(SD))
  put(paste0(study, "-pgsiMdn"), Mdn)
  put(paste0(study, "-pgsiZero"), sprintf("%.0f", zero))
  put(paste0(study, "-pgsiModPlus"), sprintf("%.0f", moderate + problem))
  put(paste0(study, "-pgsiProblem"), sprintf("%.0f", problem))
})
write_tab(c("\\begin{tabular}{lcccccc}", "\\toprule",
  "Study & \\textit{M} (\\textit{SD}) & \\textit{Mdn} & Non-problem (0) & Low risk (1--2) & Moderate risk (3--7) & Problem gambling (8+) \\\\",
  "\\midrule",
  pmap_chr(pgsi_tab, \(study, n, M, SD, Mdn, zero, low, moderate, problem)
    sprintf("%s (\\textit{n} = %d) & %s (%s) & %s & %.0f\\%% & %.0f\\%% & %.0f\\%% & %.0f\\%% \\\\",
            studies[[study]]$label, n, f2(M), f2(SD), Mdn, zero, low, moderate, problem)),
  "\\bottomrule", "\\end{tabular}"), "tab_pgsi.tex")

# =============================================================================
# 2. Near-miss effect: NM vs CL on all four ratings, every study
# =============================================================================
dv_lab <- c(motivation = "Motivation to play", pleased = "Pleasure", luck = "Luck", confidence = "Confidence (pre-race)")
nmcl <- map_dfr(studies, function(s) {
  map_dfr(names(dv_lab), function(v) {
    w <- s$pm |> select(prolificPID, condition, all_of(v)) |>
      group_by(prolificPID, condition) |> summarise(y = mean(.data[[v]]), .groups = "drop") |>
      pivot_wider(names_from = condition, values_from = y)
    paired(w$NM, w$CL) |> mutate(dv = v)
  })
}, .id = "study")
pwalk(nmcl, function(study, dv, ...) {
  r <- list(...)
  k <- paste0(study, "-", dv)
  put(paste0(k, "-NM"), f1(r$mA)); put(paste0(k, "-CL"), f1(r$mB)); put(paste0(k, "-diff"), f1(r$diff))
  put(paste0(k, "-stat"), stat_paired(r)); put(paste0(k, "-BF01"), fbf(r$BF01))
})
iwalk(studies, function(s, k) {
  rows <- nmcl |> filter(study == k)
  lines <- pmap_chr(rows, function(study, n, mA, mB, diff, t, df, p, dz, BF10, BF01, dv)
    minus(sprintf("%s & %s & %s & %s & %s & %s & %s & %s & %s \\\\", dv_lab[[dv]], f1(mA), f1(mB), f1(diff),
            fdf(df), f2(t), fpt(p), f2(dz), fbf(BF10))))
  write_tab(c("\\begin{tabular}{lcccccccc}", "\\toprule",
    "Rating & NM & CL & Diff. & \\textit{df} & \\textit{t} & \\textit{p} & $d_z$ & BF$_{10}$ \\\\", "\\midrule",
    lines, "\\bottomrule", "\\end{tabular}"), sprintf("tab_nmcl_%s.tex", k))
})

# Study 1: the full ordering of outcomes on motivation
m1 <- s1_pm |> select(prolificPID, condition, motivation) |> pivot_wider(names_from = condition, values_from = motivation)
put("s1-NWvNM-stat", stat_paired(paired(m1$NW, m1$NM)))
put("s1-CWvNW-stat", stat_paired(paired(m1$CW, m1$NW)))
cm1 <- s1_pm |> group_by(condition) |> summarise(across(c(motivation, pleased, luck, confidence), mean))
pwalk(cm1, function(condition, motivation, pleased, luck, confidence) {
  put(paste0("s1-", condition, "-motivation"), f1(motivation)); put(paste0("s1-", condition, "-pleased"), f1(pleased))
})

# Near-miss effect within each Study 5 group
walk(c("betting", "no_betting"), function(g) {
  w <- s6_pm |> filter(group == g) |> select(prolificPID, condition, motivation) |>
    pivot_wider(names_from = condition, values_from = motivation)
  r <- paired(w$NM, w$CL)
  k <- paste0("s5-", sub("_", "", g))
  put(paste0(k, "-mot-diff"), f1(r$diff)); put(paste0(k, "-mot-stat"), stat_paired(r)); put(paste0(k, "-n"), r$n)
})
# Exploratory: is the near-miss effect (NM - CL) on each rating smaller when betting is available?
# Two-tailed (not a pre-specified hypothesis).
walk(c("motivation", "pleased", "luck"), function(v) {
  dd <- s6_pm |> select(prolificPID, group, condition, all_of(v)) |>
    pivot_wider(names_from = condition, values_from = all_of(v)) |> mutate(d = NM - CL)
  a <- dd$d[dd$group == "betting"]; b <- dd$d[dd$group == "no_betting"]
  tt <- t.test(a, b); sp <- sqrt(((length(a) - 1) * var(a) + (length(b) - 1) * var(b)) / (length(a) + length(b) - 2))
  bf <- extractBF(ttestBF(a, b))$bf
  put(paste0("s5-inter-", v), sprintf("$t(%s) = %s$, $p %s$, $d = %s$, $\\mathrm{BF}_{10} %s$",
                                      fdf(tt$parameter), f2(tt$statistic), fp(tt$p.value), f2((mean(a) - mean(b)) / sp), bf_op(bf)))
  put(paste0("s5-inter-", v, "-bet"), f1(mean(a))); put(paste0("s5-inter-", v, "-nobet"), f1(mean(b)))
  # the cell means, to check a smaller gap isn't just clear-loss ratings sitting on the floor
  for (g in c("betting", "no_betting")) for (cnd in c("CW", "NW", "NM", "CL")) {
    x <- dd[[cnd]][dd$group == g]
    put(sprintf("s5-%s-%s-%s", sub("_", "", g), v, cnd), f1(mean(x)))
    if (cnd == "CL") put(sprintf("s5-%s-%s-CLzero", sub("_", "", g), v), sprintf("%.0f", 100 * mean(x < 5)))
  }
})
# Same four cell means, trial level, for a group x outcome figure
s5_cells <- s6 |> group_by(prolificPID, group, condition) |>
  summarise(across(c(motivation, pleased, luck), mean), .groups = "drop")

# =============================================================================
# 3. Trajectory (near-miss trials only), Studies 2-5
# =============================================================================
traj_stats <- function(nm_trials) {
  map_dfr(c("pleased", "motivation", "luck", "confidence"), function(v) {
    a  <- anova(lmer(as.formula(paste(v, "~ trajectory + (1|prolificPID)")), data = nm_trials))
    pt <- nm_trials |> group_by(prolificPID, trajectory) |> summarise(y = mean(.data[[v]]), .groups = "drop") |>
      pivot_wider(names_from = trajectory, values_from = y)
    cu_fb <- paired(pt$`catch-up`, pt$`fall-back`); cu_st <- paired(pt$`catch-up`, pt$stable)
    tibble(dv = v, F = a$`F value`, df1 = a$NumDF, df2 = a$DenDF, p = a$`Pr(>F)`,
           m_cu = mean(pt$`catch-up`), m_fb = mean(pt$`fall-back`), m_st = mean(pt$stable),
           cufb = list(cu_fb), cust = list(cu_st))
  })
}
traj <- list(s2 = traj_stats(s2_nm), s3 = traj_stats(s3_nm), s4 = traj_stats(s4_nm), s5 = traj_stats(s6_nm))
iwalk(traj, function(d, k) pwalk(d, function(dv, F, df1, df2, p, m_cu, m_fb, m_st, cufb, cust) {
  kk <- paste0(k, "-traj-", dv)
  put(paste0(kk, "-omni"), sprintf("$F(%d, %s) = %s$, $p %s$", as.integer(df1), f1(df2), f2(F), fp(p)))
  put(paste0(kk, "-cu"), f1(m_cu)); put(paste0(kk, "-fb"), f1(m_fb)); put(paste0(kk, "-st"), f1(m_st))
  put(paste0(kk, "-cufb"), stat_paired(cufb)); put(paste0(kk, "-cust"), stat_paired(cust))
}))

# Study 2 planned contrasts (preregistered): catch-up vs fall-back, catch-up vs stable;
# Holm across the six (2 contrasts x motivation, pleasure, luck)
s2c <- traj$s2 |> filter(dv != "confidence") |>
  transmute(dv, cufb = map(cufb, identity), cust = map(cust, identity)) |>
  pivot_longer(c(cufb, cust), names_to = "contrast", values_to = "r") |>
  mutate(t = map_dbl(r, "t"), df = map_dbl(r, "df"), p = map_dbl(r, "p"), dz = map_dbl(r, "dz"),
         diff = map_dbl(r, "diff"), BF10 = map_dbl(r, "BF10"), holm = p.adjust(p, "holm"))
write_tab(c("\\begin{tabular}{llcccccc}", "\\toprule",
  "Rating & Contrast & Diff. & \\textit{t}(\\textit{df}) & \\textit{p} & \\textit{p}$_{\\text{Holm}}$ & $d_z$ & BF$_{10}$ \\\\", "\\midrule",
  pmap_chr(s2c, function(dv, contrast, r, t, df, p, dz, diff, BF10, holm)
    minus(sprintf("%s & %s & %s & %s(%s) & %s & %s & %s & %s \\\\", dv_lab[[dv]],
            c(cufb = "Catch-up vs fall-back", cust = "Catch-up vs stable")[[contrast]],
            f1(diff), f2(t), fdf(df), fpt(p), fpt(holm), f2(dz), fbf(BF10)))),
  "\\bottomrule", "\\end{tabular}"), "tab_traj_s2.tex")

# Omnibus trajectory effect in every study (one table)
omni <- imap_dfr(traj, \(d, k) d |> mutate(study = k))
write_tab(c("\\begin{tabular}{lcccc}", "\\toprule",
  "Rating & Study 2 & Study 3 & Study 4 & Study 5 \\\\", "\\midrule",
  map_chr(c("pleased", "motivation", "luck", "confidence"), function(v) {
    cells <- omni |> filter(dv == v) |>
      mutate(cell = sprintf("\\textit{F} = %s, \\textit{p} %s", f2(F), ifelse(p < .001, "$<$ .001", paste("=", nolead(sprintf("%.3f", p)))))) |>
      pull(cell)
    paste0(dv_lab[[v]], " & ", paste(cells, collapse = " & "), " \\\\")
  }),
  "\\bottomrule", "\\end{tabular}"), "tab_traj_omnibus.tex")

# =============================================================================
# 4. Study 2: exploratory PGSI moderation of the catch-up advantage on pleasure
# =============================================================================
pg2 <- s2 |> group_by(prolificPID) |> summarise(pgsi = first(pgsi_total), .groups = "drop") |>
  mutate(band = if_else(pgsi >= 3, "elevated", "low"))
pp2 <- s2_nm |> group_by(prolificPID, trajectory) |> summarise(pleased = mean(pleased), .groups = "drop") |>
  pivot_wider(names_from = trajectory, values_from = pleased) |>
  mutate(cu_fb = `catch-up` - `fall-back`) |> left_join(pg2, by = "prolificPID")
walk(c("low", "elevated"), function(b) {
  d <- pp2 |> filter(band == b); r <- paired(d$`catch-up`, d$`fall-back`)
  put(paste0("s2-pgsi-", b, "-n"), r$n); put(paste0("s2-pgsi-", b, "-diff"), f1(r$diff))
  put(paste0("s2-pgsi-", b, "-stat"), stat_paired(r))
})
bt <- t.test(cu_fb ~ band, data = pp2)
put("s2-pgsi-band-stat", sprintf("$t(%s) = %s$, $p %s$", fdf(bt$parameter), f2(abs(bt$statistic)), fp(bt$p.value)))
nm2 <- s2_nm |> left_join(pg2, by = "prolificPID")
ic <- anova(lmer(pleased ~ trajectory * scale(pgsi) + (1|prolificPID), data = nm2))["trajectory:scale(pgsi)", ]
put("s2-pgsi-cont-stat", sprintf("$F(%d, %s) = %s$, $p %s$", as.integer(ic$NumDF), f1(ic$DenDF), f2(ic$`F value`), fp(ic$`Pr(>F)`)))
il <- anova(lmer(pleased ~ trajectory * scale(log1p(pgsi)) + (1|prolificPID), data = nm2))["trajectory:scale(log1p(pgsi))", ]
put("s2-pgsi-log-stat", sprintf("$F(%d, %s) = %s$, $p %s$", as.integer(il$NumDF), f1(il$DenDF), f2(il$`F value`), fp(il$`Pr(>F)`)))
sp <- cor.test(pp2$pgsi, pp2$cu_fb, method = "spearman", exact = FALSE)
put("s2-pgsi-rho-stat", sprintf("$r_s = %s$, $p %s$", nolead(f2(sp$estimate)), fp(sp$p.value)))

# =============================================================================
# 5. Betting (Studies 3 and 4, and the betting group of Study 5)
# =============================================================================
final_bal <- function(d) d |> arrange(prolificPID, trialNumber) |> group_by(prolificPID) |>
  summarise(fb = last(balanceAfter), floor = any(balanceAfter <= 20), .groups = "drop")
bet_desc <- function(d, key) {
  st <- as.numeric(d$betStakePct) * 100
  put(paste0(key, "-stakeM"), f1(mean(st))); put(paste0(key, "-stakeSD"), f1(sd(st)))
  put(paste0(key, "-stakeMdn"), f1(median(st)))
  put(paste0(key, "-stakeLE25"), sprintf("%.0f", 100 * mean(st <= 25)))
  put(paste0(key, "-stakeGE90"), sprintf("%.0f", 100 * mean(st >= 90)))
  fb <- final_bal(d)
  put(paste0(key, "-balM"), f1(mean(fb$fb))); put(paste0(key, "-balMdn"), f1(median(fb$fb)))
  put(paste0(key, "-balMin"), min(fb$fb)); put(paste0(key, "-balMax"), max(fb$fb))
  put(paste0(key, "-floorN"), sum(fb$floor))
}
bet_desc(s3, "s3"); bet_desc(s4, "s4"); bet_desc(s6 |> filter(group == "betting"), "s5bet")

s3_opts <- s3 |> count(betStakePct) |> mutate(pct = 100 * n / sum(n))
pwalk(s3_opts, \(betStakePct, n, pct) put(sprintf("s3-opt%.0f", 100 * as.numeric(betStakePct)), sprintf("%.0f", pct)))
put("s3-twolowest", sprintf("%.0f", sum(s3_opts$pct[as.numeric(s3_opts$betStakePct) <= .25])))

# NM vs CL on the stake placed on the NEXT race
next_stake <- function(lag1) lag1 |> filter(prev_condition %in% c("NM", "CL")) |>
  group_by(prolificPID, prev_condition) |> summarise(stake = mean(as.numeric(betStakePct)) * 100, .groups = "drop") |>
  pivot_wider(names_from = prev_condition, values_from = stake) |> filter(!is.na(NM), !is.na(CL))
for (k in c("s3", "s4")) {
  w <- next_stake(get(paste0(k, "_lag1"))); r <- paired(w$NM, w$CL)
  put(paste0(k, "-bet-NM"), f1(r$mA)); put(paste0(k, "-bet-CL"), f1(r$mB)); put(paste0(k, "-bet-diff"), f2(r$diff))
  put(paste0(k, "-bet-stat"), stat_paired(r)); put(paste0(k, "-bet-BF01"), fbf(r$BF01))
}
# Study 4 robustness: the stakes are right-skewed, so two tests that don't assume normality
w4n <- next_stake(s4_lag1)
put("s4-bet-wilcox-p", fp(wilcox.test(w4n$NM, w4n$CL, paired = TRUE, exact = FALSE)$p.value))
lg <- function(p) log((p + .001) / (1 - p + .001))
w4l <- s4_lag1 |> filter(prev_condition %in% c("NM", "CL")) |> group_by(prolificPID, prev_condition) |>
  summarise(s = mean(lg(as.numeric(betStakePct))), .groups = "drop") |>
  pivot_wider(names_from = prev_condition, values_from = s) |> filter(!is.na(NM), !is.na(CL))
rl <- paired(w4l$NM, w4l$CL)
put("s4-bet-logit-stat", sprintf("$t(%s) = %s$, $p %s$, $\\mathrm{BF}_{01} = %s$", fdf(rl$df), f2(rl$t), fp(rl$p), fbf(rl$BF01)))

# Mean next-race stake after each outcome (table)
lag_means <- function(lag1) lag1 |> group_by(prolificPID, prev_condition) |>
  summarise(s = mean(as.numeric(betStakePct)) * 100, .groups = "drop") |>
  group_by(prev_condition) |> summarise(M = mean(s), SD = sd(s), .groups = "drop")
lm3 <- lag_means(s3_lag1); lm4 <- lag_means(s4_lag1)
write_tab(c("\\begin{tabular}{lcc}", "\\toprule",
  "Previous race & Study 3 & Study 4 \\\\", "\\midrule",
  map_chr(c("CW", "NW", "NM", "CL"), \(c) sprintf("%s & %s (%s) & %s (%s) \\\\", cond_labs[[c]] |> str_to_sentence(),
      f1(lm3$M[lm3$prev_condition == c]), f1(lm3$SD[lm3$prev_condition == c]),
      f1(lm4$M[lm4$prev_condition == c]), f1(lm4$SD[lm4$prev_condition == c]))),
  "\\bottomrule", "\\end{tabular}"), "tab_nextstake.tex")

# =============================================================================
# 6. Confidence across studies (the observation that motivated Study 5)
# =============================================================================
conf_pp <- bind_rows(
  s1 |> group_by(prolificPID) |> summarise(conf = mean(confidence)) |> mutate(study = "Study 1", betting = "No betting"),
  s2 |> group_by(prolificPID) |> summarise(conf = mean(confidence)) |> mutate(study = "Study 2", betting = "No betting"),
  s3 |> group_by(prolificPID) |> summarise(conf = mean(confidence)) |> mutate(study = "Study 3", betting = "Betting"),
  s4 |> group_by(prolificPID) |> summarise(conf = mean(confidence)) |> mutate(study = "Study 4", betting = "Betting"))
cs <- conf_pp |> group_by(study) |> summarise(n = n(), M = mean(conf), SD = sd(conf), .groups = "drop")
pwalk(cs, \(study, n, M, SD) { k <- paste0("s", sub("Study ", "", study)); put(paste0(k, "-confM"), f1(M)); put(paste0(k, "-confSD"), f1(SD)) })
a12 <- conf_pp |> filter(betting == "No betting") |> pull(conf); a34 <- conf_pp |> filter(betting == "Betting") |> pull(conf)
d_cross <- (mean(a34) - mean(a12)) / sqrt(((length(a12) - 1) * var(a12) + (length(a34) - 1) * var(a34)) / (length(a12) + length(a34) - 2))
put("cross-M12", f1(mean(a12))); put("cross-M34", f1(mean(a34))); put("cross-d", f2(d_cross))
put("cross-n12", length(a12)); put("cross-n34", length(a34))
tc <- t.test(a34, a12)
put("cross-stat", sprintf("$t(%s) = %s$, $p %s$, $d = %s$", fdf(tc$parameter), f2(tc$statistic), fp(tc$p.value), f2(d_cross)))
pw <- function(d, side) ceiling(power.t.test(delta = abs(d), sd = 1, power = .80, type = "two.sample", alternative = side)$n)
put("s5-power-n-cross", pw(d_cross, "one.sided")); put("s5-power-n-d4", pw(.4, "one.sided"))

# =============================================================================
# 7. Study 5: bet availability and confidence (between subjects)
# =============================================================================
gb <- s6_pm |> group_by(prolificPID, group) |> summarise(conf = mean(confidence), .groups = "drop")
gbet <- gb$conf[gb$group == "betting"]; gno <- gb$conf[gb$group == "no_betting"]
t1 <- t.test(gbet, gno, alternative = "less"); t2 <- t.test(gbet, gno)
sp5 <- sqrt(((length(gbet) - 1) * var(gbet) + (length(gno) - 1) * var(gno)) / (length(gbet) + length(gno) - 2))
d5 <- (mean(gbet) - mean(gno)) / sp5
bf5 <- extractBF(ttestBF(gbet, gno, nullInterval = c(-Inf, 0)))$bf[1]
put("s5-nbet", length(gbet)); put("s5-nnobet", length(gno))
put("s5-betM", f1(mean(gbet))); put("s5-betSD", f1(sd(gbet))); put("s5-nobetM", f1(mean(gno))); put("s5-nobetSD", f1(sd(gno)))
put("s5-diff", f1(mean(gbet) - mean(gno))); put("s5-d", f2(d5))
put("s5-stat", sprintf("$t(%s) = %s$, one-tailed $p %s$, $d = %s$, $\\mathrm{BF}_{-0} = %s$",
                       fdf(t1$parameter), f2(t1$statistic), fp(t1$p.value), f2(d5), fbf(bf5)))
put("s5-p2", fp(t2$p.value))
put("s5-wilcox-p", fp(wilcox.test(gbet, gno, alternative = "less", exact = FALSE)$p.value))
put("s5-assigned-bet", sum(s6_bypid$group == "betting")); put("s5-assigned-nobet", sum(s6_bypid$group == "no_betting"))
# exclusion rate by group (random assignment check: attrition should not differ)
eb <- s6_bypid |> count(group, exclude) |> pivot_wider(names_from = exclude, values_from = n, values_fill = 0)
put("s5-excl-bet", sprintf("%.0f", 100 * eb$`TRUE`[eb$group == "betting"] / sum(eb[eb$group == "betting", -1])))
put("s5-excl-nobet", sprintf("%.0f", 100 * eb$`TRUE`[eb$group == "no_betting"] / sum(eb[eb$group == "no_betting", -1])))
et <- chisq.test(table(s6_bypid$group, s6_bypid$exclude))
put("s5-excl-chisq", sprintf("$\\chi^2(%d) = %s$, $p %s$", as.integer(et$parameter), f2(et$statistic), fp(et$p.value)))

# =============================================================================
# 8. Figures
# =============================================================================
theme_ms <- theme_classic(base_size = 10) +
  theme(strip.background = element_blank(), strip.text = element_text(face = "bold"),
        plot.title = element_text(size = 10, face = "bold"), legend.position = "bottom")
ab <- c(CW = "Clear\nwin", NW = "Narrow\nwin", NM = "Near\nmiss", CL = "Clear\nloss")

cond_fig <- function(pm) {
  map(names(dv_lab), function(v) {
    s <- wsci(pm |> group_by(prolificPID, condition) |> summarise(y = mean(.data[[v]]), .groups = "drop"), condition, "y")
    ggplot(s, aes(condition, m, fill = condition)) +
      geom_col(width = .65) + geom_errorbar(aes(ymin = lo, ymax = hi), width = .15) +
      scale_fill_manual(values = cond_cols, guide = "none") + scale_x_discrete(labels = ab) +
      coord_cartesian(ylim = c(0, 100)) + labs(title = hy(dv_lab[[v]]), x = NULL, y = hy("Rating (0-100)")) + theme_ms
  }) |> wrap_plots(ncol = 2)
}
iwalk(studies, \(s, k) ggsave(file.path(out, "figures", sprintf("fig_conditions_%s.pdf", k)), cond_fig(s$pm), width = 6.5, height = 5.2))

traj_fig <- function(pt, dvs_show = names(dv_lab)) {
  map(dvs_show, function(v) {
    s <- wsci(pt, trajectory, v)
    ggplot(s, aes(trajectory, m, fill = trajectory)) +
      geom_col(width = .6) + geom_errorbar(aes(ymin = lo, ymax = hi), width = .14) +
      scale_fill_manual(values = traj_cols, guide = "none") + scale_x_discrete(labels = hy) + coord_cartesian(ylim = c(0, 100)) +
      labs(title = hy(dv_lab[[v]]), x = NULL, y = hy("Rating (0-100)")) + theme_ms
  }) |> wrap_plots(ncol = 2)
}
ggsave(file.path(out, "figures", "fig_trajectory_s2.pdf"), traj_fig(s2_pt), width = 6.5, height = 5.2)
# Studies 3-5: pleasure only (the rating that moved in Study 2), one panel per study
tr345 <- map2(list(s3_pt, s4_pt, s6_pt), c("Study 3", "Study 4", "Study 5"), function(pt, lab) {
  s <- wsci(pt, trajectory, "pleased")
  ggplot(s, aes(trajectory, m, fill = trajectory)) + geom_col(width = .6) +
    geom_errorbar(aes(ymin = lo, ymax = hi), width = .14) + scale_fill_manual(values = traj_cols, guide = "none") + scale_x_discrete(labels = hy) +
    coord_cartesian(ylim = c(0, 60)) + labs(title = lab, x = NULL, y = hy("Pleasure (0-100)")) + theme_ms
}) |> wrap_plots(ncol = 3)
ggsave(file.path(out, "figures", "fig_trajectory_s345.pdf"), tr345, width = 6.5, height = 2.6)

# Study 2 PGSI x trajectory (pleasure)
pgs <- s2_pt |> left_join(pg2 |> mutate(band = if_else(band == "elevated", "PGSI 3+", "PGSI 0-2")), by = "prolificPID") |>
  group_by(band) |> group_modify(~ wsci(.x, trajectory, "pleased")) |> ungroup()
fpg <- ggplot(pgs, aes(trajectory, m, colour = band, group = band)) +
  geom_line(linewidth = .8) + geom_point(size = 2.2) + geom_errorbar(aes(ymin = lo, ymax = hi), width = .1) +
  scale_colour_manual(values = c("PGSI 3+" = "#CC3311", "PGSI 0-2" = "#4477AA"), name = NULL) +
  labs(x = hy("Near-miss trajectory"), y = hy("Pleasure (0-100)")) + theme_ms
ggsave(file.path(out, "figures", "fig_pgsi_s2.pdf"), fpg, width = 4.2, height = 3.4)

# Betting figures
bet_fig <- function(d, lag1, discrete) {
  st <- d |> mutate(stake = as.numeric(betStakePct) * 100)
  pa <- if (discrete) {
    st |> count(stake) |> mutate(pct = 100 * n / sum(n)) |>
      ggplot(aes(factor(stake), pct)) + geom_col(fill = "grey45", width = .6) +
      labs(title = "A. Stakes chosen (all races)", x = "Stake (% of balance)", y = "% of races") + theme_ms
  } else {
    ggplot(st, aes(stake)) + geom_histogram(binwidth = 5, boundary = 0, fill = "grey45", colour = "white") +
      labs(title = "A. Stakes chosen (all races)", x = "Stake (% of balance)", y = "Races") + theme_ms
  }
  pl <- lag1 |> group_by(prolificPID, prev_condition) |> summarise(y = mean(as.numeric(betStakePct)) * 100, .groups = "drop")
  s <- wsci(pl, prev_condition, "y")
  pb <- ggplot(s, aes(prev_condition, m, fill = prev_condition)) + geom_col(width = .65) +
    geom_errorbar(aes(ymin = lo, ymax = hi), width = .15) + scale_fill_manual(values = cond_cols, guide = "none") +
    scale_x_discrete(labels = ab) + labs(title = "B. Stake on the next race, by outcome", x = "Outcome of previous race",
                                         y = "Stake (% of balance)") + theme_ms
  pa + pb
}
ggsave(file.path(out, "figures", "fig_bets_s3.pdf"), bet_fig(s3, s3_lag1, TRUE), width = 6.5, height = 3)
ggsave(file.path(out, "figures", "fig_bets_s4.pdf"), bet_fig(s4, s4_lag1, FALSE), width = 6.5, height = 3)

# Confidence across studies + Study 5 groups
cc <- bind_rows(conf_pp,
  gb |> transmute(prolificPID, conf, study = "Study 5",
                  betting = if_else(group == "betting", "Betting", "No betting"))) |>
  group_by(study, betting) |> summarise(n = n(), M = mean(conf), se = sd(conf) / sqrt(n), .groups = "drop") |>
  mutate(lo = M - qt(.975, n - 1) * se, hi = M + qt(.975, n - 1) * se)
fcc <- ggplot(cc, aes(study, M, fill = betting)) +
  geom_col(position = position_dodge(.75), width = .7) +
  geom_errorbar(aes(ymin = lo, ymax = hi), position = position_dodge(.75), width = .15) +
  scale_fill_manual(values = c("No betting" = "#9ecae1", "Betting" = "#08519c"), name = "Betting available") +
  coord_cartesian(ylim = c(0, 70)) + labs(x = NULL, y = hy("Mean pre-race confidence (0-100)")) + theme_ms
ggsave(file.path(out, "figures", "fig_confidence_across.pdf"), fcc, width = 6, height = 3.4)

# Study 5: ratings by outcome, split by group (within-subject CIs computed within each group)
f5g <- map(c("motivation", "pleased", "luck"), function(v) {
  s <- s5_cells |> group_by(group) |> group_modify(~ wsci(.x, condition, v)) |> ungroup() |>
    mutate(group = if_else(group == "betting", "Betting", "No betting"))
  ggplot(s, aes(condition, m, fill = group)) +
    geom_col(position = position_dodge(.75), width = .7) +
    geom_errorbar(aes(ymin = lo, ymax = hi), position = position_dodge(.75), width = .15) +
    scale_fill_manual(values = c("No betting" = "#9ecae1", "Betting" = "#08519c"), name = NULL) +
    scale_x_discrete(labels = ab) + coord_cartesian(ylim = c(0, 100)) +
    labs(title = hy(dv_lab[[v]]), x = NULL, y = hy("Rating (0-100)")) + theme_ms
}) |> wrap_plots(ncol = 3, guides = "collect") & theme(legend.position = "bottom")
ggsave(file.path(out, "figures", "fig_s5_groups.pdf"), f5g, width = 7, height = 3.2)

# Study 5 primary
g5 <- gb |> mutate(group = if_else(group == "betting", "Betting", "No betting"))
s5s <- g5 |> group_by(group) |> summarise(n = n(), M = mean(conf), se = sd(conf) / sqrt(n), .groups = "drop") |>
  mutate(lo = M - qt(.975, n - 1) * se, hi = M + qt(.975, n - 1) * se)
f5 <- ggplot(g5, aes(group, conf)) +
  geom_jitter(width = .12, alpha = .35, size = 1.3) +
  geom_pointrange(data = s5s, aes(y = M, ymin = lo, ymax = hi), size = .5, linewidth = .8) +
  coord_cartesian(ylim = c(0, 100)) + labs(x = NULL, y = hy("Mean pre-race confidence (0-100)")) + theme_ms
ggsave(file.path(out, "figures", "fig_s5_primary.pdf"), f5, width = 3.6, height = 3.4)

# =============================================================================
# 9. Write numbers.tex
# =============================================================================
esc <- function(x) gsub("%", "\\\\%", x, fixed = TRUE)
lines <- c("% Generated by manuscript/make_assets.R -- do not edit by hand.",
           sprintf("%% Built %s from the current study*-pavlovia/data folders.", format(Sys.time(), "%Y-%m-%d %H:%M")),
           "\\makeatletter",
           "\\newcommand{\\res}[1]{\\@ifundefined{res@#1}{\\textbf{??#1??}}{\\@nameuse{res@#1}}}",
           imap_chr(res, \(v, k) sprintf("\\@namedef{res@%s}{%s}", k, v)),
           "\\makeatother")
writeLines(lines, file.path(out, "numbers.tex"))
message(sprintf("wrote %d numbers, %d tables, %d figures",
                length(res), length(list.files(file.path(out, "tables"))), length(list.files(file.path(out, "figures")))))
