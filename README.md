# BizTrip screener agent

An little exercise in building a natural language agent to perform "recruitment screening" tasks.

Currently uses `Claude` for its LLM.

## Running locally

set `ANTHROPIC_API_KEY` in our env. 

Then:

    uv venv
    source .venv/bin/activate
    uv pip install -r requirements.txt

    ./start.sh

## How it works

This is a basic ReAct agent. Virtually everything is in the [system prompt](./screener/recruiting_agent.py).

A few interesting bits:

- Background info on the BizTrip company is loaded into the agent's context at startup. This allows the agent
to answer questions about the company. The info also includes job descriptions so the agent knows what it 
is looking for generally in candidates.

- Tactical and behavioral questions are included in the prompt, but as "things you may want to ask about".

- The agent is instructed to "have a back-and-forth conversation with the candidate". So rather than a typical
customer service script, the agent tries to engage in a conversation, and the user is free to ask questions
at any point in the process.

- The agent has functions for recording responses and _reflections_ as the conversation is ongoing.

```
"Sally S","Initial contact and background","Candidate corrected their name to Sally S."
"Sally S","Interest in company staff and location","Candidate asked about BizTrip staff composition, showing interest in the team structure."
"Sally S","Why work at BizTrip and candidate priorities","Candidate asked about value proposition of working at BizTrip, showing interest in company benefits and culture."
"Sally S",reflection:,"Candidate seems to be evaluating company value proposition carefully, suggesting they're actively job searching and comparing options. They're direct in their communication style."
```

