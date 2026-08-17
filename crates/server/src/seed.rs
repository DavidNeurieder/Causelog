//! Demo seeding: a first user and a playful, filled-out three-project
//! universe so the app is fun to poke around in before real use.

use std::collections::HashSet;

use kaizen_content::now_ms;
use kaizen_model::{DecisionOption, Goal};
use kaizen_server::auth;
use kaizen_server::repository::{Repository as _, SqliteRepository};
use uuid::Uuid;

const DEMO_USER: &str = "demo";
const DEMO_PASSWORD: &str = "demo-password";

const TEAM_USER: &str = "alice";
const TEAM_PASSWORD: &str = "longenough1";
const PENDING_USER: &str = "bob";
const PENDING_PASSWORD: &str = "longenough1";

const SQLITE_PROJECT: &str = "SQLite + Rust API";
const GLORIA_PROJECT: &str = "The Legend of Gloria the Monstera";
const COFFEE_PROJECT: &str = "The Coffee Machine Uprising";

const SEED_PROJECTS: [&str; 3] = [GLORIA_PROJECT, COFFEE_PROJECT, SQLITE_PROJECT];

/// First-run friendliness: create a demo user (if none exists) and seed three
/// projects showing the whole golden path — goal → decision → experiment →
/// note, with links between them. Two of them are unapologetically silly.
///
/// The demo user is **admin**. Two extra users are seeded to show multi-user:
/// - `alice` / `longenough1` — approved, added as a member of the Gloria project.
/// - `bob` / `longenough1` — registered but pending admin approval.
pub async fn seed_demo(database_url: &str) -> anyhow::Result<()> {
    let repo = SqliteRepository::connect(database_url).await?;
    repo.migrate().await?;

    ensure_demo_user(&repo).await?;
    ensure_team_users(&repo).await?;

    let projects = repo.list_projects().await?;
    let existing: HashSet<&str> = projects.iter().map(|p| p.title.as_str()).collect();
    if SEED_PROJECTS.iter().all(|t| existing.contains(t)) {
        tracing::info!("demo project already seeded");
        return Ok(());
    }

    // Look up the demo user for project ownership.
    let demo_user = repo.find_user_by_username(DEMO_USER).await?.unwrap();

    if !existing.contains(SQLITE_PROJECT) {
        seed_datastore_project(&repo, demo_user.id).await?;
    }
    if !existing.contains(GLORIA_PROJECT) {
        seed_gloria_project(&repo, demo_user.id).await?;
    }
    if !existing.contains(COFFEE_PROJECT) {
        seed_coffee_project(&repo, demo_user.id).await?;
    }

    tracing::info!(
        "demo seeded — log in as admin: '{DEMO_USER}' / '{DEMO_PASSWORD}'\n\
         other users: '{TEAM_USER}' / '{TEAM_PASSWORD}' (approved member), \
         '{PENDING_USER}' / '{PENDING_PASSWORD}' (pending approval)"
    );
    Ok(())
}

async fn ensure_demo_user(repo: &SqliteRepository) -> anyhow::Result<()> {
    if repo.find_user_by_username(DEMO_USER).await?.is_none() {
        let hash = auth::hash_password(DEMO_PASSWORD)
            .map_err(|e| anyhow::anyhow!("failed to hash password: {e:?}"))?;
        repo.create_first_user(DEMO_USER, "Demo", &hash).await?;
        tracing::info!("created demo user '{DEMO_USER}' (password '{DEMO_PASSWORD}')");
    } else {
        tracing::info!("demo user already exists");
    }
    Ok(())
}

/// Seed two extra users to demonstrate multi-user: one approved member, one
/// pending approval.
async fn ensure_team_users(repo: &SqliteRepository) -> anyhow::Result<()> {
    let hash = auth::hash_password(TEAM_PASSWORD)
        .map_err(|e| anyhow::anyhow!("failed to hash password: {e:?}"))?;

    // Alice — approved, regular user.
    if repo.find_user_by_username(TEAM_USER).await?.is_none() {
        let alice = repo.create_user(TEAM_USER, "Alice", &hash).await?;
        repo.approve_user(alice.id).await?;
        tracing::info!("created user '{TEAM_USER}' (approved, password '{TEAM_PASSWORD}')");
    }

    // Bob — registered but not yet approved.
    if repo.find_user_by_username(PENDING_USER).await?.is_none() {
        repo.create_user(PENDING_USER, "Bob", &hash).await?;
        tracing::info!(
            "created user '{PENDING_USER}' (pending approval, password '{PENDING_PASSWORD}')"
        );
    }

    Ok(())
}

