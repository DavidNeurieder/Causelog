//! First-run "Explore an example": seeds one small, self-contained project
//! that walks the whole golden path — goal → decision → experiment → lesson —
//! so a brand-new user can see what a finished story looks like in under two
//! minutes.

use causelog_content::now_ms;
use causelog_model::{DecisionOption, Project};
use uuid::Uuid;

use crate::repository::Repository;

const EXAMPLE_TITLE: &str = "The Coffee Machine Uprising";
const EXAMPLE_SUMMARY: &str = "A tiny example: the team refilled the office coffee machine at noon — and everything stopped being fine.";

/// Create the example project for `user`. Calls are intentionally plain and
/// sequential so the flow is easy to follow.
pub async fn seed_example_project(repo: &dyn Repository, user_id: Uuid) -> anyhow::Result<Project> {
    let project = repo
        .create_project(EXAMPLE_TITLE, EXAMPLE_SUMMARY, "active", Some(user_id))
        .await?;

    let goal = repo
        .create_goal(
            project.id,
            "A coffee machine the team trusts",
            "Twice a week the machine runs dry at noon and the queue grows into a decision-by-acclamation.",
            Some(user_id),
            Some(user_id),
        )
        .await?;

    let decision = repo
        .create_decision(
            project.id,
            Some(goal.id),
            "Keep the office coffee refilled",
            "Refills happen on a vague sense of 'someone should'. When noon hit, nobody had, so the decision got made at the machine.",
            &[
                DecisionOption {
                    id: "o1".to_string(),
                    label: "Scheduled refill (Tue + Thu)".to_string(),
                    pros: "Predictable; spread the load.".to_string(),
                    cons: "Needs a tiny ritual to stick.".to_string(),
                },
                DecisionOption {
                    id: "o2".to_string(),
                    label: "Vending backup machine".to_string(),
                    pros: "Zero discipline needed.".to_string(),
                    cons: "Cost + machine floor space.".to_string(),
                },
                DecisionOption {
                    id: "o3".to_string(),
                    label: "Copycat free coffee".to_string(),
                    pros: "Removes the dependency.".to_string(),
                    cons: "Actually unpopular. Who knew.".to_string(),
                },
            ],
            Some(user_id),
        )
        .await?;

    let experiment = repo
        .create_experiment(
            project.id,
            Some(goal.id),
            Some(decision.id),
            "Two-week scheduled refill pilot",
            "If refills happen on a fixed calendar, the machine will be stocked at noon with zero reminders.",
            Some(user_id),
        )
        .await?;

    repo.create_event(
        experiment.id,
        "measurement",
        now_ms(),
        "Day 7: stock level at noon — full, for the first time in two weeks.",
    )
    .await?;
    repo.create_event(
        experiment.id,
        "observation",
        now_ms(),
        "No one asked in chat; the refill ritual just happened in the background.",
    )
    .await?;

    repo.update_experiment(
        experiment.id,
        "Two-week scheduled refill pilot",
        "If refills happen on a fixed calendar, the machine will be stocked at noon with zero reminders.",
        "done",
        "At noon every day of the pilot the machine had beans. Zero pings to #coffee.",
        "Small rituals beat big reminders — schedule the boring step and the team forgets it.",
    )
    .await?;

    repo.resolve_decision(
        decision.id,
        "decided",
        Some("o1".to_string()),
        "The pilot made the choice obvious: scheduled refill worked with zero friction, and it needs no new hardware.",
        Some(now_ms() + 24 * 60 * 60 * 1000),
    )
    .await?;

    repo.create_note(
        project.id,
        "Rituals outlast reminders",
        "Nobody wants to be 'the one who reminds everyone'. A fixed slot needs no champion — that's why the scheduled refill outlasted the group chat.",
        Some("experiment"),
        Some(experiment.id),
        Some(user_id),
    )
    .await?;

    Ok(project)
}
