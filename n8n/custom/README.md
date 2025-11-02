# Custom n8n Python Scripts

This directory is for custom Python scripts that can be used within n8n workflows.

## Usage

Place your Python scripts here and they will be available to n8n via the Python node.

## Example Script

Create a file `example_ai_agent.py`:

```python
#!/usr/bin/env python3
"""
Example AI Agent using CrewAI and LangChain
"""

from crewai import Agent, Task, Crew
from langchain_openai import ChatOpenAI
import os

def create_research_agent():
    """Create a research agent using CrewAI"""
    
    llm = ChatOpenAI(
        model="gpt-4",
        api_key=os.getenv("OPENAI_API_KEY")
    )
    
    researcher = Agent(
        role='Research Analyst',
        goal='Conduct thorough research on given topics',
        backstory='Expert analyst with deep research skills',
        llm=llm,
        verbose=True
    )
    
    return researcher

def run_research(topic):
    """Run research on a topic"""
    
    agent = create_research_agent()
    
    task = Task(
        description=f'Research the following topic: {topic}',
        agent=agent,
        expected_output='Detailed research report'
    )
    
    crew = Crew(
        agents=[agent],
        tasks=[task],
        verbose=True
    )
    
    result = crew.kickoff()
    return result

if __name__ == "__main__":
    import sys
    topic = sys.argv[1] if len(sys.argv) > 1 else "AI trends in 2024"
    result = run_research(topic)
    print(result)
```

## Using in n8n

1. Add a "Execute Command" node
2. Set command to: `python /home/node/.n8n/custom/example_ai_agent.py "Your topic"`
3. Or use the "Python" node and import your scripts

## Available Libraries

The following Python libraries are pre-installed:

- `langchain` - LLM application framework
- `crewai` - Multi-agent framework
- `openai` - OpenAI API client
- `anthropic` - Anthropic Claude API client
- `supabase` - Supabase client
- `pandas` - Data manipulation
- `requests` - HTTP library
- `beautifulsoup4` - Web scraping

See Dockerfile for complete list.

## Environment Variables

All environment variables from docker-compose.yml are available:
- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `SUPABASE_URL`
- `SUPABASE_SERVICE_KEY`
- etc.

## Best Practices

1. Add proper error handling
2. Log important events
3. Use environment variables for secrets
4. Document your scripts
5. Test locally before deploying
