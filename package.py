import re
import shutil
from pathlib import Path


# -------------------------------------------------------
# Packaging config
# -------------------------------------------------------

ROOT = Path(__file__).parent
ADDON_NAME = ROOT.name
TOC_PATH = ROOT / "BetterTransmog.toc"

# (source path relative to ROOT, output folder name inside zip)
TARGETS = [(Path("."), ADDON_NAME)]

# Files/directories that should never be shipped
EXCLUDES = {
    ".git",
    ".github",
    ".gitmodules",
    ".gitignore",
    ".gitattributes",
    ".vscode",
    ".venv",
    "dist",
    "*.code-workspace",
    "*.py",
    "*.ps1",
    "*AGENTS.md",
}


def read_version() -> str:
    """Read version from BetterTransmog.toc (## Version: x.y.z)."""
    if not TOC_PATH.exists():
        return "0.0.0"

    for line in TOC_PATH.read_text(encoding="utf-8").splitlines():
        if line.lower().startswith("## version:"):
            return line.split(":", 1)[1].strip() or "0.0.0"

    return "0.0.0"


def should_exclude(rel_path: Path) -> bool:
    """Return True when a relative path should be excluded from packaging."""
    as_posix = rel_path.as_posix()

    for pattern in EXCLUDES:
        if rel_path.match(pattern):
            return True
        if any(part == pattern for part in rel_path.parts):
            return True
        if Path(as_posix).match(pattern):
            return True

    return False


def copy_filtered_tree(src: Path, dst: Path, source_root: Path) -> None:
    """Recursively copy source tree into destination, applying exclusions."""
    for item in src.iterdir():
        rel_from_root = item.relative_to(source_root)
        if should_exclude(rel_from_root):
            continue

        target = dst / item.name

        if item.is_dir():
            target.mkdir(parents=True, exist_ok=True)
            copy_filtered_tree(item, target, source_root)
            continue

        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(item, target)


def apply_release_overrides(staged_root: Path) -> None:
    """
    Apply minimal release-time overrides to the staged addon files.

    Current policy:
    - Force Core.Debug = false in Core.lua so debug logging is disabled in release builds.
    """
    core_lua = staged_root / "Core.lua"
    if not core_lua.exists():
        return

    content = core_lua.read_text(encoding="utf-8")
    content = re.sub(r"\bCore\.Debug\s*=\s*true\s*;?", "Core.Debug = false;", content)
    core_lua.write_text(content, encoding="utf-8")


def package_target(target_path: Path, archive_name: str, dist_dir: Path, version: str) -> None:
    """Build one addon zip from a target source path."""
    src = ROOT / target_path
    if not src.exists():
        raise FileNotFoundError(f"Missing target: {src}")

    tmp_root = dist_dir / "_tmp"
    staged_addon_root = tmp_root / archive_name

    if tmp_root.exists():
        shutil.rmtree(tmp_root)

    staged_addon_root.mkdir(parents=True, exist_ok=True)
    copy_filtered_tree(src, staged_addon_root, src)
    apply_release_overrides(staged_addon_root)

    output_stem = dist_dir / f"{archive_name}.{version}"
    archive_path = shutil.make_archive(str(output_stem), "zip", tmp_root, archive_name)

    shutil.rmtree(tmp_root)
    print(f"Created {archive_path}")


def main() -> None:
    dist_dir = ROOT / "dist"
    dist_dir.mkdir(exist_ok=True)

    version = read_version()

    for target_path, archive_name in TARGETS:
        package_target(target_path, archive_name, dist_dir, version)


if __name__ == "__main__":
    main()
