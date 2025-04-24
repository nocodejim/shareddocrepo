# Cape Certificate Expired Process Value Stream Map

This diagram represents the value stream map for the Cape Certificate Expired Process, showing the sequence of activities with process times and wait times.

```mermaid
flowchart LR
    A("Automated Email
    11:27 AM
    PT: 0 min") --> B("Manual Email
    Forward
    11:45 AM
    PT: 5 min")
    B --> C("Manual Email
    Response
    12:11 PM
    PT: 10 min")
    C --> D("Work Order
    Manager App
    12:33 PM
    PT: 5 min")
    D --> E("ISO Resource
    Pulled Certs
    12:37 PM
    PT: 15 min")
    E --> F("API Construct
    Completed
    12:39 PM
    PT: 10 min")
    F --> G("CRQ Created
    2:32 PM
    PT: 10 min")
    G --> H("Task 1
    ISO/API
    2:42 PM
    PT: 4 min")
    H --> I("Task 2
    Testing/Dev
    2:46 PM
    PT: 5 min")
    I --> J("Planning/
    Staging
    3:25 PM
    PT: 1 min")
    J --> K("Manager
    Approval
    3:26 PM
    PT: 1 min")
    K --> L("Assigned
    ToDo
    3:27 PM
    PT: 2 min")
    L --> M("SMS/SRA
    Approval
    3:29 PM
    PT: 9 min")
    M --> N("Implementation
    in Progress
    3:38 PM
    PT: 38 min")
    N --> O("Final Review
    Complete
    4:16 PM
    PT: 15 min")
    O --> P("CRQ Closed
    8:24 AM
    next day
    PT: 5 min")
    
    A1["LT: 18 min"] -.- B
    B1["LT: 21 min"] -.- C
    C1["LT: 12 min"] -.- D
    D1["LT: 4 min"] -.- E
    E1["LT: 2 min"] -.- F
    F1["LT: 113 min"] -.- G
    G1["LT: 10 min"] -.- H
    H1["LT: 0 min"] -.- I
    I1["LT: 34 min"] -.- J
    J1["LT: 0 min"] -.- K
    K1["LT: 0 min"] -.- L
    L1["LT: 0 min"] -.- M
    M1["LT: 0 min"] -.- N
    N1["LT: 0 min"] -.- O
    O1["LT: 968 min"] -.- P
    
    classDef process fill:#d4f1f9,stroke:#333,stroke-width:1px;
    classDef leadtime fill:#f5f5f5,stroke:#666,stroke-width:1px,stroke-dasharray: 5 5;
    
    class A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P process;
    class A1,B1,C1,D1,E1,F1,G1,H1,I1,J1,K1,L1,M1,N1,O1 leadtime;

    subgraph metrics["Process Metrics"]
        TotalPT["Total Process Time: 135 min"]
        TotalLT["Total Wait Time: 1182 min"]
        Ratio["Value-Add Ratio: 10.2%"]
    end
```

## Value Stream Map Analysis

### Key Process Steps:
1. **Initial Notification (11:27 AM - 12:33 PM)**
   - Automated email triggers the process
   - Manual email handling and work order creation

2. **Technical Work (12:37 PM - 12:39 PM)**
   - ISO resource pulls certificates
   - API construction completed

3. **Change Request Processing (2:32 PM - 3:29 PM)**
   - CRQ creation and task assignments
   - Planning, manager approval, and notifications

4. **Implementation & Review (3:38 PM - 4:16 PM)**
   - Implementation work
   - Final review by development team

5. **Closure (8:24 AM next day)**
   - CRQ formally closed

### Waiting Time Analysis:
- **Major Wait Times:**
  - Overnight wait (968 min): Final review to CRQ closure
  - Mid-day gap (113 min): API construction to CRQ creation
  - Email handling delays (21 min): Between email forwards and responses

- **Efficiency Metrics:**
  - Total Process Time: 135 minutes of actual work
  - Total Wait Time: 1182 minutes of non-value-adding time
  - Value-Add Ratio: Only 10.2% of total time adds value

### Improvement Opportunities:
1. Investigate the 113-minute gap between API construction and CRQ creation
2. Evaluate if overnight wait for CRQ closure is necessary or could be expedited
3. Look for automation opportunities in the email notification and forwarding steps
4. Examine continuous flow possibilities for the afternoon implementation phases