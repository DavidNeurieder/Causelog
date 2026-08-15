//! Kaizen content handling: time helpers and safe Markdown → HTML rendering.

use pulldown_cmark::html::push_html;
use pulldown_cmark::{Event, Options, Parser};

/// Milliseconds since the Unix epoch (UTC), the repository's timestamp unit.
pub fn now_ms() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0)
}

/// Render Markdown to HTML. Raw HTML (inline or block) is stripped before
/// rendering, so user content can never inject tags; every other CommonMark
/// construct is kept.
pub fn render_markdown(md: &str) -> String {
    let options = Options::empty();
    let parser = Parser::new_ext(md, options)
        .filter(|event| !matches!(event, Event::Html(_) | Event::InlineHtml(_)));
    let mut out = String::with_capacity(md.len() + 256);
    push_html(&mut out, parser);
    out
}

/// Plain text of a Markdown document (markup stripped) — used for excerpts
/// and search-index bodies.
pub fn plain_text(md: &str) -> String {
    let options = Options::empty();
    let mut out = String::with_capacity(md.len());
    for event in Parser::new_ext(md, options) {
        match event {
            Event::Text(t) | Event::Code(t) => out.push_str(&t),
            Event::SoftBreak | Event::HardBreak => out.push(' '),
            _ => {}
        }
    }
    out.split_whitespace().collect::<Vec<_>>().join(" ")
}

/// Days since the Unix epoch → civil date (Howard Hinnant's algorithm).
fn civil_from_days(days: i64) -> (i64, u32, u32) {
    let z = days + 719_468;
    let era = if z >= 0 { z } else { z - 146_096 } / 146_097;
    let doe = z - era * 146_097;
    let yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365;
    let y = yoe + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    (if m <= 2 { y + 1 } else { y }, m as u32, d as u32)
}

/// Civil date → days since the Unix epoch (Howard Hinnant's algorithm).
fn days_from_civil(y: i64, m: u32, d: u32) -> i64 {
    let y = if m <= 2 { y - 1 } else { y };
    let era = if y >= 0 { y } else { y - 399 } / 400;
    let yoe = y - era * 400;
    let mp = ((m + 9) % 12) as i64;
    let doy = (153 * mp + 2) / 5 + d as i64 - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    era * 146_097 + doe - 719_468
}

/// Format a millisecond timestamp as `YYYY-MM-DD` (UTC).
pub fn format_date_ms(ms: i64) -> String {
    let (y, m, d) = civil_from_days(ms.div_euclid(86_400_000));
    format!("{y:04}-{m:02}-{d:02}")
}

/// Parse `YYYY-MM-DD` (UTC) into a millisecond timestamp at start-of-day.
/// Impossible dates (2026-02-30, 2025-04-31) are rejected.
pub fn parse_date_ms(s: &str) -> Option<i64> {
    let parts: Vec<&str> = s.split('-').collect();
    if parts.len() != 3 {
        return None;
    }
    let y: i64 = parts[0].parse().ok()?;
    let m: u32 = parts[1].parse().ok()?;
    let d: u32 = parts[2].parse().ok()?;
    if !(1000..=9999).contains(&y) {
        return None;
    }
    if parts[1].len() != 2 || parts[2].len() != 2 {
        return None;
    }
    let leap = y % 4 == 0 && (y % 100 != 0 || y % 400 == 0);
    let days_in_month = match m {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
        4 | 6 | 9 | 11 => 30,
        2 => 28 + leap as u32,
        _ => return None,
    };
    if !(1..=days_in_month).contains(&d) {
        return None;
    }
    Some(days_from_civil(y, m, d) * 86_400_000)
}

#[cfg(test)]
mod tests {
    use super::*;

    const DAY_MS: i64 = 86_400_000;

    fn round_trip(y: i64, m: u32, d: u32) {
        let ms = days_from_civil(y, m, d) * DAY_MS;
        assert_eq!(
            civil_from_days(ms.div_euclid(DAY_MS)),
            (y, m, d),
            "{y}-{m:02}-{d:02}"
        );
        assert_eq!(format_date_ms(ms), format!("{y:04}-{m:02}-{d:02}"));
        assert_eq!(parse_date_ms(&format!("{y:04}-{m:02}-{d:02}")), Some(ms));
    }

    #[test]
    fn render_markdown_strips_inline_html() {
        let out = render_markdown("hello <script>alert(1)</script> world");
        assert!(!out.contains("script"), "raw inline HTML must be stripped");
        assert!(out.contains("hello"), "text is preserved");
        assert!(out.contains("world"));
    }

    #[test]
    fn render_markdown_drops_block_html_entirely() {
        let out = render_markdown("before\n\n<div onclick=\"evil()\">inner</div>\n\nafter");
        assert!(!out.contains("div"), "block HTML must be stripped");
        assert!(!out.contains("onclick"));
        assert!(
            !out.contains("inner"),
            "a hostile block is dropped wholesale"
        );
        assert!(out.contains("before"));
        assert!(out.contains("after"));
    }

    #[test]
    fn render_markdown_keeps_commonmark_constructs() {
        let out =
            render_markdown("# Title\n\n**bold** and `code`\n\n- item\n\n[link](https://x.y)");
        assert!(out.contains("<h1>Title</h1>"));
        assert!(out.contains("<strong>bold</strong>"));
        assert!(out.contains("<code>code</code>"));
        assert!(out.contains("<li>item</li>"));
        assert!(out.contains(r#"<a href="https://x.y">link</a>"#));
    }

    #[test]
    fn render_markdown_empty_is_empty() {
        assert_eq!(render_markdown(""), "");
    }

    #[test]
    fn plain_text_strips_markup() {
        assert_eq!(plain_text("# Hi **there**"), "Hi there");
        assert_eq!(plain_text("a\nb"), "a b");
        assert_eq!(plain_text("`code` and [x](y)"), "code and x");
    }

    #[test]
    fn dates_round_trip_common() {
        round_trip(2026, 8, 15);
        round_trip(1970, 1, 1);
        round_trip(2024, 2, 29);
        round_trip(2025, 2, 28);
        round_trip(2000, 3, 1);
        round_trip(1999, 12, 31);
        round_trip(2038, 1, 19);
    }

    #[test]
    fn dates_round_trip_pre_epoch_and_sample_range() {
        round_trip(1969, 12, 31);
        round_trip(1945, 9, 2);
        for y in [1600, 1700, 1800, 1900, 2100, 2400, 9999] {
            round_trip(y, 1, 1);
            round_trip(y, 12, 31);
        }
    }

    #[test]
    fn parse_date_ms_rejects_bad_input() {
        for bad in [
            "2026-13-01",
            "2026-02-30",
            "2026-00-10",
            "2026-01-00",
            "2026-01-32",
            "abc",
            "",
            "2026-01",
            "2026-01-01-extra",
            "26-01-01",
            "2026-1-1",
        ] {
            assert_eq!(parse_date_ms(bad), None, "should reject {bad:?}");
        }
    }

    #[test]
    fn now_ms_is_positive_and_recent() {
        let now = now_ms();
        assert!(now > 1_700_000_000_000, "now_ms must be plausible");
    }
}
