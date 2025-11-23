from pathlib import Path

requirements.json = """\


"""


def create_requirements_json(project_root: Path, publish_path: Path, force: bool) -> None:
    # Ensure project root exists
    project_root.mkdir(parents=True, exist_ok=True)

    # Ensure the directory for publish.yml exists, e.g. .github/workflows
    publish_path.parent.mkdir(parents=True, exist_ok=True)

    if publish_path.exists() and not force:
        print(f"[setup-project-env] {publish_path} already exists. "
              f"Use --force to overwrite.")
        return

    action = "Overwriting" if publish_path.exists() else "Creating"
    print(f"[setup-project-env] {action} {publish_path}")
    publish_path.write_text(PUBLISH_YML_CONTENT, encoding="utf-8")
