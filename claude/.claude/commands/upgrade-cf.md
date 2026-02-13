# Migrate pyproject.toml from Poetry 1.4.2 to Poetry 2.2.1 Format

Migrate the pyproject.toml file from Poetry 1.4.2 format to Poetry 2.2.1 format with the following upgrades:

- **Python version**: Upgrade to Python 3.13
- **Poetry version**: Upgrade to 2.2.1
- **functions-framework**: Upgrade to version 3.10 or newer
- **All dependencies**: Update to latest versions compatible with Python 3.13

## Key Changes Required

### 1. Package Metadata (PEP 621)

Convert `[tool.poetry]` metadata to `[project]` table:

- Move `name`, `version`, `description` to `[project]`
- Convert `authors = ["Name <email>"]` to `authors = [{ name = "Name", email = "email" }]`
- Convert `python = "~3.10"` from dependencies to `requires-python = ">=3.13,<3.14"` in `[project]`

### 2. Dependencies

Convert `[tool.poetry.dependencies]` to `[project].dependencies`:

- Use list format: `dependencies = ["package>=1.0", "other-package"]`
- **For packages with custom sources**: Add to both `[project].dependencies` AND `[tool.poetry.dependencies]`
  - `[project].dependencies`: Declares the dependency (PEP 621 standard)
  - `[tool.poetry.dependencies]`: Specifies the source location (Poetry-specific)
- Convert version constraints:
  - `~X.Y.Z` → `>=X.Y.Z` (relaxed for better compatibility)
  - `^X.Y.Z` → `>=X.Y.Z` (relaxed for better compatibility)
  - `*` → no version constraint

### 3. Dev Dependencies

Convert `[tool.poetry.dev-dependencies]` to `[dependency-groups]`:

```toml
[dependency-groups]
dev = ["black", "pytest", "mypy"]
```

### 4. Package Sources

Update `[[tool.poetry.source]]` syntax:

- Replace `secondary = true` with `priority = "explicit"` or `"supplemental"`
- Options: `priority = "primary"`, `"supplemental"`, `"explicit"`

**IMPORTANT:** Always explicitly define PyPI as the primary source when using private registries:

```toml
[[tool.poetry.source]]
name = "pypi-public"
url = "https://pypi.org/simple/"
priority = "primary"

[[tool.poetry.source]]
name = "gcp"
url = "https://us-python.pkg.dev/data-flow-275112/rentspree-data-pipeline/simple"
priority = "explicit"
```

Note: Use `priority = "explicit"` for private registries where packages must be explicitly requested using `source = "gcp"` in the dependency specification.

### 5. Build System

Update to Poetry 2.x:

```toml
[build-system]
requires = ["poetry-core>=2.0.0"]
build-backend = "poetry.core.masonry.api"
```

### 6. Non-package Projects

If this is not a distributable package, add:

```toml
[tool.poetry]
package-mode = false
```

## Private Packages Dual Declaration

For packages from private registries, declare in BOTH places:

```toml
# 1. In [project].dependencies
dependencies = ["private-package"]

# 2. In [tool.poetry.dependencies]
[tool.poetry.dependencies]
private-package = { version = "^1.0.0", source = "custom" }

# 3. Define source with priority = "explicit"
[[tool.poetry.source]]
name = "custom"
url = "https://your-registry-url/simple"
priority = "explicit"
```

---

## Verification Steps

After applying all changes to `pyproject.toml`, verify that all dependencies support Python 3.13:

1. make sure master or main branch is up to date
1. Move the changes to a new branch named `feature/upgrade-python`
1. Update all python and poetry references to be version 3.13 and 2.2.1 respectively in github workflow files
1. Update Python version

    ```bash
    poetry env use 3.13
    ```

1. **Update the lock file**:

   ```bash
   poetry lock
   ```

1. **Test the installation**:

   ```bash
   poetry install
   ```

1. **Troubleshooting**: If `poetry install` fails, check error message and verify package supports Python 3.13 on PyPI

1. **Codebase validation**:

  ```bash
  make ci-test
  ```

1. **Runtime validation**:

  ```bash
  poetry run dagster dev
  ```

---

**Please apply these changes to the pyproject.toml file, preserving all existing dependencies and their version constraints.**
