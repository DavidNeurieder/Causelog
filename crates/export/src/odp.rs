//! ODP (ODF presentation) slides: a minimal slide model built from the
//! project's [`ProjectStory`], rendered as a LibreOffice-openable
//! `.odp` (a ZIP of Flat basic XML) — deliberately "beautiful, editable,
//! boringly compatible" per the exports spec: text boxes and simple lists,
//! no SmartArt, animations or proprietary effects.

use causelog_content::format_date_ms;
use causelog_model::DecisionOption;

use crate::model::TimelineEvent;
use crate::story::ProjectStory;

/// One slide of a presentation. Built from the story, then rendered as ODP.
#[derive(Debug, Clone, PartialEq)]
pub enum Slide {
    Title {
        title: String,
        subtitle: String,
    },
    Goal {
        title: String,
        body: String,
    },
    Decision {
        title: String,
        state: String,
        /// Id of the chosen option (`decided_option`), compared against
        /// `DecisionOption.id`. The display label is derived from it.
        decided_option: Option<String>,
        decided_label: Option<String>,
        context: String,
        rationale: String,
        options: Vec<DecisionOption>,
    },
    Experiment {
        title: String,
        status: String,
        hypothesis: String,
        result: String,
    },
    Lesson {
        text: String,
    },
    Timeline {
        entries: Vec<TimelineEvent>,
    },
}

/// A whole presentation: title plus an ordered list of slides.
#[derive(Debug, Clone, PartialEq)]
pub struct Presentation {
    pub title: String,
    pub slides: Vec<Slide>,
}

/// Derive the deck from a project story: title slide, goal, one slide per
/// decision / experiment / lesson, then the timeline.
pub fn build_presentation(story: &ProjectStory) -> Presentation {
    let mut slides = vec![Slide::Title {
        title: story.title.clone(),
        subtitle: story.summary.clone(),
    }];

    if let Some(goal) = &story.goal {
        slides.push(Slide::Goal {
            title: goal.title.clone(),
            body: goal.body.clone(),
        });
    }

    for d in &story.key_decisions {
        let decided_label = d
            .decided_option
            .as_deref()
            .and_then(|id| d.options.iter().find(|o| o.id == id))
            .map(|o| o.label.clone());
        slides.push(Slide::Decision {
            title: d.title.clone(),
            state: d.state.clone(),
            decided_option: d.decided_option.clone(),
            decided_label,
            context: d.context.clone(),
            rationale: d.rationale.clone(),
            options: d.options.clone(),
        });
    }

    for e in &story.experiments {
        slides.push(Slide::Experiment {
            title: e.title.clone(),
            status: e.status.clone(),
            hypothesis: e.hypothesis.clone(),
            result: e.result.clone(),
        });
    }

    for lesson in &story.lessons {
        slides.push(Slide::Lesson {
            text: lesson.text.clone(),
        });
    }

    if !story.timeline.is_empty() {
        slides.push(Slide::Timeline {
            entries: story.timeline.clone(),
        });
    }

    Presentation {
        title: story.title.clone(),
        slides,
    }
}

/// Slide heading used as the on-slide title and the draw:page name.
fn slide_title(slide: &Slide) -> &str {
    match slide {
        Slide::Title { title, .. }
        | Slide::Goal { title, .. }
        | Slide::Decision { title, .. }
        | Slide::Experiment { title, .. } => title,
        Slide::Lesson { .. } => "Lesson",
        Slide::Timeline { .. } => "Timeline",
    }
}

/// Escape a string for XML text content (`&`, `<`, `>`, `"`, `'`).
fn escape(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    for c in s.chars() {
        match c {
            '&' => out.push_str("&amp;"),
            '<' => out.push_str("&lt;"),
            '>' => out.push_str("&gt;"),
            '"' => out.push_str("&quot;"),
            '\'' => out.push_str("&apos;"),
            _ => out.push(c),
        }
    }
    out
}

/// One `<text:p>` paragraph, optionally styled.
fn para(text: &str, style: &str) -> String {
    if style.is_empty() {
        format!("<text:p>{}</text:p>", escape(text))
    } else {
        format!(
            "<text:p text:style-name=\"{}\">{}</text:p>",
            style,
            escape(text)
        )
    }
}

