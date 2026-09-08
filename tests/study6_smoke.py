"""Browser checks for Study 6. Runs locally; never sends participant data online.

Full sessions advance videos with a synthetic ended event after checking that
the first video loads. This checks task flow, not human viewing or study effects.
"""
import csv
import io
import json
import math
import re
import threading
from collections import Counter
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]
ARTIFACTS = ROOT / "tests" / "study6_artifacts"


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def slider(page, selector, value):
    page.locator(selector).evaluate(
        "(el, value) => { el.value = value; el.dispatchEvent(new Event('input', {bubbles:true})); }",
        value,
    )


def session(page, group):
    assert page.locator("#consent-agree").is_enabled()
    assert page.locator("html").get_attribute("data-study-group") == group
    page.locator("#consent-agree").click()
    assert ("On every race" in page.locator("#intro-group-copy").inner_text()) == (group == "betting")
    page.screenshot(path=str(ARTIFACTS / f"{group}_intro.png"), full_page=True)
    page.locator("#start-button").click()
    bet_screens = 0
    for trial in range(20):
        page.locator(".dog-card").first.click()
        page.locator("#choice-next").click()
        page.locator("#assignment-next").click()
        assert page.locator("#screen-confidence").is_visible()
        assert page.locator("#confidence-next").is_disabled()
        slider(page, "#confidence-slider", 20 + trial)
        page.locator("#confidence-next").click()
        if group == "betting":
            assert page.locator("#screen-bet").is_visible()
            assert page.locator("#bet-next").is_disabled()
            slider(page, "#bet-slider", [0, 100, 5, 50][trial % 4])
            if trial == 0:
                page.screenshot(path=str(ARTIFACTS / "betting_slider.png"), full_page=True)
            page.locator("#bet-next").click()
            bet_screens += 1
        else:
            assert not page.locator("#screen-bet").is_visible()
            assert not page.locator(".status-balance").is_visible()
        if page.locator("#screen-attention").is_visible():
            target = int(re.search(r"to (\d+)", page.locator("#attention-label").inner_text())[1])
            slider(page, "#attention-slider", target)
            page.locator("#attention-next").click()
        assert page.locator("#screen-race").is_visible()
        if trial == 0:
            page.wait_for_function("document.querySelector('#race-video').readyState >= 1")
            assert page.locator("#race-video").evaluate("el => el.duration") > 5
        page.locator("#race-video").evaluate("el => el.dispatchEvent(new Event('ended'))")
        if page.locator("#screen-outcome-check").is_visible():
            finish = page.locator("#result-place").text_content()
            answer = {"1st": 1, "2nd": 2, "3rd": 3, "Did not win": 99}[finish]
            page.locator(f'#outcome-check-options [data-answer="{answer}"]').click()
        assert page.locator("#screen-result").is_visible()
        assert page.locator("#result-points").is_visible() == (group == "betting")
        page.locator("#result-next").click()
        assert page.locator("#postrace-next").is_disabled()
        for index, name in enumerate(["pleased", "motivation", "luck"]):
            slider(page, f"#{name}-slider", 20 + trial + index)
        page.locator("#postrace-next").click()
    assert bet_screens == (20 if group == "betting" else 0)
    assert page.locator("#screen-pgsi").is_visible()
    for index in range(1, 10):
        page.locator(f"#pgsi-{index}-0").check()
    page.locator("#pgsi-next").click()
    assert page.locator("#screen-finish").is_visible()


def verify_rows(rows, group):
    assert len(rows) == 20
    assert {row["studyId"] for row in rows} == {"study6"}
    assert {row["group"] for row in rows} == {group}
    assert Counter(row["condition"] for row in rows) == {"CW": 4, "NW": 6, "NM": 6, "CL": 4}
    assert len({row["raceId"] for row in rows}) == 20
    assert rows[0]["condition"] in {"CW", "NW"}
    assert all(len({rows[j]["condition"] for j in range(i, i + 3)}) > 1 for i in range(18))
    for cond in ["NM", "NW"]:
        assert Counter(r["trajectory"] for r in rows if r["condition"] == cond) == {
            "catch-up": 2, "fall-back": 2, "stable": 2,
        }
    truth = lambda x: str(x).lower() == "true"
    assert sum(truth(row["attentionCheck"]) for row in rows) == 2
    assert sum(truth(row["outcomeCheck"]) for row in rows) == 2
    assert all(truth(row["attentionPass"]) for row in rows if truth(row["attentionCheck"]))
    assert all(truth(row["outcomeCheckPass"]) for row in rows if truth(row["outcomeCheck"]))
    assert all(row["consentGivenAt"] and row["completedAt"] for row in rows)
    assert all(float(row["pgsi_total"]) == 0 for row in rows)
    if group == "betting":
        assert all(truth(row["betAvailable"]) for row in rows)
        assert {float(row["betStakePct"]) for row in rows} == {0, 1, .05, .5}
        assert all(float(row["balanceAfter"]) >= 20 for row in rows)
        # Match the app's own rounding exactly: Math.round(100 * raw) / 100, which
        # breaks .5 ties upward. Python's round() uses banker's rounding plus float
        # representation quirks, so it can disagree at exact half-cent boundaries
        # (e.g. balance=57 -> raw=1.355 -> JS gives 1.36, bare round(x,2) gives 1.35).
        raw = .5 + 1.5 * min(float(rows[-1]["balanceAfter"]) / 100, 1)
        expected = math.floor(raw * 100 + 0.5) / 100
        actual = [float(row["bonusGBP"]) for row in rows]
        assert all(value == expected for value in actual), (expected, actual, rows[-1]["balanceAfter"])
    else:
        assert all(not truth(row["betAvailable"]) for row in rows)
        assert all(row["betStakePct"] == "" and row["bonusGBP"] == "" for row in rows)
        assert {row["bonusAssignment"] for row in rows} == {"matched-after-collection"}
        assert all(float(row["pointsWon"]) == 0 for row in rows)


