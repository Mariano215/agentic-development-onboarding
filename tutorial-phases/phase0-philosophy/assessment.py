#!/usr/bin/env python3
"""
Phase 0 Assessment: VibeOps Manifesto Understanding
Tests comprehension of core agentic development principles
"""

import json
import os
import sys
from datetime import datetime
from typing import List, Dict, Any

# Color codes for output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    BOLD = '\033[1m'
    NC = '\033[0m'  # No Color

def get_questions() -> List[Dict[str, Any]]:
    """Return the 5 assessment questions testing manifesto understanding"""
    return [
        {
            "id": 1,
            "question": "According to the VibeOps manifesto, what is the primary bottleneck in agentic development?",
            "options": [
                "A) AI processing speed and token limits",
                "B) Human coding speed and implementation time",
                "C) Human judgment capacity and verification decisions",
                "D) Network latency and deployment infrastructure"
            ],
            "correct": "C",
            "explanation": {
                "correct": "Correct! The manifesto emphasizes that agentic development shifts the bottleneck from human coding speed (traditional) to human judgment capacity. Humans focus on making good decisions about what 'success' looks like and how to verify it, while AI handles implementation.",
                "incorrect": "Not quite. While these can be factors, the manifesto specifically identifies the shift from human coding speed (traditional bottleneck) to human judgment capacity (agentic bottleneck) as the key change."
            }
        },
        {
            "id": 2,
            "question": "What is the correct sequence of the VibeOps development cycle?",
            "options": [
                "A) Plan → Code → Test → Deploy",
                "B) Envision → Explore → Execute → Evolve",
                "C) Frame → Model → Generate → Observe",
                "D) Research → Prototype → Implement → Verify"
            ],
            "correct": "B",
            "explanation": {
                "correct": "Excellent! The VibeOps development cycle is: Envision (Human-led), Explore (Collaborative), Execute (AI-led, Human-guided), and Evolve (Continuous). This represents the flow from human vision to collaborative exploration to AI-assisted execution to continuous learning.",
                "incorrect": "That's not the VibeOps cycle. The correct sequence is: Envision → Explore → Execute → Evolve, representing the flow from human vision through collaborative exploration to guided execution and continuous improvement."
            }
        },
        {
            "id": 3,
            "question": "What does 'Proof beats progress' mean in agentic development?",
            "options": [
                "A) Mathematical proofs are required for all code",
                "B) Documentation must be completed before coding",
                "C) Verified success criteria matter more than impressive demos",
                "D) Code reviews must be formal and comprehensive"
            ],
            "correct": "C",
            "explanation": {
                "correct": "Perfect! 'Proof beats progress' means that working software with verified success criteria is more valuable than impressive demos or quick progress without verification. It's about ensuring real value over apparent progress.",
                "incorrect": "'Proof beats progress' specifically means prioritizing verified success criteria and working software over impressive demos or apparent progress. It's about substance over show."
            }
        },
        {
            "id": 4,
            "question": "How should security be handled in agentic development according to VibeOps principles?",
            "options": [
                "A) Security testing after implementation is complete",
                "B) AI handles all security decisions automatically",
                "C) Security considered only during code review phase",
                "D) Threat modeling and verification gates before deployment"
            ],
            "correct": "D",
            "explanation": {
                "correct": "Exactly right! Agentic development applies verification-first principles to security, meaning threat modeling and security verification gates come before deployment, not after. Security is built in from the start through verified understanding.",
                "incorrect": "In agentic development, security follows the verification-first principle. This means threat modeling and security verification gates come before deployment, not as an afterthought."
            }
        },
        {
            "id": 5,
            "question": "What is the primary role of humans in mature agentic development?",
            "options": [
                "A) Writing most of the code with AI assistance",
                "B) Managing project timelines and resource allocation",
                "C) Making judgment calls, tradeoffs, and defining constraints",
                "D) Testing and debugging AI-generated code"
            ],
            "correct": "C",
            "explanation": {
                "correct": "Spot on! In mature agentic development, humans focus on the highest-value activities: making judgment calls about what success looks like, evaluating tradeoffs, defining constraints and values, and orchestrating the collaboration. AI handles implementation.",
                "incorrect": "While these activities may be part of development, the manifesto emphasizes that humans in agentic development focus on judgment calls, tradeoffs, constraints, and orchestration—the uniquely human cognitive strengths that AI cannot replace."
            }
        }
    ]

def calculate_score(correct_answers: int, total_questions: int) -> int:
    """Calculate percentage score"""
    return int((correct_answers / total_questions) * 100)

def ensure_progress_dir():
    """Ensure the progress directory exists"""
    progress_dir = os.path.expanduser("~/.claude-onboarding/manifesto-assessment")
    os.makedirs(progress_dir, exist_ok=True)
    return progress_dir

