# Chary: A Generic Helm Chart

Chary is a flexible Helm chart that lets you create customized charts and templates directly from `values.yaml` or raw manifest files.

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

- Create `values.yaml` file with your manifests, [more examples here](values.yaml)

  ```yml
  manifests:
  - kind: Deployment
  ```

- Check what's rendered

  ```sh
  helm --debug template myapp chary/chary -f values.yaml
  ```

- Deploy

  ```sh
  helm install myapp chary/chary -f values.yaml
  ```

### As dependency subchart

- Set up your chart with `Chart.yaml`

  ```yml
  apiVersion: v2
  name: myapp
  version: 0.1.0
  appVersion: "1.16.0"
  dependencies:
  - name: chary
    version: "*" # choose from https://github.com/0zhu/chary/tags
    repository: "https://0zhu.github.io/chary"
  ```

- Create `values.yaml` file with your manifests, [more examples here](values.yaml)

  - Pass manifests to `Chary` subchart in `values.yaml`

    ```yml
    chary:
      manifests:
      - kind: Deployment
    ```

  - Or use `Chary`'s helper functions

    - In `templates/manifests.yaml`

      ```
      {{ include "chary.manifests" . }}
      ```

    - In `templates/NOTES.txt` (optional)

      ```
      {{ include "chary.notes" . }}
      ```

    - Then define manifests in `values.yaml`

      ```yml
      manifests:
      - kind: Deployment
      # parent chart's files and context will become available for templating
      - kind: ConfigMap
        data:
          config: |
            {{- .Files.Get "config.txt" | nindent 4 }}
      ```

      Optionally, store additional manifests as yaml files in `manifests/`, like `manifests/example.yaml`

      ```yml
      kind: Deployment
      ```

- Check what's rendered

  ```sh
  helm --debug template myapp . -f values.yaml
  ```

- Deploy

  ```sh
  helm install myapp . -f values.yaml
  ```

## Contributing

Add predefined manifests to [templates/manifests](templates/manifests) and reference them in [templates/_manifests.tpl](templates/_manifests.tpl)