async fn finish_goal(repo: &SqliteRepository, goal: &Goal, status: &str) -> anyhow::Result<()> {
    repo.update_goal(goal.id, &goal.title, &goal.body, status)
        .await?;
    Ok(())
}

/// The serious project: a worked example of choosing a datastore for a small
/// self-hosted service. This one is the seed content of old, kept intact.
async fn seed_datastore_project(repo: &SqliteRepository, created_by: Uuid) -> anyhow::Result<()> {
    let project = repo
        .create_project(
            SQLITE_PROJECT,
            "A worked example: choosing a datastore for a small self-hosted service.",
            "active",
            Some(created_by),
        )
        .await?;
    let goal = repo
        .create_goal(
            project.id,
            "Ship the MVP with the least operational surface",
            "One machine, one binary, no external services.",
            Some(created_by),
        )
        .await?;

    let decision = repo
        .create_decision(
            project.id,
            Some(goal.id),
            "Which datastore?",
            "The API keeps one user's history; writes are rare and local.",
            &[
                DecisionOption {
                    id: "o1".into(),
                    label: "SQLite".into(),
                    pros: "Zero ops, single file, transactional, fast enough for one writer."
                        .into(),
                    cons: "Single-writer semantics.".into(),
                },
                DecisionOption {
                    id: "o2".into(),
                    label: "Postgres".into(),
                    pros: "Concurrent writers, familiar ops.".into(),
                    cons: "A whole server to run and back up.".into(),
                },
            ],
            Some(created_by),
        )
        .await?;
    repo.resolve_decision(
        decision.id,
        "decided",
        Some("o1".into()),
        "One writer is the actual load; SQLite removes the operational surface.",
        None,
    )
    .await?;

    let experiment = repo
        .create_experiment(
            project.id,
            Some(goal.id),
            Some(decision.id),
            "WAL for six weeks",
            "WAL mode keeps reads fast while a single writer applies changes.",
            Some(created_by),
        )
        .await?;
    repo.update_experiment(
        experiment.id,
        "WAL for six weeks",
        "WAL mode keeps reads fast while a single writer applies changes.",
        "done",
        "Reads stayed responsive and no locking incidents occurred.",
        "SQLite WAL is a free win for single-writer workloads.",
    )
    .await?;

    let note = repo
        .create_note(
            project.id,
            &format!("Lesson: {}", experiment.title),
            "SQLite WAL is a free win for single-writer workloads. Re-evaluate if a second writer ever appears.",
            Some("experiment"),
            Some(experiment.id),
            Some(created_by),
        )
        .await?;
    repo.create_link(
        project.id,
        "note",
        note.id,
        "decision",
        decision.id,
        "supports",
    )
    .await?;

    Ok(())
}