def save_assessment_result(score: int, total: int, answers: List[str], passed: bool):
    """Save assessment results to progress tracking"""
    progress_dir = ensure_progress_dir()

    result = {
        "timestamp": datetime.now().isoformat(),
        "score_percentage": score,
        "correct_answers": sum(1 for i, answer in enumerate(answers) if answer == get_questions()[i]["correct"]),
        "total_questions": total,
        "passed": passed,
        "passing_threshold": 80,
        "answers": answers
    }

    # Save latest result
    with open(os.path.join(progress_dir, "latest.json"), "w") as f:
        json.dump(result, f, indent=2)

    # Also append to history
    history_file = os.path.join(progress_dir, "history.json")
    history = []
    if os.path.exists(history_file):
        try:
            with open(history_file, "r") as f:
                history = json.load(f)
        except:
            history = []

    history.append(result)
    with open(history_file, "w") as f:
        json.dump(history, f, indent=2)

def display_question(question_data: Dict[str, Any]) -> str:
    """Display a question and get user input"""
    print(f"\n{Colors.CYAN}{Colors.BOLD}Question {question_data['id']}:{Colors.NC}")
    print(f"{Colors.WHITE}{question_data['question']}{Colors.NC}\n")

    for option in question_data['options']:
        print(f"  {Colors.YELLOW}{option}{Colors.NC}")

    while True:
        print(f"\n{Colors.BLUE}Enter your answer (A, B, C, or D): {Colors.NC}", end="")
        answer = input().strip().upper()
        if answer in ['A', 'B', 'C', 'D']:
            return answer
        else:
            print(f"{Colors.RED}Please enter A, B, C, or D{Colors.NC}")

def show_result(question_data: Dict[str, Any], user_answer: str):
    """Show whether answer was correct and explanation"""
    correct_answer = question_data['correct']
    is_correct = user_answer == correct_answer

    if is_correct:
        print(f"\n{Colors.GREEN}✓ Correct!{Colors.NC}")
        print(f"{Colors.GREEN}{question_data['explanation']['correct']}{Colors.NC}")
    else:
        print(f"\n{Colors.RED}✗ Incorrect{Colors.NC}")
        print(f"{Colors.RED}The correct answer was {correct_answer}.{Colors.NC}")
        print(f"{Colors.YELLOW}{question_data['explanation']['incorrect']}{Colors.NC}")

    print(f"{Colors.PURPLE}{'='*60}{Colors.NC}")

def run_assessment() -> bool:
    """Run the full assessment and return whether user passed"""
    print(f"{Colors.BOLD}{Colors.CYAN}")
    print("╔════════════════════════════════════════════════════════════════╗")
    print("║                   VIBEOPS MANIFESTO ASSESSMENT                ║")
    print("║                                                                ║")
    print("║  This assessment tests your understanding of the core          ║")
    print("║  principles of agentic development and VibeOps philosophy.     ║")
    print("║                                                                ║")
    print("║  • 5 questions covering key manifesto concepts                 ║")
    print("║  • 80% required to pass (4/5 questions correct)               ║")
    print("║  • Immediate feedback on each answer                           ║")
    print("║  • You can retake if needed                                    ║")
    print("╚════════════════════════════════════════════════════════════════╝")
    print(f"{Colors.NC}\n")

    questions = get_questions()
    user_answers = []
    correct_count = 0

    # Ask all questions
    for question_data in questions:
        user_answer = display_question(question_data)
        user_answers.append(user_answer)

        if user_answer == question_data['correct']:
            correct_count += 1

        show_result(question_data, user_answer)

    # Calculate and show final results
    score = calculate_score(correct_count, len(questions))
    passed = score >= 80

    print(f"\n{Colors.BOLD}{Colors.WHITE}")
    print("╔════════════════════════════════════════════════════════════════╗")
    print("║                        ASSESSMENT RESULTS                     ║")
    print("╚════════════════════════════════════════════════════════════════╝")
    print(f"{Colors.NC}")

    print(f"{Colors.BOLD}Final Score: {Colors.CYAN}{score}%{Colors.NC} ({correct_count}/{len(questions)} correct)")
    print(f"Required to pass: {Colors.YELLOW}80%{Colors.NC}")

    if passed:
        print(f"\n{Colors.GREEN}{Colors.BOLD}🎉 CONGRATULATIONS! YOU PASSED! 🎉{Colors.NC}")
        print(f"{Colors.GREEN}You've demonstrated strong understanding of VibeOps principles.{Colors.NC}")
        print(f"{Colors.GREEN}You're ready to proceed to the practical phases of agentic development!{Colors.NC}")
    else:
        print(f"\n{Colors.RED}{Colors.BOLD}Assessment not passed.{Colors.NC}")
        print(f"{Colors.YELLOW}You need at least 80% (4/5 questions) to proceed.{Colors.NC}")
        print(f"{Colors.BLUE}Review the manifesto and comparison document, then try again!{Colors.NC}")

    # Save results
    save_assessment_result(score, len(questions), user_answers, passed)

    return passed

def main():
    """Main entry point"""
    if len(sys.argv) > 1 and sys.argv[1] == "--retry":
        print(f"{Colors.YELLOW}Taking assessment again...{Colors.NC}\n")

    try:
        passed = run_assessment()
        return 0 if passed else 1
    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}Assessment cancelled.{Colors.NC}")
        return 1
    except Exception as e:
        print(f"\n{Colors.RED}Error running assessment: {e}{Colors.NC}")
        return 1

if __name__ == "__main__":
    sys.exit(main())