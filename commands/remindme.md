- write an aggent log summarization subagent that emphasises consistent structure and tracking changes in key files like claude.md
- in galph, use wc character count (not lines) to decide whether fix_plan housekeeping is needed
- 'evidence only' behavior mode is still propagating to ralph. this i swrong. ralph should at least be able to write one off scripts (maybe also tests) when in that mode
- add a repomix review prompt / sub-prompt to the galph / ralph workflow
- galph / ralph treat codebase as too much of a black box. need a tracing / call chain following prompt / subagent that steps through the codebase from every relevant entry point and returns findings in a standard format 
- try https://github.com/pchalasani/claude-code-tools/tree/main?tab=readme-ov-file#tmux-cli-bridging-claude-code-and-interactive-clis
- "I give an outline of what I want to do, and give some breadcrumbs for any relevant existing files that are related in some way, ask it to figure out context for my change and to write up a summary of the full scope of the change we're making, including an index of file paths to all relevant files with a very concise blurb about what each file does/contains, and then also to produce a step-by-step plan at the end. I generally always have to tell it to NOT think about this like a traditional engineering team plan, this is a senior engineer and LLM code agent working together, think only about technical architecture, otherwise you get "phase 1 (1-2 weeks), phase 2 (2-4 weeks), step a (4-8 hours)" sort of nonsense timelines in your plan. Then I review the steps myself to make sure they are coherent and make sense, and I poke and prod the LLM to fix anything that seems weird, either fixing context or directions or whatever. Then I feed the entire document to another clean context window (or two or three) and ask it to "evaluate this plan for cohesiveness and coherency, tell me if it's ready for engineering or if there's anything underspecified or unclear" and iterate on that like 1-3 times until I run a fresh context window and it says "This plan looks great, it's well crafted, organized, etc...." and doesn't give feedback. Then I go to a fresh context window and tell it "Review the document @MY_PLAN.md thoroughly and begin implementation of step 1, stop after step 1 before doing step 2" and I start working through the steps with it.

"
- emph: always have to tell it to NOT think about this like a traditional engineering team plan, this is a senior engineer and LLM code agent working together, think only about technical architecture, otherwise you get "phase 1 (1-2 weeks), phase 2 (2-4 weeks), step a (4-8 hours)" sort of nonsense timelines in your plan.
- context7 mcp
- review https://news.ycombinator.com/item?id=45107962
- https://github.com/wshobson/commands/
- git@github.com:wshobson/agents.git
- improve the rd and implementation plan with things like data flow analysis, component interface definitions, basically better specs / understanding of the existing and new components and how they interact 
- think about whether to reintroduce idls. 
- standardize dir structure with subdirs for things like session 
  histories. need better conventions when each type of doc is saved to and 
  accessed, and what to keep under version control, and what to include in 
  repomix bundles
- write a validate-plan-gemini command (long running webui sesssions etc
- add a spec generation step to the initiative workflow, something like <this>
- close the loop with linting and unit tests
- zen mcp
- try alternate planning structures, such as: 
  - https://github.com/acoliver/vibetools/blob/main/executor/plans/PLAN.md
  - https://github.com/acoliver/vibetools/tree/main/executor/scripts
  - https://github.com/acoliver/llxprt-code/tree/main/project-plans/prompt-config/plan
- experiment with more manual styles where I stub out comments directly or with todos 

<this>
"One fantastic tip I discovered (sorry I've forgotten who wrote it but probably a fellow HNer):

If you're using an AI for the "architecture" / spec phase, play a few of the models off each other.

I will start with a conversation in Cursor (with appropriate context) and ask Gemini 2.5 Pro to ask clarifying questions and then propose a solution, and once I've got something, switch the model to O3 (or your other preferred thinking model of choice - GPT-5 now?). Add the line "please review the previous conversation and critique the design, ask clarifying questions, and proposal alternatives if you think this is the wrong direction."

Do that a few times back and forth and with your own brain input, you should have a pretty robust conversation log and outline of a good solution.

Export that whole conversation into an .md doc, and use THAT in context with Claude Code to actually dive in and start writing code.

You'll still need to review everything and there will still be errors and bad decisions, but overall this has worked surprisingly well and efficiently for me so far.""
</this>
