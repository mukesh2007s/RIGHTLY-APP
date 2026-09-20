# ⚖️ RIGHTLY – AI Legal Rights Assistant

> An AI-powered mobile application that helps users understand their legal rights through simple, accessible, and conversational guidance.

## 📱 About the Project

**RIGHTLY** is an AI-powered legal rights assistant designed to make legal information easier to understand and access.

Instead of searching through complex legal documents, users can interact with the application using natural language and receive simplified explanations related to their legal rights and common legal situations.

The application combines **Flutter** for cross-platform mobile development with the **Google Gemini API** to provide AI-powered conversational assistance.

---

## 🎯 Problem Statement

Legal information is often difficult for ordinary users to understand because of complex terminology, lengthy documents, and limited awareness of applicable rights.

Many people may not know:

- What legal rights they have
- Which actions they can take in a situation
- Where to find relevant legal information
- How to understand complicated legal terminology

RIGHTLY aims to provide a simple interface where users can ask questions and receive understandable AI-assisted explanations.

---

## 💡 Key Features

### 🤖 AI Legal Assistant
Ask legal-rights-related questions using natural language and receive AI-generated explanations.

### 💬 Conversational Interface
Interact with the assistant through a simple chat-based interface.

### 📖 Simplified Legal Information
Complex legal concepts can be explained in easier language for general users.

### ⚡ Fast Responses
The application uses an AI API to generate responses dynamically.

### 📱 Mobile Application
Built with Flutter to support modern mobile application development.

### 🔐 User-Friendly Design
Designed with simplicity and accessibility in mind.

---

## 🛠️ Technology Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Mobile application development |
| **Dart** | Application programming language |
| **Google Gemini API** | AI-powered conversational assistance |
| **Android Studio / VS Code** | Development environment |
| **Git & GitHub** | Version control and project management |

---

## 🏗️ System Architecture

```text
┌─────────────────────┐
│       User          │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   RIGHTLY Mobile    │
│       App           │
│      Flutter        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Gemini API        │
│   AI Processing     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ AI Generated        │
│ Legal Explanation   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│       User          │
└─────────────────────┘
┌─────────────────────┐
│       User          │
└─────────────────────┘
