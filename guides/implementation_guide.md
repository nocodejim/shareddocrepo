# SharePoint Trivia Game - Quick Implementation Guide

## Day 1: SharePoint Setup (2-3 hours)

### Step 1: Run PowerShell Setup
1. Open PowerShell as Administrator
2. Install PnP PowerShell: `Install-Module -Name PnP.PowerShell -Force`
3. Update the `$SiteUrl` in the script with your SharePoint site
4. Run the SharePoint setup script
5. Verify all lists were created in your SharePoint site

### Step 2: Set Permissions
```powershell
# After connecting to your site
Set-PnPListPermission -Identity "Players" -User "Everyone" -AddRole "Contribute"
Set-PnPListPermission -Identity "QuestionResponses" -User "Everyone" -AddRole "Contribute"
Set-PnPListPermission -Identity "TriviaQuestions" -User "HostGroup" -AddRole "Full Control"
```

## Day 2: Power Automate Flows (1-2 hours)

### Flow 1: Score Calculator
1. Go to Power Automate → Create → Automated cloud flow
2. Trigger: "When an item is created" → Select QuestionResponses list
3. Add condition: `IsCorrect equals true`
4. Add action: Get items from Players list where PlayerName = trigger PlayerName
5. Add action: Update item in Players list, Score = CurrentScore + 1

### Flow 2: Session Controller (for host)
1. Create → Instant cloud flow
2. Add text input: "SessionCode"
3. Add number input: "Action" (1=Next Question, 2=End Game, 3=Start Game)
4. Add condition based on Action
5. Update GameSessions list accordingly

## Day 3: User Interface (2-3 hours)

### Option A: SharePoint Web Part (Recommended)
1. Go to your SharePoint site
2. Add new page → "Trivia Game"
3. Add web part → Embed
4. Paste the Player Interface HTML
5. Update SharePoint API endpoints in JavaScript

### Option B: Teams App
1. Create new Teams app in App Studio
2. Upload HTML as a tab
3. Configure for your channel

### Option C: Standalone Page
1. Save HTML file to SharePoint document library
2. Share link with participants
3. Host controls game from separate admin page

## Day 4: Testing & Go-Live

### Pre-Game Setup Checklist:
- [ ] Add your trivia questions to TriviaQuestions list
- [ ] Create game session using PowerShell helper function
- [ ] Test with 2-3 people
- [ ] Verify scoring works
- [ ] Check leaderboard updates

## Quick Start Commands

### Create a New Game Session:
```powershell
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/YourSite" -Interactive
$sessionCode = New-TriviaSession -SessionName "Monday Meeting Trivia" -HostEmail "you@company.com" -TotalQuestions 5
Write-Host "Game Code: $sessionCode"
```

### Add Questions Quickly:
```powershell
$questions = @(
    @{Question="What does API stand for?"; AnswerA="Application Programming Interface"; AnswerB="Automated Program Integration"; AnswerC="Advanced Protocol Implementation"; CorrectAnswer="A"; Category="Tech"},
    @{Question="Which company owns LinkedIn?"; AnswerA="Google"; AnswerB="Microsoft"; AnswerC="Meta"; CorrectAnswer="B"; Category="Business"}
)
foreach($q in $questions) { Add-PnPListItem -List "TriviaQuestions" -Values $q }
```

## Host Instructions (Game Day):

1. **Before the meeting:**
   - Run the session creation script
   - Share the 6-digit game code
   - Have participants navigate to your trivia page

2. **During the game:**
   - Manually update GameSessions → CurrentQuestion to advance
   - Set Status to "Active" to start
   - Monitor real-time leaderboard in Players list

3. **Game flow:**
   - Players join using code
   - You start game (update status)
   - Questions advance automatically via Power Automate
   - Scores update automatically
   - View final leaderboard at end

## Troubleshooting:

### Common Issues:
- **Players can't join:** Check SharePoint permissions on Players list
- **Scores not updating:** Verify Power Automate flow is running
- **Real-time updates slow:** SharePoint list views refresh every 30 seconds

### Quick Fixes:
- Refresh SharePoint pages to see updates
- Use Teams notifications for faster updates
- Have backup manual scoring in Excel

## Alternative: Simplified Manual Version

If automation isn't working perfectly:

1. Use the HTML interface for questions/answers
2. Host manually advances questions
3. Use SharePoint Players list view sorted by Score for leaderboard
4. Manually update scores if needed

## Extensions for Next Time:

- Add Teams bot for notifications
- Create Power BI dashboard for analytics
- Add multimedia questions (images/videos)
- Implement timer synchronization
- Add team-based scoring

---

**Total setup time: 6-8 hours spread over 3-4 days**  
**Complexity: Medium (with PowerShell automation)**  
**Reliability: High (SharePoint/O365 infrastructure)**