def main():
    ARTIFACTS.mkdir(parents=True, exist_ok=True)
    handler = partial(QuietHandler, directory=str(ROOT))
    server = ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    base = f"http://127.0.0.1:{server.server_port}"
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, executable_path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")
        try:
            for group in ["betting", "no_betting"]:
                context = browser.new_context(viewport={"width": 1280, "height": 1000}, accept_downloads=True)
                page = context.new_page()
                errors = []
                page.on("pageerror", lambda error: errors.append(str(error)))
                page.goto(f"{base}/study6-docs/?group={group}&participant=TEST-{group}")
                session(page, group)
                with page.expect_download() as download:
                    page.locator("#download-csv").click()
                rows = list(csv.DictReader(Path(download.value.path()).read_text().splitlines()))
                verify_rows(rows, group)
                assert not errors, errors
                print(f"PASS: local {group}, 20 races, timing/order, checks, PGSI, CSV and bonus fields")
                context.close()

            context = browser.new_context()
            page = context.new_page()
            page.goto(f"{base}/study6-docs/?participant=TEST-random")
            first = page.evaluate("Study6Assignment.assign()")
            page.reload()
            assert page.evaluate("Study6Assignment.assign()") == first
            print("PASS: random assignment persists after reload")
            context.close()

            # Mock the production host and all API calls. No external writes.
            for group in ["betting", "no_betting"]:
                context = browser.new_context(viewport={"width": 1280, "height": 1000})
                assignment = {"group": group, "method": "crypto-random-1to1-v1", "assignedAt": "2026-09-08T00:00:00Z"}
                context.add_init_script("localStorage.setItem('study6:assignment:v1:TEST-prod', " + json.dumps(json.dumps(assignment)) + ");")
                saved = []
                calls = []
                redirects = []
                def route_request(route):
                    url = route.request.url
                    if "/api/v2/" in url:
                        calls.append((route.request.method, url))
                        assert "/experiments/538074/" in url
                        if url.endswith("/results"):
                            body = route.request.post_data or ""
                            match = re.search(r'name="value"\r\n\r\n(.*?)\r\n--', body, re.S)
                            assert match, "No CSV in upload"
                            saved.extend(csv.DictReader(io.StringIO(match[1])))
                        route.fulfill(json={"token": "TEST-TOKEN"})
                    elif "app.prolific.com" in url:
                        redirects.append(url)
                        route.fulfill(body="Test completion")
                    else:
                        path = urlparse(url).path
                        local = ROOT / "study6-pavlovia" / (path.lstrip("/") or "index.html")
                        route.fulfill(path=str(local))
                context.route("**/*", route_request)
                page = context.new_page()
                errors = []
                page.on("pageerror", lambda error: errors.append(str(error)))
                opposite = "betting" if group == "no_betting" else "no_betting"
                page.goto(f"https://study6-test.pavlovia.org/?PROLIFIC_PID=TEST-prod&group={opposite}&reps=1")
                assert not calls, "Server session opened before consent"
                session(page, group)
                page.wait_for_function("document.querySelector('#finish-copy').textContent.includes('Your data has been saved')")
                verify_rows(saved, group)
                assert len([x for x in calls if x[0] == "POST" and x[1].endswith("/sessions")]) == 1
                assert any(method == "DELETE" for method, _ in calls)
                page.locator("#return-prolific").click()
                page.wait_for_url("**/submissions/complete?cc=C1AAQL25")
                assert redirects == ["https://app.prolific.com/submissions/complete?cc=C1AAQL25"]
                assert not errors, errors
                print(f"PASS: production {group}, overrides ignored, consent, upload, close and completion redirect (mock API)")
                context.close()
        finally:
            browser.close()
            server.shutdown()


if __name__ == "__main__":
    main()
