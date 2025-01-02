# Spira-Azure OpenAI Integration Architecture

```mermaid
flowchart TD
    subgraph Spira["SpiraPlan"]
        SpiraUI["SpiraApp UI Components"]
        SpiraAdmin["SpiraApp Admin Settings"]
        SpiraAPI["Spira REST API"]
    end

    subgraph AzureCloud["Azure Cloud"]
        subgraph AOAI["Azure OpenAI Service"]
            GPT4["GPT-4o-mini Model"]
            Prompts["System Prompts"]
        end
    end

    subgraph DataFlow["Data & Interaction Flow"]
        ReqGen["Generate Requirements"]
        TestGen["Generate Test Cases"]
        TaskGen["Generate Tasks"]
        RiskGen["Generate Risks"]
        BDDGen["Generate BDD Scenarios"]
    end

    SpiraUI --> |"User triggers\ngeneration"| DataFlow
    SpiraAdmin --> |"Configuration\n& API Keys"| AOAI
    DataFlow --> |"API Calls"| SpiraAPI
    SpiraAPI --> |"HTTP/REST"| AOAI
    AOAI --> |"Process\nRequests"| GPT4
    GPT4 --> |"Use Custom\nPrompts"| Prompts
    Prompts --> |"Generate\nContent"| GPT4
    GPT4 --> |"Return\nResults"| SpiraAPI
    SpiraAPI --> |"Create/Update\nArtifacts"| SpiraUI

    style Spira fill:#86BC25,color:#fff
    style AzureCloud fill:#0078D4,color:#fff
    style AOAI fill:#19C6FF,color:#000
    style DataFlow fill:#FFB900,color:#000
