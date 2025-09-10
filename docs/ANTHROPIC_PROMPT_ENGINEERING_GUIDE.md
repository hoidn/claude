# Anthropic Claude Prompt Engineering Guide

*A comprehensive guide compiled from official Anthropic documentation*

## Table of Contents

1. [Introduction](#introduction)
2. [Core Prompt Engineering Techniques](#core-prompt-engineering-techniques)
3. [Be Clear and Direct](#be-clear-and-direct)
4. [Use Examples (Multishot Prompting)](#use-examples-multishot-prompting)
5. [Chain of Thought Reasoning](#chain-of-thought-reasoning)
6. [XML Tags for Structure](#xml-tags-for-structure)
7. [System Prompts and Roles](#system-prompts-and-roles)
8. [Prefilling Responses](#prefilling-responses)
9. [Prompt Chaining](#prompt-chaining)
10. [Long Context Best Practices](#long-context-best-practices)
11. [Advanced Techniques](#advanced-techniques)
12. [Best Practices Summary](#best-practices-summary)

## Introduction

Prompt engineering is the practice of crafting effective instructions to get optimal outputs from Claude. This guide synthesizes all official Anthropic documentation on prompt engineering techniques, ordered by effectiveness.

### Key Advantages of Prompting vs. Fine-tuning

- **Resource Efficiency**: No training data or computational resources required
- **Cost-Effectiveness**: Lower operational costs
- **Maintains General Knowledge**: Preserves Claude's broad capabilities
- **Faster Iteration**: Immediate testing and refinement
- **Transparency**: More interpretable than fine-tuned models

### When to Apply Prompt Engineering

- **Before fine-tuning**: Always try prompt engineering first
- **Define success criteria**: Clearly establish what good output looks like
- **Develop tests**: Create test cases to evaluate prompt effectiveness
- **Iterate systematically**: Test, refine, and improve prompts based on results

## Core Prompt Engineering Techniques

Listed in order of effectiveness according to Anthropic:

1. **Prompt Generator** - Use Anthropic Console's automated prompt generation
2. **Be Clear and Direct** - Provide explicit, detailed instructions
3. **Use Examples** - Implement multishot/few-shot prompting
4. **Chain of Thought** - Let Claude think through problems step-by-step
5. **XML Tags** - Structure prompts with clear organization
6. **System Prompts** - Give Claude specific roles and expertise
7. **Prefill Responses** - Guide output format and skip preambles
8. **Prompt Chaining** - Break complex tasks into sequential steps
9. **Long Context Tips** - Optimize handling of extensive documents

## Be Clear and Direct

### Golden Rule
> "Show your prompt to a colleague with minimal context. If they're confused, Claude will likely be confused too."

### Core Principles

#### 1. Provide Complete Context
- Explain the task's purpose
- Describe the intended audience
- Outline the workflow context
- Define success criteria

#### 2. Be Extremely Specific
- State exactly what you want
- Specify format, structure, and style
- Include technical constraints
- Define edge case handling

#### 3. Use Sequential Instructions
- Number your steps
- Break complex tasks into components
- Use clear section headers
- Maintain logical flow

### Example: Transforming Vague to Specific

**❌ Vague:**
```
Analyze this report and summarize key points.
```

**✅ Specific:**
```
Analyze this incident report. Skip preambles. Extract only:
1) Root cause
2) Duration (with timestamps)
3) Impacted services
4) Affected user count
5) Estimated revenue loss

Format as bullet points. Keep responses under 50 words per point.
```

### Best Practices
- Treat Claude like a "brilliant but new employee with amnesia"
- Include all relevant background information
- Specify exact output requirements
- Handle edge cases explicitly
- Test prompts with colleagues first

## Use Examples (Multishot Prompting)

### Overview
Multishot prompting (few-shot prompting) dramatically improves accuracy, consistency, and performance by providing 3-5 well-crafted examples.

### Key Benefits
- **Accuracy**: Reduces misinterpretation
- **Consistency**: Enforces uniform output
- **Performance**: Boosts handling of complex tasks
- **Clarity**: Better than abstract instructions

### Implementation Structure

```xml
<examples>
  <example>
    Input: [specific input 1]
    Output: [desired output 1]
  </example>
  <example>
    Input: [specific input 2]
    Output: [desired output 2]
  </example>
  <example>
    Input: [specific input 3]
    Output: [desired output 3]
  </example>
</examples>

Now process this input: [actual input]
```

### Best Practices
- **Use 3-5 diverse examples** (more examples = better performance)
- **Ensure examples are:**
  - Relevant to your use case
  - Diverse enough to cover edge cases
  - Consistently formatted
- **Use XML tags** for clear structure
- **Ask Claude to evaluate** your examples for quality

### Pro Tips
- Have Claude generate additional examples based on your initial set
- Examples train understanding better than abstract instructions
- Cover various scenarios and edge cases
- Maintain consistent formatting across all examples

## Chain of Thought Reasoning

### Core Concept
Chain of Thought (CoT) prompting encourages Claude to break down complex problems step-by-step, leading to more accurate and nuanced outputs.

**Fundamental Principle**: "Without outputting its thought process, no thinking occurs!"

### Three Approaches to Thinking

#### 1. Basic Chain of Thought
```
Think step-by-step before providing your answer.
```

#### 2. Guided Chain of Thought
```
Think through this problem:
1. First, identify the key components
2. Then, analyze relationships
3. Finally, synthesize conclusions
```

#### 3. Structured with XML Tags
```xml
<thinking>
Let me work through this systematically:
1. [Analysis step 1]
2. [Analysis step 2]
3. [Synthesis]
</thinking>

<answer>
[Final response]
</answer>
```

### Extended Thinking (Claude 4 Models)

**Features:**
- Minimum thinking budget: 1,024 tokens
- Can use tools during thinking
- Best performed in English
- Use for complex STEM problems, strategic planning, optimization

**Best Practice:**
```
Please think about this problem thoroughly and in great detail. 
Consider multiple approaches and show your complete reasoning.
```

### When to Use CoT

**Use for:**
- Complex mathematical problems
- Multi-step analysis
- Writing complex documents
- Decisions with multiple factors
- Tasks requiring systematic reasoning

**Benefits:**
- **Accuracy**: Reduces errors in complex tasks
- **Coherence**: More organized responses
- **Debugging**: Visible thought process helps identify issues

## XML Tags for Structure

### Why Use XML Tags

XML tags provide powerful structuring that improves:
- **Clarity**: Separates different prompt components
- **Accuracy**: Better interpretation of complex prompts
- **Flexibility**: Easy modification of specific sections
- **Parsing**: Simpler programmatic processing

### Best Practices

1. **Be Consistent**: Use same tag names throughout
2. **Nest Logically**: Create hierarchical structures
3. **Use Descriptive Names**: Tags should describe content purpose
4. **No Universal Standard**: Adapt tags to your needs

### Common Patterns

#### Basic Structure
```xml
<instructions>
Task guidelines here
</instructions>

<context>
Background information here
</context>

<examples>
Demonstration cases here
</examples>

<data>
Input to process here
</data>
```

#### Multi-Document Analysis
```xml
<documents>
  <document index="1">
    <source>filename.pdf</source>
    <content>{{DOCUMENT_CONTENT}}</content>
  </document>
  <document index="2">
    <source>data.xlsx</source>
    <content>{{DATA_CONTENT}}</content>
  </document>
</documents>

<query>
Analyze these documents and provide insights.
</query>
```

#### Complex Task Decomposition
```xml
<task>
Main objective description
</task>

<requirements>
  <format>Output structure requirements</format>
  <constraints>Limitations and rules</constraints>
  <deadline>Time constraints</deadline>
</requirements>

<steps>
  <step number="1">First action</step>
  <step number="2">Second action</step>
  <step number="3">Third action</step>
</steps>
```

## System Prompts and Roles

### Core Concept
System prompts establish Claude's identity, expertise, and behavioral guidelines before any user interaction begins.

### Implementation
```python
response = client.messages.create(
    model="claude-3-7-sonnet",
    system="You are a senior data scientist with 15 years of experience in predictive modeling and customer analytics at Fortune 500 companies.",
    messages=[{"role": "user", "content": "Analyze this dataset"}]
)
```

### Best Practices for Role Definition

#### 1. Be Specific About Expertise
```python
# ❌ Too Vague
system="You are a consultant."

# ✅ Specific and Contextual
system="""You are a management consultant specializing in digital transformation 
for retail companies, with 10 years experience helping traditional businesses 
adopt e-commerce strategies."""
```

#### 2. Include Multiple Characteristics
```python
system="""You are Dr. Sarah Chen, a senior data scientist.

Expertise:
- Predictive modeling and machine learning
- Customer behavior analysis
- Risk assessment and fraud detection

Communication style:
- Analytical and evidence-based
- Clear for non-technical stakeholders
- Always includes confidence levels
- Provides actionable recommendations"""
```

#### 3. Define Behavioral Boundaries
```python
system="""You are a licensed financial advisor with fiduciary duty.

Guidelines:
- Never provide specific investment advice without full assessment
- Always emphasize diversification importance
- Distinguish between education and personalized advice
- Recommend professional consultation for complex matters"""
```

### When to Use System vs User Prompts

**System Prompts For:**
- Role and expertise definition
- Overall interaction tone
- Background context
- Behavioral boundaries

**User Prompts For:**
- Specific tasks
- Dynamic information
- Task-specific context
- Follow-up questions

## Prefilling Responses

### Concept
Prefilling guides Claude's responses by including initial text in the Assistant message, allowing you to:
- Skip preambles
- Enforce specific formats
- Maintain character consistency
- Direct initial actions

### Implementation
```python
messages=[
    {"role": "user", "content": "Extract product details from this description"},
    {"role": "assistant", "content": "{"}  # Prefill forces JSON format
]
```

### Common Use Cases

#### 1. Force JSON Output
```python
{"role": "assistant", "content": "{"}
```

#### 2. Skip Explanations
```python
{"role": "assistant", "content": "The answer is:"}
```

#### 3. Maintain Character
```python
{"role": "assistant", "content": "[Sherlock Holmes]"}
```

#### 4. Start Code Blocks
```python
{"role": "assistant", "content": "```python\n"}
```

### Technical Requirements
- Not available in extended thinking modes
- Cannot end with trailing whitespace
- Must naturally lead into continuation
- Included as Assistant message content

## Prompt Chaining

### Concept
Break complex tasks into smaller, sequential prompts where each focuses on a specific subtask.

### Benefits
- **Improved Accuracy**: Full attention on each subtask
- **Enhanced Clarity**: Simpler instructions per step
- **Better Debugging**: Easy issue identification
- **Reduced Errors**: Prevents dropping steps

### Implementation Patterns

#### Sequential Processing
```python
def analyze_document(doc):
    # Step 1: Summarize
    summary = claude_call(f"Summarize: {doc}")
    
    # Step 2: Extract key points
    key_points = claude_call(f"Extract key points from: {summary}")
    
    # Step 3: Generate insights
    insights = claude_call(f"Generate insights from: {key_points}")
    
    return insights
```

#### Self-Correction Chain
```python
def self_correcting_output(task):
    # Generate
    draft = claude_call(f"Create: {task}")
    
    # Critique
    feedback = claude_call(f"Critique this: {draft}")
    
    # Refine
    final = claude_call(f"Improve based on feedback: {draft}\n{feedback}")
    
    return final
```

#### Parallel Processing
```python
# Process independent subtasks simultaneously
results = parallel_process([
    lambda: claude_call("Research topic A"),
    lambda: claude_call("Research topic B"),
    lambda: claude_call("Research topic C")
])

# Combine results
synthesis = claude_call(f"Synthesize: {results}")
```

### Best Practices
- **Single responsibility** per prompt
- **Clear handoffs** between steps
- **Use XML tags** for information transfer
- **Include validation** steps
- **Test each link** independently

## Long Context Best Practices

### Critical Rule
**Always place long documents (20,000+ tokens) at the TOP of your prompt**
- Can improve performance by up to 30%
- Place before instructions, queries, and examples

### Document Organization
```xml
<documents>
  <document index="1">
    <source>annual_report.pdf</source>
    <document_content>
      {{LONG_DOCUMENT_CONTENT}}
    </document_content>
  </document>
  <document index="2">
    <source>analysis.xlsx</source>
    <document_content>
      {{MORE_CONTENT}}
    </document_content>
  </document>
</documents>

<!-- Instructions come AFTER documents -->
<instructions>
First, quote relevant sections from the documents.
Then provide your analysis based on those quotes.
</instructions>
```

### Quote-First Methodology
- Ask Claude to quote relevant parts before analysis
- Helps "cut through the noise" of extensive content
- Grounds responses in specific document sections
- Improves accuracy and reduces hallucination

### Context Window Management
- Claude supports 200,000 token context window
- Use structured XML for multiple documents
- Include source identification for traceability
- Optimize placement for best performance

## Advanced Techniques

### Combining Techniques
Most effective prompts combine multiple techniques:

```xml
<!-- System prompt for role -->
System: You are a senior financial analyst.

<!-- XML structure for organization -->
<documents>
  <document>{{FINANCIAL_DATA}}</document>
</documents>

<!-- Examples for consistency -->
<examples>
  <example>
    Input: Q1 Revenue: $1M
    Analysis: Growth trend positive, 15% YoY increase
  </example>
</examples>

<!-- Chain of thought for reasoning -->
<instructions>
Think step-by-step through the financial analysis.
Show your reasoning in <thinking> tags.
</instructions>

<!-- Prefill for format -->
Assistant: <thinking>
```

### The Think Tool (API)
```json
{
  "name": "think",
  "description": "Use for complex reasoning",
  "input_schema": {
    "type": "object",
    "properties": {
      "thought": {
        "type": "string",
        "description": "A thought to process"
      }
    }
  }
}
```

### Performance Optimization Tips

1. **Test Iteratively**: Start simple, add complexity gradually
2. **Measure Results**: Use consistent test cases
3. **Combine Techniques**: Layer methods for best results
4. **Monitor Token Usage**: Stay within limits efficiently
5. **Use Console Tools**: Leverage Anthropic's prompt generator

## Best Practices Summary

### Universal Principles

1. **Clarity First**: If a human colleague wouldn't understand, neither will Claude
2. **Examples > Instructions**: Show, don't just tell
3. **Structure Matters**: Use XML tags for organization
4. **Think Before Acting**: Enable reasoning for complex tasks
5. **Test Everything**: Validate prompts with diverse inputs

### Prompt Engineering Workflow

1. **Define Success**: Clear criteria for good output
2. **Start Simple**: Basic prompt first
3. **Add Examples**: Include 3-5 diverse cases
4. **Structure with XML**: Organize complex prompts
5. **Enable Thinking**: Add CoT for complex reasoning
6. **Chain if Needed**: Break into subtasks
7. **Iterate and Test**: Refine based on results

### Common Pitfalls to Avoid

- **Being too vague**: Always be specific
- **Skipping examples**: Examples dramatically improve performance
- **Poor structure**: Unorganized prompts confuse Claude
- **No thinking space**: Complex tasks need reasoning
- **Ignoring context limits**: Manage token usage carefully
- **Not testing**: Always validate with test cases

### Resources

- [Anthropic Console](https://console.anthropic.com/dashboard) - Prompt generator tool
- [GitHub Tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial) - Interactive examples
- [Google Sheets Tutorial](https://docs.google.com/spreadsheets/d/19jzLgRruG9kjUQNKtCg1ZjdD6l6weA6qRXG5zLIAhC8) - Practical exercises

---

*This guide synthesizes official Anthropic documentation on prompt engineering. For the latest updates, visit the [official documentation](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/).*