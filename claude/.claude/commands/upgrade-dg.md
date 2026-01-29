# Migrate pyproject.toml from Poetry 1.4.2 to Poetry 2.2.1 Format

Migrate the pyproject.toml file from Poetry 1.4.2 format to Poetry 2.2.1 format with the following upgrades:

- **Python version**: Upgrade to Python 3.13
- **Poetry version**: Upgrade to 2.2.1
- **Dagster version**: Upgrade to `>=1.12.8,<1.13.0`
- **All dependencies**: Update to latest versions compatible with Python 3.13
- **Pandas version**: Upgrade to `>=2.3.0`
- **Pendulum version**: Upgrade to `>=3.1.0` for Python 3.13 compatibility
- **Shapely version**: Explicitly require `>=2.0.6` for Python 3.13 compatibility
- **google-cloud-storage version**: Upgrade to `>=3.8.0` for Python 3.13 compatibility and latest features
- **Add dagster-webserver**: Include `dagster-webserver` package for the Dagster web UI

## Key Changes Required

### 1. Package Metadata (PEP 621)

Convert `[tool.poetry]` metadata to `[project]` table:

- Move `name`, `version`, `description` to `[project]`
- Convert `authors = ["Name <email>"]` to `authors = [{ name = "Name", email = "email" }]`
- Convert `python = "~3.10"` from dependencies to `requires-python = ">=3.13,<3.14"` in `[project]`

### 2. Dependencies

Convert `[tool.poetry.dependencies]` to `[project].dependencies`:

- Use list format: `dependencies = ["package>=1.0", "other-package"]`
- For extras: `"google-cloud-aiplatform[prediction]>=1.70.0"`
- **For packages with custom sources**: Add to both `[project].dependencies` AND `[tool.poetry.dependencies]`
  - `[project].dependencies`: Declares the dependency (PEP 621 standard)
  - `[tool.poetry.dependencies]`: Specifies the source location (Poetry-specific)
- **Upgrade dagster**: `"dagster>=1.12.8,<1.13.0"`
- **Add dagster-webserver**: `"dagster-webserver"` (for Dagster web UI)
- **Upgrade pandas**: `"pandas>=2.3.0"` (upgrade from 1.5.x to 2.3.x)
- **Upgrade pendulum**: `"pendulum>=3.1.0"` (required for Python 3.13 compatibility, pendulum 2.x uses distutils which was removed in Python 3.12+)
- **Explicitly add shapely**: `"shapely>=2.0.6"` (required for Python 3.13 compatibility, as transitive dependency from google-cloud-aiplatform)
- **Upgrade google-cloud-storage**: `"google-cloud-storage>=3.8.0"` (upgrade from 2.x to 3.x for Python 3.13 support and improved checksumming)
- **Upgrade google-cloud-aiplatform**: `"google-cloud-aiplatform[prediction]>=1.75.0"` (for Pydantic 2.x compatibility)
- **Upgrade all other packages**: Update to latest versions (see `UPDATE_DEPENDENCIES_TO_LATEST.md` for detailed version list)
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

**Note**: `dagit` is deprecated in favor of `dagster-webserver`. Move it from dev dependencies to main dependencies as `dagster-webserver`.

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

## Critical Python 3.13 Compatibility Notes

- **pendulum < 3.1.0**: Fails on Python 3.13 (distutils removed). Use `>=3.1.0`
- **shapely < 2.0.6**: No Python 3.13 support. Explicitly add `>=2.0.6`
- **google-cloud-aiplatform < 1.75**: Needs Pydantic 2.x. Use `>=1.75.0`
- **google-cloud-storage < 3.0**: Limited Python 3.13 support. Use `>=3.8.0`
- **dagit**: Deprecated. Use `dagster-webserver` in main dependencies

## Private Packages Dual Declaration

For packages from private registries, declare in BOTH places:

```toml
# 1. In [project].dependencies
dependencies = ["private-package>=1.0.0"]

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

1. **Update the lock file**:

   ```bash
   poetry lock
   ```

2. **Test the installation**:

   ```bash
   poetry install
   ```

3. **Troubleshooting**: If `poetry install` fails, check error message and verify package supports Python 3.13 on PyPI

4. **Codebase validation**:

  ```bash
  make ci-test
  ```

1. **Runtime validation**:

  ```bash
  poetry run dagster dev
  ```

---

**Please apply these changes to the pyproject.toml file, preserving all existing dependencies and their version constraints.**