/// Body-copy paragraphs for a slide, prefixed with a muted kicker line.
fn body(paragraphs: &[(&str, String)]) -> String {
    let mut out = String::new();
    for (style, text) in paragraphs {
        out.push_str(&para(text, style));
    }
    out
}

fn page_xml(index: usize, slide: &Slide) -> String {
    let title = slide_title(slide);
    let page_name = format!("Slide {}", index + 1);
    let body_xml = match slide {
        Slide::Title { subtitle, .. } => body(&[
            ("P-kicker", "Project story".into()),
            ("P-body-lg", subtitle.clone()),
        ]),
        Slide::Goal {
            body: body_text, ..
        } => body(&[("P-kicker", "Goal".into()), ("P-body", body_text.clone())]),
        Slide::Decision {
            state,
            decided_option,
            decided_label,
            context,
            rationale,
            options,
            ..
        } => {
            let chosen = decided_label
                .as_deref()
                .map(|l| format!("Chosen: {l}"))
                .unwrap_or_else(|| "Not decided".into());
            let mut lines = vec![
                ("P-kicker", format!("Decision · {state}")),
                ("P-body", chosen),
            ];
            if !context.is_empty() {
                lines.push(("P-body", format!("Why: {context}")));
            }
            if !rationale.is_empty() {
                lines.push(("P-body", format!("Reasoning: {rationale}")));
            }
            if !options.is_empty() {
                let mut opts: Vec<String> = options
                    .iter()
                    .map(|o| format!("- {} — pro: {} con: {}", o.label, o.pros, o.cons))
                    .collect();
                // Compare by option id (the stable key), never by label, and
                // derive the display label from that same option.
                if let Some(oid) = decided_option.as_deref()
                    && let Some(o) = options.iter().find(|o| o.id == oid)
                {
                    opts.push(format!("→ {}", o.label));
                }
                lines.push(("P-kicker", "Alternatives".into()));
                for o in opts {
                    lines.push(("P-list", o));
                }
            }
            body(&lines)
        }
        Slide::Experiment {
            status,
            hypothesis,
            result,
            ..
        } => {
            let mut lines = vec![("P-kicker", format!("Experiment · {status}"))];
            if !hypothesis.is_empty() {
                lines.push(("P-body", format!("Hypothesis: {hypothesis}")));
            }
            if !result.is_empty() {
                lines.push(("P-body", format!("Result: {result}")));
            }
            body(&lines)
        }
        Slide::Lesson { text } => {
            body(&[("P-kicker", "Lesson".into()), ("P-body-lg", text.clone())])
        }
        Slide::Timeline { entries } => {
            let mut lines: Vec<(&str, String)> =
                vec![("P-kicker", "What happened, in order".into())];
            for e in entries {
                let mut text = format!("{} · {} — {}", format_date_ms(e.at_ms), e.kind, e.title);
                if !e.detail.is_empty() {
                    text.push_str(" — ");
                    text.push_str(&e.detail);
                }
                lines.push(("P-list", text));
            }
            body(&lines)
        }
    };

    format!(
        r##"<draw:page draw:name="{page_name}" draw:style-name="dp1" draw:master-page-name="Default">
<draw:frame presentation:class="title" draw:style-name="gr1" draw:text-style-name="P-title" svg:x="0.6cm" svg:y="0.55cm" svg:width="26.8cm" svg:height="1.9cm">
  <draw:text-box><text:p text:style-name="P-title">{title}</text:p></draw:text-box>
</draw:frame>
<draw:frame presentation:class="outline" draw:style-name="gr1" draw:text-style-name="P-body" svg:x="0.9cm" svg:y="2.7cm" svg:width="26.2cm" svg:height="11.9cm">
  <draw:text-box>{body_xml}
</draw:text-box>
</draw:frame>
</draw:page>"##,
        page_name = escape(&page_name),
        title = escape(title),
        body_xml = body_xml,
    )
}