/// Office-plant soap opera. Gloria has outlived three keyboards and two
/// interns; her wellbeing is treated with the seriousness it deserves.
async fn seed_gloria_project(repo: &SqliteRepository, created_by: Uuid) -> anyhow::Result<()> {
    let project = repo
        .create_project(
            GLORIA_PROJECT,
            "Gloria is an office monstera who has outlived three keyboards, two interns, and one brutally dark era of office lighting. This project treats her continued existence with the seriousness it deserves.",
            "active",
            Some(created_by),
        )
        .await?;

    // Add Alice as a member so the demo shows cross-user access.
    if let Some(alice) = repo.find_user_by_username(TEAM_USER).await? {
        repo.add_project_member(project.id, alice.id, "member")
            .await
            .ok();
    }

    let g_alive = repo
        .create_goal(
            project.id,
            "Keep Gloria alive for 90 consecutive days",
            "Day 90 is the contract milestone. Nobody knows who holds the contract. We just know it expires.",
            Some(created_by),
        )
        .await?;
    let g_climb = repo
        .create_goal(
            project.id,
            "Get Gloria to actually climb the moss pole",
            "She has been 'considering it' since March. Her leaves go in every direction except up.",
            Some(created_by),
        )
        .await?;
    repo.create_goal(
        project.id,
        "Reach 15 leaves",
        "Current count: 13. The 14th fell off in what can only be described as passive aggression.",
        Some(created_by),
    )
    .await?;
    let g_clap = repo
        .create_goal(
            project.id,
            "Teach Gloria to clap when a build passes",
            "She has no arms and has shown no aptitude. Dropped after she shed a leaf in disgust.",
            Some(created_by),
        )
        .await?;
    finish_goal(repo, &g_alive, "done").await?;
    finish_goal(repo, &g_clap, "dropped").await?;

    let d_water = repo
        .create_decision(
            project.id,
            Some(g_alive.id),
            "How often should we water Gloria?",
            "Opinions range from 'strictly liturgical' to 'whenever she looks sad'. Evidence required.",
            &[
                DecisionOption {
                    id: "w1".into(),
                    label: "Every Sunday, strictly".into(),
                    pros: "Repeatable, calendar-first, immune to vibes.".into(),
                    cons: "Gloria fakes thirst on off-days to test our resolve.".into(),
                },
                DecisionOption {
                    id: "w2".into(),
                    label: "When the soil is dry, like a normal person".into(),
                    pros: "Plant-aware, evidence-based, drought-friendly.".into(),
                    cons: "Requires making eye contact with soil.".into(),
                },
                DecisionOption {
                    id: "w3".into(),
                    label: "Ask Gloria".into(),
                    pros: "Maximum delegation, zero decisions.".into(),
                    cons: "Her answer is always 'sometime soon'.".into(),
                },
            ],
            Some(created_by),
        )
        .await?;
    repo.resolve_decision(
        d_water.id,
        "decided",
        Some("w2".into()),
        "Gloria's thirst is a data signal, not a mood. The Sunday group is also tired of being lied to by a plant.",
        Some(now_ms() + 90 * 86_400_000),
    )
    .await?;

    let d_pot = repo
        .create_decision(
            project.id,
            Some(g_alive.id),
            "Should we move Gloria to a self-watering pot?",
            "A salesperson promised it would 'think for itself'. We have trust issues.",
            &[
                DecisionOption {
                    id: "p1".into(),
                    label: "Yes, hands-free living".into(),
                    pros: "Watering becomes someone else's problem.".into(),
                    cons: "It is nobody's problem. That is the problem.".into(),
                },
                DecisionOption {
                    id: "p2".into(),
                    label: "No, keep the terracotta".into(),
                    pros: "Terracotta is honest about its wetness.".into(),
                    cons: "It is also honest about being broken if dropped.".into(),
                },
            ],
            Some(created_by),
        )
        .await?;
    repo.resolve_decision(
        d_pot.id,
        "rejected",
        Some("p2".into()),
        "Self-watering pots are a subscription to root rot with extra steps.",
        None,
    )
    .await?;

    repo.create_decision(
        project.id,
        Some(g_climb.id),
        "Moss pole or coconut husk pole?",
        "Gloria must be given a support structure before she leans into the next cubicle.",
        &[
            DecisionOption {
                id: "c1".into(),
                label: "Moss pole".into(),
                pros: "The classic; moss holds moisture for aerial roots.".into(),
                cons: "Classic is a polite word for 'what everyone has'.".into(),
            },
            DecisionOption {
                id: "c2".into(),
                label: "Coconut husk pole".into(),
                pros: "Rough texture, great grip, smells like a vacation.".into(),
                cons: "Sheds bits everywhere; the vacuum speaks to us now.".into(),
            },
        ],
        Some(created_by),
    )
    .await?;

    let e_talk = repo
        .create_experiment(
            project.id,
            Some(g_alive.id),
            Some(d_water.id),
            "Does encouragement actually grow leaves?",
            "Speaking kindly to Gloria for ten minutes a day increases leaf production.",
            Some(created_by),
        )
        .await?;
    repo.create_event(
        e_talk.id,
        "measurement",
        now_ms(),
        "Baseline: 12 leaves and a stare of quiet judgment.",
    )
    .await?;
    repo.create_event(
        e_talk.id,
        "observation",
        now_ms(),
        "Daily affirmations began. Gloria visibly unimpressed.",
    )
    .await?;
    repo.create_event(
        e_talk.id,
        "measurement",
        now_ms(),
        "Week six: still 12 leaves. One new aerial root, pointed directly away from us.",
    )
    .await?;
    repo.update_experiment(
        e_talk.id,
        "Does encouragement actually grow leaves?",
        "Speaking kindly to Gloria for ten minutes a day increases leaf production.",
        "done",
        "Leaf count unchanged across six weeks of peak positivity.",
        "Plants do not care about your feelings. Water is the only love language Gloria speaks.",
    )
    .await?;

    let e_window = repo
        .create_experiment(
            project.id,
            Some(g_climb.id),
            None,
            "The corner window vs the Desk of Mystery",
            "The corner window grows Gloria faster than the desk with the 'good vibes' lighting.",
            Some(created_by),
        )
        .await?;
    repo.create_event(
        e_window.id,
        "observation",
        now_ms(),
        "Gloria rotated 3° toward the window. Treated as a positive sign.",
    )
    .await?;
    repo.create_event(
        e_window.id,
        "milestone",
        now_ms(),
        "Week two: Gloria has committed to a lean.",
    )
    .await?;
    repo.update_experiment(
        e_window.id,
        "The corner window vs the Desk of Mystery",
        "The corner window grows Gloria faster than the desk with the 'good vibes' lighting.",
        "running",
        "",
        "",
    )
    .await?;

    let note = repo
        .create_note(
            project.id,
            "Gloria's care guide",
            "The definitive rules, learned the hard way:\n\n- Water when the soil is dry, not on a schedule. Gloria can smell a schedule.\n- Encouragement is a zero-calorie snack. She is not interested.\n- The moss pole is a suggestion, and she has not responded to suggestions.\n- The one true lesson: **water is the only love language**.",
            Some("experiment"),
            Some(e_talk.id),
            Some(created_by),
        )
        .await?;
    repo.create_link(
        project.id, "note", note.id, "decision", d_water.id, "supports",
    )
    .await?;
    repo.create_link(
        project.id,
        "experiment",
        e_talk.id,
        "decision",
        d_water.id,
        "follows",
    )
    .await?;

    Ok(())
}

