This repository showcases Agentic AI development in Power BI.

# 🔍 What is Agentic Development?

Agentic development is a new paradigm where developers shift from writing code or using UI applications to guiding intelligent agents. The developer defines the what - the requirements, rules, and intent - and the AI agent handles the how - generating specs, implementing the model, running validations, fixing issues, and iterating toward a working solution. 

You can achieve agentic development in Power BI combining the following features:
- Open file formats with [Power BI Project file format (PBIP)](https://learn.microsoft.com/power-bi/developer/projects/projects-overview) with [TMDL language](https://learn.microsoft.com/analysis-services/tmdl/tmdl-overview) and [Power BI enhanced Report format (PBIR)](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-report?tabs=v2%2Cdesktop). 
- MCP Server [powerbi-modeling-mcp](https://github.com/microsoft/powerbi-modeling-mcp)


>[!IMPORTANT]
>**powerbi-modeling-mcp** is currently in private preview. If you're interested in trying it out, you can sign up [here](https://forms.office.com/r/0MXYd6uzwE).

▶️End-to-End demo: [LinkedIn post & video](https://www.linkedin.com/feed/update/urn:li:activity:7347917906363518977/?commentUrn=urn%3Ali%3Acomment%3A(ugcPost%3A7347917694953754625%2C7348260275357204482)&dashCommentUrn=urn%3Ali%3Afsd_comment%3A(7348260275357204482%2Curn%3Ali%3AugcPost%3A7347917694953754625)))

See the branch [final](https://github.com/RuiRomano/pbip-demo-agentic-mcp/tree/final) to inspect the final output.

# ⚙️ How does it work?

1. Create a high-level requirement docs, similar to [requirements.md](.input/requirements.md).
2. Prompt AI agent to create a new semantic model but create a spec before implementation. [prompt example](.input/prompt.md). Give it context about your Power BI development style.
3. AI creates a development spec – readable, reviewable, and adjustable.
4. You review the spec, and when OK. Just say **GO** and the agent starts implementing the spec autonomously.
5. You can ground the development with Best Pratice Analysis (see [.bpa/](.bpa/)). And autonomously fixes issues and iterated until there are no issues.
6. You open the Power BI application and review the result, just like you would with a teammate’s pull request.

>[!IMPORTANT]
>Its very important to provide AI knowledge/context about your Power BI development style and Power BI concepts such as PBIP structure. See [.kb/ folder](.kb/).

# 🧪 Try it yourself

1. Clone this Repo into your laptop
2. Install [Visual Studio Code](https://code.visualstudio.com/)
3. Install [GitHub Copilot extension](https://docs.github.com/en/copilot/responsible-use-of-github-copilot-features/responsible-use-of-github-copilot-chat-in-your-ide?tool=vscode)
4. Open Github Copilot Chat in [Agent mode](https://code.visualstudio.com/blogs/2025/02/24/introducing-copilot-agent-mode)
5. Copy and paste the [prompt](.input/prompt.md) into the chat.
6. Review the generated development spec, then prompt Copilot to proceed with implementing the semantic model.