fn content_xml(presentation: &Presentation) -> String {
    let pages: String = presentation
        .slides
        .iter()
        .enumerate()
        .map(|(i, s)| page_xml(i, s))
        .collect();

    format!(
        r##"<?xml version="1.0" encoding="UTF-8"?>
<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" office:version="1.2">
<office:scripts/>
<office:font-face-decls>
<style:font-face style:name="Liberation Sans" svg:font-family="Liberation Sans"/>
</office:font-face-decls>
<office:automatic-styles>
<style:style style:name="dp1" style:family="drawing-page" style:parent-style-name="Default">
<style:drawing-page-properties presentation:page-scaling="none" presentation:transition-style="none" presentation:transition-speed="medium" presentation:transition-type="manual"/>
</style:style>
<style:style style:name="gr1" style:family="graphic" style:parent-style-name="Default">
<style:graphic-properties text:anchor-type="as-char" svg:y="0cm" style:vertical-pos="top" style:vertical-rel="line" style:vertical-width="relative" style:horizontal-pos="center" style:horizontal-rel="frame" style:horizontal-width="relative" style:wrap="none" style:number-wrapped-paragraphs="no-limit" style:number-lines="false" style:line-number="0" text:number-lines="false" text:line-number="0" style:run-through="foreground" style:flow-with-text="true" style:print="true" style:shrink-to-fit="false"/>
</style:style>
<style:style style:name="P-title" style:family="paragraph" style:parent-style-name="Title">
<style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:margin-top="0cm" fo:margin-bottom="0cm" style:line-height="112%"/>
<style:text-properties style:font-name="Liberation Sans" style:font-family-generic="swiss" style:font-pitch="variable" fo:font-size="130%" style:font-size-asian="130%" style:font-size-complex="130%" fo:font-weight="bold" style:font-weight-asian="bold" style:font-weight-complex="bold" fo:color="#1f2a37"/>
</style:style>
<style:style style:name="P-kicker" style:family="paragraph" style:parent-style-name="title">
<style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:margin-top="0cm" fo:margin-bottom="0.05cm" style:line-height="112%"/>
<style:text-properties style:font-name="Liberation Sans" style:font-family-generic="swiss" style:font-pitch="variable" fo:font-size="62%" style:font-size-asian="62%" style:font-size-complex="62%" fo:font-weight="bold" fo:color="#6b7280" fo:text-transform="uppercase"/>
</style:style>
<style:style style:name="P-body" style:family="paragraph" style:parent-style-name="outline1">
<style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:margin-top="0cm" fo:margin-bottom="0.1cm" style:line-height="112%"/>
<style:text-properties style:font-name="Liberation Sans" style:font-family-generic="swiss" style:font-pitch="variable" fo:font-size="58%" style:font-size-asian="58%" style:font-size-complex="58%" fo:color="#111827"/>
</style:style>
<style:style style:name="P-body-lg" style:family="paragraph" style:parent-style-name="outline1">
<style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:margin-top="0cm" fo:margin-bottom="0.1cm" style:line-height="112%"/>
<style:text-properties style:font-name="Liberation Sans" style:font-family-generic="swiss" style:font-pitch="variable" fo:font-size="66%" style:font-size-asian="66%" style:font-size-complex="66%" fo:color="#111827"/>
</style:style>
<style:style style:name="P-list" style:family="paragraph" style:parent-style-name="outline1">
<style:paragraph-properties fo:margin-left="0.4cm" fo:margin-right="0cm" fo:margin-top="0cm" fo:margin-bottom="0.05cm" style:line-height="112%"/>
<style:text-properties style:font-name="Liberation Sans" style:font-family-generic="swiss" style:font-pitch="variable" fo:font-size="52%" style:font-size-asian="52%" style:font-size-complex="52%" fo:color="#111827"/>
</style:style>
</office:automatic-styles>
<office:body>
<office:presentation>
{pages}</office:presentation>
</office:body>
</office:document-content>
"##,
        pages = pages,
    )
}

