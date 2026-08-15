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
