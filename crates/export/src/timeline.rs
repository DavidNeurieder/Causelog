//! Derived timeline: a flat, time-ordered stream of what happened in a
//! project. Rendered from entity and event timestamps (there is no separate
//! timeline table), so every renderer shows the same history.

use crate::model::{ExportProject, TimelineEvent};

/// Build the project timeline: experiment start/end, decision resolutions and
/// raw experiment events, sorted chronologically (ties by id).
pub fn derive_timeline(project: &ExportProject) -> Vec<TimelineEvent> {
    let mut events = Vec::with_capacity(
        project.events.len() + project.experiments.len() * 2 + project.decisions.len(),
    );

    for e in &project.experiments {
        if let Some(started) = e.started_at_ms {
            events.push(TimelineEvent {
                at_ms: started,
                kind: "experiment_started".to_string(),
                title: e.title.clone(),
                detail: String::new(),
            });
        }
        if let Some(ended) = e.ended_at_ms {
            events.push(TimelineEvent {
                at_ms: ended,
                kind: "experiment_ended".to_string(),
                title: e.title.clone(),
                detail: format!("status: {}", e.status),
            });
        }
    }

    for d in &project.decisions {
        if let Some(at) = d.decided_at_ms {
            let option = d
                .decided_option
                .as_deref()
                .and_then(|id| d.options.iter().find(|o| o.id == id))
                .map(|o| format!(" — {}", o.label))
                .unwrap_or_default();
            events.push(TimelineEvent {
                at_ms: at,
                kind: "decision_resolved".to_string(),
                title: d.title.clone(),
                detail: format!("{}: {}{}", d.status, d.title, option),
            });
        }
    }

    for ev in &project.events {
        events.push(TimelineEvent {
            at_ms: ev.at_ms,
            kind: ev.kind.clone(),
            title: experiment_title(project, ev.experiment_id),
            detail: ev.note.clone(),
        });
    }

    events.sort_by_key(|e| (e.at_ms, format!("{}:{}", e.kind, e.title)));
    events
}

fn experiment_title(project: &ExportProject, id: uuid::Uuid) -> String {
    project
        .experiments
        .iter()
        .find(|e| e.id == id)
        .map(|e| e.title.clone())
        .unwrap_or_else(|| id.to_string())
}
