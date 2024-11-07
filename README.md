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
  ```
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
  ```
  apiVersion: v2
  name: myapp
  version: 0.1.0
  appVersion: "1.16.0"
  dependencies:
  - name: chary
    version: "*" # or certain version
    repository: "https://0zhu.github.io/chary"
  ```
- Customize values in 2 possible ways
  1. Pass manifests to `Chary` subchart in `values.yaml`
      ```
      chary:
        manifests:
        - kind: Deployment
      ```
  2. Use `Chary`'s helper functions
      - In `templates/manifests.yaml`
        ```
        {{ include "chary.manifests" . }}
        ```
      - In `templates/NOTES.txt` (optional)
        ```
        {{ include "chary.notes" . }}
        ```
      - Then define manifests in `values.yaml`
        ```
        manifests:
        - kind: Deployment
        # parent chart's files and context will become available for templating
        - kind: ConfigMap
          data:
            config: |
              {{- .Files.Get "config.txt" | nindent 4 }}
        ```
        Optionally, store additional manifests as yaml files in `manifests/`
        - `manifests/example.yaml`
          ```
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
