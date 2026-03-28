# Contributing to CloudDrove Claude Skills

Thanks for your interest in contributing! This guide covers how to add new skills, improve existing ones, and submit changes.

## Getting Started

1. Fork and clone the repository
2. Test locally with `claude --plugin-dir ./plugins/k8s-skills`
3. Make your changes
4. Submit a pull request

## Adding a New Skill to an Existing Plugin

1. Create a directory under `plugins/<plugin-name>/skills/<skill-name>/`
2. Write a `SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: my-skill
   description: "When to trigger this skill and what it does..."
   ---
   ```
3. Add reference docs in `references/` for detailed content
4. Add scripts in `scripts/` with `--help` support
5. Test the skill triggers with natural language queries

## Adding a New Slash Command

1. Create a markdown file in `plugins/<plugin-name>/commands/`
2. Add frontmatter with description and allowed-tools:
   ```yaml
   ---
   description: Short description for /help
   argument-hint: [arg1] [arg2]
   allowed-tools: Read, Bash(kubectl:*)
   ---
   ```
3. Write instructions for Claude (what to do when invoked)
4. Test with `/<plugin-name>:<command-name>`

## Adding a New Plugin

1. Create directory structure under `plugins/<plugin-name>/`
2. Add `.claude-plugin/plugin.json` with name, version, description
3. Add skills, commands, or agents
4. Register the plugin in `.claude-plugin/marketplace.json` at the repo root
5. Add a `README.md` for the plugin

## Guidelines

- Keep `SKILL.md` under 500 lines — move detailed content to `references/`
- Write in imperative/third-person style for AI consumption
- Include working examples, not pseudo-code
- Scripts must support `--help` and work as black-box tools
- All kubectl/helm commands must be accurate and tested
- YAML examples must be valid and production-ready

## Reporting Issues

- Use the [bug report template](https://github.com/clouddrove/claude-skills/issues/new?template=bug_report.md) for problems
- Use the [feature request template](https://github.com/clouddrove/claude-skills/issues/new?template=feature_request.md) for suggestions
- Use the [new skill template](https://github.com/clouddrove/claude-skills/issues/new?template=new_skill.md) to request new plugins

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
