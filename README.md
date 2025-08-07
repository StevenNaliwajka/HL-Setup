# HL-Common-Setup
----

This setup system is designed to help developers quickly bootstrap and compose modular projects using
a set of building block components — in a style similar to Infrastructure as Code (IaC).

Each module is self-contained, but also supports hierarchical orchestration, allowing it to function as:

- A parent, installing and configuring its dependent modules
- A child, executing its own setup scripts when used independently

The system is fully automatable and scalable, supporting both top-down and bottom-up execution flows.

----

### Endpoints:
Every module must expose:
- A `setup()` entrypoint
- A `metadata` object or method
- A config file (optional or enforced)

----

### Codeflow:
➤ Parse manifest  
➤ Run pre_setup hook  
➤ Install OS/Pip/Git dependencies  
➤ Ask about and install dependents (recursively)  
➤ Prompt user for config (if configurable)  
➤ Run post_setup hook  
➤ Build Docker (if build: true)  
➤ When launched:  
➤ Run on_launch hooks  
➤ Optionally run healthcheck  
✅ DONE  
--------------

```json
{  
  // === Module Identity ===  
  "module": "Web",  
  "category": "HL",  

  // === Dependencies ===  
  "dependencies": { 
    "os": ["curl", "python3"],
    "pip": ["requests", "dash"],
    "git": [
      "https://github.com/example/utility-lib"
    ],
    "docker": false
  },

  // === Optional Internal Module Dependencies ===  
  "dependents": {
    // Devs will be prompted for each of these during setup
    "Plotter": {
      "repo": "https://github.com/example/plotter",
      "default": true
    },
    "Uploader": {
      "repo": "https://github.com/example/uploader",
      "default": true
    },
    "Downloader": {
      "repo": "https://github.com/example/downloader",
      "default": true
    },
    "Status": {
      "repo": "https://github.com/example/status",
      "default": false
    }
  },

  // === Docker Image Configuration ===
  "docker": {
    "build": true,
    "entrypoint": "main.py",
    "expose_port": 8050
  },

  // === Setup Behavior ===
  "configurable": true,

  // === Lifecycle Hooks ===
  "hooks": {
    "pre_setup": "scripts/pre_setup.sh",
    "post_setup": "scripts/post_setup.sh",
    "on_launch": ["scripts/init.sh"],
    "healthcheck": "scripts/health_check.sh"
  }
}
```

### PARENT_MODULE_PATH

If set, this environment variable tells the setup system where to look for local copies of dependent modules.

This allows modules to reuse already-cloned or local modules instead of downloading them again.

**Example usage:**

```bash
PARENT_MODULE_PATH=/opt/myproject/HL-Web python setup.py