/// The 11am queue has been declared a public health crisis. Our dignified
/// response is documented here: more coffee.
async fn seed_coffee_project(repo: &SqliteRepository, created_by: Uuid) -> anyhow::Result<()> {
    let project = repo
        .create_project(
            COFFEE_PROJECT,
            "The 11am queue has been declared a public health crisis. This project documents our dignified response: more coffee.",
            "paused",
            Some(created_by),
        )
        .await?;

    let g_queue = repo
        .create_goal(
            project.id,
            "Eliminate the 11am queue of despair",
            "Peak hour currently has a seven-minute wait. Unacceptable for people who are technically adults.",
            Some(created_by),
        )
        .await?;
    let g_budget = repo
        .create_goal(
            project.id,
            "Cut the monthly coffee budget by 15% without a riot",
            "The bean fund is leaking. The bean fund has feelings.",
            Some(created_by),
        )
        .await?;
    let g_second = repo
        .create_goal(
            project.id,
            "Put a second machine in the kitchen corner",
            "Dropped: the kitchen corner is load-bearing, emotionally.",
            Some(created_by),
        )
        .await?;
    finish_goal(repo, &g_queue, "done").await?;
    finish_goal(repo, &g_second, "dropped").await?;

    let d_machine = repo
        .create_decision(
            project.id,
            Some(g_queue.id),
            "Bean-to-cup machine or drip plus a serious grinder?",
            "The leadership office has a 'compact espresso solution'. Nobody knows what that means.",
            &[
                DecisionOption {
                    id: "m1".into(),
                    label: "Bean-to-cup machine".into(),
                    pros: "Fancy, one button, smells expensive.".into(),
                    cons: "Priced like a small car; cleans itself only in theory.".into(),
                },
                DecisionOption {
                    id: "m2".into(),
                    label: "Drip + a grinder that means business".into(),
                    pros: "Cheaper, repairable, predictable.".into(),
                    cons: "Two devices to maintain; minor barista-envy in leadership.".into(),
                },
            ],
            Some(created_by),
        )
        .await?;
    repo.resolve_decision(
        d_machine.id,
        "decided",
        Some("m2".into()),
        "Nobody has ever told the grinder to 'hurry up', and that's the standard we hold appliances to.",
        None,
    )
    .await?;

    let d_lever = repo
        .create_decision(
            project.id,
            Some(g_queue.id),
            "The lever espresso machine?",
            "It is very cool. That is the entire argument.",
            &[
                DecisionOption {
                    id: "l1".into(),
                    label: "Buy it, it's cool".into(),
                    pros: "It is extremely cool.".into(),
                    cons: "Maintenance manual is in Italian. We do not speak Italian. It broke the maintenance guy's spirit.".into(),
                },
                DecisionOption {
                    id: "l2".into(),
                    label: "Respectfully decline".into(),
                    pros: "Everyone keeps their spirit.".into(),
                    cons: "We will never know true coolness.".into(),
                },
            ],
            Some(created_by),
        )
        .await?;
    repo.resolve_decision(
        d_lever.id,
        "rejected",
        Some("l2".into()),
        "The lever is a signature move, and we do not have the arms.",
        None,
    )
    .await?;

    let d_strong = repo
        .create_decision(
            project.id,
            Some(g_budget.id),
            "Stronger coffee at +10% beans: yes or extremely yes?",
            "The budget says 'no'. The queue says otherwise. The queue has the higher ground.",
            &[
                DecisionOption {
                    id: "s1".into(),
                    label: "Yes".into(),
                    pros: "Might buy us twenty calm minutes.".into(),
                    cons: "It is a different line item.".into(),
                },
                DecisionOption {
                    id: "s2".into(),
                    label: "Extremely yes".into(),
                    pros: "Somebody finally fixes the queue.".into(),
                    cons: "The bean fund files a complaint.".into(),
                },
            ],
            Some(created_by),
        )
        .await?;

    let e_queue = repo
        .create_experiment(
            project.id,
            Some(g_queue.id),
            Some(d_machine.id),
            "Measure the queue (and the despair)",
            "The 11am queue is a measurable function of bean throughput.",
            Some(created_by),
        )
        .await?;
    repo.create_event(
        e_queue.id,
        "measurement",
        now_ms(),
        "Monday 10:30 — 47 cups in 40 minutes; six people pretending to read emails near the machine.",
    )
    .await?;
    repo.create_event(
        e_queue.id,
        "observation",
        now_ms(),
        "Dave re-queued with a thermos. A thermos, Dave.",
    )
    .await?;
    repo.create_event(
        e_queue.id,
        "measurement",
        now_ms(),
        "Friday 11:00 — queue dissolved after maintenance gave the machine a stern look.",
    )
    .await?;
    repo.update_experiment(
        e_queue.id,
        "Measure the queue (and the despair)",
        "The 11am queue is a measurable function of bean throughput.",
        "done",
        "Confirmed: peak demand is real. The bottleneck is morale, not water pressure.",
        "Buy the second machine. You cannot fix a morale problem with stronger beans, but you can delay it by twenty minutes.",
    )
    .await?;

    repo.create_experiment(
        project.id,
        Some(g_budget.id),
        Some(d_strong.id),
        "The 10% stronger beans experiment",
        "Nobody will notice a 10% strength increase. Dave will.",
        Some(created_by),
    )
    .await?;

    let note = repo
        .create_note(
            project.id,
            "The three types of office coffee drinker",
            "Field notes from the queue:\n\n- **The Siphon**: has a dedicated mug and a backup mug.\n- **The Purist**: black, silent, deeply suspicious of oat milk.\n- **Dave**: thermos, returns, judgment.",
            Some("experiment"),
            Some(e_queue.id),
            Some(created_by),
        )
        .await?;
    let letter = repo
        .create_note(
            project.id,
            "An open letter to whoever left the grounds in the sink",
            "Dear whoever,\n\nThe grounds are not a garnish. The sink is not a compost bin. The intern who fished them out is on their third cup and cannot be reached.\n\nWe stand by the sink.",
            None,
            None,
            Some(created_by),
        )
        .await?;
    repo.create_link(
        project.id,
        "note",
        note.id,
        "experiment",
        e_queue.id,
        "follows",
    )
    .await?;
    repo.create_link(
        project.id,
        "note",
        letter.id,
        "decision",
        d_machine.id,
        "related",
    )
    .await?;
    repo.create_link(
        project.id,
        "experiment",
        e_queue.id,
        "decision",
        d_machine.id,
        "supports",
    )
    .await?;

    Ok(())
}