fn styles_xml() -> String {
    r##"<?xml version="1.0" encoding="UTF-8"?>
<office:document-styles xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" office:version="1.2">
<office:font-face-decls>
<style:font-face style:name="Liberation Sans" svg:font-family="Liberation Sans"/>
</office:font-face-decls>
<office:styles>
<style:default-style style:family="graphic">
<style:graphic-properties text:anchor-type="as-char" fo:margin-left="0cm" fo:margin-right="0cm" fo:margin-top="0cm" fo:margin-bottom="0cm" style:vertical-pos="top" style:vertical-rel="line" style:horizontal-pos="center" style:horizontal-rel="frame" style:wrap="none" style:number-wrapped-paragraphs="no-limit" style:number-lines="false" style:line-number="0" text:number-lines="false" text:line-number="0" style:run-through="foreground" style:flow-with-text="true" style:print="true" style:shrink-to-fit="false"/>
</style:default-style>
<style:default-style style:family="paragraph">
<style:paragraph-properties text:number-lines="false" text:line-number="0" fo:line-height="112%"/>
<style:text-properties style:font-name="Liberation Sans" fo:font-size="8pt" style:font-size-asian="8pt" style:font-size-complex="8pt"/>
</style:default-style>
<style:style style:name="Default" style:family="graphic"/>
<style:style style:name="Title" style:family="presentation">
<style:graphic-properties draw:fill="none" draw:stroke="none" text:anchor-type="as-char" style:vertical-pos="top" style:vertical-rel="line" style:horizontal-pos="center" style:horizontal-rel="frame" style:wrap="none" style:number-wrapped-paragraphs="no-limit" style:number-lines="false" style:line-number="0" text:number-lines="false" text:line-number="0" style:run-through="foreground" style:flow-with-text="true" style:print="true" style:shrink-to-fit="false"/>
<style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:margin-top="0cm" fo:margin-bottom="0cm"/>
<style:text-properties style:font-name="Liberation Sans" style:font-family-generic="swiss" style:font-pitch="variable" fo:font-size="57%" style:font-size-asian="57%" style:font-size-complex="57%" fo:font-weight="bold" style:font-weight-asian="bold" style:font-weight-complex="bold" fo:color="#1f2a37"/>
</style:style>
<style:style style:name="title" style:family="presentation">
<style:graphic-properties draw:fill="none" draw:stroke="none" text:anchor-type="as-char" style:vertical-pos="top" style:vertical-rel="line" style:horizontal-pos="center" style:horizontal-rel="frame" style:wrap="none" style:number-wrapped-paragraphs="no-limit" style:number-lines="false" style:line-number="0" text:number-lines="false" text:line-number="0" style:run-through="foreground" style:flow-with-text="true" style:print="true" style:shrink-to-fit="false"/>
<style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:margin-top="0cm" fo:margin-bottom="0cm"/>
<style:text-properties style:font-name="Liberation Sans" style:font-family-generic="swiss" style:font-pitch="variable" fo:font-size="57%" style:font-size-asian="57%" style:font-size-complex="57%" fo:font-weight="bold" style:font-weight-asian="bold" style:font-weight-complex="bold" fo:color="#111827"/>
</style:style>
<style:style style:name="outline1" style:family="presentation">
<style:graphic-properties draw:fill="none" draw:stroke="none" text:anchor-type="as-char" style:vertical-pos="top" style:vertical-rel="line" style:horizontal-pos="center" style:horizontal-rel="frame" style:wrap="none" style:number-wrapped-paragraphs="no-limit" style:number-lines="false" style:line-number="0" text:number-lines="false" text:line-number="0" style:run-through="foreground" style:flow-with-text="true" style:print="true" style:shrink-to-fit="false"/>
<style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:margin-top="0cm" fo:margin-bottom="0.1cm" style:line-height="112%"/>
<style:text-properties style:font-name="Liberation Sans" style:font-family-generic="swiss" style:font-pitch="variable" fo:font-size="58%" style:font-size-asian="58%" style:font-size-complex="58%" fo:color="#111827"/>
</style:style>
<style:style style:name="Outl" style:family="presentation"/>
</office:styles>
<office:master-styles>
<style:master-page style:name="Default" style:page-layout-name="DefaultLayout" draw:style-name="Default">
<style:presentation-page-layout style:name="AL1T0">
<presentation:placeholder presentation:object="title" svg:x="1.08cm" svg:y="0.68cm" svg:width="24.74cm" svg:height="2.24cm"/>
<presentation:placeholder presentation:object="outline" svg:x="1.08cm" svg:y="3.27cm" svg:width="24.74cm" svg:height="10.84cm"/>
</style:presentation-page-layout>
<draw:page-thumbnail presentation:class="page" draw:style-name="Default" svg:x="0cm" svg:y="0cm" svg:width="0cm" svg:height="0cm" style:shadow="none"/>
<draw:frame presentation:class="title" draw:style-name="Title" draw:text-style-name="Title" svg:x="1.08cm" svg:y="0.68cm" svg:width="24.74cm" svg:height="2.24cm">
<draw:text-box><text:p text:style-name="Title">Title</text:p></draw:text-box>
</draw:frame>
<draw:frame presentation:class="outline" draw:style-name="Outl" draw:text-style-name="Outl" svg:x="1.08cm" svg:y="3.27cm" svg:width="24.74cm" svg:height="10.84cm">
<draw:text-box><text:p text:style-name="outline1">Text</text:p></draw:text-box>
</draw:frame>
</style:master-page>
</office:master-styles>
<office:font-face-decls>
<style:font-face style:name="Liberation Sans" svg:font-family="Liberation Sans"/>
</office:font-face-decls>
</office:document-styles>
"##
        .to_string()
}

