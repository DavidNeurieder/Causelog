//! One-pager renderers: a single, self-contained document distilled from the
//! same [`crate::ProjectStory`] the UI shows, so a shared artifact can never
//! drift from what the author sees.
//!
//! Customization is a plain ordered list of section keys (see
//! [`ONE_PAGER_SECTIONS`]); unknown keys are ignored and empty sections are
//! skipped without leaving a blank heading.
//!
//! Two output formats are provided:
//!  * [`one_pager_html`] — a standalone, inline-styled HTML document
//!    (printable, hostable, email-safe).
//!  * [`one_pager_svg`] — an equivalent vector document (A4, points).
//!
//! PDF is intentionally not generated here: the canonical path is "print the
//! preview to PDF" from the browser, which reuses the exact same document.

/// Canonical section order. `current_state` is folded into the decision
/// blocks rather than being a separate toggle.
pub const ONE_PAGER_SECTIONS: [&str; 6] = [
    "goal",
    "problem",
    "decisions",
    "evidence",
    "lessons",
    "timeline",
];

/// Resolve the requested section keys against the canonical order. An empty
/// request means "everything"; unknown keys are dropped.
pub fn selected_sections(requested: &[String]) -> Vec<String> {
    if requested.is_empty() {
        return ONE_PAGER_SECTIONS.iter().map(|s| s.to_string()).collect();
    }
    ONE_PAGER_SECTIONS
        .iter()
        .filter(|want| requested.iter().any(|r| r.eq_ignore_ascii_case(want)))
        .map(|s| s.to_string())
        .collect()
}

fn esc(input: &str) -> String {
    input
        .replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
}

