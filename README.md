📦 flutter_i18n_extractor

Automatically extract hard-coded Flutter UI text and generate app_en.arb localization files using Dart AST analysis.

No regex. No manual copy-paste. Just run one command.

✨ Features

🔍 Scans all Dart files inside lib/

🧠 Uses Dart Analyzer AST (safe & accurate)

🗂️ Generates lib/l10n/app_en.arb

♻️ Avoids duplicate keys

🧹 Filters non-UI strings

⚡ Fast & CLI-based

🛠️ Works with existing Flutter Intl setup

🚀 Installation

Add as a dev dependency in your Flutter project:

dev_dependencies:
  flutter_i18n_extractor: ^0.1.0


Then run:

flutter pub get

▶️ Usage

From the root of your Flutter project, run:

flutter pub run flutter_i18n_extractor


That’s it.

The tool will:

Scan lib/

Extract UI strings

Generate lib/l10n/app_en.arb

📁 Output Structure
lib/
 ├── l10n/
 │   └── app_en.arb
 └── main.dart

🧪 Example
Input (Flutter code)
Text("Login")
ElevatedButton(
  onPressed: () {},
  child: Text("Submit"),
)
SnackBar(
  content: Text("Invalid OTP"),
)

Output (app_en.arb)
{
  "login": "Login",
  "submit": "Submit",
  "invalidOtp": "Invalid OTP"
}

🔑 Key Generation Rules
UI Text	Generated Key
Login	login
Welcome Back	welcomeBack
Invalid OTP	invalidOtp
Already registered?	alreadyRegistered

Keys are camelCase

Special characters are removed

Duplicate text reuses the same key

⚠️ Limitations (Important)

This package intentionally avoids risky behavior.

❌ Not extracted

Logs (print, debugPrint)

API keys / routes

Long paragraphs (>100 chars)

Strings with {}, %, or template placeholders

Generated files (*.g.dart)

❌ Not supported (yet)

Auto-replacing widgets (Text("x") → S.of(context).x)

AI auto-translation

IDE / VS Code integration

Pluralization & ICU messages

🧠 Recommended Workflow

Run extractor

Review app_en.arb

Configure Flutter Intl / intl_utils

Generate localization classes

Manually replace UI text (or wait for auto-replace feature)

🔮 Roadmap

Planned for upcoming versions:

🔁 Auto-replace UI text

🌍 AI-powered translations

🧩 ICU & plural support

⚙️ CLI flags (--replace, --exclude)

💼 Pro version for large apps

🛡️ Why AST instead of Regex?
Regex	AST
❌ Breaks easily	✅ Safe
❌ False positives	✅ Accurate
❌ No context	✅ Knows real Dart code

This tool uses Dart Analyzer, same engine as Flutter & IDEs.

🤝 Contributing

PRs and ideas are welcome 🙌
If you find edge cases, please open an issue.

📄 License

MIT License
Free to use in personal and commercial projects.

⭐ Support the Project

If this tool saves you time:

⭐ Star it on GitHub

📢 Share with Flutter devs

💡 Suggest new features