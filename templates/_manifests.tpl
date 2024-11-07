{{- /* Iterate over manifests defined in Values and Files and pass them to templating */}}
{{- define "chary.manifests" -}}
  {{- range $index, $manifest := .Values.manifests }}
    {{- include "chary.manifest" (set $ "Manifest" .) }}
  {{- end }}
  {{- range $path, $_ := .Files.Glob "manifests/*.yaml" }}
    {{- include "chary.manifest" (set $ "Manifest" ($.Files.Get $path)) }}
  {{- end }}
{{- end }}

{{- /* Apply common and resource-specific templates to passed manifests */ -}}
{{- define "chary.manifest" -}}
  {{- $manifests := list }}
  {{- if kindIs "string" .Manifest }}
    {{- range (regexSplit `(?m)^---\s*$` (tpl .Manifest .) -1) }}
      {{- $manifests = append $manifests (fromYaml .) }}
    {{- end }}
  {{- else }}
    {{- $manifests = list (fromYaml (tpl (toYaml .Manifest) (merge (deepCopy $) .Manifest))) }}
  {{- end }}
  {{- range $manifest := (compact $manifests) }}
    {{- $context := merge (deepCopy $) $manifest }}
    {{- if has $manifest.kind (list
      "DaemonSet"
      "Deployment"
      "Ingress"
      "Service"
      "StatefulSet"
      ) }}
      {{- $manifest = merge (fromYaml (include (print "chary." $manifest.kind) $context)) $manifest }}
      {{- $context = merge $context $manifest }}
    {{- end }}
    {{- $manifest = merge (fromYaml (include "chary.common" $context)) $manifest }}
---
    {{- toYaml $manifest }}
  {{- end }}
{{- end }}

{{- /* Common manifest fields */}}
{{- define "chary.common" -}}
apiVersion: {{ default "v1" .apiVersion }}
metadata:
  labels:
    {{- include "chary.labels" . | nindent 4 }}
    {{- with dig "metadata" "labels" (dict) . }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  name: {{ dig "metadata" "name" (include "chary.fullname" .) . }}
  {{- if not (eq .kind "Namespace") }}
  namespace: {{ dig "metadata" "namespace" .Release.Namespace . }}
  {{- end }}
{{- end }}

{{- /* Custom notes */}}
{{- define "chary.notes" -}}
  {{- if .Values.notes }}
    {{ tpl .Values.notes . }}
  {{- end }}
{{- end }}
