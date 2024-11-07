<!-- Chary -->
# Chary

[![Artifact Hub](https://img.shields.io/badge/ArtifactHUB-blue?style=for-the-badge&logo=artifacthub&logoColor=white)](https://artifacthub.io/packages/helm/chary/chary)
[![GitHub](https://img.shields.io/badge/GitHub-black?style=for-the-badge&logo=github&logoColor=white)](https://github.com/0zhu/chary)

A generic Helm chart that lets you create customized charts and templates directly from `values.yaml` or raw Kubernetes manifest files.

## Features

- Reuse one chart across multiple apps
- Modify resources and templates directly from `values.yaml`
- Customize resources using standard manifest structure

## Usage

### As remote chart

- Add repo

  ```sh
  helm repo add chary https://0zhu.github.io/chary
  ```

- Create [`values.yaml`](values.yaml) file with your manifests

  ```yml
  manifests:
  - kind: Deployment
    # ...
  ```

- Deploy

  ```sh
  helm upgrade --install myapp chary/chary -f values.yaml
  ```

### As dependency subchart

- Add `Chary` to your `Chart.yaml`

  ```yml
  apiVersion: v2
  name: myapp
  version: 0.1.0
  appVersion: "1.16.0"
  dependencies:
  - name: chary
    version: "*" # https://github.com/0zhu/chary/tags
    repository: "https://0zhu.github.io/chary"
  ```

- Create `values.yaml` file with your manifests

  ```yml
  chary:
    manifests:
    - kind: Deployment
      # ...
  ```

- Deploy

  ```sh
  helm upgrade --install myapp . -f values.yaml
  ```

### As dependency subchart with local context and files

- Add `Chary` to your `Chart.yaml`

- Add `Chary`'s helper function to your `templates/manifests.yaml`

  <!-- {% raw %} -->
  ```yml
  {{ include "chary.manifests" . }}
  ```
  <!-- {% endraw %} -->

- Create `values.yaml` file with your manifests

  <!-- {% raw %} -->
  ```yml
  manifests:
  - kind: Deployment
    # parent chart's files and context become available for templating
  - kind: ConfigMap
    data:
      config: |
        {{- .Files.Get "config.txt" | nindent 4 }}
  ```
  <!-- {% endraw %} -->

  You can also add manifests as yaml files in `manifests/`:

  ```yml
  kind: Deployment
  # ...
  ```

- Deploy

  ```sh
  helm upgrade --install myapp . -f values.yaml
  ```

## Customization

For examples of templating and guidance on modifying manifests, refer to the default [`values.yaml`](values.yaml) file.

## Contributing

Add predefined manifests to `templates/manifests/` and reference them in `templates/_manifests.tpl`.
