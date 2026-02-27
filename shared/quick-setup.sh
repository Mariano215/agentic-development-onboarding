#!/bin/bash

# VibeOps Quick Setup Wizard
# Interactive installer for Claude Code skills, agents, and MCP servers
# Sources from the team config repo: github.com/Mariano215/claude-code
# Can be sourced by onboard.sh or run standalone

set -euo pipefail

# Color definitions (safe to re-declare if already sourced)
QS_CYAN='\033[0;36m'
QS_BLUE='\033[0;34m'
QS_GREEN='\033[0;32m'
QS_YELLOW='\033[1;33m'
QS_RED='\033[0;31m'
QS_WHITE='\033[1;37m'
QS_MAGENTA='\033[0;35m'
QS_NC='\033[0m'

# Team config repo
QS_TEAM_REPO="https://github.com/Mariano215/claude-code.git"
QS_CLAUDE_DIR="$HOME/.claude"
QS_SETTINGS_FILE="$QS_CLAUDE_DIR/settings.json"

# ── Stage A: Prerequisites ──────────────────────────────────────────────────

qs_check_prerequisites() {
    echo -e "${QS_CYAN}=== Stage A: Checking Prerequisites ===${QS_NC}"
    echo
    local missing_hard=()
    local missing_soft=()

    for cmd in claude git jq; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo -e "  ${QS_GREEN}✅ $cmd${QS_NC} $(command -v "$cmd")"
        else
            echo -e "  ${QS_RED}❌ $cmd${QS_NC} — required"
            missing_hard+=("$cmd")
        fi
    done

    for cmd in node npx; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo -e "  ${QS_GREEN}✅ $cmd${QS_NC} $(command -v "$cmd")"
        else
            echo -e "  ${QS_YELLOW}⚠️  $cmd${QS_NC} — recommended (some MCP servers need it)"
            missing_soft+=("$cmd")
        fi
    done

    echo

    if [[ ${#missing_hard[@]} -gt 0 ]]; then
        echo -e "${QS_RED}Missing required tools: ${missing_hard[*]}${QS_NC}"
        echo -e "${QS_BLUE}Install them and try again.${QS_NC}"
        echo
        return 1
    fi

    if [[ ${#missing_soft[@]} -gt 0 ]]; then
        echo -e "${QS_YELLOW}Note: Some optional tools are missing. MCP servers that need Node.js may not work.${QS_NC}"
        echo
    fi

    return 0
}

# ── Stage B: Backup ──────────────────────────────────────────────────────────

qs_create_backup() {
    echo -e "${QS_CYAN}=== Stage B: Backing Up Current Config ===${QS_NC}"
    echo

    local backup_dir="$QS_CLAUDE_DIR/backups/quick-setup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    local backed_up=0

    if [[ -f "$QS_SETTINGS_FILE" ]]; then
        cp "$QS_SETTINGS_FILE" "$backup_dir/settings.json"
        echo -e "  ${QS_GREEN}✅${QS_NC} settings.json"
        backed_up=$((backed_up + 1))
    fi

    if [[ -d "$QS_CLAUDE_DIR/skills" ]]; then
        cp -r "$QS_CLAUDE_DIR/skills" "$backup_dir/skills"
        echo -e "  ${QS_GREEN}✅${QS_NC} skills/"
        backed_up=$((backed_up + 1))
    fi

    if [[ -d "$QS_CLAUDE_DIR/agents" ]]; then
        cp -r "$QS_CLAUDE_DIR/agents" "$backup_dir/agents"
        echo -e "  ${QS_GREEN}✅${QS_NC} agents/"
        backed_up=$((backed_up + 1))
    fi

    if [[ $backed_up -eq 0 ]]; then
        echo -e "  ${QS_YELLOW}No existing config to back up (fresh install)${QS_NC}"
        rmdir "$backup_dir" 2>/dev/null || true
    else
        echo -e "\n  ${QS_BLUE}Backup saved to: ${backup_dir}${QS_NC}"
    fi

    echo
}

# ── Stage C: Clone Team Repo ─────────────────────────────────────────────────

qs_clone_repo() {
    echo -e "${QS_CYAN}=== Stage C: Fetching Team Config ===${QS_NC}"
    echo

    QS_TEMP_DIR=$(mktemp -d)
    # Ensure cleanup on any exit from this point
    trap 'rm -rf "$QS_TEMP_DIR" 2>/dev/null' EXIT

    echo -e "  ${QS_BLUE}Cloning ${QS_TEAM_REPO}...${QS_NC}"
    if ! git clone --depth 1 --quiet "$QS_TEAM_REPO" "$QS_TEMP_DIR/claude-code" 2>&1; then
        echo -e "  ${QS_RED}Failed to clone team repo.${QS_NC}"
        echo -e "  ${QS_YELLOW}Check your network connection and repo access.${QS_NC}"
        echo
        return 1
    fi

    QS_REPO_DIR="$QS_TEMP_DIR/claude-code"
    echo -e "  ${QS_GREEN}✅ Team config fetched successfully${QS_NC}"
    echo
    return 0
}

# ── Stage D: Interactive Selection ───────────────────────────────────────────

# Helper: present a numbered selection menu
# Usage: qs_select_menu "Category" array_of_paths result_array_name
qs_select_menu() {
    local category="$1"
    shift
    local -n _items=$1
    shift
    local -n _selected=$1

    _selected=()

    if [[ ${#_items[@]} -eq 0 ]]; then
        echo -e "  ${QS_YELLOW}No ${category} found in team repo.${QS_NC}"
        echo
        return
    fi

    echo -e "${QS_WHITE}Available ${category}:${QS_NC}"
    echo
    local i=1
    for item in "${_items[@]}"; do
        local name
        name=$(basename "$item")
        echo -e "  ${QS_WHITE}${i}.${QS_NC} ${name}"
        i=$((i + 1))
    done
    echo
    echo -e "  ${QS_BLUE}Enter comma-separated numbers (e.g. 1,3), 'a' for all, 'n' for none:${QS_NC}"
    read -r -p "  > " selection

    if [[ "$selection" == "n" || "$selection" == "N" ]]; then
        return
    fi

    if [[ "$selection" == "a" || "$selection" == "A" ]]; then
        _selected=("${_items[@]}")
        return
    fi

    # Parse comma-separated numbers
    IFS=',' read -ra nums <<< "$selection"
    for num in "${nums[@]}"; do
        # Trim whitespace
        num=$(echo "$num" | tr -d '[:space:]')
        if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#_items[@]} )); then
            _selected+=("${_items[$((num - 1))]}")
        else
            echo -e "  ${QS_YELLOW}Skipping invalid selection: ${num}${QS_NC}"
        fi
    done
}

qs_interactive_selection() {
    echo -e "${QS_CYAN}=== Stage D: Select Components ===${QS_NC}"
    echo

    # 1. Skills
    local skill_files=()
    if [[ -d "$QS_REPO_DIR/skills/security" ]]; then
        while IFS= read -r -d '' f; do
            skill_files+=("$f")
        done < <(find "$QS_REPO_DIR/skills/security" -name "*.skill" -print0 2>/dev/null | sort -z)
    fi

    echo -e "${QS_MAGENTA}── Skills ──${QS_NC}"
    QS_SELECTED_SKILLS=()
    qs_select_menu "Skills" skill_files QS_SELECTED_SKILLS
    echo

    # 2. Agents
    local agent_files=()
    if [[ -d "$QS_REPO_DIR/agents/security" ]]; then
        while IFS= read -r -d '' f; do
            agent_files+=("$f")
        done < <(find "$QS_REPO_DIR/agents/security" -name "*.md" -print0 2>/dev/null | sort -z)
    fi

    echo -e "${QS_MAGENTA}── Agents ──${QS_NC}"
    QS_SELECTED_AGENTS=()
    qs_select_menu "Agents" agent_files QS_SELECTED_AGENTS
    echo

    # 3. MCP Servers
    echo -e "${QS_MAGENTA}── MCP Servers ──${QS_NC}"
    echo
    echo -e "${QS_WHITE}Available MCP Servers:${QS_NC}"
    echo
    echo -e "  ${QS_WHITE}1.${QS_NC} Context7 (documentation lookup)"
    echo -e "  ${QS_WHITE}2.${QS_NC} Playwright (browser automation testing)"
    echo
    echo -e "  ${QS_BLUE}Enter comma-separated numbers (e.g. 1,2), 'a' for all, 'n' for none:${QS_NC}"
    read -r -p "  > " mcp_selection

    QS_SELECTED_MCP=()
    if [[ "$mcp_selection" == "a" || "$mcp_selection" == "A" ]]; then
        QS_SELECTED_MCP=("context7" "playwright")
    elif [[ "$mcp_selection" != "n" && "$mcp_selection" != "N" ]]; then
        IFS=',' read -ra mcp_nums <<< "$mcp_selection"
        for num in "${mcp_nums[@]}"; do
            num=$(echo "$num" | tr -d '[:space:]')
            case "$num" in
                1) QS_SELECTED_MCP+=("context7") ;;
                2) QS_SELECTED_MCP+=("playwright") ;;
                *) echo -e "  ${QS_YELLOW}Skipping invalid selection: ${num}${QS_NC}" ;;
            esac
        done
    fi

    # Prompt for Context7 API key if selected
    QS_CONTEXT7_KEY=""
    for mcp in "${QS_SELECTED_MCP[@]}"; do
        if [[ "$mcp" == "context7" ]]; then
            echo
            echo -e "  ${QS_BLUE}Context7 API key (leave blank to skip):${QS_NC}"
            read -r -p "  > " QS_CONTEXT7_KEY
            break
        fi
    done

    echo

    # 4. Confirmation summary
    echo -e "${QS_CYAN}=== Installation Summary ===${QS_NC}"
    echo
    echo -e "${QS_WHITE}Skills (${#QS_SELECTED_SKILLS[@]}):${QS_NC}"
    if [[ ${#QS_SELECTED_SKILLS[@]} -eq 0 ]]; then
        echo -e "  (none)"
    else
        for s in "${QS_SELECTED_SKILLS[@]}"; do echo -e "  + $(basename "$s")"; done
    fi

    echo -e "${QS_WHITE}Agents (${#QS_SELECTED_AGENTS[@]}):${QS_NC}"
    if [[ ${#QS_SELECTED_AGENTS[@]} -eq 0 ]]; then
        echo -e "  (none)"
    else
        for a in "${QS_SELECTED_AGENTS[@]}"; do echo -e "  + $(basename "$a")"; done
    fi

    echo -e "${QS_WHITE}MCP Servers (${#QS_SELECTED_MCP[@]}):${QS_NC}"
    if [[ ${#QS_SELECTED_MCP[@]} -eq 0 ]]; then
        echo -e "  (none)"
    else
        for m in "${QS_SELECTED_MCP[@]}"; do echo -e "  + $m"; done
    fi

    echo
    read -r -p "Proceed with installation? (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo -e "${QS_BLUE}Installation cancelled.${QS_NC}"
        return 1
    fi

    return 0
}

# ── Stage E: Install ─────────────────────────────────────────────────────────

qs_install() {
    echo
    echo -e "${QS_CYAN}=== Stage E: Installing ===${QS_NC}"
    echo

    local success=0
    local failed=0

    # Install skills
    if [[ ${#QS_SELECTED_SKILLS[@]} -gt 0 ]]; then
        mkdir -p "$QS_CLAUDE_DIR/skills"
        for src in "${QS_SELECTED_SKILLS[@]}"; do
            local name
            name=$(basename "$src")
            if cp "$src" "$QS_CLAUDE_DIR/skills/$name" 2>/dev/null; then
                echo -e "  ${QS_GREEN}✅${QS_NC} skill: $name"
                success=$((success + 1))
            else
                echo -e "  ${QS_RED}❌${QS_NC} skill: $name (copy failed)"
                failed=$((failed + 1))
            fi
        done
    fi

    # Install agents
    if [[ ${#QS_SELECTED_AGENTS[@]} -gt 0 ]]; then
        mkdir -p "$QS_CLAUDE_DIR/agents"
        for src in "${QS_SELECTED_AGENTS[@]}"; do
            local name
            name=$(basename "$src")
            if cp "$src" "$QS_CLAUDE_DIR/agents/$name" 2>/dev/null; then
                echo -e "  ${QS_GREEN}✅${QS_NC} agent: $name"
                success=$((success + 1))
            else
                echo -e "  ${QS_RED}❌${QS_NC} agent: $name (copy failed)"
                failed=$((failed + 1))
            fi
        done
    fi

    # Merge MCP servers into settings.json
    if [[ ${#QS_SELECTED_MCP[@]} -gt 0 ]]; then
        qs_merge_mcp_servers
    fi

    echo
    echo -e "${QS_CYAN}=== Results ===${QS_NC}"
    echo -e "  ${QS_GREEN}Succeeded: ${success}${QS_NC}"
    if [[ $failed -gt 0 ]]; then
        echo -e "  ${QS_RED}Failed:    ${failed}${QS_NC}"
    fi
    echo
}

qs_merge_mcp_servers() {
    # Build a JSON fragment with only the selected MCP servers
    local mcp_json="{}"

    for mcp in "${QS_SELECTED_MCP[@]}"; do
        case "$mcp" in
            context7)
                local env_block="{}"
                if [[ -n "$QS_CONTEXT7_KEY" ]]; then
                    env_block=$(jq -n --arg key "$QS_CONTEXT7_KEY" '{"CONTEXT7_API_KEY": $key}')
                fi
                mcp_json=$(echo "$mcp_json" | jq --argjson env "$env_block" \
                    '.context7 = {"command": "npx", "args": ["-y", "@upstash/context7-mcp@latest"], "env": $env}')
                ;;
            playwright)
                mcp_json=$(echo "$mcp_json" | jq \
                    '.playwright = {"command": "npx", "args": ["-y", "@anthropic-ai/mcp-playwright"]}')
                ;;
        esac
    done

    # Ensure settings.json exists with minimal structure
    mkdir -p "$QS_CLAUDE_DIR"
    if [[ ! -f "$QS_SETTINGS_FILE" ]]; then
        echo '{}' > "$QS_SETTINGS_FILE"
    fi

    # Validate existing settings.json is valid JSON
    if ! jq empty "$QS_SETTINGS_FILE" 2>/dev/null; then
        echo -e "  ${QS_RED}❌ settings.json is not valid JSON — skipping MCP merge${QS_NC}"
        echo -e "  ${QS_YELLOW}   Your backup is in ~/.claude/backups/${QS_NC}"
        return 1
    fi

    # Merge: only touch .mcpServers, preserve everything else
    local temp_file
    temp_file=$(mktemp)

    if jq --argjson new "$mcp_json" \
        '.mcpServers = ((.mcpServers // {}) * $new)' \
        "$QS_SETTINGS_FILE" > "$temp_file" 2>/dev/null; then

        mv "$temp_file" "$QS_SETTINGS_FILE"
        for mcp in "${QS_SELECTED_MCP[@]}"; do
            echo -e "  ${QS_GREEN}✅${QS_NC} MCP server: $mcp"
        done
    else
        rm -f "$temp_file"
        echo -e "  ${QS_RED}❌ Failed to merge MCP servers into settings.json${QS_NC}"
        echo -e "  ${QS_YELLOW}   Your backup is in ~/.claude/backups/${QS_NC}"
        return 1
    fi
}

# ── Main Entry Point ─────────────────────────────────────────────────────────

run_quick_setup() {
    echo -e "${QS_CYAN}╔════════════════════════════════════════════════════════════════════════════╗${QS_NC}"
    echo -e "${QS_CYAN}║                     ${QS_WHITE}⚡ Quick Setup Wizard ⚡${QS_CYAN}                              ║${QS_NC}"
    echo -e "${QS_CYAN}║           ${QS_MAGENTA}Install team skills, agents & MCP servers${QS_CYAN}                    ║${QS_NC}"
    echo -e "${QS_CYAN}╚════════════════════════════════════════════════════════════════════════════╝${QS_NC}"
    echo

    # Stage A
    if ! qs_check_prerequisites; then
        read -p "Press Enter to return..."
        return 1
    fi

    # Stage B
    qs_create_backup

    # Stage C
    if ! qs_clone_repo; then
        read -p "Press Enter to return..."
        return 1
    fi

    # Stage D
    if ! qs_interactive_selection; then
        read -p "Press Enter to return..."
        return 0
    fi

    # Stage E
    qs_install

    echo -e "${QS_GREEN}Quick setup complete!${QS_NC}"
    echo
    read -p "Press Enter to continue..."
}

# Standalone execution support
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_quick_setup
fi
