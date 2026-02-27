# Developer Prompt: Team Insights & Perception Gap Analysis

**Objective:** Expand the DevOps Maturity Assessment Platform to support its primary goal: acting as a "cultural value stream map" and longitudinal alignment tool. The tool must allow grouping of individual self-assessments by project/team and generate statistical reports that highlight perception gaps (areas of concern) and areas of consensus (areas of praise). Crucially, the tool must also track these metrics **over time** (e.g., establishing a baseline before a DevOps engineer embeds with a team, and measuring improvements in alignment as time passes).

Please implement the following architectural, database, and UI changes to achieve this.

---

## 1. Database Model Updates

Currently, [backend/app/models.py](file:///home/jim/devops-maturity-model/backend/app/models.py) uses a simple `team_name` string on the [Assessment](file:///home/jim/devops-maturity-model/backend/app/models.py#150-178) model. To enable reliable grouping and statistical analysis, we need stricter relational mapping and flexible tagging.

**Actions Required:**

1. **Create a `Project` (or `Team`) Model:**
   - Add a new model that links to [Organization](file:///home/jim/devops-maturity-model/backend/app/models.py#39-54).
   - Fields: `id`, `organization_id`, `name`, `description`.
   - Update [Assessment](file:///home/jim/devops-maturity-model/backend/app/models.py#150-178) to include `project_id` (ForeignKey) instead of or in addition to the raw `team_name` string.

2. **Add Tagging Support:**
   - Add a `tags` column to the [Assessment](file:///home/jim/devops-maturity-model/backend/app/models.py#150-178) model using `ARRAY(String)`.
   - This allows users to tag an assessment with metadata (e.g., `["Q3-2025", "frontend-guild", "migration-project"]`) for ad-hoc grouping.

3. **Demographic/Role Context:**
   - Ensure the [Assessment](file:///home/jim/devops-maturity-model/backend/app/models.py#150-178) or [User](file:///home/jim/devops-maturity-model/backend/app/models.py#56-75) model captures the person's functional role (e.g., "Developer", "QA", "Security", "Ops") to help contextualize the perception gaps in the reports.

4. **Assessment Campaigns/Batches:**
   - Add a `campaign_id` or `batch_identifier` to the [Assessment](file:///home/jim/devops-maturity-model/backend/app/models.py#150-178) model (or establish a date-based grouping query).
   - This enables comparing a "Baseline" assessment round (e.g., before embedding a DevOps engineer) against "Follow-up" rounds (e.g., 3 months later).

---

## 2. Statistical Analysis Engine (Backend Endpoints)

Create a new analytics endpoint (e.g., `GET /api/analytics/projects/{project_id}/insights`) that aggregates all completed assessments for a specific project/team.

**Algorithm Requirements:**

For a given group of assessments (filtered by `project_id` or specific `tags`):
1. **Aggregate Responses:** For every question in the framework, gather all `GateResponse.score` values submitted by the individual team members.
2. **Calculate Mean (Average):** Calculate the average score for each question to determine overall perceived maturity.
3. **Calculate Variance / Standard Deviation:** Calculate the spread of the scores. This is the **most critical metric**.

**Categorization Logic:**
- **Area of Concern (Disconnects):** Questions with high variance (e.g., standard deviation > 1.5). This indicates a major perception gap (e.g., Ops voted 1, Dev voted 5).
- **Area of Praise (Consensus Strength):** Questions with high mean (e.g., > 4.0) AND low variance (e.g., standard deviation < 0.8). Everyone agrees the team is doing this well.
- **Area of Universal Need (Consensus Weakness):** Questions with low mean (e.g., < 2.0) AND low variance. Everyone agrees the team is struggling here.

**Longitudinal Comparison:**
- Create an endpoint specifically for comparing two assessment batches (e.g., `GET /api/analytics/projects/{project_id}/trends?baseline=uuid1&current=uuid2`).
- The logic must return the **delta** in both mean score and variance. The goal is to see variance *decrease* over time as the embedded DevOps engineer helps the team communicate and align.

**Endpoint Response Payload Example:**
```json
{
  "project_name": "Core Banking API",
  "assessment_count": 8,
  "insights": {
    "perception_gaps": [
      {
        "question_id": "uuid",
        "question_text": "How easily can team members access information?",
        "mean_score": 3.0,
        "variance": 2.1,
        "score_distribution": {"Dev": 4, "Ops": 1, "QA": 4} 
      }
    ],
    "areas_of_praise": [
      {
        "question_id": "uuid",
        "question_text": "Does executive leadership actively support transformation?",
        "mean_score": 4.5,
        "variance": 0.4
      }
    ]
  }
}
```

---

## 3. Frontend UI Updates

Build a new **"Team Insights Dashboard"** that consumes the new analytics endpoint.

**UI Elements to Build:**

1. **Grouping/Filtering Toolbar:**
   - Allow users (Scrum Masters, Agile Coaches, Managers) to select a Project, Team, or specific Tags to generate a report.

2. **The "Perception Gap" Visualizer:**
   - Do not just show bar charts of averages.
   - Use **Box-and-Whisker plots** or **Dot plots** for each question. This visually demonstrates the spread of answers. A wide spread is a discussion starter.
   - Highlight the top 3 high-variance questions in a dedicated "Discussion Starters" alert box.

3. **Role-Based Heatmap:**
   - Create a table where rows are Questions and columns are Roles (Dev, Sec, Ops, QA). 
   - Color code the cells by average score from that role. This will instantly highlight if the "Security" column is starkly red while the "Dev" column is heavily green.

4. **Longitudinal Trend Visualizer:**
   - Build a timeline view (e.g., dual line charts or sparklines) comparing "Baseline Assessment" to "Current Assessment."
   - Specifically chart the **Variance Trend**: visually celebrate when a high-disconnect question from 3 months ago has converged into a low-variance consensus today. This proves the embedded engineer effectively drove team alignment.

5. **Export to Presentation:**
   - Ensure these specific visualizers (especially the top disconnects and alignment improvements) can be easily exported to PDF or copied to the clipboard to be pasted into a Retrospective deck.