/// Standalone HTML document with no external dependencies.
pub fn one_pager_html(story: &crate::ProjectStory, sections: &[String]) -> String {
    let sel = selected_sections(sections);
    let mut body = String::new();

    if sel.iter().any(|s| s == "goal")
        && let Some(goal) = &story.goal
    {
        body.push_str("<section><h3>Goal</h3>");
        body.push_str(&format!("<h4>{}</h4>", esc(&goal.title)));
        if !goal.body.is_empty() {
            body.push_str(&format!("<p>{}</p>", esc(&goal.body)));
        }
        body.push_str("</section>");
    }

    if sel.iter().any(|s| s == "problem")
        && let Some(problem) = &story.problem
        && !problem.is_empty()
    {
        body.push_str(&format!(
            "<section><h3>Problem</h3><p>{}</p></section>",
            esc(problem)
        ));
    }

    if sel.iter().any(|s| s == "decisions") && !story.key_decisions.is_empty() {
        body.push_str("<section><h3>Key decisions</h3>");
        for d in &story.key_decisions {
            body.push_str("<article><header><h4>");
            body.push_str(&esc(&d.title));
            body.push_str("</h4><span class=\"tag\">");
            body.push_str(&esc(&d.state));
            body.push_str("</span></header>");
            if !d.context.is_empty() {
                body.push_str(&format!("<p>{}</p>", esc(&d.context)));
            }
            if !d.rationale.is_empty() {
                body.push_str(&format!("<p class=\"why\">Why: {}</p>", esc(&d.rationale)));
            }
            body.push_str("</article>");
        }
        body.push_str("</section>");
    }

    if sel.iter().any(|s| s == "evidence") && !story.experiments.is_empty() {
        body.push_str("<section><h3>Evidence</h3>");
        for e in &story.experiments {
            body.push_str("<article><header><h4>");
            body.push_str(&esc(&e.title));
            body.push_str("</h4><span class=\"tag\">");
            body.push_str(&esc(&e.status));
            body.push_str("</span></header>");
            if !e.hypothesis.is_empty() {
                body.push_str(&format!("<p>Hypothesis: {}</p>", esc(&e.hypothesis)));
            }
            if !e.result.is_empty() {
                body.push_str(&format!("<p>Result: {}</p>", esc(&e.result)));
            }
            for ev in &e.events {
                body.push_str(&format!(
                    "<p class=\"event\">{}{}</p>",
                    esc(&ev.kind),
                    if ev.note.is_empty() {
                        String::new()
                    } else {
                        format!(": {}", esc(&ev.note))
                    }
                ));
            }
            body.push_str("</article>");
        }
        body.push_str("</section>");
    }

    if sel.iter().any(|s| s == "lessons") && !story.lessons.is_empty() {
        body.push_str("<section><h3>Lessons</h3><ul>");
        for l in &story.lessons {
            let text = if l.text.is_empty() {
                "—".to_string()
            } else {
                esc(&l.text)
            };
            body.push_str(&format!("<li>{text}</li>"));
        }
        body.push_str("</ul></section>");
    }

    if sel.iter().any(|s| s == "timeline") && !story.timeline.is_empty() {
        body.push_str("<section><h3>Timeline</h3><ul>");
        for t in &story.timeline {
            let day = format_day(t.at_ms);
            body.push_str(&format!(
                "<li><time>{day}</time> {}<em>{}</em></li>",
                esc(&t.kind),
                if t.detail.is_empty() {
                    esc(&t.title)
                } else {
                    esc(&t.detail)
                }
            ));
        }
        body.push_str("</ul></section>");
    }

    format!(
        r#"<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>{title}</title>
<style>
  body {{ font-family: system-ui, -apple-system, sans-serif; max-width: 700px; margin: 2.5rem auto; padding: 0 1rem; color: #1c1e21; line-height: 1.5; }}
  h1 {{ font-size: 1.7rem; margin: 0 0 .25rem; }} header.head {{ border-bottom: 2px solid #333; padding-bottom: .75rem; margin-bottom: 1.5rem; }}
  .status {{ color: #666; font-size: .85rem; text-transform: uppercase; letter-spacing: .05em; }}
  .summary {{ color: #555; }} h3 {{ font-size: .8rem; text-transform: uppercase; letter-spacing: .08em; color: #666; border-bottom: 1px solid #ddd; margin: 1.5rem 0 .75rem; }} h4 {{ margin: 0; }}
  article {{ margin: 0 0 .75rem; padding-left: .9rem; border-left: 3px solid #8892a0; }} article header {{ display: flex; gap: .6rem; align-items: baseline; }}
  .tag {{ color: #4a5568; font-size: .8rem; text-transform: uppercase; letter-spacing: .04em; }} article p {{ margin: .25rem 0; color: #333; }} .why {{ color: #555; }}
  .event {{ color: #666; font-size: .9rem; margin: .15rem 0; }} ul {{ padding-left: 1.2rem; }} li {{ margin: .25rem 0; }}
  time {{ color: #666; margin-right: .5rem; font-size: .9rem; }} em {{ color: #333; font-style: normal; }}
  @page {{ margin: 2cm; }} @media print {{ body {{ max-width: none; margin: 0; }} }}
</style></head><body>
<header class="head"><div class="status">{status}</div><h1>{title}</h1>
<p class="summary">{summary}</p></header>
{body}
</body></html>"#,
        title = esc(&story.title),
        status = esc(&story.status),
        summary = esc(&story.summary),
    )
}

fn format_day(ms: i64) -> String {
    causelog_content::format_day_ms(ms)
}

/// Approximate average glyph width at 11.5pt, used for wrapping.
fn wrap(text: &str, width_chars: usize) -> Vec<String> {
    let mut out = Vec::new();
    let mut current = String::new();
    for word in text.split_whitespace() {
        if current.is_empty() {
            current.push_str(word);
        } else if current.len() + 1 + word.len() <= width_chars {
            current.push(' ');
            current.push_str(word);
        } else {
            out.push(current);
            current = word.to_string();
        }
    }
    if !current.is_empty() {
        out.push(current);
    }
    out
}

/// One text line of the SVG document.
struct SvgLine {
    x: f64,
    y: f64,
    size: f64,
    fill: &'static str,
    weight: &'static str,
    text: String,
}

macro_rules! line {
    ($lines:expr, $x:expr, $y:expr, $size:expr, $fill:expr, $weight:expr, $text:expr) => {
        $lines.push(SvgLine {
            x: $x,
            y: $y,
            size: $size,
            fill: $fill,
            weight: $weight,
            text: $text.to_string(),
        })
    };
}

/// Vector (SVG) rendering of the same document on an A4 page, in points.
pub fn one_pager_svg(story: &crate::ProjectStory, sections: &[String]) -> String {
    const W: f64 = 595.0;
    const MARGIN: f64 = 56.0;
    const LINE: f64 = 18.0;

    let sel = selected_sections(sections);
    let mut lines: Vec<SvgLine> = Vec::new();
    let mut y = 60.0;
    let heading = |name: &str, lines: &mut Vec<SvgLine>, y: &mut f64| {
        *y += 22.0;
        line!(
            lines,
            MARGIN,
            *y,
            13.0,
            "#666666",
            "bold",
            name.to_uppercase()
        );
        *y += 12.0;
        line!(lines, MARGIN, *y, 11.0, "#8892a0", "normal", "─".repeat(52));
        *y += 10.0;
    };

    line!(
        lines,
        MARGIN,
        y,
        11.0,
        "#666666",
        "normal",
        story.status.to_uppercase()
    );
    y += 22.0;
    line!(lines, MARGIN, y, 24.0, "#1c1e21", "bold", &story.title);
    y += 20.0;
    if !story.summary.is_empty() {
        for wl in wrap(&story.summary, 72) {
            line!(lines, MARGIN, y, 12.0, "#666666", "normal", wl);
            y += LINE;
        }
    }
    y += 8.0;

    for s in &sel {
        match s.as_str() {
            "goal" => {
                if let Some(goal) = &story.goal {
                    heading("Goal", &mut lines, &mut y);
                    line!(lines, MARGIN, y, 15.0, "#1c1e21", "bold", &goal.title);
                    y += LINE;
                    for wl in wrap(&goal.body, 68) {
                        line!(lines, MARGIN, y, 12.0, "#1c1e21", "normal", wl);
                        y += LINE;
                    }
                }
            }
            "problem" => {
                if let Some(problem) = &story.problem
                    && !problem.is_empty()
                {
                    heading("Problem", &mut lines, &mut y);
                    for wl in wrap(problem, 72) {
                        line!(lines, MARGIN, y, 12.0, "#1c1e21", "normal", wl);
                        y += LINE;
                    }
                }
            }
            "decisions" => {
                if !story.key_decisions.is_empty() {
                    heading("Key decisions", &mut lines, &mut y);
                    for d in &story.key_decisions {
                        let state = if d.state.is_empty() { "open" } else { &d.state };
                        line!(lines, MARGIN, y, 13.0, "#1c1e21", "bold", &d.title);
                        line!(
                            lines,
                            MARGIN + 300.0,
                            y,
                            11.0,
                            "#666666",
                            "bold",
                            state.to_uppercase()
                        );
                        y += LINE;
                        for wl in wrap(&d.context, 72) {
                            line!(lines, MARGIN, y, 11.5, "#666666", "normal", wl);
                            y += LINE;
                        }
                        for wl in wrap(&d.rationale, 72) {
                            line!(
                                lines,
                                MARGIN,
                                y,
                                11.5,
                                "#1c1e21",
                                "normal",
                                format!("Why: {wl}")
                            );
                            y += LINE;
                        }
                        y += 6.0;
                    }
                }
            }
            "evidence" => {
                if !story.experiments.is_empty() {
                    heading("Evidence", &mut lines, &mut y);
                    for e in &story.experiments {
                        let st = if e.status.is_empty() {
                            "planned"
                        } else {
                            &e.status
                        };
                        line!(lines, MARGIN, y, 13.0, "#1c1e21", "bold", &e.title);
                        line!(
                            lines,
                            MARGIN + 300.0,
                            y,
                            11.0,
                            "#666666",
                            "bold",
                            st.to_uppercase()
                        );
                        y += LINE;
                        if !e.hypothesis.is_empty() {
                            for wl in wrap(&e.hypothesis, 72) {
                                line!(lines, MARGIN, y, 11.5, "#666666", "normal", wl);
                                y += LINE;
                            }
                        }
                        if !e.result.is_empty() {
                            for wl in wrap(&e.result, 72) {
                                line!(lines, MARGIN, y, 11.5, "#1c1e21", "normal", wl);
                                y += LINE;
                            }
                        }
                        y += 6.0;
                    }
                }
            }
            "lessons" => {
                if !story.lessons.is_empty() {
                    heading("Lessons", &mut lines, &mut y);
                    for l in &story.lessons {
                        let text = if l.text.is_empty() {
                            "—".to_string()
                        } else {
                            l.text.clone()
                        };
                        for wl in wrap(&text, 72) {
                            line!(
                                lines,
                                MARGIN,
                                y,
                                11.5,
                                "#1c1e21",
                                "normal",
                                format!("• {wl}")
                            );
                            y += LINE;
                        }
                    }
                }
            }
            "timeline" if !story.timeline.is_empty() => {
                heading("Timeline", &mut lines, &mut y);
                for t in &story.timeline {
                    let detail = if t.detail.is_empty() {
                        &t.title
                    } else {
                        &t.detail
                    };
                    line!(
                        lines,
                        MARGIN,
                        y,
                        11.5,
                        "#666666",
                        "normal",
                        format_day(t.at_ms)
                    );
                    line!(lines, MARGIN + 90.0, y, 11.5, "#1c1e21", "normal", detail);
                    y += LINE;
                }
            }
            _ => {}
        }
    }
    y += 10.0;
    line!(
        lines,
        MARGIN,
        y,
        9.0,
        "#666666",
        "normal",
        format!("Generated from {} — Causelog", story.title)
    );

    let height = (y + 8.0).max(842.0);
    let mut content = String::new();
    for l in lines {
        content.push_str(&format!(
            "<text x=\"{:.1}\" y=\"{:.1}\" font-size=\"{:.1}\" fill=\"{}\" font-weight=\"{}\" font-family=\"system-ui, sans-serif\">{}</text>\n",
            l.x,
            l.y,
            l.size,
            l.fill,
            l.weight,
            esc(&l.text)
        ));
    }

    format!(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{W:.0}\" height=\"{height:.1}\" viewBox=\"0 0 {W:.0} {height:.1}\">\n<rect width=\"{W:.0}\" height=\"{height:.1}\" fill=\"#ffffff\" />\n<rect x=\"8\" y=\"8\" width=\"{W:.0}\" height=\"{height:.1}\" fill=\"none\" stroke=\"#d9dce1\" />\n{content}</svg>"
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample() -> crate::ProjectStory {
        crate::ProjectStory {
            title: "Causelog".to_string(),
            summary: "Track decisions with evidence.".to_string(),
            status: "active".to_string(),
            goal: Some(crate::StoryGoal {
                id: uuid::Uuid::new_v4(),
                title: "Ship it".to_string(),
                body: "Reduce decision debt.".to_string(),
                status: "open".to_string(),
            }),
            problem: Some("Too much drift.".to_string()),
            key_decisions: vec![crate::StoryDecision {
                id: uuid::Uuid::new_v4(),
                title: "Batch uploads".to_string(),
                state: "validated".to_string(),
                decided_option: None,
                context: "We kept free-threading on the call path.".to_string(),
                rationale: "Faster, simpler.".to_string(),
                options: Vec::new(),
                links: Vec::new(),
            }],
            experiments: vec![crate::StoryExperiment {
                id: uuid::Uuid::new_v4(),
                decision_id: None,
                title: "Batch pilot".to_string(),
                status: "done".to_string(),
                hypothesis: "Batching cuts the call count.".to_string(),
                result: "Worked.".to_string(),
                lesson: String::new(),
                events: Vec::new(),
            }],
            lessons: vec![crate::StoryLesson {
                id: uuid::Uuid::new_v4(),
                text: "Test in prod? No.".to_string(),
            }],
            current_state: Vec::new(),
            timeline: vec![crate::TimelineEvent {
                at_ms: 1_720_000_000_000,
                kind: "decision_resolved".to_string(),
                title: "Batch uploads".to_string(),
                detail: String::new(),
            }],
        }
    }

    #[test]
    fn html_default_renders_all_sections_in_order() {
        let html = one_pager_html(&sample(), &[]);
        let order = [
            "Goal",
            "Problem",
            "Key decisions",
            "Evidence",
            "Lessons",
            "Timeline",
        ];
        let mut last = 0;
        for heading in order {
            let at = html.find(heading).unwrap_or_else(|| panic!("{heading}"));

            assert!(at > last, "{heading} out of order");
            last = at;
        }
        assert!(html.starts_with("<!doctype html>"));
        assert!(html.contains("<h4>Batch uploads</h4>"));
        assert!(html.contains("<time>"));
    }

    #[test]
    fn html_respects_section_selection() {
        let html = one_pager_html(&sample(), &["goal".to_string(), "lessons".to_string()]);
        assert!(html.contains(">Goal<"));
        assert!(html.contains(">Lessons<"));
        assert!(!html.contains("Problem"));
        assert!(!html.contains("Evidence"));
        assert!(!html.contains("Batch uploads"));
    }

    #[test]
    fn html_escapes_markup() {
        let mut s = sample();
        s.lessons[0].text = "<script>alert(1)</script>".to_string();
        let html = one_pager_html(&s, &["lessons".to_string()]);
        assert!(!html.contains("<script>alert"));
        assert!(html.contains("&lt;script&gt;"));
    }

    #[test]
    fn svg_renderer_contains_sections_and_escaping() {
        let mut s = sample();
        s.lessons[0].text = "A & B > C".to_string();
        let svg = one_pager_svg(&s, &[]);
        assert!(svg.starts_with("<?xml"));
        assert!(svg.contains("<svg"));
        assert!(svg.contains(">GOAL<"));
        assert!(svg.contains("A &amp; B &gt; C"));
        assert!(svg.contains(">Batch uploads<"));
        assert!(svg.contains(">Batch pilot<"));
    }

    #[test]
    fn selected_sections_filters_unknown_and_preserves_order() {
        assert_eq!(selected_sections(&[]), ONE_PAGER_SECTIONS);
        let sel = selected_sections(&[
            "timeline".to_string(),
            "bogus".to_string(),
            "problem".to_string(),
        ]);
        assert_eq!(sel, vec!["problem", "timeline"]);
    }
}
