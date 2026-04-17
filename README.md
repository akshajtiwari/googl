# This branch is for the development of the Admin website
## NGO Coordinator Admin Website — Frontend Functionalities

---

### 1. Dashboard & Overview
- Summary cards (total volunteers, active tasks, pending needs, coverage %)
- Real-time activity feed (recent assignments, new reports, volunteer check-ins)
- Alerts/notifications panel (urgent unmet needs, low volunteer coverage zones)
- Quick-action buttons (assign volunteer, add task, upload report)

---

### 2. Heatmap & Geospatial Visualization
- Interactive heatmap of community needs by area/locality
- Toggle layers — need type (food, medical, shelter, education, etc.)
- Volunteer coverage overlay (where volunteers are vs where needs are)
- Underserved zone highlighting
- Zoom to ward/block/district level
- Time-filter (view need density over past week/month)
- Click on zone → see need breakdown + assigned volunteers for that area

---

### 3. Data Ingestion & Report Management
- View all reports submitted by volunteers (source, date, area tags)
- Data parsing status per report (processed / pending / failed)
- Duplicate entry detection flag
- Export compiled data as CSV/PDF
- Filter reports by date, area, type, or volunteer

---

### 4. Needs Management
- List of all identified community needs with severity tags (critical / moderate / low)
- Filter by type, area, status (open / in-progress / resolved)
- Create a new need entry manually
- Edit / close / escalate a need
- Assign a need directly to a volunteer or team from this view
- Need detail page — full description, source report, history, assigned volunteers

---

### 5. Volunteer Management
- Add new volunteer (name, contact, skills, availability, location)
- View all volunteers in a table/list with status (active / inactive / on-task)
- Volunteer profile page
  - Personal info & contact
  - Skills & certifications
  - Availability schedule
  - Assignment history
  - Performance stats (tasks completed, hours logged, areas covered)
  - Documents/ID verification status
- Edit volunteer details
- Deactivate / remove volunteer
- Bulk import volunteers via CSV

---

### 6. Assignment & Matching
- Smart match suggestions — system recommends best volunteer for a need based on skill, location proximity, availability
- Manual assignment override
- Assign single volunteer or a team to a task
- View currently assigned volunteers per task
- Reassign or unassign with reason logging
- Assignment timeline view (who is doing what, when)

---

### 7. Task Management
- Create tasks linked to specific needs and areas
- Task detail — description, location, required skills, deadline, priority
- Task status tracking (open → assigned → in-progress → completed → verified)
- Coordinator can mark tasks verified after volunteer completion
- Task history log

---

### 8. Volunteer Availability & Scheduling
- Calendar view of volunteer availability across the team
- See who is free on a given date/time for quick assignment
- Shift scheduling for recurring tasks
- Conflict detection (volunteer already assigned elsewhere)

---

### 9. Analytics & Reporting
- Needs resolved over time (line/bar charts)
- Volunteer utilization rate
- Average response time (need reported → volunteer assigned)
- Top contributing volunteers leaderboard
- Area-wise impact summary
- Exportable reports (PDF / Excel) for donor/stakeholder presentations

---

### 10. Communication
- Broadcast announcements to all or selected volunteers
- Send targeted message to a specific volunteer
- Notification templates (assignment alert, task update, urgent callout)
- In-app message log / history

---

### 11. Settings & Configuration
- Manage need categories and tags
- Manage skill categories for volunteers
- Set alert thresholds (e.g., alert if zone has 10+ unmet needs)
- User roles & permissions (super admin, regional coordinator, viewer)
- Manage coordinator accounts