fn meta_xml(presentation: &Presentation, causelog_version: &str) -> String {
    format!(
        r##"<?xml version="1.0" encoding="UTF-8"?>
<office:document-meta xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:grddl="http://www.w3.org/2003/g/data-view#" office:version="1.2">
<office:meta>
<meta:generator>Causelog/{version}</meta:generator>
<dc:title>{title}</dc:title>
<meta:creation-date>{date}</meta:creation-date>
<dc:creator>Causelog</dc:creator>
</office:meta>
</office:document-meta>
"##,
        version = escape(causelog_version),
        title = escape(&presentation.title),
        date = escape(&format_date_ms(causelog_content::now_ms())),
    )
}

fn manifest_xml() -> String {
    r##"<?xml version="1.0" encoding="UTF-8"?>
<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.2">
<manifest:file-entry manifest:full-path="/" manifest:media-type="application/vnd.oasis.opendocument.presentation"/>
<manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>
<manifest:file-entry manifest:full-path="styles.xml" manifest:media-type="text/xml"/>
<manifest:file-entry manifest:full-path="meta.xml" manifest:media-type="text/xml"/>
</manifest:manifest>
"##
        .to_string()
}

/// Errors from packaging a presentation into ODP bytes.
#[derive(Debug, thiserror::Error)]
pub enum OdfError {
    #[error("odp packaging failed: {0}")]
    Zip(#[from] zip::result::ZipError),
    #[error("odp part could not be written: {0}")]
    Io(#[from] std::io::Error),
}

/// Render a presentation to ODP bytes (a ZIP of ODF XML). Packaging failures
/// are returned, never panicked on.
pub fn render_odp(
    presentation: &Presentation,
    causelog_version: &str,
) -> Result<Vec<u8>, OdfError> {
    use zip::write::SimpleFileOptions;

    let mut buf = std::io::Cursor::new(Vec::new());
    {
        let mut writer = zip::ZipWriter::new(&mut buf);

        // `mimetype` must be the first entry and stored uncompressed for a
        // valid OpenDocument package.
        writer.start_file(
            "mimetype",
            SimpleFileOptions::default().compression_method(zip::CompressionMethod::Stored),
        )?;
        std::io::Write::write_all(
            &mut writer,
            b"application/vnd.oasis.opendocument.presentation",
        )?;

        let stored = [
            ("content.xml", content_xml(presentation)),
            ("styles.xml", styles_xml()),
            ("meta.xml", meta_xml(presentation, causelog_version)),
            ("META-INF/manifest.xml", manifest_xml()),
        ];
        let options =
            SimpleFileOptions::default().compression_method(zip::CompressionMethod::Deflated);
        for (name, content) in stored {
            writer.start_file(name, options)?;
            std::io::Write::write_all(&mut writer, content.as_bytes())?;
        }
        writer.finish()?;
    }
    Ok(buf.into_inner())
}
