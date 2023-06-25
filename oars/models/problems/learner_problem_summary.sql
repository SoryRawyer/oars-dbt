-- summary table for a learner's performance on and interactions with a
-- particular problem
with summary as (
    select
        org,
        course_id,
        problem_id,
        actor_id,
        success,
        attempts,
        0 as num_hints_displayed,
        0 as num_answers_displayed
    from {{ ref('problem_results') }}
    union all
    select
        org,
        course_id,
        problem_id,
        actor_id,
        null as success,
        null as attempts,
        case help_type
            when 'hint' then 1
            else 0
        end as num_hints_displayed,
        case help_type
            when 'answer' then 1
            else 0
        end as num_answers_displayed
    from {{ ref('problem_hints') }}
)

-- n.b.: there should only be one row per org, course, problem, and actor
-- in problem_results, so any(success) and any(attempts) should return the
-- values from that part of the union and not the null values used as
-- placeholders in the problem_hints part of the union
select
    org,
    course_id,
    problem_id,
    actor_id,
    coalesce(any(success), false) as success,
    coalesce(any(attempts), 0) as attempts,
    sum(num_hints_displayed) as num_hints_displayed,
    sum(num_answers_displayed) as num_answers_displayed
from
    summary
group by
    org,
    course_id,
    problem_id,
    actor_id
