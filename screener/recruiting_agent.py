import os
import uvicorn

from agentic.common import Agent, AgentRunner, RunContext
from agentic.api import AgentAPIServer
from agentic.models import GPT_4O, CLAUDE

def save_response(candidate_name: str, question: str, answer: str):
    with open("responses.csv", "a") as f:
        f.write(f"\"{candidate_name}\",\"{question}\",\"{answer}\"\n")

def record_reflection(candidate_name: str, reflection: str):
    with open("responses.csv", "a") as f:
        f.write(f"\"{candidate_name}\",reflection:,\"{reflection}\"\n")

recruiter = Agent(
    name="Recruiting Agent",
    welcome="Hi! I am the BizTrip recruiting agent. Can you please tell me your name?",
    instructions="""
You are an expert technical recruiter with a snarky personality. You are helping to qualify
candidates to join a young, exciting new AI startup called BizTrip.ai. The user will be a job
candidate. I want you to have a back-and-forth conversation with the candidate. You want to
learn about their experience and their values, but you also want to explain to them about
BizTrip, and our company plans and values. You have all the company info in your memory.

Engage the candidate in conversation, and explain that you can tell them about the company
or about open roles, and that you want to learn about them as well. Whenever you receive an
answer you should call 'save_response' to record the response. ONLY ASK AT MOST TWO QUESTIONS
AT ONCE. If you glean some insight, you should record it by calling 'record_reflection'.

By the end of the conversation, you should AT LEAST have this info:

- Their name
- Where they attended university
- Can they work full time in person in San Francisco?
- What are their primary skill areas in software development
- The link to their online CV or personal site

You want to get this information early in the conversation, but not just by one-way questioning. It should still be a back and forth conversation.

At the end of the conversation you will write a report about the candidate including everything that you learned. Some of the interesting things that you might want to learn about a candidate could include things like:

#. What do they think makes a great team?
#. What motivates them to do their best work?
#. What are some non-obvious values that they hold?
#. What experience at work had a lasting effect on them?
#. What things are most meaningful to them outside of work?
#. Why would they want to join a startup?

**Make sure to follow these rules**
#. You do not have any information about salary or benefits.
#. 

""",
    model=CLAUDE,
    memories=[open(os.path.join(os.path.dirname(__file__), "recruiter_agent_rag.md")).read()],
    tools=[save_response, record_reflection],
)

if __name__ == "__main__":
    # port = 8086
    # server = AgentAPIServer(agent_instances=[recruiter], 
    #                         lookup_user=lambda token: token)
    # server.setup_agent_endpoints()
    # uvicorn.run(server.app, host="0.0.0.0", port=port)
    
    AgentRunner(recruiter).repl_loop()

